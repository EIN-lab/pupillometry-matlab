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

    cmd = read_json(fname)

    p1 = Popen([cmd['vid']], stdout=PIPE)
    p2 = Popen([cmd['tee']], stdin=p1.stdout, stdout=PIPE)
    p3 = Popen([cmd['nc']], stdin=p2.stdout, stdout=PIPE)
    p1.stdout.close()  # Allow p1 to receive a SIGPIPE if p2 exits.
    p2.stdout.close()
    output = p2.communicate()[0]

    #command_line = "raspivid -o - -t 5000 | tee /home/pi/mnt/finc/_Group/Projects/Astrocyte\ Calcium/Current\ Milestones/GYS1\ knockouts/Awake/Video/`date +%y-%m-%d`_video.h264 | nc 192.168.1.238 5001"

    #args = shlex.split(command_line)
    #print args
    # send acquire command with parameters specified in .json
    #p = subprocess.Popen(args)

    # convert saved file to .mp4
def read_json(fname)
    # Read params from external .json file
    with open(fname) as data_file:
        data = json.load(data_file)

    prefix = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")

    duration = data["cam_settings"]["duration"]
    filepath = "".join(data["paths"]["savepath"], prefix, data["paths"]["filename"])
    ip = data["paths"]["stream"]
    port = "5001"

    # parse command
    vid_cmd = " ".join("raspivid -o - -t", duration)
    tee_cmd = " ".join("| tee", filepath)
    nc_cmd = " ".join("| nc", ip, port)

    return {'vid':vid_cmd, 'tee':tee_cmd, 'nc':nc_cmd}

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
