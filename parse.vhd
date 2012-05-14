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
	signal data		: std_logic_vector(123 downto 0);
	signal write	: std_logic;
	signal dataOut	: std_logic_vector(123 downto 0);
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
		variable i			: integer;
	begin
		while not endfile(infile) loop
			readline(infile, line_buffer);

			for i in line_length - 1 downto 0 loop
				read(line_buffer, char, is_string);

				-- End of line detected
				if not is_string then
					exit;
				end if;

				-- Logic for parsing SREC file here
			end loop;

		end loop;
		wait for 10 ns;
	end process;
end main;
