VHDL_GEN_SOURCES = hog_types.vhd hog_globals.vhd hog_tb.vhd conv2s33a_16_act.vhd sqrt_16_act.vhd opp_16_act.vhd abs_16_act.vhd abs_9_act.vhd sum2u88_act.vhd psumb_act.vhd fsum_act.vhd norm32_act.vhd e1block_act.vhd sum32_act.vhd resizing_act.vhd cordic_act.vhd shifting_act.vhd hog_net.vhd
INPUT_STREAMS = sample.txt
OUTPUT_STREAMS = val.txt

vhdl.elab:
	$(GHDL) -a $(GHDL_ELAB_OPTS) hog_types.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) hog_globals.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) hog_tb.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) conv2s33a_16_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) sqrt_16_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) opp_16_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) abs_16_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) abs_9_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) sum2u88_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) psumb_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) fsum_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) norm32_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) e1block_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) sum32_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) resizing_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) cordic_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) shifting_act.vhd
	$(GHDL) -a $(GHDL_ELAB_OPTS) hog_net.vhd
	$(GHDL) -e $(GHDL_ELAB_OPTS) hog_tb
