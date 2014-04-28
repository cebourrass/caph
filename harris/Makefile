# PLATFORM DEPENDANT VALUES
include ../../../Makefile.config

CAPH= caph
TXT2BIN=../../../bin/$(_TXT2BIN)
BIN2TXT=../../../bin/$(_BIN2TXT)
PGM2BIN=../../../bin/$(_PGM2BIN)
BIN2PGM=../../../bin/$(_BIN2PGM)

SYNTH_DIR = ../../../utils/synthesis/altera


test: sim systemc vhdl

# SYSTEMC SPECIFIC MACROS
CXXFLAGS    = -I. -I../../../lib/systemc -I$(SC_DIR)/include -Wno-deprecated
LDFLAGS	    =  -L../../../lib/systemc -L$(SC_DIR)/lib-$(TARGET_ARCH) 

SC_GEN_HEADERS 	= local_filter_act.h dythr_act.h histsort_act.h cornerness_act.h square_act.h mult_act.h norm_act.h d_act.h abs_act.h dl_act.h maddn_act.h harris_globals.h
SC_GEN_SOURCES 	= ./systemc/local_filter_act.cpp \
		  ./systemc/dythr_act.cpp	\
		  ./systemc/histsort_act.cpp	\
		  ./systemc/cornerness_act.cpp	\
		  ./systemc/square_act.cpp	\
		  ./systemc/mult_act.cpp	\
		  ./systemc/norm_act.cpp	\
		  ./systemc/d_act.cpp 		\
		  ./systemc/abs_act.cpp		\
		  ./systemc/dl_act.cpp 		\
		  ./systemc/maddn_act.cpp 	\
		  ./systemc/thr_act.cpp 	\
		  ./systemc/harris_net.cpp	\
		  ./systemc/harris_globals.cpp
SC_GEN_OBJS    	= $(SC_GEN_SOURCES:.cpp=.o)
SC_EXE	   		= sc.exe
SC_OPTS			= -sc_default_fifo_capacity 256000 -sc_target_dir systemc
# VHDL SPECIFIC MACROS

GHDLOPTS 	= -P../../../lib/vhdl --ieee=synopsys -fexplicit

VHDL_GEN_SOURCES = histof_act.vhd cornerness_act.vhd harris_globals.vhd mult_act.vhd square_act.vhd d_act.vhd dl_act.vhd maddn_act.vhd thr_act.vhd abs_act.vhd  harris_net.vhd conv_tb.vhd
CAPH_OPTS= -dump_tenv -dump_typed -type_wires -phantom_types -dump_senv
TARGET_DIR_VHDL= ./vhdl/


# DOT and SIMULATION

dot: harris.cph
	$(CAPH) -fmt  dot harris.cph
	$(GRAPHVIZ) harris.dot

sim: harris.cph
	$(CAPH) -run $(CAPH_OPTS) -chan_cap 512000  harris.cph

# SYSTEMC

systemc.code: harris.cph
	$(CAPH) -fmt systemc -sc_stop_time 5000000 -sc_dump_fifo_stats $(SC_OPTS) harris.cph


systemc.exe: $(SC_EXE)

$(SC_EXE): $(SC_GEN_OBJS)
	$(SC_LD) $(LDFLAGS) $(SC_GEN_OBJS) -o $(SC_EXE) -lsystemc  2>&1 | c++filt

systemc.run: $(SC_EXE)
	./$(SC_EXE)

systemc: systemc.run

# VHDL

vhdl.code: harris.cph
	$(CAPH) -fmt vhdl -vhdl_use_native_mul -vhdl_annot_file harris_fifo_stats.dat -vhdl_target_dir $(TARGET_DIR_VHDL) harris.cph

vhdl.elab: #vhdl.code
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)harris_globals.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)cornerness_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)local_filter_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)histsort_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)mult_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)square_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)norm_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)d_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)dl_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)dythr_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)thr_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)abs_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)maddn_act.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)harris_net.vhd
	$(GHDL) -a $(GHDLOPTS) $(TARGET_DIR_VHDL)harris_tb.vhd
	$(GHDL) -e $(GHDLOPTS) harris_tb

vhdl.run: vhdl.elab sample.bin
	$(GHDL) -r $(GHDLOPTS) harris_tb --stop-time=6ms
	$(BIN2PGM) 34 result.bin result.pgm

vhdl: vhdl.code vhdl.elab vhdl.run

vhdl.view: harris_tb.vcd
	$(GTKWAVE) harris_tb.vcd -a harris_tb.sav

sample.bin: sample.pgm
	$(PGM2BIN) 34 sample.pgm > sample.bin

syn:
	sh compile.sh $(SYNTH_DIR)
	#ocamlc -o synthesis unix.cma synthesis.ml

# GENERIC RULES

.cpp.o:
	$(SC_CXX) $(CXXFLAGS) -c -o $@ $<


clean :
	-rm -f *.o *~ *_old $(SC_EXE)
	-rm -f a.out
	-rm -f core
	-rm -f *.vcd
	-rm -f *.dot
	-rm -f doc/*.log doc/*.dvi doc/*.rel doc/*.aux
	-rm -f work-obj93.cf
	-rm -f synthesis *.txt

clobber: clean
	-rm -f $(SC_GEN_SOURCES) $(SC_GEN_HEADERS)
	-rm -f $(VHDL_GEN_SOURCES)
	-rm -f result.txt result_*.pgm 
	-rm -f doc/*.pdf 
	-rm -f *.h *.cpp *.vhd
	-rm -f *.pgm *.dat *.bin

d_act.o: d_act.cpp
dl_act.o: dl_act.cpp
maddn_act.o: maddn_act.cpp
harris_globals.o: harris_globals.cpp
harris_net.o: harris_net.cpp
d_act.cpp: systemc.code
