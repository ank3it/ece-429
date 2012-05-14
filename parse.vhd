-- TODO:
-- [ ] Add parsing logic
-- [ ] Add proper wait until/for
-- [ ] Add memory interface code
-- [ ] Test!
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity parse is
	generic (
		filename	: string := "file.txt";
		line_length	: natural := 50
	);

	port (
		i_clock		: in std_logic
	);
end parse;

architecture main of parse is
	signal address	: std_logic_vector(123 downto 0);
	signal data	: std_logic_vector(123 downto 0);
	signal write	: std_logic;
	signal dataOut	: std_logic_vector(123 downto 0);
	signal iter	: integer := 0;
	signal data_length : unsigned(7 downto 0) := x"00";
	signal dataword	   : unsigned(31 downto 0) := x"00000000";
	signal addressword : unsigned(31 downto 0) := x"00000000";
	signal currChar	   : unsigned(7 downto 0) := x"00";
begin

	-- Memory component instantiation
	mem : entity work.Memory(memory_main)
		port map (
			ActualAddress => address,
			data => data,
			clock => i_clock,
			write => write,
			dataOut => dataOut
		);

	parseSREC : process
		file infile			: text open read_mode is filename;
		variable line_buffer: line;
		variable char		: character;
		variable is_string	: boolean;
		variable i		: integer;
	begin
		while not endfile(infile) loop
			readline(infile, line_buffer);
			
			iter <= 0;
			data_length <= x"00";
			dataword <= x"00000000";
			addressword <= x"00000000";
			
			for i in line_length - 1 downto 0 loop
				read(line_buffer, char, is_string);
				
				iter <= iter + 1;
				currChar <= to_unsigned(character'pos(char),8);
	  			currChar <= to_unsigned(to_integer(currChar) - 48, 8);			
				
				-- End of line detected
				if not is_string then
					exit;
				end if;

				-- Logic for parsing SREC file here
				if iter < 3 then -- skipping first 2 characters
				    					
				elsif iter < 5 then -- getting data length
				    data_length <= to_unsigned(to_integer(data_length) * 16, 8);
	                	    data_length <= to_unsigned(to_integer(data_length) + to_integer(currChar), 8);	
				else 
	
				end if;
			end loop;

		end loop;
		wait for 10 ns;
	end process;
end main;
