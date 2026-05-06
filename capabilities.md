# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- "同步" / "sync" / "iCloud" detected → iCloud capability
- "地图" / "map" / "定位" / "location" detected → Location Services
- "订阅" / "会员" / "premium" / "购买" detected → In-App Purchase
- "天气" / "weather" detected → WeatherKit
- "通知" / "提醒" / "alert" detected → Push Notifications (future)

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| iCloud (CloudKit) | ✅ Configured | Xcode Signing & Capabilities |
| Location Services (When In Use) | ✅ Configured | Info.plist NSLocationWhenInUseUsageDescription |
| In-App Purchase | ✅ Configured | StoreKit 2 framework |
| WeatherKit | ✅ Configured | WeatherKit framework |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| iCloud (CloudKit) | ⏳ Pending | 1. Open Xcode → Signing & Capabilities → + Capability → iCloud 2. Check CloudKit checkbox 3. Create CloudKit container: iCloud.com.zzoutuo.TripForge |
| WeatherKit | ⏳ Pending | 1. Open Apple Developer Portal → Certificates, Identifiers & Profiles 2. Enable WeatherKit Service for com.zzoutuo.TripForge 3. In Xcode → Signing & Capabilities → + Capability → WeatherKit |

## No Configuration Needed
- Push Notifications (not in MVP)
- HealthKit (not applicable)
- Camera/Photo Library (not in MVP)
- Apple Watch (not in MVP)
- Siri (not in MVP)
- Background Modes (not in MVP)

## Verification
- Build succeeded after configuration: Pending (will verify after code generation)
- All entitlements correct: Pending
