
from Tkinter import *
from tkFileDialog import asksaveasfilename

from picamera import PiCamera
from brightpi import *
import datetime, time, itertools
import RPi.GPIO as GPIO

# Parser for optional arguments
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--light", action='store_false', default=True,
    dest='light', help="Toggle BrightPi.")
parser.add_argument('--fullscreen', action='store_true', default=False,
    dest='fullscreen', help="Toggle fullscreen preview.")
parser.add_argument("--prevsize",  type=float, default=320,
    help="Width of the preview window.",)
parser.add_argument("-r", "--framerate",  type=int, default=30,
    help="Camera frame rate used for recordings.",)
parser.add_argument("--rotation",  type=int, default=180,
    help="Rotation of camera output picture, in degree.",)
parser.add_argument("--timeout",  type=int, default=20,
    help="How long the program will wait for an external trigger.",)
args = parser.parse_args()

channelPush = 40	# GPIO pin for push button/trigger LOW=active
effects = ['off', 'all', 'IR', 'white']

class CamGUI:
    """A simple GUI to control RasPi camera recordings

    This simple GUI lets users start and stop camera preview and recording,
    as well as control a BrightPi light source. Length and storage path can be
    set. The GUI accepts external triggers on GPIO21, pull LOW to trigger.
    """

    def __init__(self, master):
        """Create and pack all GUI elements"""

        self.master = master
        master.title("Camera Control")

        self.label = Label(master, text="Control the camera!")
        self.label.pack()

        self.open_preview = Button(master, text="Start Preview",
            command=camera.start_preview)
        self.open_preview.pack()

        self.close_preview = Button(master, text="Stop Preview",
            command=camera.stop_preview)
        self.close_preview.pack()

        self.record_time_label = Label(master, text="Time (s)")
        self.record_time_label.pack()

        self.record_time_value = Entry(master)
        self.record_time_value.insert(0, "0")
        self.tooltip = Label(master, text="", width=40)
        self.record_time_value.pack()
        self.tooltip.pack(fill = "x")

        self.record_time_value.bind("<Enter>", self.on_enter)
        self.record_time_value.bind("<Leave>", self.on_leave)

        self.file_name_label = Label(master, text="File name")
        self.file_name_label.pack()

        self.file_name_value = Entry(master)
        self.file_name_value.insert(0, "./")
        self.file_name_value.pack()

        self.save_file = Button(master, text="Browse...",
            command=self.point_save_location)
        self.save_file.pack()
        self.wait_trigger_flag = IntVar()
        self.wait_trigger = Checkbutton(master, text="External trigger",
            variable=self.wait_trigger_flag)
        self.wait_trigger.pack()

        self.start_rec = Button(master, text="Start Recording",
            command=self.start_recording)
        self.start_rec.pack()

        self.stop_rec = Button(master, text="Stop Recording",
            command=camera.stop_recording)
        self.stop_rec.pack()

        # Skip lamp control, if necessary
        if args.light:
            self.light_label = Label(master, text="LED light")
            self.light_label.pack()

            LIGHT_Var = StringVar(root)
            LIGHT_Var.set(effects[0])
            LIGHT_Option = OptionMenu(master, LIGHT_Var, *effects,
                command=self.set_light)
            LIGHT_Option.pack()

    def on_enter(self, event):
        """Tooltip for record time label"""

        self.tooltip.configure(text="Use 0 for infinite recording.")

    def on_leave(self, event):
        """Tooltip for record time label"""

        self.tooltip.configure(text="")

    def set_light(self, value):
        """BrightPi control"""

        if (value == 'all'):
	        leds_on = LED_ALL
	        leds_off = 0
        elif (value == 'IR'):
	        leds_on = LED_IR
	        leds_off = LED_WHITE
        elif (value == 'white'):
	        leds_on = LED_WHITE
	        leds_off = LED_IR
        else:
	        leds_on = 0
	        leds_off = LED_ALL

        if not (leds_off == LED_ALL):
            brightPi.set_led_on_off(leds_on, ON)

        if not (leds_on == LED_ALL):
            brightPi.set_led_on_off(leds_off, OFF)

    def start_recording(self):
        """Start recording or wait for trigger"""

	    # check trigger state
        self.trigState = False
        doWait = self.wait_trigger_flag.get()
        if doWait:
            self.wait_for_trigger()
            return

        if self.trigState:
            self.wait_trigger_flag.set(1)

        fname = self.file_name_value.get()

        if fname == "./":
            date = datetime.datetime.now().strftime("%d_%m_%Y_%H_%M_%S")
            fname = "./"+ date+ ".h264"

        time_rec = int(self.record_time_value.get())
        camera.start_recording(fname)

        if (time_rec > 0):
            sys.stdout.write("\rRecording started\n")
            for remaining in range(time_rec, 0, -1):
                sys.stdout.write("\r")
                sys.stdout.write("{:2d} seconds remaining.".format(remaining))
                sys.stdout.flush()
                camera.wait_recording(1)

            camera.stop_recording()
            sys.stdout.write("\rDone recording!               \n")

    def point_save_location(self):
        """ Ask user where to save the file"""

        fname = asksaveasfilename(
            defaultextension=".h264",
            initialdir="./")

        if fname is None:
            return
        self.file_name_value.delete(0,END)
        self.file_name_value.insert(0,fname)

    def wait_for_trigger(self):
        """Wait for a trigger to arrive

        When waiting for a trigger, the timeout value in GPIO.wait_for_trigger()
        defines maximum response latency. Length of range in for loop multiplied
        by timeout + debounce time gives time until trigger timeout."""

        print('Waiting for trigger ')
        spinner = itertools.cycle(['-', '/', '|', '\\']) # set up spinning "wheel"

        numloops = int(args.timeout * 5) # Number of loops until timeout

        for x in range(numloops):
            GPIO.wait_for_edge(channelPush, GPIO.FALLING, timeout=195)
            time.sleep(0.005) #debounce 5ms

	        # double-check - workaround for messy edge detection
            if GPIO.input(channelPush) == 0:
                self.trigState = True
                self.wait_trigger.deselect()
                self.start_recording()
                return
	    else:
		time.sleep(0.195)

            sys.stdout.write(spinner.next())  # write the next character
            sys.stdout.flush()                # flush stdout buffer (actual character display)
            sys.stdout.write('\b')            # erase the last written char

        self.wait_trigger.deselect()
        sys.stdout.write('\bNo trigger arrived\n')
        sys.stdout.flush()
        return


# Set up trigger input GPIO
GPIO.setmode(GPIO.BOARD)
GPIO.setup(channelPush, GPIO.IN, pull_up_down=GPIO.PUD_UP) # internal pull up

# Check whether BrightPi is used
if args.light:
    brightPi = BrightPi()
    brightPi.reset()

    # Define LEDs
    LED_ALL = (1,2,3,4,5,6,7,8)
    LED_WHITE = LED_ALL[0:4]
    LED_IR = LED_ALL[4:8]
    ON = 1
    OFF = 0

# Create camera object with defined settings
camera = PiCamera()
camera.rotation = args.rotation
camera.color_effects = (128,128) #b/w
camera.framerate = args.framerate
camera.preview_fullscreen = args.fullscreen

#calculate preview size
height = int(args.prevsize * 0.75)
width = args.prevsize
camera.preview_window = (100,20,width,height)

# Create GUI
root = Tk()
my_gui = CamGUI(root)

# Loop until interrupted
try:
    root.mainloop()
except KeyboardInterrupt:
    GPIO.cleanup()
    camera.close()
