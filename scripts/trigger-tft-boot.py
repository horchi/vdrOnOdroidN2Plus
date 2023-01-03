#!/usr/bin/python3

import Odroid.GPIO as GPIO
import time, os
import sys, subprocess

def pingCheck(host):
	command = ['ping', '-c 1', '-q', '-W 1', host]
	p = subprocess.run(command, capture_output=True)

	if p.returncode == 0:
		return True
	else:
		return False

if len(sys.argv) < 2:
	print("Missing argument <host>")
	sys.exit()

rpi = 3
host = sys.argv[1]
running = pingCheck(host)

# print('host: ', host, ' running: ', running)

if running:
	print(host, "already running")
	sys.exit()

print("trigger boot of", host)

GPIO.setmode(GPIO.BOARD)
GPIO.setup(rpi, GPIO.OUT)

GPIO.output(rpi, GPIO.HIGH)
time.sleep(0.2)
GPIO.output(rpi, GPIO.LOW)
time.sleep(0.2)
GPIO.output(rpi, GPIO.HIGH)
