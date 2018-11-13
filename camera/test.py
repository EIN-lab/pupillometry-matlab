import RPi.GPIO as GPIO
import time as time

GPIO.setmode(GPIO.BOARD)
GPIO.setup(40, GPIO.IN, pull_up_down=GPIO.PUD_UP)

time.sleep(10) #wait for second RPi to be ready
print('Armed')

start = time.time()

while True:

    GPIO.wait_for_edge(40, GPIO.FALLING) #workaround for messy edge detection
    time.sleep(0.005) #debounce 5ms
    if GPIO.input(40) == 0:
        print('Button pressed!')

    if time.time() - start > 30:

        print('Timeout')
	break

    time.sleep(0.1)
