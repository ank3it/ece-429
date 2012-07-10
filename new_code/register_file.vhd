-- register_file.vhd
-- Group: 13

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

entity register_file is
	generic(  
		data_width 		: natural := 32;
		addr_width 		: natural := 5;
		size 			: natural := 32
	);

	port (
		clock 			: in std_logic;
		read_address1	: in std_logic_vector(addr_width - 1 downto 0);
		read_address2	: in std_logic_vector(addr_width - 1 downto 0);
		write_address	: in std_logic_vector(addr_width - 1 downto 0);
		write_enable 	: in std_logic;
		data_in			: in std_logic_vector(data_width - 1 downto 0);
		finish			: in std_logic;
		data_out1 		: out std_logic_vector(data_width - 1 downto 0);
		data_out2		: out std_logic_vector(data_width - 1 downto 0)
	);
end register_file;

architecture main of register_file is        
        type regfile_type is array (0 to size - 1) of std_logic_vector(data_width - 1 downto 0);
        signal regfile : regfile_type ;
        signal abc : std_logic_vector(data_width - 1 downto 0);
        
begin
	-- Read
	data_out1 <= regfile(to_integer(unsigned(read_address1)));
	data_out2 <= regfile(to_integer(unsigned(read_address2)));

	process
		variable my_line : line;  -- type 'line' comes from textio
		variable num: unsigned( 4 downto 0);
		variable load : std_logic := '0';
		variable print : std_logic := '1';
		variable finish2 : std_logic := '1';
	begin	
		if ( load = '0' ) then
		load := '1';
		regfile(0) <=  "00000000000000000000000000000000";
		regfile(1) <=  "00000000000000000000000000000001";
		regfile(2) <=  "00000000000000000000000000000010";
		regfile(3) <=  "00000000000000000000000000000011";
		regfile(4) <=  "00000000000000000000000000000100";
		regfile(5) <=  "00000000000000000000000000000101";
		regfile(6) <=  "00000000000000000000000000000110";
		regfile(7) <=  "00000000000000000000000000000111";
		regfile(8) <=  "00000000000000000000000000001000";
		regfile(9) <=  "00000000000000000000000000001001";
		regfile(10) <=  "00000000000000000000000000001010";
		regfile(11) <=  "00000000000000000000000000001011";
		regfile(12) <=  "00000000000000000000000000001100";
		regfile(13) <=  "00000000000000000000000000001101";
		regfile(14) <=  "00000000000000000000000000001110";
		regfile(15) <=  "00000000000000000000000000001111";
		regfile(16) <=  "00000000000000000000000000010000";
		regfile(17) <=  "00000000000000000000000000010001";
		regfile(18) <=  "00000000000000000000000000010010";
		regfile(19) <=  "00000000000000000000000000010011";
		regfile(20) <=  "00000000000000000000000000010100";
		regfile(21) <=  "00000000000000000000000000010101";
		regfile(22) <=  "00000000000000000000000000010110";
		regfile(23) <=  "00000000000000000000000000010111";
		regfile(24) <=  "00000000000000000000000000011000";
		regfile(25) <=  "00000000000000000000000000011001";
		regfile(26) <=  "00000000000000000000000000011010";
		regfile(27) <=  "00000000000000000000000000011011";
		regfile(28) <=  "00000000000000000000000000011100";
		regfile(29) <=  "00000000000000000000010000011101";
		regfile(30) <=  "00000000000000000000000000011110";
		regfile(31) <=  "00000000000000000000000000011111";
		
		else
			wait until falling_edge(clock);	

			if print = '1' OR (finish = '1' AND finish2 = '1') then
				print := '0';
				
				if finish = '1' then 
					finish2 := '0';
					write( my_line, string'("After Execution:") );
				else
					write( my_line, string'("Before Execution:") );
				end if;
				
				writeline(output, my_line);
				for i in 0 to 31 loop
					write( my_line, string'("$") );
					write( my_line, i );
					write( my_line, string'(" = ") );
					write( my_line , to_integer(signed(regfile(i))) );
					writeline( output, my_line );
				end loop;
			end if;
		
			if write_enable = '1' then
				regfile(to_integer(unsigned(write_address))) <= data_in;
			end if;
		end if;	
	end process;

end main;
