-- This file is part of the CAPH Compiler distribution
-- http://wwwlasmea.univ-bpclermont.fr/Personnel/Jocelyn.Serot/caph.html
-- (C) F.Berry  2013 (Francois.Berry@univ-bpclermont.fr)


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Magic_FIFO is
generic
   (
       depth    : integer  :=        50;    -- Donne la profondeur de la FIFO = depth - 1
       size     : integer  :=        10;   -- Specifie la taille des cases de la FIFO
       DEPT_TH  : integer  :=        1   -- Specifie le seuil RAM/LE
   );

 port (
         full : out std_logic;
         datain : in std_logic_vector (size-1 downto 0);
         enw : in std_logic;
         empty : out std_logic;
         dataout : out std_logic_vector(size-1 downto 0);
         enr : in std_logic;
         clk : in std_logic;
         rst: in std_logic
         );
end Magic_FIFO;


architecture archi of Magic_FIFO is
 constant ad_Max : integer := depth;
 constant ad_Min : integer := 0;
 
 type fifo_length is array ( 0 to depth) of std_logic_vector((size-1) downto 0);
 signal tmp: fifo_length ;

 signal address: integer range 0 to depth := ad_Max;



  signal we_a,enr_c,enw_c:std_logic;
  signal readaddr : natural range 0 to depth;
  signal writeaddr : natural range 0 to depth;

--shared variable readaddr,writeaddr : integer  :=0; 
signal cnt, cnt_c : integer  :=0;
signal inputD,outputD,inputR,outputR: STD_LOGIC_VECTOR (size-1 DOWNTO 0); 


 -- instancie une mem
component single_clock_ram is
 generic ( depth: integer := 10; size: integer := 10);
	PORT (
	clock: IN STD_LOGIC;
	data: IN STD_LOGIC_VECTOR (size-1 DOWNTO 0);
	write_address: IN INTEGER RANGE 0 to depth;
	read_address: IN INTEGER RANGE 0 to depth;
	we: IN STD_LOGIC;
	q: OUT STD_LOGIC_VECTOR (size-1 DOWNTO 0)
	);
end component;

 begin

----------------------------------------------
--  Construct Small FIFO
----------------------------------------------


Small_Fifo: if depth<DEPT_TH generate


-- Shift register generation
   shift_reg: process (clk)
     begin

  if (clk'event and clk='1' ) then

       if (enr='1' and enw='0') then
         for i in 0 to (depth-1) loop
           tmp(i+1) <= tmp(i);
         end loop;
       end if;

       if (enw='1' and enr='1') then
			if (address = ad_Max)  then
				tmp(address-1)<=datain;
			else
			   for i in 0 to (depth-1) loop
				   tmp(i+1) <= tmp(i);
				end loop;
       tmp(address)<=datain;	
			 end if;
       end if;


       if (enw='1' and enr='0') then
       tmp(address-1)<=datain;
       end if;

   end if;
   end process shift_reg;


-- Compteur permettant de fixer la position de lecture et d'ecriture
   counter : process(clk, rst)

   begin
    if ( rst='0' ) then  
       address <= ad_Max;
     elsif (clk='1' and clk'event) then

       -- Lecture simple
       -- on lit une nouvelle donnée dans la FIFO quand il y a encore
       -- on lit une nouvelle donnée dans la FIFO et l' on fait une lecture simultanée donc on n'incrémente pas
       -- ce qui correspond à wr='0'

           if (enr = '1' and enw='0' and address < ad_Max) then -- On peut alors lire et on "mange une case"
               address <= address + 1;
           end if;

       -- Ecriture simple
       -- on écrit dans une nouvelle case de la FIFO quand il y a de la place.
       -- on écrit dans la case courante de la FIFO s'il on fait une lecture simultanée donc on ne décrémente pas
       -- ce qui correspond à rd='0'
           if (enw = '1' and enr='0' and address > ad_Min) then
               address <= address - 1;
           end if;
 
       -- Ecriture et lecture simultan�e
           
            if (enw = '1' and enr='1' and address= ad_Max) then
               address <= address;
           end if;

     end if;
   end process counter;

-- Test des flags
   test_flag : process(address,enw,enr)
   begin
      -- Gestion du Flag EMPTY
      -- Il passe à 1 quand on essaie de lire dans la fifo sans y écrire
      -- et qu'il ne reste plus qu'une donnée donc l'address > max -2

--        if ( enr='1' and address > (ad_Max-2) ) then
        if (  address > (ad_Max-1) ) then
           empty<= '1';
         else
           empty <='0';
         end if;

      -- Gestion du Flag FULL
      -- Il passe à 1 quand on essaie d'écrire dans la fifo sans la lire
      -- et qu'il ne reste plus qu'une place donc l'address < 2

--        if (enw = '1' and address < (ad_Min+2) ) then
        if ( address < (ad_Min+1) ) then
           full<= '1';
         else
           full <='0';
         end if;

   end process test_flag;

   dataout <= tmp(depth-1);

	end generate;

----------------------------------------------
--  Construct Big FIFO
----------------------------------------------


Big_FIFO: 
	if depth>=DEPT_TH generate


MEM :single_clock_ram generic map (depth,size) port map (clk,inputR,writeaddr, readaddr, enw, outputR );
 
-- Gestion de l'address

	process(clk)
	begin
	if ( clk'event and clk='1' ) then
	enw_c<=enw;
	enr_c<=enr;
	cnt_c<=cnt;
	end if;
	end process ;

-- Bypass when the FIFO is empty and we write and read simulaneoulsy

	MUX: process(datain, outputD,outputR,enw_c,enr_c,cnt_c)
	begin
	
	if (cnt_c=0 and enr_c='1' and enw_c='1') then
		inputD<= datain;
		inputR<= (others => 'X');
		dataout<= outputD;
	else
		inputR<= datain;
		inputD<= (others => 'X');
		dataout<= outputR;
	end if;

	end process MUX;


-- Flag Empty/full management		
Flag: process(cnt)
	begin
	if (  cnt  = 0 ) then empty <= '1'; else empty <='0'; end if;
	if ( cnt = depth ) then full<= '1'; else full <='0';end if;
	end process Flag;

	
-- process(clk,rst)
--  begin
--    if ( rst='0' ) then         
--      readaddr := 0;
--      writeaddr := 0;
--      cnt <= 0;
--      
--    elsif ( clk'event and clk='1' ) then 
--	 
--	 outputD<= inputD;
--	 
--      -- Read
--      if ( enr = '1'  ) then
--        if ( readaddr = depth-1 ) then
--          readaddr :=  0; -- circular buffer
--        else
--          readaddr := readaddr + 1; 
--        end if; 
--      end if;
--
--      -- Write
--      if( enw = '1' and cnt < depth ) then   
--        if ( writeaddr = depth-1 ) then
--          writeaddr :=  0; -- circular buffer
--        else
--          writeaddr := writeaddr + 1;   
--        end if;
--      end if;
--
--		  
--      -- internal counter for Flag manegment
--      if ( enw = '1' and enr = '0' and cnt < depth ) then
--        cnt <= cnt + 1;
--      elsif ( enw = '0' and enr = '1' and cnt > 0) then
--        cnt <= cnt - 1;
--      end if;
--		
--    end if;
--		
--end process;



 process(clk,rst)
  begin
    if ( rst='0' ) then         
      readaddr <= 0;
      writeaddr <= 0;
      cnt <= 0;
      
    elsif ( clk'event and clk='1' ) then 
	 
	 outputD<= inputD;
	 
      -- Read
      if ( enr = '1'  ) then
        if ( readaddr = depth-1 ) then
          readaddr <=  0; -- circular buffer
        else
          readaddr <= readaddr + 1; 
        end if; 
      end if;

      -- Write
      if( enw = '1' and cnt < depth ) then   
        if ( writeaddr = depth-1 ) then
          writeaddr <=  0; -- circular buffer
        else
          writeaddr <= writeaddr + 1;   
        end if;
      end if;

		  
      -- internal counter for Flag manegment
      if ( enw = '1' and enr = '0' and cnt < depth ) then
        cnt <= cnt + 1;
      elsif ( enw = '0' and enr = '1' and cnt > 0) then
        cnt <= cnt - 1;
      end if;
		
    end if;
		
end process;









	end generate;

end archi;
