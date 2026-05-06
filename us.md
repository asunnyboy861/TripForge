# TripForge - iOS Development Guide

## Executive Summary

TripForge is an AI-powered travel itinerary planner that combines intelligent trip generation with real-time geographic verification (Grounding) to eliminate AI hallucinations. Built natively with SwiftUI and MapKit, TripForge delivers a map-first, performant travel planning experience that addresses the core frustrations travelers face: fragmented information, app-switching fatigue, unreliable AI recommendations, and excessive paywalls.

**Target Audience**: US-based travelers (solo, couples/families, business, groups) aged 25-55 who plan 2-5 trips per year and are frustrated with current tools.

**Key Differentiators**:
- AI + MapKit Grounding: Real-time location verification ensures zero hallucinated recommendations
- Free core features: Dark mode, offline access, email parsing, and basic planning are free
- Map-first UI: Interactive MapKit with route visualization, not just pin drops
- Native performance: SwiftUI + Core Data handles 100+ activities without lag
- Competitive pricing: $29.99/year vs Wanderlog $40/year and TripIt $49/year

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **Wanderlog** ($40/yr) | Map-based planning, real-time collaboration, comprehensive free tier, AI route optimization | 20+ places causes lag, dark mode behind paywall, PDF export behind paywall, Google Maps dependency | Native MapKit (no API fees), better performance, free dark mode + offline, lower price |
| **TripIt** ($49/yr) | Best email parsing, flight tracking, 20M+ users, calendar sync | No AI planning, no interactive map view, outdated UI, no collaboration | AI planning + map view + modern SwiftUI UI + collaboration |
| **iplan.ai** ($3.99-9.99) | Fast AI generation, minute-by-minute planning, offline access | Template-based itineraries, no real-time adjustment, weak collaboration, 3.7 rating | Personalized AI with Grounding, real-time weather adjustment, CloudKit collaboration |
| **Tripsy** ($4.99-299) | Full feature set, flight tracking, Apple ecosystem integration | Confusing pricing, steep learning curve, limited free tier | Simple pricing, intuitive UX, clear free vs Pro boundaries |
| **MagicMiles** ($6.99/mo) | Privacy-focused, offline access | High price, no collaboration, limited features | Lower price + collaboration + more features |

## Apple Design Guidelines Compliance

- **Human Interface Guidelines**: Follow iOS 17+ navigation patterns (NavigationStack, sheet presentations), use standard SF Symbols, respect safe areas and dynamic type
- **MapKit Integration**: Use native MapKit for all mapping features, avoiding third-party map dependencies
- **Privacy**: All data stored locally via Core Data, iCloud sync is optional and user-controlled, no third-party analytics
- **Accessibility**: VoiceOver support for all interactive elements, dynamic type scaling, high contrast support
- **Dark Mode**: Full support using semantic colors (Color.primary, Color.secondary, etc.)
- **Haptics**: UIImpactFeedbackGenerator for drag-drop, swipe actions, and AI generation completion
- **StoreKit 2**: Compliant IAP with restore purchases, clear subscription terms, no dark patterns

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), no UIKit
- **Data**: Core Data with NSPersistentCloudKitContainer for optional iCloud sync
- **Networking**: URLSession + async/await, no third-party networking libraries
- **Maps**: MapKit (native, no API fees)
- **AI**: OpenAI GPT-4o-mini API with Agentic Loop + MapKit Grounding tools
- **Weather**: WeatherKit for real-time weather data
- **IAP**: StoreKit 2 for subscription management
- **Concurrency**: Swift Concurrency (async/await, Actor)
- **Error Handling**: Result type + custom Error enums
- **Dependency Management**: SPM only, minimal third-party dependencies

## Module Structure

```
TripForge/
├── TripForgeApp.swift
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift
│   │   └── APIEndpoints.swift
│   ├── AI/
│   │   ├── AIAgentService.swift
│   │   ├── AIToolRegistry.swift
│   │   ├── GeocodeTool.swift
│   │   ├── SearchPlacesTool.swift
│   │   ├── GetDirectionsTool.swift
│   │   ├── GetWeatherTool.swift
│   │   └── SaveTripPlanTool.swift
│   ├── Parsing/
│   │   └── EmailParser.swift
│   ├── Storage/
│   │   ├── CoreDataStack.swift
│   │   └── PurchaseManager.swift
│   └── Extensions/
│       ├── Color+Theme.swift
│       ├── Date+Extensions.swift
│       └── View+Extensions.swift
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── TripList/
│   │   ├── TripListView.swift
│   │   └── TripListViewModel.swift
│   ├── TripDetail/
│   │   ├── TripDetailView.swift
│   │   ├── TripDetailViewModel.swift
│   │   ├── DayTimelineView.swift
│   │   ├── MapOverviewView.swift
│   │   ├── BookingsView.swift
│   │   └── BudgetView.swift
│   ├── AIPlanning/
│   │   ├── AIPlanningView.swift
│   │   ├── AIPlanningViewModel.swift
│   │   └── AIPlanningProgressView.swift
│   ├── ActivityEditor/
│   │   ├── ActivityEditorView.swift
│   │   └── ActivityEditorViewModel.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── ContactSupportView.swift
│   │   └── PaywallView.swift
│   └── Components/
│       ├── TripCardView.swift
│       ├── ActivityRowView.swift
│       ├── DayPickerView.swift
│       └── TravelStylePicker.swift
├── Models/
│   ├── Trip.swift
│   ├── DayPlan.swift
│   ├── Activity.swift
│   ├── Booking.swift
│   └── TravelStyle.swift
└── Resources/
    └── Assets.xcassets
```

## Implementation Flow

1. Set up Core Data models (Trip, DayPlan, Activity, Booking) with relationships
2. Implement CoreDataStack with NSPersistentCloudKitContainer
3. Build HomeView with AI entry card and trip list
4. Build TripListView with CRUD operations
5. Build TripDetailView with tab navigation (Timeline/Map/Bookings/Budget)
6. Build DayTimelineView with activity list and swipe actions
7. Build MapOverviewView with MapKit annotations and route polylines
8. Build ActivityEditorView for add/edit activities
9. Implement AI Agent Service with OpenAI GPT-4o-mini
10. Implement AI Tool Registry with MapKit Grounding tools
11. Build AIPlanningView with destination, dates, style, budget inputs
12. Build AIPlanningProgressView with real-time progress and map rendering
13. Implement EmailParser for booking confirmation extraction
14. Implement PurchaseManager with StoreKit 2
15. Build PaywallView and SettingsView
16. Build ContactSupportView with feedback backend
17. Add WeatherKit integration for weather-aware planning
18. Test on iPhone and iPad simulators

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: Forge Blue (#007AFF), Forge Teal (#5AC8FA), Forge Orange (#FF9500)
  - Semantic: Success Green (#34C759), Warning Yellow (#FFCC00), Error Red (#FF3B30), AI Purple (#AF52DE)
  - Category: Sightseeing Blue, Dining Orange, Shopping Pink, Transport Gray, Accommodation Purple, Entertainment Yellow, Nature Green
  - Dark Mode: Pure black (#000000) background for OLED, Surface (#1C1C1E), Elevated (#2C2C2E)
- **Typography**: SF Pro Rounded for headings (Bold 34pt, Semibold 28pt), SF Pro for body (Regular 17pt), SF Pro Mono for timestamps (13pt)
- **Layout**: Map-first design (50% screen for map in detail view), progressive disclosure, max content width 720pt on iPad
- **Animations**: Spring animations (0.3s) for drag-drop, gradient pulse for AI generation, progressive map rendering during AI planning
- **Interactions**: Swipe-to-complete/delete activities, drag-to-reorder, haptic feedback on actions, pinch-to-zoom map

## Code Generation Rules

- Architecture: MVVM + Repository Pattern
- Swift Concurrency: async/await, Actor for thread safety
- Core Data: All attributes optional or with defaults, all relationships have inverses
- SwiftUI only: No UIKit references
- No code comments: Code should be self-documenting
- Error handling: Result type + custom Error enums
- iPad layout: Always add .frame(maxWidth: 720).frame(maxWidth: .infinity) for main ScrollView content
- No .tabViewStyle(.sidebarAdaptable)
- Minimum iOS 17.0

## Build & Deployment Checklist

- [ ] Bundle ID: com.zzoutuo.TripForge
- [ ] Deployment Target: iOS 17.0
- [ ] App Icon configured in Asset Catalog
- [ ] Capabilities: iCloud (CloudKit), Location Services (when in use)
- [ ] StoreKit 2 subscription configured
- [ ] Privacy Policy page deployed
- [ ] Support page deployed
- [ ] Terms of Use page deployed (subscription required)
- [ ] App Store metadata prepared (keytext.md)
- [ ] Tested on iPhone XS Max simulator
- [ ] Tested on iPad Pro 13-inch (M4) simulator
- [ ] No API keys or secrets in source code
- [ ] .gitignore properly configured
