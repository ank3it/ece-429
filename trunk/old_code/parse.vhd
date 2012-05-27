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
	signal addressBits : integer := 0;
	signal dataBits   : integer := 0;
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
				
				--currC <= to_unsigned(character'pos(char),8);
	  			case char is
					when '0' => currChar <= x"00";
					when '1' => currChar <= x"01";
					when '2' => currChar <= x"02";
					when '3' => currChar <= x"03";
					when '4' => currChar <= x"04";
					when '5' => currChar <= x"05";
					when '6' => currChar <= x"06";
					when '7' => currChar <= x"07";
					when '8' => currChar <= x"08";
					when '9' => currChar <= x"09";
					when 'A' => currChar <= x"0A";
					when 'B' => currChar <= x"0B";
					when 'C' => currChar <= x"0C";
					when 'D' => currChar <= x"0D";
					when 'E' => currChar <= x"0E";
					when 'F' => currChar <= x"0F";
					when others => currChar <= x"00";
				end case;
				
				--currChar <= to_unsigned(to_integer(currC) - 48, 8); -- subtacting by 48 to convert into number			
				
				wait until rising_edge(i_clock);				
				
				iter <= iter + 1;
				-- End of line detected
				if not is_string then
					exit;
				end if;
				
				-- Logic for parsing SREC file here
				if iter = 1 then -- skipping first character 'S' 
				
				elsif iter = 2 then -- record type -> determines address characters in the line.
					case currChar is
					 when "00000000" => addressBits <= 4; 
					 when "00000001" => addressBits <= 4;
					 when "00000101" => addressBits <= 4;
					 when "00001001" => addressBits <= 4;
					 when "00000010" => addressBits <= 6;
					 when "00001000" => addressBits <= 6;
					 when "00000011" => addressBits <= 8;
					 when "00000111" => addressBits <= 8;
					 when others => addressBits <= 8;
					end case;  			
		
				elsif iter < 5 then -- getting data length
				    if iter = 4 then
					data_length <= to_unsigned((to_integer(data_length)*16) + to_integer(currChar) - 2 - addressBits, 8); 
					-- datalength = addressBits - checksumBits
				    else
					data_length <= to_unsigned((to_integer(data_length)*16) + to_integer(currChar), 8);	
				    end if;
	
				elsif iter < (5 + addressBits) then -- getting address 
				    addressword <= to_unsigned((to_integer(addressword) * 16) + to_integer(currChar), 32);
				    --addressword <= to_unsigned(to_integer(addressword) + to_integer(currChar), 32);	     	
				    
			            if iter = (4 + addressBits) then
					-- 32-BIT ADDRESS DATA IS READY IN SIGNAL "addressword"
				    end if;		
	
				elsif iter < (5 + addressBits + data_length) then -- getting data 
				    dataword <= to_unsigned((to_integer(dataword) * 16) + to_integer(currChar), 32);
                                    --dataword <= to_unsigned(to_integer(dataword) + to_integer(currChar), 32);
	
				    if dataBits = 77777777777777777777777777777777777777777777777777777777777777777777777777777 then
					dataBits <= 0;
					-- new 32-BIT DATA IS READY IN SIGNAL "dataword"
					-- ""reset dataword here!!""
					--   =====================
				    else
					dataBits <= dataBits + 1;
				    end if;

				end if;
				--wait until rising_edge(i_clock);
			end loop;
		end loop;
		wait for 10 ns;
	end process;
end main;
