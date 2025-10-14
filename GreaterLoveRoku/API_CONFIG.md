# Greater Love TV Roku App - API Configuration

## Castr API Integration

### API Endpoints
- **Base URL**: `https://api.castr.com/v2`
- **Shows Endpoint**: `/videos?page=1&per_page=50`
- **Authentication**: Basic Auth with Access Token

### Authentication
- **Access Token**: `5aLoKjrNjly4`
- **Secret Key**: `UjTCq8wOj76vjXznGFzdbMRzAkFq6VlJElBQ`
- **Auth Header**: `Basic NWFMb0tqck5qbHk0OlVqVENxOHdPajc2dmpYem5HRnpkYk1SekFrRnE2VmxKRWxCUQ==`

### Live Streaming URLs
- **Channel 1 HLS**: `https://rpn.bozztv.com/dvrfl03/itv04060/index.m3u8`
- **Channel 1 Embed**: `https://swf.tulix.tv/iframe/greaterlove/`
- **Channel 2 HLS**: `https://rpn.bozztv.com/dvrfl04/itv04019/index.m3u8`
- **Channel 2 Embed**: `https://swf.tulix.tv/iframe/greaterlove2/`

### Thumbnail Generation
- **Pattern**: `https://player.castr.com/api/v1/vod/{videoId}/thumbnail`
- **Example**: `https://player.castr.com/api/v1/vod/FEgYaygr8QDofmKX/thumbnail`

### Show Data Structure
```json
{
  "_id": "show_id",
  "name": "Show Name",
  "enabled": true,
  "type": "vod",
  "data": [
    {
      "id": "video_id.mp4",
      "fileName": "Episode Title",
      "enabled": true,
      "bytes": 2981260901,
      "mediaInfo": {
        "durationMins": 29,
        "duration": 1712,
        "width": 1920,
        "height": 1080,
        "fps": 29
      },
      "playback": {
        "embed_url": "https://player.castr.com/vod/video_id"
      }
    }
  ]
}
```

### Available Shows (51 Total)
1. Gospel Tabernacle
2. World Overcomers
3. Go Ye
4. Kingdom Builders
5. Voice of Evangelism
6. City On A Hill
7. Keith Nix Ministries
8. Right Now
9. Flashpoint Ministries
10. Redemption Today
11. The Bride Live
12. The Shield of Faith
13. Seeds Kids
14. Voice of Hope
15. Chosen Kids
16. Gospel for Everyone
17. Radiant Living Worship Center
18. Kevin Wallace Ministries
19. Touched By The Truth
20. Better Life Now
... and 31 more shows

### Video Playback
- **Format**: MP4 with H.264/AAC codecs
- **Resolution**: 1920x1080 (HD)
- **Frame Rate**: 24-30 fps
- **Duration**: Typically 29 minutes per episode
- **File Size**: 300MB - 3GB per episode

### Implementation Notes
- All API calls use HTTPS with SSL certificates
- Authentication is required for all requests
- Thumbnails are generated dynamically from video frames
- Live streams use HLS protocol for optimal TV playback
- Episode data includes metadata for duration, resolution, and file size
