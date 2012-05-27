

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

-- The clock process has been based on the testbench code given in ECE 327 by Prof. Mark Aagaard
-- This file has both parsing and testBench code
entity tb is
			generic(  
                  filename        : string := "file.txt";
                  line_length     : natural := 50
                  );
end tb;

architecture main of tb is
        signal address  	: std_logic_vector(31 downto 0);
        signal data     	: std_logic_vector(31 downto 0);
        signal writeReady   : std_logic;
        signal dataOut  	: std_logic_vector(31 downto 0);
  
        constant period  	: time := 2000 ms;
  
        signal clock 		: std_logic;
        signal reset 		:  std_logic;
   begin

   mem : entity work.Memory(memory_main)
      port map (
			ActualAddress => address,
			data => data,
			clock => clock,
			writeEnable => writeReady,
			dataOut => dataOut
        );
    ----------------------------------------------------
    --reset, parsing and output to std_out
    process
      
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
                        --writeline(output,line_buffer);
                        iter := 0;
                        
                        data_length := x"00";
                        dataword := x"00000000";
                        addressword := x"00000000";
                       
                        for i in line_length - 1 downto 0 loop
                                read(line_buffer, char123, is_string);
                                --read(line_buffer,char123,end_of_line);
                                --write(my_line, string'(" Char Reading "));
                                --write(my_line, char123);
                                --writeline(output,my_line);
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
                               --write(my_line, string'(" Curr Char "));
                               --write(my_line, to_integer(currChar));
                               --writeline(output,my_line);
                                -- End of line detected
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
									--write(my_line, string'(" Print addressBits = ")); 
									-- write(my_line, (addressBits));    
                                    --writeline(output, my_line);                              
               
                                elsif iter < 5 then -- getting data length
                                    data_length := data_length sll 4;
                                    data_length := data_length + (currChar);    
                                                                                                                       -- -6 = -4(address) - 2(checksum)   
                                    --write(my_line, string'(" Print data Length = ")); 
                                    --write(my_line, to_integer(data_length));    
                                    --writeline(output, my_line);                                                                                     
                                    if iter = 4 then
                                        data_length := to_unsigned(to_integer(data_length)*2 - 2 - addressBits, 8); -- datalength = addressBits - checksumBits
                                        --write(my_line, string'(" Print data Length = ")); 
                                        --write(my_line, to_integer(data_length));    
                                        --writeline(output, my_line); 
                                    end if;
       
                                elsif iter < (5 + addressBits) then -- getting address
                                    databits := 0;
                                    addressword := addressword sll 4;
                                    addressword := addressword + (currChar);            
                                   
									--addressword := to_unsigned(addressword(31 downto 4) & currChar(3 downto 0));
                                    --if iter = (4 + addressBits) then
                                      --write(my_line, string'(" Print addressword = ")); 
                                      --hwrite(my_line, std_logic_vector(addressword));
                                      --writeline(output, my_line); 
                                        -- 32-BIT ADDRESS DATA IS READY IN SIGNAL "addressword"
                                    --end if;            
       
                                elsif iter < (5 + addressBits + data_length) then -- getting data
                                    dataBits := dataBits + 1;
               
                                    dataword := dataword sll 4;
                                    dataword := ((dataword) + (currChar));
                                    
                                    --write(my_line, string'(" Print dataword = ")); 
                                    --write(my_line, to_integer(dataword));
                                    --writeline(output, my_line);
                                    
                                    if dataBits = 8 then
                                        dataBits := 0;
                                        --write(my_line, string'(" Print dataword = ")); 
                                        --hwrite(my_line, std_logic_vector(dataword));
                                        --writeline(output, my_line);
                                        writeReady <= '1';
                                        data <= std_logic_vector(dataword);
                                        address <= std_logic_vector(addressword);
                                        addressword := addressword + 4;
                                        counter := counter + 1;
                                        wait until rising_edge(clock);
                                        writeReady <= '0';
                                        -- new 32-BIT DATA IS READY IN SIGNAL "dataword"
                                        -- ""reset dataword here!!""
                                        --   =====================
                                    end if;

                                end if;
                                --wait until rising_edge(i_clock);
                        end loop;
                end loop;
                --wait for 10 ns;
                -- Read From Memory and output to STD_OUT
                addressword := x"80020000";
                address <= std_logic_vector(addressword);
                wait until rising_edge(clock);
                while (counter /= 0) loop
                  wait until rising_edge(clock);
                  counter := counter - 1;
                  hwrite( my_line , address );
                  write( my_line, string'(" : "));
                  hwrite( my_line, dataOut);
                  writeline(output, my_line);
                  address <= std_logic_vector(unsigned(address) + 4);
                  wait until rising_edge(clock);
              end loop;
      wait;
      reset <= '0';
      
    end process;


    -- clock
    process
    begin
      clock <= '0';
      wait for period/2;
      clock <= '1';
      wait for period/2;
    end process;
end main;


