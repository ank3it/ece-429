LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.textio.all;

package fileio_pkg is

	-- Read single line from given file and return result as a string
	procedure read_line(file infile : text; result_string : out string);

end package fileio_pkg;

package body fileio_pkg is

	---------------------------- read_line() -----------------------------
	-- infile : file pointer to the file where the line is being read from
	-- result_string : the string in which the line will be returned
	procedure read_line(file infile: text; result_string : out string) is
		variable line_buffer	: line;
		variable char			: character;
		variable is_string		: boolean;
	begin
		-- Read a line into buffer
		readline(infile, line_buffer);

		-- Clear result string
		for i in result_string'range loop
			result_string(i) := ' ';
		end loop;

		-- Copy line contents from buffer to result string
		for i in result_string'range loop
			read(line_buffer, char, is_string);
			result_string(i) := char;

			-- Exit if end of file is detected
			if not is_string then
				exit;
			end if;
		end loop;
	end procedure read_line;
end package body fileio_pkg;
