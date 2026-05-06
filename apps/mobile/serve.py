import http.server
import socketserver
import os

PORT = int(os.environ.get("PORT", 8080))
DIRECTORY = "."

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Content-Security-Policy", "default-src 'self'; script-src 'self' 'unsafe-eval' 'wasm-unsafe-eval' 'unsafe-inline' blob: https: *; style-src 'self' 'unsafe-inline' https: *; img-src 'self' data: https: *; font-src 'self' data: https: *; connect-src 'self' https: *; media-src 'self' https: *; object-src 'none'; frame-src 'self' https: *;")
        super().end_headers()

with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
