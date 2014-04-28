
PROJECT=hog.qpf
SDC_FILE= hog.sdc
TOP_LEVEL_VHD=../hog_net.vhd
all: project map fit sta 

project:
	./sdc.pl -i $(TOP_LEVEL_VHD) -o i$(SDC_FILE) -period 20 -input_min_delay 0.2 -output_min_delay 0.2 -input_max_delay 0.5 -output_max_delay 0.5
	quartus_sh -t hog.tcl
map:
	quartus_map $(PROJECT)
fit:
	quartus_fit $(PROJECT)
sta:
	quartus_sta -sdc $(SDC_FILE) $(PROJECT)

.PHONY:clean
clean:
	rm -rf db
	rm -rf incremental_db
	rm hog.fit.*
	rm hog.map.*
	rm hog.sta.*
	rm hog.pin
	rm hog.qws
	rm hog.flow.rpt
	rm hog.asm.rpt
	rm hog.eda.rpt
	rm hog.jdi
	rm hog.sof
