# Complete Setup Guide for Greater Love TV Roku App

## Quick Start for Mac Users

### Step 1: Roku Device Setup

1. **Put Roku in Developer Mode**:
   - On your Roku remote: Press Home 3x, Up 2x, Right 1x, Left 1x, Right 1x, Left 1x, Right 1x
   - Enable "Developer Options"
   - Set password to `rokudev`
   - Note the IP address displayed

2. **Find Your Roku's IP Address** (if not shown):
   - Go to Settings > Network > About
   - Write down the IP address (e.g., 192.168.1.100)

### Step 2: Development Environment

Your Mac is already set up with:
- ✅ Node.js and npm installed via Homebrew
- ✅ Roku development tools installed (`roku-deploy`, `bslint`, `brighterscript`)
- ✅ Project structure created with all necessary files

### Step 3: Configure and Deploy

1. **Edit the deployment config**:
   ```bash
   cd /Users/noraiz/Desktop/RokuTv/GreaterLoveRoku
   nano roku-deploy.json
   ```

   Change this line:
   ```json
   "host": "",
   ```

   To your Roku's IP:
   ```json
   "host": "192.168.1.XXX",
   ```

2. **Deploy to your Roku**:
   ```bash
   npm run deploy
   ```

3. **The app will appear on your Roku home screen as "Greater Love TV"**

### Step 4: Testing the App

Once deployed, the app will:
1. Load live streams from the Greater Love Network API
2. Display shows and episodes
3. Allow you to play live streams and video content
4. Show QR codes for donation and engagement

## Alternative: Using Roku Simulator

If you don't have a physical Roku device:

1. **Download Roku Simulator**:
   - Visit: https://developer.roku.com/en-ca/downloads
   - Download "Roku OS Simulator for macOS"
   - Install and launch

2. **Package and Upload**:
   ```bash
   npm run build
   ```
   - Open simulator web interface (usually http://localhost:8080)
   - Upload the generated package

## Viewing Your App in Action

### Live Streams
- The app connects to: `https://api.vidapp.co/v1/users/6751c91bb4b7c627b5d15e6d/livestreams`
- Displays active streams with HLS playback

### Video On Demand
- Loads shows from: `https://api.vidapp.co/v1/users/6751c91bb4b7c627b5d15e6d/video-folders`
- Browse episodes within each show
- Play individual episodes

### Navigation
- Use Roku remote to navigate between sections
- Select items to play content
- Back button returns to previous screen

## Development Workflow

### Making Changes
1. Edit BrightScript files in `components/` or `source/`
2. Run `npm run deploy` to update the Roku
3. App automatically restarts with new code

### Debugging
- Access developer console at: `http://[ROKU_IP]`
- View console logs and debugging information
- Monitor performance and memory usage

### File Watching (Auto-deploy)
```bash
npm run watch
```
This will automatically redeploy when you save files.

## Common Commands Reference

```bash
# Navigate to project
cd /Users/noraiz/Desktop/RokuTv/GreaterLoveRoku

# Build and lint
npm run build

# Deploy once
npm run deploy

# Deploy with auto-redeployment on file changes
npm run watch

# View app on Roku
# Navigate to "Greater Love TV" on Roku home screen
```

## Troubleshooting

### App doesn't appear on Roku
- Ensure Roku is in developer mode
- Check IP address in roku-deploy.json
- Verify network connectivity

### Deployment fails
- Check that both Mac and Roku are on same WiFi network
- Verify Roku developer password is correct
- Try restarting Roku and trying again

### Video won't play
- Check internet connection on Roku
- Verify API endpoints are accessible
- Check stream URLs in the API response

## Next Steps

Your Greater Love TV Roku app is ready! You can now:

1. **Test all functionality** on your Roku device
2. **Modify the code** to add new features
3. **Customize the UI** by editing the XML/BrightScript files
4. **Prepare for Roku Channel Store** submission when ready

The app includes the same core functionality as the original tvOS app:
- Live streaming with HLS support
- Video on demand episodes
- API integration for dynamic content
- Professional UI matching the original design
- Error handling and loading states