#!/usr/bin/env python3

import sys

from http.server import HTTPServer, SimpleHTTPRequestHandler
import socketserver

class ThreadedHTTPServer(socketserver.ThreadingMixIn, HTTPServer):
    pass

if __name__ == '__main__':
    server = ThreadedHTTPServer(("0.0.0.0", 8000), SimpleHTTPRequestHandler)
    print("Web server started")
    server.serve_forever()
