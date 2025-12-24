#!/bin/bash
# Get the current utun interface name
utun=$(ifconfig | grep utun | grep 1500 | cut -d : -f1 | tail -1)

# Routes will be appended below by the scripts...