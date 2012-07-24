library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

-- The clock process has been based on the testbench code given in ECE 327 by Prof. Mark Aagaard
-- This file has both parsing and testBench code
entity load is
			generic(  
                  filename        : string := "BubbleSort.srec";
                  line_length     : natural := 50
                  );
                  
      port (
                clk : in std_logic;
                address : out std_logic_vector(31 downto 0);
                data    : out std_logic_vector(31 downto 0);
                writeReady : out std_logic;
                reset : out std_logic              
        );
        
end load;

architecture main of load is
   begin
    ----------------------------------------------------
    --reset, parsing and output to std_out
    load:process
				file infile                	: text open read_mode is filename;
                variable line_buffer		: line;
                variable char123           	: character;
                variable is_string      	: boolean;
                variable i              	: integer;
                variable my_line 			: line;  -- type 'line' comes from textio
                variable iter 				: integer;
                variable currChar    		: unsigned(7 downto 0) := x"00";
                variable data_length 		: unsigned(7 downto 0) := x"00";
                variable dataword    		: unsigned(31 downto 0) := x"00000000";
                variable addressword 		: unsigned(31 downto 0) := x"00000000";
                variable addressBits 		: integer := 0;
                variable dataBits   		: integer := 0;
                variable counter 			: integer;
        begin

          reset <= '1';
                readline(infile, line_buffer);
                counter := 0;
                while not endfile(infile) loop
                        readline(infile, line_buffer);
                        iter := 0;
                        data_length := x"00";
                        dataword := x"00000000";
                        addressword := x"00000000";
                       
                        for i in line_length - 1 downto 0 loop
                                read(line_buffer, char123, is_string);
                                iter := iter + 1;
                                if iter = 1 then -- skipping first character 'S'
                                  next;
                                end if;
                                 case char123 is
                                        when '0' => currChar := x"00";
                                        when '1' => currChar := x"01";
                                        when '2' => currChar := x"02";
                                        when '3' => currChar := x"03";
                                        when '4' => currChar := x"04";
                                        when '5' => currChar := x"05";
                                        when '6' => currChar := x"06";
                                        when '7' => currChar := x"07";
                                        when '8' => currChar := x"08";
                                        when '9' => currChar := x"09";
                                        when 'A' => currChar := x"0A";
                                        when 'B' => currChar := x"0B";
                                        when 'C' => currChar := x"0C";
                                        when 'D' => currChar := x"0D";
                                        when 'E' => currChar := x"0E";
                                        when 'F' => currChar := x"0F";
                                        when others => currChar := x"00";
                                end case;
                                if not is_string then
                                        exit;
                                end if;

                                -- Logic for parsing SREC file here
                                if iter = 2 then -- record type -> determines address characters in the line.
                                        case currChar is
                                         when "00000000" => addressBits := 4;
                                         when "00000001" => addressBits := 4;
                                         when "00000101" => addressBits := 4;
                                         when "00001001" => addressBits := 4;
                                         when "00000010" => addressBits := 6;
                                         when "00001000" => addressBits := 6;
                                         when "00000011" => addressBits := 8;
                                         when "00000111" => addressBits := 8;
                                         when others => addressBits := 8;
                                        end case;
                                elsif iter < 5 then -- getting data length
                                    data_length := data_length sll 4;
                                    data_length := data_length + (currChar);                                                                                       
                                    if iter = 4 then
                                        data_length := to_unsigned(to_integer(data_length)*2 - 2 - addressBits, 8); -- datalength = addressBits - checksumBits
                                    end if;
       
                                elsif iter < (5 + addressBits) then -- getting address
                                    databits := 0;
                                    addressword := addressword sll 4;
                                    addressword := addressword + (currChar);                       
       
                                elsif iter < (5 + addressBits + data_length) then -- getting data
                                    dataBits := dataBits + 1;
                                    dataword := dataword sll 4;
                                    dataword := ((dataword) + (currChar));
                                    
                                    if dataBits = 8 then
                                        dataBits := 0;
                                        writeReady <= '1';
                                        data <= std_logic_vector(dataword);
                                        address <= std_logic_vector(addressword);
                                        addressword := addressword + 4;
                                        counter := counter + 1;
                                        wait until rising_edge(clk);
                                        writeReady <= '0';
                                    end if;

                                end if;

                        end loop;
                end loop;
                reset <= '0';
      wait;
    end process;
end main;






