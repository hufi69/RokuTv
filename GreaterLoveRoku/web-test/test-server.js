// Simple HTTP server for testing Roku app
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;

const server = http.createServer((req, res) => {
    let filePath = '.' + req.url;
    if (filePath === './') {
        filePath = './roku-tv-simulator.html';
    }

    const extname = String(path.extname(filePath)).toLowerCase();
    const mimeTypes = {
        '.html': 'text/html',
        '.js': 'text/javascript',
        '.css': 'text/css',
        '.json': 'application/json',
        '.png': 'image/png',
        '.jpg': 'image/jpg',
        '.gif': 'image/gif',
        '.svg': 'image/svg+xml',
        '.wav': 'audio/wav',
        '.mp4': 'video/mp4',
        '.woff': 'application/font-woff',
        '.ttf': 'application/font-ttf',
        '.eot': 'application/vnd.ms-fontobject',
        '.otf': 'application/font-otf',
        '.wasm': 'application/wasm'
    };

    const contentType = mimeTypes[extname] || 'application/octet-stream';

    fs.readFile(filePath, (error, content) => {
        if (error) {
            if (error.code === 'ENOENT') {
                res.writeHead(404, { 'Content-Type': 'text/html' });
                res.end(`
                    <h1>404 - File Not Found</h1>
                    <p>Available files:</p>
                    <ul>
                        <li><a href="/roku-tv-simulator.html">Roku TV Simulator</a></li>
                        <li><a href="/index.html">Web Interface</a></li>
                        <li><a href="/roku-simulator.html">Basic Simulator</a></li>
                    </ul>
                `);
            } else {
                res.writeHead(500);
                res.end('Server Error: ' + error.code);
            }
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content, 'utf-8');
        }
    });
});

server.listen(PORT, () => {
    console.log(`🚀 Test server running at http://localhost:${PORT}`);
    console.log(`📺 Roku TV Simulator: http://localhost:${PORT}/roku-tv-simulator.html`);
    console.log(`🌐 Web Interface: http://localhost:${PORT}/index.html`);
    console.log(`📱 Basic Simulator: http://localhost:${PORT}/roku-simulator.html`);
    console.log(`\n💡 Make sure the API proxy is running on port 3001!`);
});
