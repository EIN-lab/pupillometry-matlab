
from Tkinter import *
from tkFileDialog import asksaveasfilename

from picamera import PiCamera
from brightpi import *
import datetime, time, itertools
import RPi.GPIO as GPIO

channelPush = 40	# GPIO pin for push button/trigger LOW=active
effects = ['all', 'IR', 'white', 'off']

class MyFirstGUI:
    def __init__(self, master):
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
        self.file_name_value.insert(0, "/home/pi/Videos/")
        self.file_name_value.pack()

        self.save_file = Button(master, text="Browse...",
            command=self.point_save_location)
        self.save_file.pack()
	self.wait_trigger_flag = IntVar()
	self.wait_trigger = Checkbutton(master, text="External trigger", variable=self.wait_trigger_flag)
	self.wait_trigger.pack()

        self.start_rec = Button(master, text="Start Recording",
            command=self.start_recording)
        self.start_rec.pack()

        self.stop_rec = Button(master, text="Stop Recording",
            command=camera.stop_recording)
        self.stop_rec.pack()

        LIGHT_Var = StringVar(root)
        LIGHT_Var.set(effects[0])
        LIGHT_Option = OptionMenu(self.master, LIGHT_Var, *effects,
            command=self.set_light)
        LIGHT_Option.pack()

    def on_enter(self, event):
        self.tooltip.configure(text="Use 0 for infinite recording.")

    def on_leave(self, event):
        self.tooltip.configure(text="")

    def set_light(self, value):
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
	# check trigger state
	doWait = self.wait_trigger_flag.get()
	if doWait:
	    self.wait_for_trigger()
	    return

	fname = self.file_name_value.get()

	if fname is None:
	    date = datetime.datetime.now().strftime("%d_%m_%Y_%H_%M_%S")
	    fname = "/home/pi/Videos/"+ date+ ".h264"

	time_rec = int(self.record_time_value.get())
	camera.start_recording(fname)

	if (time_rec > 0):
	    camera.wait_recording(time_rec)
	    camera.stop_recording()

    def point_save_location(self):
        fname = asksaveasfilename(
            defaultextension=".h264",
            initialdir="/home/pi/Videos/")

        if fname is None:
            return
        self.file_name_value.delete(0,END)
        self.file_name_value.insert(0,fname)

    def wait_for_trigger(self):
	print('Waiting for trigger ')
	spinner = itertools.cycle(['-', '/', '|', '\\']) # set up spinning "wheel"

	for x in range(50):

            GPIO.wait_for_edge(channelPush, GPIO.FALLING, timeout=195)
            time.sleep(0.005) #debounce 5ms

	    # double-check - workaround for messy edge detection
            if GPIO.input(channelPush) == 0:
            	self.wait_trigger.deselect()
		self.start_recording()
		return

            sys.stdout.write(spinner.next())  # write the next character
            sys.stdout.flush()                # flush stdout buffer (actual character display)
            sys.stdout.write('\b')            # erase the last written char
	
	self.wait_trigger.deselect()
	sys.stdout.write('\bNo trigger arrived\n')
	sys.stdout.flush()
	return


# Set up GPIO
GPIO.setmode(GPIO.BOARD)
GPIO.setup(channelPush, GPIO.IN, pull_up_down=GPIO.PUD_UP) # internal pull up

brightPi = BrightPi()
brightPi.reset()

LED_ALL = (1,2,3,4,5,6,7,8)
LED_WHITE = LED_ALL[0:4]
LED_IR = LED_ALL[4:8]
ON = 1
OFF = 0

camera = PiCamera()
camera.rotation = 180
camera.color_effects = (128,128) #b/w
camera.framerate = 30
camera.preview_fullscreen = False
camera.preview_window = (100,20,320,240)

root = Tk()
my_gui = MyFirstGUI(root)

try:
    root.mainloop()
except KeyboardInterrupt:
    GPIO.cleanup()
    camera.close()
