# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Face ID / Touch ID biometric authentication (keyword: "Face ID", "Touch ID", "生物识别")
- No iCloud / CloudKit needed (keyword: "离线", "100% offline", "零网络请求")
- No Push Notifications needed
- No In-App Purchase needed (one-time paid download)
- No HealthKit needed
- No Camera needed (receipt photo is P2 priority, deferred)
- No Location Services needed
- No Apple Watch companion needed
- No Siri integration needed for MVP (AppIntents is P2)
- No Background Modes needed

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Face ID (NSFaceIDUsageDescription) | Configured | Added INFOPLIST_KEY_NSFaceIDUsageDescription to project.pbxproj |

## No Configuration Needed

| Capability | Reason |
|------------|--------|
| iCloud / CloudKit | App is 100% offline, no cloud sync |
| Push Notifications | No server, no notifications |
| In-App Purchase | One-time paid download model |
| HealthKit | Not a health app |
| Camera | Receipt photo deferred to P2 |
| Location Services | Not needed |
| Apple Watch | Not in MVP scope |
| Background Modes | No background processing needed |
| Siri / AppIntents | Deferred to P2 phase |

## Verification
- Build succeeded after configuration: Pending
- All entitlements correct: Pending
