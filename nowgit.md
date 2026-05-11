# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | VaultLedger |
| **Git URL** | git@github.com:asunnyboy861/VaultLedger.git |
| **Repo URL** | https://github.com/asunnyboy861/VaultLedger |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/VaultLedger/ | ✅ Active |
| Support | https://asunnyboy861.github.io/VaultLedger/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/VaultLedger/privacy.html | ✅ Active |
| Terms of Use | N/A | Not required for paid download apps |

## Repository Structure

```
VaultLedger/
├── VaultLedger/                    # iOS App Source Code
│   ├── VaultLedger.xcodeproj/      # Xcode Project
│   ├── VaultLedger/                # Swift Source Files
│   │   ├── Views/
│   │   ├── Models/
│   │   └── ...
│   └── ...
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html (only for subscription)
├── .github/workflows/
│   └── deploy.yml
├── us.md
├── keytext.md
├── capabilities.md
├── icon.md
├── price.md
└── nowgit.md
```
