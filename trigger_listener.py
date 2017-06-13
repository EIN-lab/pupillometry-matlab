import itertools, sys, os
from subprocess import call
import json
import datetime

from time import sleep
from picamera import PiCamera

try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO!  This is probably because you need superuser privileges.  You can achieve this by using 'sudo' to run your script")

# connect data drive
isMount = os.path.ismount('/home/pi/mnt/finc')
if not isMount:
    try:
        p = call(["mount", "/home/pi/mnt/finc"])
    except RuntimeError:
        print("No internet connection!")

# Function definitions
def cam_trigger(channel):
    # Camera recording
    print('Trigger detected on channel %s. Recording...\n'%channel)

    camera.start_recording(filepath)
    camera.wait_recording(duration)
    camera.stop_recording()
    print('Recording ended\n')

def read_json(fname):
    # Read params from external .json file
    with open(fname) as data_file:
        data = json.load(data_file)

    return data

# Predefined values
channel = 11
fname = 'params.json'
data = read_json(fname)

# Generate unique filename
prefix = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
duration = int(data["cam_settings"]["duration"])
filepath = ''.join((data["paths"]["savepath"], prefix, data["paths"]["filename"]))

# Set up GPIO
GPIO.setmode(GPIO.BOARD)
GPIO.setup(channel, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

# Create Camera object
camera = PiCamera()
camera.rotation = 180
camera.color_effects = (128,128)
camera.framerate = 25
camera.zoom = (.4, .4, .2, .2)

# Start a preview as overlay
camera.start_preview(alpha=192) # remove alpha=192 to remove transparency
sleep(2) # Camera warm-up time
spinner = itertools.cycle(['-', '/', '|', '\\']) # set up spinning "wheel"

try:
    print("Ready for trigger\n")
    while True:
        ch_trig = GPIO.wait_for_edge(channel, GPIO.RISING,timeout=10)
        sys.stdout.write(spinner.next())  # write the next character
        sys.stdout.flush()                # flush stdout buffer (actual character display)
        sys.stdout.write('\b')            # erase the last written char
        if ch_trig is not None:
            cam_trigger(ch_trig)
except KeyboardInterrupt:
    camera.stop_preview()
    GPIO.cleanup()
