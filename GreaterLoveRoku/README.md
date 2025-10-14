# Greater Love TV - Roku Channel

This is a Roku channel app converted from the original tvOS Greater Love Network app. It features live streaming, video on demand content, and interactive elements.

## Features

- **Live Streaming**: Real-time HLS streaming with automatic reconnection
- **Video On Demand**: Episodic content organized by shows
- **Categories**: Browse content by different show categories
- **API Integration**: Connects to the Greater Love Network API
- **QR Code Integration**: Links to donation, prayer requests, and mobile app

## Development Setup

### Prerequisites

1. **Node.js and npm**: Required for Roku development tools
   ```bash
   # Already installed via Homebrew
   brew install node npm
   ```

2. **Roku Development Tools**:
   ```bash
   npm install -g roku-deploy bslint brighterscript
   ```

### Running the App

#### Method 1: Using Roku Device (Recommended)

1. **Enable Developer Mode on your Roku**:
   - Press Home button 3x, Up 2x, Right 1x, Left 1x, Right 1x, Left 1x, Right 1x
   - Set a password (default: rokudev)
   - Note the IP address

2. **Configure deployment**:
   ```bash
   # Edit roku-deploy.json and set your Roku's IP
   vim roku-deploy.json
   # Change "host": "" to "host": "192.168.1.XXX"
   ```

3. **Deploy to Roku**:
   ```bash
   npm run deploy
   ```

#### Method 2: Using Roku Simulator (Development Only)

1. **Download Roku Simulator**:
   - Go to https://developer.roku.com/en-ca/downloads
   - Download "Roku OS Simulator" for macOS
   - Install the simulator

2. **Setup Simulator**:
   - Launch Roku Simulator
   - Configure network settings to match your development environment

3. **Deploy to Simulator**:
   ```bash
   # Package the app
   npm run build

   # Manually deploy to simulator through the web interface
   # Go to http://localhost:8080 (simulator web interface)
   # Upload the generated .zip file
   ```

## Project Structure

```
GreaterLoveRoku/
├── manifest                    # Channel configuration
├── source/
│   └── main.brs               # Entry point
├── components/
│   ├── MainScene.xml          # Main UI scene
│   ├── MainScene.brs          # Main scene logic
│   ├── EpisodeListScene.xml   # Episode listing
│   ├── EpisodeListScene.brs   # Episode logic
│   ├── LoadLiveStreamsTask.xml # Live stream API task
│   ├── LoadLiveStreamsTask.brs
│   ├── LoadShowsTask.xml      # Shows API task
│   └── LoadShowsTask.brs
├── images/                    # All app images and icons
├── roku-deploy.json          # Deployment configuration
└── package.json              # npm configuration
```

## API Configuration

The app connects to the Greater Love Network API:
- Base URL: `https://api.vidapp.co/v1`
- User ID: `6751c91bb4b7c627b5d15e6d`

### Live Streams Endpoint
```
GET /users/{userId}/livestreams
```

### Shows Endpoint
```
GET /users/{userId}/video-folders?limit=100&page=1
```

## Development Commands

```bash
# Lint BrightScript code
npm run build

# Deploy to Roku device
npm run deploy

# Deploy with file watching (auto-redeploy on changes)
npm run watch
```

## Key Differences from tvOS App

1. **Language**: Converted from Swift/SwiftUI to BrightScript/SceneGraph
2. **UI Framework**: Using Roku SceneGraph instead of SwiftUI
3. **Navigation**: Scene-based navigation instead of NavigationView
4. **Video Player**: Roku Video node instead of AVPlayer
5. **API Calls**: HTTP requests using roUrlTransfer instead of URLSession

## Troubleshooting

### Common Issues

1. **App won't load on Roku**:
   - Check that Roku is in developer mode
   - Verify IP address in roku-deploy.json
   - Ensure Roku and development machine are on same network

2. **Video playback issues**:
   - Check HLS stream URLs are accessible
   - Verify stream format compatibility with Roku
   - Check network connectivity

3. **API connection failures**:
   - Verify internet connectivity
   - Check API endpoint availability
   - Ensure SSL certificates are working

### Roku Developer Portal

- Access your Roku at: `http://[ROKU_IP]`
- Username: `rokudev`
- Password: `rokudev` (or your custom password)

## Deployment to Roku Channel Store

For production deployment:

1. Create Roku Developer Account
2. Package the channel for submission
3. Follow Roku's certification process
4. Submit through Partner Portal

## Support

For technical support or questions about the Greater Love TV Roku channel development, please refer to:

- [Roku Developer Documentation](https://developer.roku.com/docs)
- [BrightScript Language Reference](https://developer.roku.com/docs/references/brightscript/language/brightscript-language-reference.md)
- [SceneGraph Framework](https://developer.roku.com/docs/references/scenegraph/renderable-nodes/renderable-nodes.md)