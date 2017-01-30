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

def read_json(fname):
    # Read params from external .json file
    with open(fname) as data_file:
        params = json.loads(data_file)

    prefix = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")

    # construct full filename
    params['filename'] = ''.join((prefix, params['filename'])

    # duration = data["cam_settings"]["duration"]
    # filepath = "".join(data["paths"]["savepath"], prefix, data["paths"]["filename"])
    # ip = data["paths"]["stream"]
    # port = "5001"
    #
    # # parse command
    # vid_cmd = " ".join("raspivid -o - -t", duration)
    # tee_cmd = " ".join("| tee", filepath)
    # nc_cmd = " ".join("| nc", ip, port)
    #
    # return {'vid':vid_cmd, 'tee':tee_cmd. 'nc':nc_cmd}

try:
    while True:

        # Connect a socket to a remote server on port 8000
        sock = socket.socket()
        sock.bind(('0.0.0.0', 8000))
        sock.listen(0)

        # Accept a single connection and make a file-like object out of it
        connection = sock.accept()[0].makefile('rb')

        # read params from json
        params = read_json(filename)

        with picamera.PiCamera() as camera:
            camera.resolution = (params['width'], params['height'])
            camera.framerate = params['fps']
            camera.rotation = params['rotation']

            # Construct an instance of our custom output splitter with a filename
            # and a connected socket
            my_output = MyOutput(params['filename'], sock)

            # Record video to the custom output (we need to specify the format as the custom output doesn't pretend to be a file with a filename)
            camera.start_recording(my_output, format='h264')
            camera.wait_recording(params['duration'])
            camera.stop_recording()

        connection.close()

except KeyboardInterrupt:
    connection.close()
    sock.close()
