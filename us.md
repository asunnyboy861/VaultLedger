# VaultLedger - iOS Development Guide

## Executive Summary

VaultLedger is a 100% offline personal finance manager for iOS that prioritizes absolute data privacy. Unlike YNAB ($109/year), Monarch Money ($99.99/year), and Copilot Money ($95/year), VaultLedger requires zero network connections, stores all data locally with AES-256 encryption, and offers a one-time purchase of $4.99 — no subscriptions, ever.

**Target Audience**: Privacy-conscious users, Mint refugees, subscription-fatigued consumers, offline/travel users, and FIRE community members who refuse to share financial data with cloud services.

**Key Differentiators**:
- Zero network requests — data never leaves the device
- CSV/PDF bank statement import with preset formats for major US banks
- Automatic subscription detection algorithm
- Net worth tracking with trend visualization
- One-time $4.99 purchase — the only offline finance app with this model
- AES-256 local encryption with Face ID/Touch ID biometric lock

## Competitive Analysis

| App | Price | Offline | Privacy | CSV Import | Sub Detection | Rating | Fatal Flaw |
|-----|-------|---------|---------|------------|---------------|--------|------------|
| YNAB | $14.99/mo | Cache only | Cloud | Yes | Yes | 4.7 | Requires internet, expensive subscription |
| Monarch Money | $14.99/mo | No | Cloud | Yes | Yes | 4.5 | Requires internet, cloud storage |
| Copilot Money | $13/mo | No | Cloud | Yes | Yes | 4.6 | Apple only, cloud storage |
| Finrup | Free | Yes | iCloud | No | Yes | 4.3 | No CSV/PDF import, limited features |
| Monefy | Free+Paid | Yes | Local | No | No | 4.4 | No import, simple features |
| Goodbudget | Free+$10/mo | Partial | Cloud | Yes | No | 4.2 | Cloud, requires account |
| Simple Offline Budget | Free | Yes | Local | No | No | 4.0 | Extremely basic, no charts |
| **VaultLedger** | **$4.99 once** | **100%** | **Local AES-256** | **CSV+PDF** | **Yes** | **—** | **—** |

**Our Advantage**: Only app combining 100% offline + CSV/PDF import + subscription detection + one-time purchase.

## Apple Design Guidelines Compliance

- **Clarity**: Clean card-based layout with clear visual hierarchy; SF Pro typography; prominent amount displays using SF Mono
- **Deference**: Content-first design; minimal chrome; data visualization drives the interface
- **Depth**: Layered card system with subtle shadows; modal sheets for transaction entry; navigation stack for drill-down
- **Consistency**: Standard iOS TabView navigation; native DatePicker, Picker, and TextField components; system colors for interactive elements
- **Privacy**: No data collection whatsoever; Face ID/Touch ID integration follows LocalAuthentication best practices; App Transport Security not needed (zero network)
- **Accessibility**: VoiceOver labels on all interactive elements; Dynamic Type support; minimum 44pt touch targets; high contrast color ratios
- **Dark Mode**: Dark-first design with #1B2838 primary background; Light mode fully supported via SwiftUI semantic colors

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (DocumentPicker for file import)
- **Data**: SwiftData (iOS 17+ local persistence)
- **Encryption**: CryptoKit (AES-256-GCM for sensitive data)
- **Charts**: Swift Charts (spending trends, net worth, budget progress)
- **PDF**: PDFKit (bank statement parsing)
- **Biometrics**: LocalAuthentication (Face ID / Touch ID)
- **Widgets**: WidgetKit (quick entry, balance view)
- **Siri**: AppIntents (voice-driven transaction entry)
- **Search**: Core Spotlight (index transactions for system search)
- **Architecture**: MVVM with @Observable macro

## Module Structure

```
VaultLedger/
├── App/
│   ├── VaultLedgerApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Transaction.swift
│   ├── Account.swift
│   ├── Budget.swift
│   ├── NetWorthSnapshot.swift
│   └── Category.swift
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── TransactionListViewModel.swift
│   ├── AddTransactionViewModel.swift
│   ├── ImportViewModel.swift
│   ├── BudgetViewModel.swift
│   ├── NetWorthViewModel.swift
│   ├── SubscriptionViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── BalanceCardView.swift
│   │   ├── SpendingTrendChart.swift
│   │   ├── SubscriptionCardView.swift
│   │   └── BudgetProgressView.swift
│   ├── Transactions/
│   │   ├── TransactionListView.swift
│   │   ├── AddTransactionView.swift
│   │   ├── TransactionRowView.swift
│   │   └── CategoryPickerView.swift
│   ├── Import/
│   │   ├── ImportView.swift
│   │   ├── BankPickerView.swift
│   │   ├── FileUploadView.swift
│   │   └── ImportPreviewView.swift
│   ├── Budget/
│   │   ├── BudgetListView.swift
│   │   └── AddBudgetView.swift
│   ├── NetWorth/
│   │   ├── NetWorthView.swift
│   │   └── NetWorthChartView.swift
│   ├── Subscriptions/
│   │   ├── SubscriptionListView.swift
│   │   └── SubscriptionDetailView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       ├── AccountManagementView.swift
│       ├── CategoryEditView.swift
│       ├── DataExportView.swift
│       ├── PINSetupView.swift
│       ├── BackupRestoreView.swift
│       └── ContactSupportView.swift
├── Services/
│   ├── CSVImporter.swift
│   ├── PDFImporter.swift
│   ├── SubscriptionDetector.swift
│   ├── DataEncryptor.swift
│   ├── BiometricAuth.swift
│   ├── DataExporter.swift
│   └── BackupManager.swift
├── Helpers/
│   ├── ColorExtensions.swift
│   ├── DateExtensions.swift
│   ├── NumberFormatter+Currency.swift
│   └── Constants.swift
└── Widget/
    ├── VaultLedgerWidget.swift
    └── VaultLedgerWidgetBundle.swift
```

## Implementation Flow

1. Create SwiftData models (Transaction, Account, Budget, NetWorthSnapshot)
2. Implement App entry point with TabView navigation (Dashboard, Transactions, Import, Settings)
3. Build Dashboard view with balance cards, spending trend chart, subscription card, budget progress
4. Implement Transaction CRUD with category picker and account selector
5. Build CSV importer with bank presets (Chase, BoA, Wells Fargo, Citi) and column mapping
6. Build PDF importer using PDFKit for bank statement parsing
7. Implement subscription detection algorithm (frequency + amount pattern matching)
8. Build net worth tracking with trend chart
9. Implement budget management with progress visualization
10. Add Face ID/Touch ID biometric authentication with PIN fallback
11. Implement AES-256 encryption layer using CryptoKit
12. Add data export (CSV) and backup/restore functionality
13. Build Settings view with account management, categories, PIN setup, data export
14. Add WidgetKit widget for quick entry and balance display
15. Add AppIntents for Siri voice commands
16. Add Core Spotlight indexing for transaction search
17. Build Contact Support view with feedback submission
18. Final polish: animations, haptics, edge cases, iPad layout

## UI/UX Design Specifications

### Color Scheme

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Primary Background | Deep Sea Blue | #1B2838 | Main background, conveys security/professionalism |
| Accent | Emerald Green | #00D09C | Income, positive, growth, financial health |
| Warning | Coral Red | #FF6B6B | Expenses, over-budget, alerts |
| Neutral | System Gray | #8E8E93 | Secondary text, dividers |
| Card Background | Dark Slate | #2C3E50 | Card surfaces, layered depth |
| Surface (Light) | White | #FFFFFF | Light mode card background |
| Background (Light) | System Grouped BG | #F2F2F7 | Light mode main background |

### Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Page Title | SF Pro | 28pt | Bold |
| Main Balance | SF Mono | 34pt | Bold |
| Section Header | SF Pro | 20pt | Semibold |
| Body Text | SF Pro | 17pt | Regular |
| Caption | SF Pro | 14pt | Regular |
| Tab Bar Label | SF Pro | 10pt | Medium |

### Layout Rules

- Card corner radius: 16pt
- Standard spacing: 16pt
- Card shadow: 0pt x, 2pt y, 8pt blur, 0.1 opacity
- Minimum touch target: 44pt (Apple HIG)
- Content max width on iPad: 720pt with `.frame(maxWidth: .infinity)`
- Standard animation: 0.3s easeInOut
- Tab bar: 4 tabs (Dashboard, Transactions, Import, Settings)

### Navigation Structure

- **Tab 1 - Dashboard**: Balance overview, spending trend chart, subscription card, budget progress
- **Tab 2 - Transactions**: Filterable transaction list, add transaction button, search
- **Tab 3 - Import**: Bank selection, file upload, data preview, confirm import
- **Tab 4 - Settings**: Account management, categories, biometric lock, PIN, data export, backup, support, privacy policy

### Animations

- Tab transitions: default system
- Card appear: fade + slide up (0.3s)
- Number changes: animated counter
- Chart data updates: smooth line animation
- Button press: scale(0.97) + haptic feedback

## Code Generation Rules

- Use SwiftData @Model for all data models
- Use @Observable macro for ViewModels (not ObservableObject)
- Use Swift Concurrency (async/await) over Combine
- All SwiftData attributes must be optional or have default values
- All relationships must have inverse relationships
- Zero network requests — no URLSession, no third-party API calls
- Use SwiftUI native components (DatePicker, Picker, TextField)
- SF Symbols for all icons
- No third-party dependencies (no CocoaPods, no SPM packages)
- iPad layout: content max width 720pt, centered
- Dark mode first design with full light mode support
- No code comments unless explicitly requested

## Build & Deployment Checklist

- [ ] Bundle ID: com.zzoutuo.VaultLedger
- [ ] Deployment Target: iOS 17.0
- [ ] Swift Language Version: 5.0
- [ ] App Icon: 1024x1024 generated and added to Asset Catalog
- [ ] Capabilities: Face ID (NSFaceIDUsageDescription in Info.plist)
- [ ] Privacy: No network permissions needed
- [ ] App Store Category: Finance
- [ ] Price: $4.99 (Paid Download, Tier 5)
- [ ] Age Rating: 4+ (no user-generated content, no violence)
- [ ] Test on iPhone XS Max simulator
- [ ] Test on iPad Pro 13-inch (M4) simulator
- [ ] Push to GitHub repository
- [ ] Deploy policy pages to GitHub Pages
