# PhotoBook Setup Guide

This guide will help you get the PhotoBook app running on your Mac and iOS device.

## Quick Start (5 minutes)

### Step 1: Install Xcode
1. Download Xcode 15+ from the Mac App Store
2. Open Xcode and accept the license agreement
3. Wait for additional components to install

### Step 2: Create Xcode Project

Since this is a file-based structure, you need to create an Xcode project:

1. **Open Xcode**
2. **Create a new project**:
   - Select "iOS" → "App"
   - Click "Next"
3. **Configure the project**:
   - Product Name: `PhotoBook`
   - Team: Select your Apple Developer team
   - Organization Identifier: `com.yourcompany` (change to your identifier)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Leave "Use Core Data" and "Include Tests" unchecked
   - Click "Next"
4. **Save location**:
   - Navigate to this repository folder
   - Click "Create"

### Step 3: Add Source Files

Replace the default files with the PhotoBook files:

1. **Delete default files**:
   - Delete the default `ContentView.swift` and `PhotoBookApp.swift` if they were created

2. **Add our files** (if not automatically detected):
   - In Xcode, right-click on the PhotoBook folder
   - Select "Add Files to PhotoBook"
   - Select all `.swift` files from this repository
   - Ensure "Copy items if needed" is checked
   - Click "Add"

3. **Verify structure**:
   ```
   PhotoBook/
   ├── PhotoBookApp.swift
   ├── ContentView.swift
   ├── Info.plist
   ├── Models/
   ├── Services/
   └── Views/
   ```

### Step 4: Configure Project Settings

1. **Select PhotoBook target** in the project navigator
2. **General tab**:
   - Deployment Target: **iOS 16.0** or later
   - Bundle Identifier: Update to your unique identifier
3. **Signing & Capabilities**:
   - Select your development team
   - Enable automatic signing
4. **Info**:
   - Verify `NSPhotoLibraryUsageDescription` is present
   - Verify `NSPhotoLibraryAddUsageDescription` is present

### Step 5: Build and Run

1. **Select a simulator** or connect your iPhone
   - iOS 16+ device or simulator required
2. **Click the Play button** (or press Cmd+R)
3. **Grant photo access** when prompted
4. **Start creating photobooks!**

## Detailed Configuration

### Adding Print Service API Keys

To connect to a real print service:

1. **Open** `PhotoBook/Services/PrintServiceManager.swift`

2. **Find the Custom API section** (around line 50):
   ```swift
   guard let url = URL(string: "https://api.your-print-service.com/v1/orders")
   ```

3. **Update with your API endpoint**:
   ```swift
   guard let url = URL(string: "https://api.actual-print-service.com/v1/orders")
   ```

4. **Add your API key**:
   ```swift
   request.setValue("Bearer YOUR_ACTUAL_API_KEY", forHTTPHeaderField: "Authorization")
   ```

5. **Update response parsing** to match your API's response format

### Recommended Print Service Partners

#### Option 1: Lulu xPress (Easiest to integrate)
- Developer portal: https://developers.lulu.com/
- Free API access
- REST API with good documentation
- Supports photobooks directly

#### Option 2: Gelato API
- Website: https://www.gelato.com/
- Global print network
- Developer-friendly API
- Good for international distribution

#### Option 3: Printful
- Website: https://www.printful.com/
- Well-documented API
- Easy integration
- Good pricing

### Testing Without Real Print Service

The app includes mock responses for testing. You can:

1. Use the app without configuring a real print service
2. Mock responses will return fake order IDs
3. Perfect for development and UI testing
4. No actual orders will be placed

## Customization

### Changing App Name

1. In Xcode, select the PhotoBook target
2. Go to "General" tab
3. Change "Display Name" field
4. Update `CFBundleDisplayName` in Info.plist if needed

### Changing Color Scheme

1. Open `Assets.xcassets` (create if not exists)
2. Add "AccentColor" color set
3. Set your brand colors
4. The app will automatically use these colors

### Adding App Icon

1. Create app icons using a tool like:
   - https://appicon.co/
   - https://www.appicon.build/
2. Drag generated icons to `Assets.xcassets/AppIcon`
3. Ensure all required sizes are included

## Testing

### Testing on Simulator

The simulator can access simulated photos:
1. Open Photos app in simulator
2. Drag and drop images into the Photos app
3. Or use default sample photos

### Testing on Physical Device

1. Connect iPhone via USB
2. Trust the device in Xcode
3. Select your device as the destination
4. Build and run
5. App will appear on your home screen

### Granting Photo Access

First launch will request photo access:
1. Select "Allow Access to All Photos" for full functionality
2. Or "Select Photos" for limited access
3. Grant permission to proceed

## Troubleshooting

### "No such module 'PhotosUI'"
- **Solution**: Update deployment target to iOS 16.0+
- Go to Project Settings → General → Deployment Info

### "Code signing error"
- **Solution**: Select your team in Signing & Capabilities
- Need Apple Developer account (free for testing)

### "Photos not loading"
- **Solution**: Check photo library permissions
- Settings → Privacy → Photos → PhotoBook → Allow

### "Layout generation is slow"
- **Normal**: Quality analysis is CPU-intensive
- Large batches (50+ photos) may take 10-30 seconds
- Runs in background, UI stays responsive

### Build errors with missing files
- **Solution**: Ensure all files are added to target
- Right-click file → Show File Inspector
- Check "Target Membership" includes PhotoBook

## Performance Tips

1. **Test with fewer photos first** (5-10) to verify functionality
2. **Quality analysis** runs async but can be disabled for faster testing
3. **Use release build** for production testing (significant performance improvement)
4. **Monitor memory** with Xcode Instruments if handling 100+ photos

## Next Steps

After basic setup:

1. ✓ Run the app successfully
2. ✓ Test photo selection
3. ✓ Generate a sample layout
4. ⬜ Configure real print service API
5. ⬜ Customize styling and branding
6. ⬜ Add app icons and launch screen
7. ⬜ Test on physical device
8. ⬜ Prepare for TestFlight beta
9. ⬜ Submit to App Store

## Resources

### Apple Documentation
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [PhotosUI Framework](https://developer.apple.com/documentation/photosui)
- [Vision Framework](https://developer.apple.com/documentation/vision)

### App Store Submission
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [TestFlight Beta Testing](https://developer.apple.com/testflight/)
- [App Store Connect](https://appstoreconnect.apple.com/)

### Print APIs
- [Lulu xPress API Docs](https://developers.lulu.com/)
- [Gelato API Docs](https://developers.gelato.com/)
- [Printful API Docs](https://developers.printful.com/)

## Support

For setup issues:
- Check the README.md for detailed documentation
- Review Apple's Xcode documentation
- Verify all prerequisites are met

## License and Development

This is a starting template for your photobook app. Customize it to match your vision and business model.

Good luck with your app! 📚📸
