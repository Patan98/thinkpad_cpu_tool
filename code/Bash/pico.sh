#!/bin/bash

#IMPOSTAZIONI SINTETIZZATORE VOCALE

pico2wave -l=it-IT -w=/tmp/test.wav "$1"
aplay /tmp/test.wav
rm /tmp/test.wav
