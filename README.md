# PhotoBook - AI-Powered iOS Photobook Creator

An intelligent iOS application that automatically creates beautiful photobooks from your camera roll using AI-powered photo analysis and layout generation.

## Features

### Core Functionality
- **Smart Photo Selection**: Access and select photos from your camera roll
- **AI-Powered Quality Analysis**: Automatic photo quality scoring based on:
  - Sharpness detection using edge analysis
  - Exposure and brightness optimization
  - Composition scoring using face detection and rule of thirds
- **Intelligent Layout Generation**: Automatic page layouts with multiple styles:
  - Classic: Traditional photobook layouts
  - Modern: Grid-based contemporary designs
  - Magazine: Asymmetric editorial-style layouts
  - Collage: Maximum photo density
  - Minimal: Clean, simple presentations
- **Chronological Organization**: Photos automatically arranged by date
- **Real-time Preview**: Interactive preview of your photobook before ordering
- **Print Service Integration**: Multiple print service options

### Technical Features
- Built with SwiftUI for modern iOS (iOS 16+)
- Vision framework for AI-powered image analysis
- Core Image for advanced photo processing
- PhotosUI for seamless camera roll integration
- PDF generation for print-ready output

## Architecture

```
PhotoBook/
├── PhotoBookApp.swift          # Main app entry point
├── ContentView.swift            # Root view with tab navigation
├── Models/
│   ├── PhotoItem.swift         # Photo data model
│   └── LayoutModel.swift       # Layout and page structure
├── Services/
│   ├── PhotoManager.swift      # Photo library management
│   ├── PhotoQualityAnalyzer.swift  # AI quality analysis
│   ├── LayoutEngine.swift      # Intelligent layout generation
│   └── PrintServiceManager.swift   # Print API integration
└── Views/
    ├── PhotoSelectionView.swift    # Photo picker interface
    ├── LayoutPreviewView.swift     # Layout preview and style selection
    ├── PagePreviewView.swift       # Individual page rendering
    └── PrintOptionsView.swift      # Print service configuration
```

## Setup Instructions

### Prerequisites
- macOS with Xcode 15.0 or later
- iOS 16.0+ deployment target
- Apple Developer account (for device testing and App Store distribution)

### Installation

1. **Open in Xcode**:
   ```bash
   cd PhotoBook
   open PhotoBook.xcodeproj
   ```
   Note: If xcodeproj doesn't exist, create a new iOS App project in Xcode and add these files

2. **Configure Project Settings**:
   - Set your development team in Signing & Capabilities
   - Update bundle identifier (e.g., `com.yourcompany.photobook`)
   - Ensure minimum deployment target is iOS 16.0+

3. **Add Required Frameworks**:
   The following frameworks should be linked (usually automatic):
   - SwiftUI
   - PhotosUI
   - Vision
   - CoreImage
   - UIKit

4. **Privacy Permissions**:
   The Info.plist already includes required photo library permissions.
   Make sure these are present:
   - `NSPhotoLibraryUsageDescription`
   - `NSPhotoLibraryAddUsageDescription`

### Configuration

#### Print Service API Integration

The app includes integration points for multiple print services. To connect a real print service:

1. **Custom API** (Recommended for production):
   - Edit `PrintServiceManager.swift`
   - Update the API endpoint in `submitToCustomAPI()`
   - Add your API key and authentication
   - Implement proper error handling

2. **Third-Party Services**:
   - **Shutterfly**: Apply for partner API access at shutterflyinc.com
   - **Mixbook**: Contact Mixbook for white-label API
   - **Chatbooks**: Request API access from Chatbooks

Example API configuration:
```swift
// In PrintServiceManager.swift
guard let url = URL(string: "https://api.your-print-service.com/v1/orders") else {
    throw PrintServiceError.invalidURL
}

request.setValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
```

## Usage

### For Users

1. **Select Photos**: Tap the "Select Photos" tab and choose photos from your library
2. **Generate Layout**: Go to "Preview" tab, select a style, and tap "Generate Layout"
3. **Review & Customize**: Browse through the generated photobook pages
4. **Order**: Navigate to "Print" tab to configure options and submit your order

### For Developers

#### Adding New Layout Styles

```swift
// In LayoutModel.swift
enum LayoutStyle: String, Codable, CaseIterable {
    case yourNewStyle = "Your Style Name"
}

// In LayoutEngine.swift, update selectTemplate() method
case .yourNewStyle:
    return .yourCustomTemplate
```

#### Adding New Page Templates

```swift
// In LayoutModel.swift
enum PageTemplate: String, Codable, CaseIterable {
    case yourTemplate = "Template Name"
}

// In LayoutEngine.swift, update calculateFrames() method
case .yourTemplate:
    return [/* your CGRect frames */]
```

#### Customizing Quality Analysis

Adjust weights in `PhotoQualityAnalyzer.swift`:
```swift
let totalScore = (sharpnessScore * 0.4) +
                 (exposureScore * 0.3) +
                 (compositionScore * 0.3)
```

## App Store Submission

### Required Assets

1. **App Icon**: Create app icons for all required sizes (1024x1024 for App Store)
2. **Screenshots**: Capture screenshots for all supported device sizes
3. **Privacy Policy**: Required for App Store submission (template below)
4. **App Description**: Marketing copy for App Store listing

### Privacy Policy Template

Required disclosures:
- Photo library access for photobook creation
- Data is processed locally on device
- Photos are only uploaded to print service when user explicitly orders
- No analytics or tracking (if applicable)
- Third-party print service privacy policies

### Review Guidelines

Ensure compliance with:
- Photo library usage is clearly explained
- In-app purchases configured if charging for photobooks
- Test with TestFlight before submission
- Follow Apple's Human Interface Guidelines

## Testing

### Manual Testing Checklist

- [ ] Photo picker opens and displays library
- [ ] Photos load correctly with thumbnails
- [ ] Quality analysis completes without crashes
- [ ] Layout generation works for all styles
- [ ] Page preview renders correctly
- [ ] PDF generation produces valid output
- [ ] Print service submission handles errors gracefully
- [ ] App works on various device sizes (iPhone, iPad)

### Test Cases

1. **Empty state**: Launch app with no photos selected
2. **Single photo**: Create photobook with 1 photo
3. **Large batch**: Test with 50+ photos
4. **Low quality photos**: Verify quality analysis handles poor images
5. **Network failures**: Test print service API error handling

## Roadmap

### Planned Features
- [ ] Manual photo rearrangement (drag & drop)
- [ ] Custom text and captions
- [ ] Photo filters and editing
- [ ] Template customization
- [ ] Save drafts locally
- [ ] Share preview as PDF
- [ ] Multiple photobook projects
- [ ] Cloud sync between devices

### Future Enhancements
- [ ] Machine learning model for better quality detection
- [ ] Advanced composition analysis
- [ ] Theme-based layouts (wedding, travel, baby, etc.)
- [ ] Collaboration features
- [ ] Video integration for QR codes to video memories

## Troubleshooting

### Common Issues

**Photos not loading**:
- Check photo library permissions in Settings
- Verify Info.plist has correct usage descriptions
- Try with smaller batch of photos first

**Quality analysis is slow**:
- Analysis runs asynchronously but can be intensive
- Consider reducing image resolution for analysis
- Add progress indicators for user feedback

**Layout generation fails**:
- Ensure photos have valid images loaded
- Check console for specific error messages
- Verify photo metadata is accessible

**Print service errors**:
- Confirm API endpoint is reachable
- Check API key is valid
- Verify PDF generation produces valid output

## Performance Optimization

- Photos are cached using PHCachingImageManager
- Quality analysis runs in background
- Layout generation is async/await based
- PDF generation uses optimized rendering

## Contributing

This is a personal project, but suggestions and improvements are welcome!

## License

Copyright © 2024. All rights reserved.

## Support

For issues or questions about the code, please open an issue in the repository.

## Acknowledgments

- Uses Apple's Vision framework for image analysis
- PhotosUI for modern photo picker
- SwiftUI for reactive UI design
