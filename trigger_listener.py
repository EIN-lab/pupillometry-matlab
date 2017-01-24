import json
import shlex, subprocess
import datetime

from time import sleep

try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO!  This is probably because you need superuser privileges.  You can achieve this by using 'sudo' to run your script")

###

# Set GPIo mode
GPIO.setmode(GPIO.BOARD)

# Read params from external .json file
with open('params.json') as data_file:
    data = json.load(data_file)
print(data)

# Parse values
channel = data["GPIO_pin"]

def cam_trigger(channel):
    print('Trigger detected on channel %s'%channel)

    # Read params from external .json file
    with open('params.json') as data_file:
        data = json.load(data_file)

    prefix = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")

    raspivid = "raspivid -o - -t"
    duration = data["cam_settings"]["duration"]
    tee = "| tee"
    filepath = "".join(data["paths"]["savepath"], prefix, data["paths"]["filename"])

    nc = "| nc"
    ip = data["paths"]["stream"]
    port = "5001"

    # parse command
    command_line = " ".join(raspivid, duration, tee, filepath, nc, ip, port)

    #command_line = "raspivid -o - -t 5000 | tee /home/pi/mnt/finc/_Group/Projects/Astrocyte\ Calcium/Current\ Milestones/GYS1\ knockouts/Awake/Video/`date +%y-%m-%d`_video.h264 | nc 192.168.1.238 5001"

    args = shlex.split(command_line)
    print args
    # send acquire command with parameters specified in .json
    p = subprocess.Popen(args)

    # convert saved file to .mp4


GPIO.setup(channel, GPIO.IN)
GPIO.add_event_detect(channel, GPIO.RISING)
GPIO.add_event_callback(channel, cam_trigger)

try:
    while True:
        print 'alive'
        time.sleep(0.2)
except KeyboardInterrupt:
    GPIO.cleanup()
    sys.exit()
