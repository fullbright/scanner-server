#!/bin/bash

## Put your sane-detected device name here.
#DEVICE="snapscan"
## For network scanners use
#DEVICE="net:sane.example.org:snapscan"
#DEVICE='brother4:net1;dev0'
DEVICE="hpaio:/net/officejet_4500_g510g-m?ip=192.168.1.25&queue=false"

## See scanimage --device $(DEVICE) --help
SOURCES[0]="FlatBed"
SOURCES[1]="Automatic Document Feeder(left aligned)"
SOURCES[2]="Automatic Document Feeder(left aligned,Duplex)"
SOURCES[3]="Automatic Document Feeder(centrally aligned)"
SOURCES[4]="Automatic Document Feeder(centrally aligned,Duplex)"
SOURCES[5]="ADF"
SOURCE=${SOURCES[3]} # Default

RESOLUTIONS=(100 150 200 300 400 600 1200 2400 4800 9600)
RESOLUTION=150	# Default

MODES[0]="Black & White"
MODES[1]="Gray[Error Diffusion]"
MODES[2]="True Gray"
MODES[3]="24bit Color"
MODES[4]="24bit Color[Fast]"
MODES[5]="Gray"
MODE=${MODES[2]}	# Default

DEST=temp/dest

# Import the functions
. ./scan_functions.sh --source-only

# Start the interactive scan
interactive_scan

# End of script
