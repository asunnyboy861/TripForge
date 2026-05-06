import Foundation

@Observable
final class AIAgentService {
    var isPlanning = false
    var progressSteps: [AIProgressStep] = []
    var currentStep: String = ""
    var progress: Double = 0

    struct AIProgressStep: Identifiable {
        let id = UUID()
        let text: String
        let isComplete: Bool
    }

    private let toolRegistry = AIToolRegistry()
    private let apiClient = APIClient()

    func planTrip(destination: String, startDate: Date, endDate: Date, style: TravelStyle, budget: Double?) async throws -> TripPlanResult {
        guard let apiKey = UserDefaults.standard.string(forKey: "openai_api_key"), !apiKey.isEmpty else {
            throw AIError.noAPIKey
        }

        isPlanning = true
        progressSteps = []
        progress = 0
        defer { isPlanning = false }

        let systemPrompt = buildSystemPrompt()
        let userMessage = buildUserMessage(destination: destination, startDate: startDate, endDate: endDate, style: style, budget: budget)

        addStep("Preparing trip to \(destination)...")
        progress = 0.05

        var messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userMessage]
        ]

        var iterations = 0
        let maxIterations = 10
        var savedPlanData: Data?

        while iterations < maxIterations {
            iterations += 1

            addStep("AI is thinking...")
            progress = min(0.1 + Double(iterations) * 0.08, 0.85)

            let response = try await callAI(apiKey: apiKey, messages: messages, tools: toolRegistry.allToolDefinitions)
            let choices = response["choices"] as? [[String: Any]] ?? []
            guard let firstChoice = choices.first else { break }

            let message = firstChoice["message"] as? [String: Any] ?? [:]
            messages.append(message)

            let toolCalls = message["tool_calls"] as? [[String: Any]] ?? []

            if toolCalls.isEmpty {
                break
            }

            let toolResults = try await executeToolCalls(toolCalls)

            for (index, result) in toolResults.enumerated() {
                let toolCall = toolCalls[index]
                let funcName = (toolCall["function"] as? [String: Any])?["name"] as? String ?? "tool"
                addStep("Completed: \(funcName.replacingOccurrences(of: "_", with: " "))")
                progress = min(progress + 0.05, 0.9)

                if funcName == "save_trip_plan", let content = result["content"] as? String {
                    if let data = Data(base64Encoded: content) {
                        savedPlanData = data
                    } else if let data = content.data(using: .utf8) {
                        savedPlanData = data
                    }
                }

                messages.append([
                    "role": "tool",
                    "tool_call_id": result["id"] as? String ?? "",
                    "content": result["content"] as? String ?? ""
                ])
            }
        }

        addStep("Building your itinerary...")
        progress = 0.95

        if let data = savedPlanData,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let result = TripPlanResult(from: json)
            progress = 1.0
            addStep("Itinerary ready!")
            return result
        }

        let lastAssistantContent = messages.last(where: { ($0["role"] as? String) == "assistant" })?["content"] as? String ?? ""
        if let data = lastAssistantContent.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let result = TripPlanResult(from: json)
            progress = 1.0
            addStep("Itinerary ready!")
            return result
        }

        throw AIError.invalidResponse
    }

    private func addStep(_ text: String) {
        currentStep = text
        if let lastStep = progressSteps.last {
            progressSteps[progressSteps.count - 1] = AIProgressStep(text: lastStep.text, isComplete: true)
        }
        progressSteps.append(AIProgressStep(text: text, isComplete: false))
    }

    private func executeToolCalls(_ toolCalls: [[String: Any]]) async throws -> [[String: Any]] {
        try await withThrowingTaskGroup(of: [String: Any].self) { group in
            for toolCall in toolCalls {
                group.addTask {
                    let id = toolCall["id"] as? String ?? ""
                    let function = toolCall["function"] as? [String: Any] ?? [:]
                    let name = function["name"] as? String ?? ""
                    let arguments = function["arguments"] as? String ?? "{}"
                    let result = try await self.toolRegistry.execute(name: name, arguments: arguments)
                    return ["id": id, "content": result]
                }
            }
            var results: [[String: Any]] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }

    private func callAI(apiKey: String, messages: [[String: Any]], tools: [[String: Any]]) async throws -> [String: Any] {
        let url = APIEndpoints.chatURL(apiKey: apiKey)
        var body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "temperature": 0.7
        ]
        if !tools.isEmpty {
            body["tools"] = tools
            body["tool_choice"] = "auto"
        }
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        return try await apiClient.rawRequest(
            url: url,
            method: "POST",
            headers: [
                "Authorization": "Bearer \(apiKey)",
                "Content-Type": "application/json"
            ],
            body: bodyData
        )
    }

    private func buildSystemPrompt() -> String {
        """
        You are TripForge AI, an expert travel itinerary planner. Your job is to create personalized, practical travel itineraries.

        CRITICAL RULES:
        1. ALWAYS use tools to verify real locations, distances, and opening hours. NEVER guess or fabricate.
        2. Consider travel time between locations using the directions tool.
        3. Match the user's travel style (relaxed/balanced/packed/adventure/cultural).
        4. Respect the user's budget constraints.
        5. Group nearby activities on the same day to minimize travel time.
        6. Include realistic buffer time between activities.
        7. Call save_trip_plan as your FINAL tool call to output the complete itinerary.

        PLANNING APPROACH:
        1. First, geocode the destination city center.
        2. Search for top attractions, restaurants, and activities.
        3. Get directions between locations to calculate realistic travel times.
        4. Cluster activities by proximity for each day.
        5. Build day-by-day itinerary with proper pacing.
        6. Save the final plan.
        """
    }

    private func buildUserMessage(destination: String, startDate: Date, endDate: Date, style: TravelStyle, budget: Double?) -> String {
        let days = startDate.daysBetween(endDate) + 1
        var msg = "Plan a \(days)-day trip to \(destination) from \(startDate.fullDateString) to \(endDate.fullDateString). "
        msg += "Travel style: \(style.rawValue). "
        if let budget {
            msg += "Budget: $\(Int(budget)). "
        }
        return msg
    }
}

struct TripPlanResult {
    let destination: String
    let days: [DayPlanResult]
    let estimatedBudget: Double?
    let tips: [String]

    init(from json: [String: Any]) {
        self.destination = json["destination"] as? String ?? "Unknown"
        self.estimatedBudget = json["estimated_budget"] as? Double
        self.tips = json["tips"] as? [String] ?? []
        let daysArray = json["days"] as? [[String: Any]] ?? []
        self.days = daysArray.enumerated().map { index, dayJson in
            DayPlanResult(from: dayJson, index: index)
        }
    }
}

struct DayPlanResult {
    let dayIndex: Int
    let subtitle: String?
    let activities: [ActivityResult]

    init(from json: [String: Any], index: Int) {
        self.dayIndex = json["day_index"] as? Int ?? index + 1
        self.subtitle = json["subtitle"] as? String
        let activitiesArray = json["activities"] as? [[String: Any]] ?? []
        self.activities = activitiesArray.map { ActivityResult(from: $0) }
    }
}

struct ActivityResult {
    let title: String
    let subtitle: String?
    let latitude: Double
    let longitude: Double
    let startTime: String
    let duration: Int
    let category: String
    let notes: String?

    init(from json: [String: Any]) {
        self.title = json["title"] as? String ?? "Activity"
        self.subtitle = json["subtitle"] as? String
        self.latitude = json["latitude"] as? Double ?? 0
        self.longitude = json["longitude"] as? Double ?? 0
        self.startTime = json["start_time"] as? String ?? "09:00"
        self.duration = json["duration"] as? Int ?? 60
        self.category = json["category"] as? String ?? "other"
        self.notes = json["notes"] as? String
    }
}
