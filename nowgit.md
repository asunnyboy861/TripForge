# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | TripForge |
| **Git URL** | git@github.com:asunnyboy861/TripForge.git |
| **Repo URL** | https://github.com/asunnyboy861/TripForge |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/TripForge/ | ✅ Active |
| Support | https://asunnyboy861.github.io/TripForge/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/TripForge/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/TripForge/terms.html | ✅ Active (required for subscription) |

## Repository Structure

```
TripForge/
├── TripForge/                           # iOS App Source Code
│   ├── TripForge.xcodeproj/             # Xcode Project
│   ├── TripForge/                       # Swift Source Files
│   │   ├── Core/
│   │   │   ├── AI/
│   │   │   ├── Network/
│   │   │   ├── Parsing/
│   │   │   ├── Storage/
│   │   │   └── Extensions/
│   │   ├── Features/
│   │   │   ├── Home/
│   │   │   ├── TripDetail/
│   │   │   ├── AIPlanning/
│   │   │   ├── ActivityEditor/
│   │   │   ├── Settings/
│   │   │   └── Components/
│   │   └── Models/
│   └── ...
├── docs/                                # Policy Pages (GitHub Pages source)
│   ├── index.html                       # Landing Page
│   ├── support.html                     # Support Page
│   ├── privacy.html                     # Privacy Policy
│   └── terms.html                       # Terms of Use (subscription required)
├── .github/workflows/
│   └── deploy.yml                       # GitHub Pages deployment
├── us.md                                # English Development Guide
├── keytext.md                           # App Store Metadata
├── capabilities.md                      # Capabilities Configuration
├── icon.md                              # App Icon Details
├── price.md                             # Pricing Configuration
└── nowgit.md                            # This File
```
