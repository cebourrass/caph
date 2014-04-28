LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY single_clock_ram IS
 generic ( depth: integer := 50; size: integer := 10);
	PORT (
	clock: IN STD_LOGIC;
	data: IN STD_LOGIC_VECTOR (size-1 DOWNTO 0);
	write_address: IN INTEGER RANGE 0 to depth;
	read_address: IN INTEGER RANGE 0 to depth;
	we: IN STD_LOGIC;
	q: OUT STD_LOGIC_VECTOR (size-1 DOWNTO 0)
	);
END single_clock_ram;

ARCHITECTURE rtl OF single_clock_ram IS
	TYPE MEM IS ARRAY(0 TO depth) OF STD_LOGIC_VECTOR(size-1 DOWNTO 0);
	shared variable ram_block: MEM;
	shared variable read_address_tmp: INTEGER RANGE 0 to depth;
	BEGIN
		PROCESS (clock)
		BEGIN
			IF (clock'event AND clock = '1') THEN
				IF (we = '1') THEN
				ram_block(write_address) := data;
				END IF;

				-- VHDL semantics imply that q doesn't get data
				-- in this clock cycle
				END IF;
			read_address_tmp := (read_address);
		END PROCESS;
		q <= ram_block(read_address_tmp);
END rtl;