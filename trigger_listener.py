import sys, os
import json
import shlex
import datetime

from time import sleep
from subprocess import Popen, PIPE, call
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

# Set GPIO mode
GPIO.setmode(GPIO.BOARD)

# Predefined values
channel = 7
fname = 'params.json'

def cam_trigger(channel):
    print('Trigger detected on channel %s'%channel)

    data = read_json(fname)
    width = int(data["cam_settings"]["width"])
    height = int(data["cam_settings"]["height"])
    fps = int(data["cam_settings"]["fps"])

    camera.rotation = 180
    camera.color_effects = (128,128)
    camera.resolution = (width, height)
    camera.framerate = fps
    
    camera.start_preview()
    
    prefix = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
    duration = data["cam_settings"]["duration"]
    filepath = ''.join((data["paths"]["savepath"], prefix, data["paths"]["filename"]))
    
    camera.start_recording(filepath)
    camera.sleep(duration/1000)
    
    camera.stop_recording()
    camera.stop_preview()

    #print(cmd["vid"])

    #p1 = Popen([cmd['vid']], stdout=PIPE, shell=True, bufsize=0)
    #p2 = Popen([cmd['tee']], stdin=p1.stdout, stdout=PIPE)
    #p1.stdout.close()  # Allow p1 to receive a SIGPIPE if p2 exits.
    #p2.stdout.close()
    #output = p2.communicate()[0]

    #command_line = "raspivid -o - -t 5000 | tee /home/pi/mnt/finc/_Group/Projects/Astrocyte\ Calcium/Current\ Milestones/GYS1\ knockouts/Awake/Video/`date +%y-%m-%d`_video.h264 | nc 192.168.1.238 5001"

    #args = shlex.split(command_line)
    #print args
    # send acquire command with parameters specified in .json
    #p = subprocess.Popen(args)

    # convert saved file to .mp4
    
def read_json(fname):
  # Read params from external .json file
  with open(fname) as data_file:
      data = json.load(data_file)
  #print(data)

  #prefix = datetime.datetime.now().strftime("%Y-%m-%d_%H:%M:%S")

  #duration = data["cam_settings"]["duration"]
  #filepath = ''.join((data["paths"]["savepath"], prefix, data["paths"]["filename"]))
  #ip = data["paths"]["stream"]
  #port = "5001"

  # parse command
  #vid_cmd = " ".join(("raspivid -o - -t", duration))
  #tee_cmd = " ".join(("| tee", filepath))
  #nc_cmd = " ".join(("| nc", ip, port))

  return data

GPIO.setup(channel, GPIO.IN)
GPIO.add_event_detect(channel, GPIO.RISING)
GPIO.add_event_callback(channel, cam_trigger)

try:
    while True:
        print 'alive'
        sleep(0.2)
except KeyboardInterrupt:
    GPIO.cleanup()
    sys.exit()
