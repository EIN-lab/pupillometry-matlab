#!/usr/bin/env python

import io
import picamera
import socket


# An output (as far as picamera is concerned), is just a filename or an object
# which implements a write() method (and optionally the flush() and close()
# methods)
class MyOutput(object):
    def __init__(self, filename, sock):
        self.output_file = io.open(filename, 'wb')
        self.output_sock = sock.makefile('wb')

    def write(self, buf):
        self.output_file.write(buf)
        self.output_sock.write(buf)

    def flush(self):
        self.output_file.flush()
        self.output_sock.flush()

    def close(self):
        self.output_file.close()
        self.output_sock.close()


# Connect a socket to a remote server on port 8000
sock = socket.socket()
sock.connect(('192.168.1.238', 8000))

with picamera.PiCamera() as camera:
    camera.resolution = (640, 480)
    camera.framerate = 24

    # Construct an instance of our custom output splitter with a filename
    # and a connected socket
    my_output = MyOutput('output.h264', sock)

    # Record video to the custom output (we need to specify the format as
    # the custom output doesn't pretend to be a file with a filename)
    camera.start_recording(my_output, format='h264')
    camera.wait_recording(10)
    camera.stop_recording()
