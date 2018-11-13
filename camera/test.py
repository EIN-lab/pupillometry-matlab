import RPi.GPIO as GPIO
import time as time

GPIO.setmode(GPIO.BOARD)
GPIO.setup(40, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)


GPIO.add_event_detect(40, GPIO.RISING)  # add rising edge detection on a channel

time.sleep(10) #wait for second RPi to be ready

start = time.time()

while True:

    if GPIO.event_detected(40):

        print('Button 1 pressed')

    if time.time() - start > 30:

        print('Timeout')
	break

    time.sleep(0.1)
