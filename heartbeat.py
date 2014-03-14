import socket, time
import subprocess

while True:
    address = "node-00"
    res = subprocess.call(['ping', '-c', '3', address])
    if res == 0:
        print "ping to", address, "OK"
    elif res == 2:
        print "no response from", address
    else:
        print "ping to", address, "failed!"
    time.sleep(60)

