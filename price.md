# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group
- **Group Name**: TripForge Premium
- **Group ID**: TripForge_Premium

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: Monthly Premium
- **Product ID**: `com.zzoutuo.TripForge.monthly`
- **Price**: $3.99 per month
- **Display Name**: TripForge Pro Monthly
- **Description**: Full AI planning, unlimited trips
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: Yearly Premium
- **Product ID**: `com.zzoutuo.TripForge.yearly`
- **Price**: $29.99 per year (37% savings vs monthly)
- **Display Name**: TripForge Pro Yearly
- **Description**: Best value, save 37% annually
- **Localization**: English (US)

## Free Tier Features
- Create and edit trips (unlimited)
- Day timeline view
- Map view with MapKit
- Activity add/edit/delete
- Email import for bookings
- Dark mode
- Offline access
- AI trip generation: 10 times per month
- PDF export (basic)

## Pro Tier Features (Subscription Required)
- Unlimited AI trip generation
- AI chat-based itinerary adjustment
- Real-time weather integration and alerts
- Trip sharing and collaboration
- Advanced budget tracking
- PDF export (full, with map)
- Priority AI response
- Route optimization

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid monthly)

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Free trial terms included
- [ ] Restore purchases functionality implemented

## AI Cost Analysis
| Item | Cost |
|------|------|
| GPT-4o-mini input | $0.15/1M tokens |
| GPT-4o-mini output | $0.60/1M tokens |
| Single planning cost | ~$0.003 |
| Monthly AI cost (1000 users) | ~$15 |
| AI cost as % of revenue | <2% |

## Competitive Pricing Comparison
| App | Price | TripForge Advantage |
|-----|-------|---------------------|
| Wanderlog | $40/year | $29.99/year (25% cheaper) |
| TripIt Pro | $49/year | $29.99/year (39% cheaper) |
| iplan.ai | $3.99-9.99 | More features at similar price |
| Tripsy | $4.99-299 | Clearer pricing, better value |
| MagicMiles | $6.99/month | $3.99/month (43% cheaper) |
