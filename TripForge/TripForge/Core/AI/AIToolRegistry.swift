import Foundation
import MapKit

protocol AITool {
    var definition: [String: Any] { get }
    func execute(arguments: String) async throws -> String
}

final class AIToolRegistry {
    private let tools: [String: AITool]

    init() {
        tools = [
            "geocode": GeocodeTool(),
            "search_places": SearchPlacesTool(),
            "get_directions": GetDirectionsTool(),
            "save_trip_plan": SaveTripPlanTool()
        ]
    }

    var allToolDefinitions: [[String: Any]] {
        tools.values.map { $0.definition }
    }

    func execute(name: String, arguments: String) async throws -> String {
        guard let tool = tools[name] else {
            throw AIError.toolExecutionFailed("Unknown tool: \(name)")
        }
        return try await tool.execute(arguments: arguments)
    }
}

final class GeocodeTool: AITool {
    var definition: [String: Any] {
        [
            "type": "function",
            "function": [
                "name": "geocode",
                "description": "Convert a place name or address to geographic coordinates. Use this to verify real locations exist.",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "query": ["type": "string", "description": "Place name or address to geocode"]
                    ],
                    "required": ["query"]
                ]
            ]
        ]
    }

    func execute(arguments: String) async throws -> String {
        guard let data = arguments.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let query = json["query"] as? String else {
            throw AIError.toolExecutionFailed("Invalid geocode arguments")
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        guard let item = response.mapItems.first else {
            return "{\"found\": false, \"query\": \"\(query)\"}"
        }
        let placemark = item.placemark
        return "{\"found\": true, \"name\": \"\(placemark.name ?? query)\", \"latitude\": \(placemark.coordinate.latitude), \"longitude\": \(placemark.coordinate.longitude), \"country\": \"\(placemark.countryCode ?? "")\", \"locality\": \"\(placemark.locality ?? "")\"}"
    }
}

final class SearchPlacesTool: AITool {
    var definition: [String: Any] {
        [
            "type": "function",
            "function": [
                "name": "search_places",
                "description": "Search for points of interest near a location. Returns real businesses and attractions.",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "category": ["type": "string", "description": "Category: restaurant, attraction, hotel, cafe, museum, park, shopping"],
                        "latitude": ["type": "number", "description": "Center latitude"],
                        "longitude": ["type": "number", "description": "Center longitude"],
                        "radius": ["type": "number", "description": "Search radius in meters (default 5000)"]
                    ],
                    "required": ["category", "latitude", "longitude"]
                ]
            ]
        ]
    }

    func execute(arguments: String) async throws -> String {
        guard let data = arguments.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let category = json["category"] as? String,
              let lat = json["latitude"] as? Double,
              let lon = json["longitude"] as? Double else {
            throw AIError.toolExecutionFailed("Invalid search_places arguments")
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        let places = response.mapItems.prefix(10).map { item in
            "{\"name\": \"\(item.name ?? "Unknown")\", \"latitude\": \(item.placemark.coordinate.latitude), \"longitude\": \(item.placemark.coordinate.longitude), \"address\": \"\(item.placemark.title ?? "")\"}"
        }
        return "[\(places.joined(separator: ","))]"
    }
}

final class GetDirectionsTool: AITool {
    var definition: [String: Any] {
        [
            "type": "function",
            "function": [
                "name": "get_directions",
                "description": "Get walking/driving directions and travel time between two coordinates. Use this to verify realistic travel times.",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "from_lat": ["type": "number"],
                        "from_lon": ["type": "number"],
                        "to_lat": ["type": "number"],
                        "to_lon": ["type": "number"],
                        "transport": ["type": "string", "enum": ["walking", "driving", "transit"], "description": "Transport mode"]
                    ],
                    "required": ["from_lat", "from_lon", "to_lat", "to_lon"]
                ]
            ]
        ]
    }

    func execute(arguments: String) async throws -> String {
        guard let data = arguments.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let fromLat = json["from_lat"] as? Double,
              let fromLon = json["from_lon"] as? Double,
              let toLat = json["to_lat"] as? Double,
              let toLon = json["to_lon"] as? Double else {
            throw AIError.toolExecutionFailed("Invalid get_directions arguments")
        }
        let transportType: MKDirectionsTransportType = {
            switch json["transport"] as? String {
            case "walking": return .walking
            case "transit": return .transit
            default: return .automobile
            }
        }()
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: fromLat, longitude: fromLon)))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: toLat, longitude: toLon)))
        request.transportType = transportType
        let directions = try await MKDirections(request: request).calculate()
        guard let route = directions.routes.first else {
            return "{\"found\": false}"
        }
        return "{\"found\": true, \"distance_meters\": \(route.distance), \"distance_miles\": \(route.distance / 1609.34), \"expected_travel_time_seconds\": \(route.expectedTravelTime), \"expected_travel_time_minutes\": \(Int(route.expectedTravelTime / 60)), \"transport_type\": \"\(json["transport"] as? String ?? "driving")\"}"
    }
}

final class SaveTripPlanTool: AITool {
    var definition: [String: Any] {
        [
            "type": "function",
            "function": [
                "name": "save_trip_plan",
                "description": "Save the completed trip plan. Call this as your FINAL tool call with the complete itinerary.",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "destination": ["type": "string"],
                        "days": [
                            "type": "array",
                            "items": [
                                "type": "object",
                                "properties": [
                                    "day_index": ["type": "integer"],
                                    "subtitle": ["type": "string"],
                                    "activities": [
                                        "type": "array",
                                        "items": [
                                            "type": "object",
                                            "properties": [
                                                "title": ["type": "string"],
                                                "subtitle": ["type": "string"],
                                                "latitude": ["type": "number"],
                                                "longitude": ["type": "number"],
                                                "start_time": ["type": "string"],
                                                "duration": ["type": "integer"],
                                                "category": ["type": "string"],
                                                "notes": ["type": "string"]
                                            ],
                                            "required": ["title", "latitude", "longitude", "start_time", "duration", "category"]
                                        ]
                                    ]
                                ],
                                "required": ["day_index", "activities"]
                            ]
                        ],
                        "estimated_budget": ["type": "number"],
                        "tips": ["type": "array", "items": ["type": "string"]]
                    ],
                    "required": ["destination", "days"]
                ]
            ]
        ]
    }

    func execute(arguments: String) async throws -> String {
        "{\"status\": \"saved\", \"arguments\": \(arguments.data(using: .utf8)?.base64EncodedString() ?? "")}"
    }
}

enum AIError: LocalizedError {
    case invalidResponse
    case toolExecutionFailed(String)
    case rateLimitExceeded
    case networkError
    case noAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "AI returned an invalid response"
        case .toolExecutionFailed(let tool): "Tool execution failed: \(tool)"
        case .rateLimitExceeded: "Rate limit exceeded, please try again"
        case .networkError: "Network error, please check your connection"
        case .noAPIKey: "OpenAI API key not configured"
        }
    }
}
