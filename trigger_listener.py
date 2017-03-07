import sys, os
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

# Create Camera object
camera = PiCamera()
camera.rotation = 180
camera.color_effects = (128,128)
camera.framerate = 25
camera.start_preview()

# Set GPIO mode
GPIO.setmode(GPIO.BOARD)

# Predefined values
channel = 7
fname = 'params.json'

def cam_trigger(channel):
    print('Trigger detected on channel %s'%channel)

    data = read_json(fname)
    #width = int(data["cam_settings"]["width"])
    #height = int(data["cam_settings"]["height"])
    #fps = int(data["cam_settings"]["fps"])

    prefix = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    duration = int(data["cam_settings"]["duration"])
    filepath = ''.join((data["paths"]["savepath"], prefix, data["paths"]["filename"]))

    camera.start_recording(filepath)
    camera.wait_recording(duration)
    camera.stop_recording()

def read_json(fname):
    # Read params from external .json file
    with open(fname) as data_file:
        data = json.load(data_file)

    return data

GPIO.setup(channel, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
GPIO.add_event_detect(channel, GPIO.RISING, callback=cam_trigger, bouncetime=25000)
#GPIO.add_event_callback(channel, cam_trigger)

try:
    while True:
        sleep(.2)
except KeyboardInterrupt:
    camera.stop_preview()
    GPIO.cleanup()
    sys.exit()
