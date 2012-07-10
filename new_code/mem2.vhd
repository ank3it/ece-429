library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types


entity memory2 is
        generic(  data_width : natural := 8;
                  addr_width : natural := 32;
                  dataOut_width : natural := 32;
                  memSize : natural := 2**13;
                  filename        : string := "file.txt";
                  line_length     : natural := 50;
                  MemStart : unsigned(31 downto 0) := x"80020000");

        port (
                Actualaddress 	: in std_logic_vector(addr_width - 1 downto 0);
                data 			: in std_logic_vector(dataOut_width - 1 downto 0);
                reset 			: in std_logic;
                clock 			: in std_logic;
                writeEnable 	: in std_logic;
				stall			: in std_logic;
				controlSignal	: in std_logic_vector(7 downto 0);
                dataOut 		: out std_logic_vector(dataOut_width - 1 downto 0);
				stallOut		: out std_logic;
				controlSignalOut: out std_logic_vector(6 downto 0);
				MemExecInput	: in std_logic_vector(dataOut_width - 1 downto 0);
				MemExecOutput	: out std_logic_vector(dataOut_width - 1 downto 0);
				execDataOut		: out std_logic_vector(dataOut_width -1 downto 0)
        );
end memory2 ;

architecture main of memory2 is
        
        type total_mem is array ( 0 to memSize -1) of std_logic_vector(data_width - 1 downto 0);
        signal mem : total_mem ;
        signal address :  std_logic_vector(addr_width - 1 downto 0);
        signal address2 :  std_logic_vector(addr_width - 1 downto 0);
begin

RW:process
 variable my_line : line;  -- type 'line' comes from textio
 begin
        wait until rising_edge(clock);
		-- Forward some signals
		controlSignalOut <= controlSignal(7 downto 1);
		stallOut <= stall;
		execDataOut <= data;
		MemExecOutput <= MemExecInput;
		
		-- Read/write memory
        if writeEnable = '1' AND stall = '0' then
        	 if ( to_integer(unsigned(address)) >= 0 AND to_integer(unsigned(address)) < 8001 ) then
                mem( to_integer(unsigned(address)) ) <= data(31 downto 24) ;
                mem( to_integer(unsigned(address)+1) ) <= data(23 downto 16) ;
                mem( to_integer(unsigned(address)+2) ) <= data(15 downto 8) ;
                mem( to_integer(unsigned(address)+3) ) <= data(7 downto 0) ;
                write( my_line, string'("Mem "));
				write( my_line, string'(" Addr "));
				write( my_line, to_integer(signed(address)));
				write( my_line, string'(" Data "));
				write( my_line, to_integer(signed(data)));		
				writeline(output, my_line);
             end if;   
        else
              if ( to_integer(signed(address)) >= 0 AND to_integer(unsigned(address)) < 8001 ) then
                dataOut <= mem( to_integer(unsigned(address)) ) & mem( to_integer(unsigned(address) + 1)) & mem( to_integer(unsigned(address)  + 2) ) & mem( to_integer(unsigned(address)  + 3));
            else
                dataOut <= x"00000000";
            end if;
        end if;
  end process;
address <= address2 when (to_integer(signed(address2)) >= 0 AND to_integer(unsigned(address2)) < 8001)
			else x"00001F40"; -- 8000 in dec
address2 <= std_logic_vector(unsigned(unsigned(Actualaddress) - MemStart)) when reset = '1' else Actualaddress ;

end main;
