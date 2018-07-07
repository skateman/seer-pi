#!/usr/bin/env python3

import io
import logging
import socketserver

from http import server
from threading import Condition

from picamera import PiCamera
from picamera import PiCameraCircularIO
from picamera.array import PiMotionAnalysis

class MotionOutput(PiMotionAnalysis):
  def analyse(self, arr):
    arr = numpy.sqrt(numpy.square(arr['x'].astype(numpy.float)) + numpy.square(arr['y'].astype(numpy.float))).clip(0, 255).astype(numpy.uint8)
    if (arr > 60).sum() > 5:
        logging.info("Motion detected!")

class StreamingOutput(object):
    def __init__(self):
        self.frame = None
        self.buffer = io.BytesIO()
        self.condition = Condition()

    def write(self, buf):
        if buf.startswith(b'\xff\xd8'):
            # New frame, copy the existing buffer's content and notify all clients it's available
            self.buffer.truncate()
            with self.condition:
                self.frame = self.buffer.getvalue()
                self.condition.notify_all()
            self.buffer.seek(0)
        return self.buffer.write(buf)

class StreamingHandler(server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Age', 0)
        self.send_header('Cache-Control', 'no-cache, private')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Content-Type', 'multipart/x-mixed-replace; boundary=FRAME')
        self.end_headers()
        try:
            while True:
                with stream.condition:
                    stream.condition.wait()
                    frame = stream.frame
                self.wfile.write(b'--FRAME\r\n')
                self.send_header('Content-Type', 'image/jpeg')
                self.send_header('Content-Length', len(frame))
                self.end_headers()
                self.wfile.write(frame)
                self.wfile.write(b'\r\n')
        except Exception as e:
            logging.warning('Removed streaming client %s: %s', self.client_address, str(e))

class StreamingServer(socketserver.ThreadingMixIn, server.HTTPServer):
    allow_reuse_address = True
    daemon_threads = True

with PiCamera(resolution = (1296, 972), framerate=24) as camera:
    with PiCameraCircularIO(camera, seconds = 20) as circular:
        with MotionOutput(camera) as motion:
            stream = StreamingOutput()

            camera.start_recording(stream, format='mjpeg', splitter_port = 1, motion_output = motion)
            camera.start_recording(circular, format='mjpeg', splitter_port = 2)

            try:
                address = ('', 8000)
                server = StreamingServer(address, StreamingHandler)
                server.serve_forever()
            finally:
                camera.stop_recording()
