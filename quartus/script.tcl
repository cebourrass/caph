# Load Quartus II Tcl Project package
package require ::quartus::project
package require ::quartus::flow

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "hog"]} {
		puts "Project hog is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists hog]} {
		project_open -revision hog hog
	} else {
		project_new -revision hog hog
	}
	set need_to_close_project 1
}


remove_all_global_assignments -name *
remove_all_parameters -name *
remove_all_instance_assignments -name *_REQUIREMENT

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone III"
	set_global_assignment -name DEVICE EP3C120F780C7
	set_global_assignment -name TOP_LEVEL_ENTITY hog_net
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 12.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "11:58:39  JULY 01, 2013"
	set_global_assignment -name LAST_QUARTUS_VERSION 12.0
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name SEARCH_PATH "/home/cedric/Documents/caph/v2/dist/caph-unix/lib/vhdl/caph.vhd"
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name USE_TIMEQUEST_TIMING_ANALYZER ON 
	set_global_assignment -name SDC_FILE hog.sdc

	#options de synthese
	set_global_assignment -name DSP_BLOCK_BALANCING "DSP BLOCKS" 
	set_global_assignment -name AUTO_RAM_RECOGNITION OFF
	set_global_assignment -name ALLOW_ANY_RAM_SIZE_FOR_RECOGNITION ON

	# VHDL_FILE automatically inserted by bash script quartus_project_file 

	# Add Caph library File 
	set_global_assignment -name VHDL_FILE /home/cedric/Documents/caph/v2/dist/caph-unix/lib/vhdl/caph.vhd
	set_global_assignment -name VHDL_FILE /home/cedric/Documents/caph/v2/dist/caph-unix/lib/vhdl/Magic_FIFO.vhd
	set_global_assignment -name VHDL_FILE /home/cedric/Documents/caph/v2/dist/caph-unix/lib/vhdl/single_clock_ram.vhd
	set_global_assignment -name VHDL_FILE /home/cedric/Documents/caph/v2/dist/caph-unix/lib/vhdl/split.vhd
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top


	# Commit assignments
	export_assignments

  	if {$need_to_close_project} {
	    project_close
  }
}
