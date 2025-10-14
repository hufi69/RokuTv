// Simple Node.js proxy server to handle CORS for API testing
const http = require('http');
const https = require('https');
const url = require('url');

const PORT = 3001;
const API_BASE = 'https://api.castr.com/v2';
const ACCESS_TOKEN = '5aLoKjrNjly4';
const SECRET_KEY = 'UjTCq8wOj76vjXznGFzdbMRzAkFq6VlJElBQ';

// Static live streams from the original app
const STATIC_LIVE_STREAMS = {
    "docs": [
        {
            "_id": "static_channel_1",
            "name": "Greater Love TV Channel 1",
            "enabled": true,
            "creation_time": "2025-01-01T00:00:00.000Z",
            "embed_url": "https://swf.tulix.tv/iframe/greaterlove/",
            "hls_url": "https://rpn.bozztv.com/dvrfl03/itv04060/index.m3u8",
            "thumbnail_url": null,
            "broadcasting_status": "online",
            "ingest": null,
            "playback": {
                "hls_url": "https://rpn.bozztv.com/dvrfl03/itv04060/index.m3u8",
                "embed_url": "https://swf.tulix.tv/iframe/greaterlove/",
                "embed_audio_url": null
            }
        },
        {
            "_id": "static_channel_2",
            "name": "Greater Love TV Channel 2",
            "enabled": true,
            "creation_time": "2025-01-01T00:00:00.000Z",
            "embed_url": "https://swf.tulix.tv/iframe/greaterlove2/",
            "hls_url": "https://rpn.bozztv.com/dvrfl04/itv04019/index.m3u8",
            "thumbnail_url": null,
            "broadcasting_status": "online",
            "ingest": null,
            "playback": {
                "hls_url": "https://rpn.bozztv.com/dvrfl04/itv04019/index.m3u8",
                "embed_url": "https://swf.tulix.tv/iframe/greaterlove2/",
                "embed_audio_url": null
            }
        }
    ]
};

const server = http.createServer((req, res) => {
    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    const pathname = url.parse(req.url).pathname;

    // Handle livestreams - return static streams immediately
    if (pathname === '/livestreams') {
        console.log('Serving static live streams');
        res.setHeader('Content-Type', 'application/json');
        res.writeHead(200);
        res.end(JSON.stringify(STATIC_LIVE_STREAMS));
        return;
    }

    // Handle shows - fetch from Castr API
    if (pathname === '/shows') {
        const apiUrl = `${API_BASE}/videos?page=1&per_page=50`;

        // Create Basic Auth header
        const credentials = `${ACCESS_TOKEN}:${SECRET_KEY}`;
        const auth = Buffer.from(credentials).toString('base64');
        const authHeader = `Basic ${auth}`;

        console.log('Proxying shows request to:', apiUrl);

        // Create HTTPS request with auth headers
        const requestOptions = {
            headers: {
                'Authorization': authHeader,
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            }
        };

        https.get(apiUrl, requestOptions, (apiRes) => {
            let data = '';

            apiRes.on('data', chunk => {
                data += chunk;
            });

            apiRes.on('end', () => {
                try {
                    const castrData = JSON.parse(data);

                    // Add thumbnail URLs to episodes
                    if (castrData.docs) {
                        castrData.docs.forEach(show => {
                            if (show.data) {
                                show.data.forEach(episode => {
                                    // Create thumbnail URL for Castr videos
                                    if (episode.playback?.embed_url) {
                                        const videoId = episode.id.replace('.mp4', '');
                                        // Multiple thumbnail URL formats to try
                                        episode.thumbnail_url = `https://player.castr.com/api/v1/vod/${videoId}/thumbnail`;
                                        episode.thumbnail_url_alt = `https://img.castr.com/thumbnail/${videoId}.jpg`;
                                        episode.thumbnail_url_fallback = `https://castr.com/api/thumbnail/${videoId}`;
                                        episode.thumbnail_url_castr = `https://d1oca0jb1bx1ag.cloudfront.net/${videoId}/thumbnail.jpg`;

                                        // Generate frame extraction URL (first frame at 1 second)
                                        const embedId = episode.playback.embed_url.split('/').pop();
                                        episode.frame_thumbnail = `https://player.castr.com/live/${embedId}/thumbnail.jpg`;
                                    }
                                });
                            }
                        });
                    }

                    console.log('Castr API response processed with thumbnails');

                    // Return the enhanced Castr API data
                    res.setHeader('Content-Type', 'application/json');
                    res.writeHead(200);
                    res.end(JSON.stringify(castrData));
                } catch (parseError) {
                    console.error('JSON Parse Error:', parseError);
                    res.setHeader('Content-Type', 'application/json');
                    res.writeHead(500);
                    res.end(JSON.stringify({ error: 'Failed to parse API response', details: parseError.message }));
                }
            });

        }).on('error', (err) => {
            console.error('API Error:', err);
            res.setHeader('Content-Type', 'application/json');
            res.writeHead(500);
            res.end(JSON.stringify({ error: 'API request failed', details: err.message }));
        });
        return;
    }

    // 404 for other paths
    res.writeHead(404);
    res.end('Not Found');
});

server.listen(PORT, () => {
    console.log(`CORS Proxy server running on http://localhost:${PORT}`);
    console.log('Available endpoints:');
    console.log(`  - http://localhost:${PORT}/livestreams (Static Greater Love TV streams)`);
    console.log(`  - http://localhost:${PORT}/shows (Castr API videos)`);
});