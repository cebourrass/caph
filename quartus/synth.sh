#!/bin/bash

	ls -d -1 `pwd`/*.vhd > filelist.txt # create vhdl file list 
        sed 's/./set_global_assignment -name VHDL_FILE  &/' filelist.txt > vhdlfile.txt # Quartus Tcl script creation
        sed '53 r vhdlfile.txt' ./quartus/script.tcl > ./quartus/hog.tcl                # with inserting vhdl file list in the project
        rm  filelist.txt vhdlfile.txt
	TEST=$(grep -c "component Magic_FIFO" hog_net.vhd)

	if [ "$TEST" = "0" ]; then
        LIGNE=$(grep -n "architecture" hog_net.vhd | cut -f 1 -d ":") #search architecture line in toplevel
	VAL=$((LIGNE+1))
	sed -i "$VAL r ./quartus/fifo.txt" hog_net.vhd #insert component declaration
	sed -i '3d' hog_net.vhd 
	fi
	

