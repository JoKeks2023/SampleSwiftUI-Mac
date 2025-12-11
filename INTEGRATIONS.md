# Smart Home & Device Integrations Guide

This document describes how to integrate the SampleSwiftUI VoIP app with Apple HomeKit, Home Assistant, and Apple Watch.

## Table of Contents

- [HomeKit Integration](#homekit-integration)
- [Home Assistant Integration](#home-assistant-integration)
- [Apple Watch Companion App](#apple-watch-companion-app)
- [Use Cases](#use-cases)
- [Troubleshooting](#troubleshooting)

---

## HomeKit Integration

### Overview

The HomeKit integration exposes app settings as virtual switches that can be controlled through:
- Apple Home app
- Siri voice commands
- HomeKit automations and scenes
- Third-party HomeKit apps

### Available HomeKit Accessories

The app creates the following virtual accessories:

#### Switches (Controllable Settings)
1. **Call Notifications** - Enable/disable incoming call notifications
2. **Message Notifications** - Enable/disable message notifications
3. **Auto Answer** - Enable/disable automatic call answering
4. **Speaker by Default** - Enable/disable speaker mode by default

#### Sensors (Status Monitoring)
1. **Active Calls** - Shows the number of active calls
2. **SIP Registration** - Shows if any SIP account is registered

### Setup Instructions

#### 1. Enable HomeKit Integration

```swift
// In the app
Settings > Integrations > HomeKit > Toggle "Enable HomeKit"
```

#### 2. Configure in Home App

1. Open the **Home** app on your iPhone/iPad
2. The Siprix accessories will appear automatically
3. Organize them into rooms (e.g., "Office", "Bedroom")
4. Add to your preferred scenes

#### 3. Create Automations

**Example 1: Silence notifications when leaving home**
```
When: I leave home
Action: Turn off "Call Notifications"
```

**Example 2: Enable auto-answer when arriving at office**
```
When: I arrive at Office
Time: 9:00 AM - 5:00 PM (Weekdays)
Action: Turn on "Auto Answer"
```

**Example 3: Enable speaker mode during cooking**
```
When: "Cooking Scene" is activated
Action: Turn on "Speaker by Default"
```

### Siri Commands

Once set up, you can use these Siri commands:

```
"Hey Siri, turn on Call Notifications"
"Hey Siri, turn off Auto Answer"
"Hey Siri, is Speaker by Default on?"
"Hey Siri, activate Call Mom scene"
```

### Advanced: Creating Call Scenes

You can create HomeKit scenes to trigger calls:

1. Open Home app
2. Create a new scene (e.g., "Call Emergency")
3. The app will provide options to configure quick-dial contacts
4. Activate the scene to automatically make the call

### Technical Details

The HomeKit integration uses:
- **HomeKit Accessory Protocol (HAP)** for communication
- **Characteristic notifications** for status updates
- **Service types**: Switch, Sensor, Scene
- **Bridge mode** to expose multiple accessories

### Requirements

- iOS 13.0+ or macOS 10.15+
- Device must be on the same network as HomeKit hub
- HomeKit hub (Apple TV, HomePod, or iPad) for remote access
- iCloud account with Home enabled

---

## Home Assistant Integration

### Overview

Home Assistant integration provides:
- Webhook-based call triggering
- Call status updates sent to Home Assistant
- Integration with HA automations and scripts
- RESTful API communication

### Setup Instructions

#### 1. Install Home Assistant

If you don't have Home Assistant:
- Visit [home-assistant.io](https://home-assistant.io)
- Follow installation instructions for your platform

#### 2. Create Webhook in Home Assistant

Edit your `configuration.yaml`:

```yaml
automation:
  - alias: "Siprix Call Trigger"
    trigger:
      platform: webhook
      webhook_id: siprix_call_webhook
    action:
      service: notify.mobile_app
      data:
        title: "Incoming Call"
        message: "Call from {{ trigger.json.phone_number }}"
```

#### 3. Configure in App

```
Settings > Integrations > Home Assistant
1. Toggle "Enable Integration"
2. Enter Webhook URL: http://your-ha-server:8123/api/webhook/siprix_call_webhook
3. (Optional) Enter Long-Lived Access Token for authentication
```

#### 4. Get Long-Lived Access Token

1. In Home Assistant, click your profile (bottom left)
2. Scroll to "Long-Lived Access Tokens"
3. Click "Create Token"
4. Give it a name (e.g., "Siprix VoIP")
5. Copy and paste into the app

### Webhook Endpoints

#### Trigger a Call

```bash
POST http://your-ha-server:8123/api/webhook/siprix_call_webhook
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN

{
  "action": "make_call",
  "phone_number": "+1234567890",
  "account_id": 1,
  "with_video": false
}
```

#### Receive Call Status Updates

The app will send POST requests to your webhook:

```json
{
  "event_type": "siprix_call_status",
  "data": {
    "status": "connected",
    "phone_number": "+1234567890",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

Status values:
- `ringing` - Incoming call
- `connected` - Call connected
- `held` - Call on hold
- `disconnected` - Call ended
- `missed` - Missed call

### Example Automations

#### Auto-Call on Button Press

```yaml
automation:
  - alias: "Emergency Call Button"
    trigger:
      platform: state
      entity_id: input_button.emergency
      to: 'on'
    action:
      service: rest_command.siprix_call
      data:
        phone_number: "911"
        account_id: 1
```

#### Call When Motion Detected

```yaml
automation:
  - alias: "Call on Motion"
    trigger:
      platform: state
      entity_id: binary_sensor.motion_sensor
      to: 'on'
    condition:
      condition: time
      after: '22:00:00'
      before: '06:00:00'
    action:
      service: rest_command.siprix_call
      data:
        phone_number: "+1234567890"
        account_id: 1
```

#### Dashboard Integration

Add call status to your dashboard:

```yaml
type: entities
entities:
  - entity_id: sensor.siprix_active_calls
    name: Active Calls
  - entity_id: binary_sensor.siprix_registered
    name: SIP Registered
```

### Requirements

- Home Assistant Core 2021.1+ or Home Assistant OS
- Network connectivity between app and HA server
- (Optional) Long-lived access token for authentication

---

## Apple Watch Companion App

### Overview

The Apple Watch companion app provides:
- Quick view of active calls
- Call controls (answer, reject, hold, end)
- Call history overview
- SIP account status
- Watch face complications

### Features

#### On the Watch

1. **Call List**
   - View all active calls
   - See call duration in real-time
   - Incoming calls with answer/reject buttons

2. **Call Controls**
   - Answer/Reject incoming calls
   - Hold/Resume active calls
   - Mute/Unmute microphone
   - End calls

3. **Account Status**
   - View SIP account registration status
   - See which accounts are online

4. **Call History**
   - Last 20 calls
   - Call direction (incoming/outgoing)
   - Call duration and outcome

5. **Complications**
   - Show active call count on watch face
   - Tap to open app

#### Automatic Sync

Data syncs automatically when:
- Watch is within Bluetooth/Wi-Fi range
- Account status changes
- New call starts or ends
- Call history updates

### Setup Instructions

#### 1. Prerequisites

- iPhone with SampleSwiftUI app installed
- Apple Watch running watchOS 7.0+
- Watch paired with iPhone

#### 2. Install Watch App

1. Open the **Watch** app on iPhone
2. Scroll to "SampleSwiftUI"
3. Toggle "Show App on Apple Watch"
4. Wait for installation to complete

#### 3. Configure Watch Face

1. On Apple Watch, long-press watch face
2. Tap "Edit"
3. Select a complication slot
4. Scroll to "SampleSwiftUI"
5. Choose "Active Calls" complication

#### 4. First Launch

1. Open app on Apple Watch
2. Initial data sync will occur
3. Grant notifications permission if prompted

### Watch App Navigation

```
┌─────────────────────┐
│   Calls (Tab 1)     │ ← Active calls list
├─────────────────────┤
│  Accounts (Tab 2)   │ ← SIP account status
├─────────────────────┤
│  History (Tab 3)    │ ← Recent call history
└─────────────────────┘
```

### Call Actions

**For Incoming Calls:**
- Tap "Accept" to answer
- Tap "Decline" to reject
- Force Touch for more options

**For Active Calls:**
- Tap call to see controls
- Hold button to put on hold
- Mute button to mute mic
- End button to hang up
- Digital Crown to adjust volume

### Handoff Support

Continue calls seamlessly:
- Start call on iPhone, continue on Watch
- Answer on Watch, continue on iPhone
- Automatic audio routing

### Battery Considerations

The Watch app:
- Uses background refresh efficiently
- Updates only when data changes
- Minimal battery impact
- VoIP updates are optimized

### Technical Implementation

For developers adding Watch app:

1. **Add watchOS Target**
   ```
   File > New > Target > watchOS > Watch App for iOS App
   ```

2. **Required Files**
   - `WatchContentView.swift` - Main interface
   - `WatchCallsView.swift` - Calls list
   - `WatchCallDetailView.swift` - Call controls
   - `WatchAccountsView.swift` - Accounts list
   - `WatchHistoryView.swift` - Call history

3. **Info.plist Entries**
   ```xml
   <key>WKBackgroundModes</key>
   <array>
       <string>remote-notification</string>
   </array>
   ```

4. **Capabilities**
   - Background Modes (VoIP)
   - Push Notifications

---

## Use Cases

### Home Automation Scenarios

#### 1. Smart Doorbell
```
When: Doorbell button pressed
Action: Make call to homeowner's phone via Siprix
```

#### 2. Elderly Care
```
When: Emergency button pressed
Action: 
  - Call family member
  - Send notification to Home Assistant
  - Turn on all lights
```

#### 3. Business Hours
```
When: Office hours (9 AM - 5 PM, Weekdays)
Action: 
  - Enable auto-answer
  - Turn on call notifications
  - Set speaker by default
```

#### 4. Do Not Disturb
```
When: Sleep scene activated
Action: 
  - Disable call notifications
  - Disable message notifications
After: Sunrise
  - Re-enable notifications
```

#### 5. Security System
```
When: Security alarm triggered
Action:
  - Call security company via Siprix
  - Send status to Home Assistant
  - Record call to file
```

### Apple Watch Scenarios

#### 1. Hands-Free Calling
- Start call on Watch while driving
- Control calls without touching phone
- Use Digital Crown for volume

#### 2. Quick Response
- Answer important calls from wrist
- Reject spam calls instantly
- View caller ID on watch face

#### 3. Remote Monitoring
- Check if calls are active
- View SIP registration status
- Monitor call history

---

## Troubleshooting

### HomeKit Issues

**Problem**: Accessories not appearing in Home app
- **Solution**: Ensure HomeKit integration is enabled in app settings
- **Solution**: Restart the Home app
- **Solution**: Check if device is on same network as HomeKit hub

**Problem**: Siri commands not working
- **Solution**: Ensure accessories have unique names
- **Solution**: Try "Hey Siri, show me my accessories"
- **Solution**: Re-enable Siri in Settings

**Problem**: Automations not triggering
- **Solution**: Check HomeKit hub is online
- **Solution**: Verify automation conditions
- **Solution**: Test manually in Home app

### Home Assistant Issues

**Problem**: Webhook not responding
- **Solution**: Check webhook URL is correct
- **Solution**: Verify Home Assistant is accessible
- **Solution**: Check firewall settings

**Problem**: Authentication errors
- **Solution**: Regenerate long-lived access token
- **Solution**: Ensure token is entered correctly
- **Solution**: Check token hasn't expired

**Problem**: Call status not updating
- **Solution**: Verify webhook URL is configured
- **Solution**: Check network connectivity
- **Solution**: View Home Assistant logs for errors

### Apple Watch Issues

**Problem**: Watch app not syncing
- **Solution**: Ensure Watch is connected to iPhone
- **Solution**: Open app on both devices
- **Solution**: Tap "Sync to Watch" in iPhone app

**Problem**: Call controls not working
- **Solution**: Ensure Watch is within range
- **Solution**: Check Watch OS version (7.0+)
- **Solution**: Reinstall Watch app

**Problem**: Complications not updating
- **Solution**: Force quit Watch app
- **Solution**: Restart Apple Watch
- **Solution**: Re-add complication to watch face

### General Integration Issues

**Problem**: Integration stops working after app update
- **Solution**: Disable and re-enable integration
- **Solution**: Clear app cache
- **Solution**: Reinstall if necessary

**Problem**: Network connectivity issues
- **Solution**: Check local network permissions
- **Solution**: Verify app has network access
- **Solution**: Test with different network

---

## Security Considerations

### HomeKit
- Uses end-to-end encryption
- Requires iCloud Keychain
- Authenticated via Apple ID
- Local network only by default

### Home Assistant
- Use HTTPS for webhook URLs
- Implement long-lived access tokens
- Consider firewall rules
- Use VPN for remote access

### Apple Watch
- Uses encrypted Watch Connectivity
- Requires device pairing
- Secured by Watch passcode
- Data synced via iCloud

---

## Future Enhancements

Planned features:
- [ ] HomeKit video camera integration for video calls
- [ ] Home Assistant sensor for call quality
- [ ] Watch face complications showing account status
- [ ] Shortcuts app integration
- [ ] Matter protocol support
- [ ] Thread network support

---

## Support & Resources

### Documentation
- [Apple HomeKit Documentation](https://developer.apple.com/homekit/)
- [Home Assistant Documentation](https://www.home-assistant.io/docs/)
- [WatchOS Documentation](https://developer.apple.com/watchos/)

### Community
- GitHub Issues for bug reports
- Discussions for feature requests
- Community forum for help

### Contact
- Email: support@siprix-voip.com
- Website: https://siprix-voip.com

---

## License

These integrations are part of the SampleSwiftUI project and follow the same license terms.

## Changelog

### Version 1.0 (Current)
- Initial HomeKit integration
- Home Assistant webhook support
- Apple Watch companion app foundation
- Cross-platform macOS support

---

**Last Updated**: December 2024
