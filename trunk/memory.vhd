library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types


-- This code has been based on the memory code from ECE327 given to us by Prof. Mark Aagaard

entity Memory is
        generic(  data_width : natural := 8;
                  addr_width : natural := 32;
                  dataOut_width : natural := 32;
                  memSize : natural := 2**23;
                  MemStart : unsigned(31 downto 0) := x"80020000");

        port (
                Actualaddress : in std_logic_vector(addr_width - 1 downto 0);
                data : in std_logic_vector(dataOut_width - 1 downto 0);
                clock : in std_logic;
                writeEnable : in std_logic;
                dataOut : out std_logic_vector(dataOut_width - 1 downto 0)
        );
end Memory ;

architecture memory_main of memory is
        
        type total_mem is array ( 0 to memSize -1) of std_logic_vector(data_width - 1 downto 0);
        signal mem : total_mem ;
        signal address :  std_logic_vector(addr_width - 1 downto 0);
begin

RW:process
 begin
        wait until rising_edge(clock);
        if writeEnable = '1' then
                mem( to_integer(unsigned(address)) ) <= data(31 downto 24) ;
                mem( to_integer(unsigned(address)+1) ) <= data(23 downto 16) ;
                mem( to_integer(unsigned(address)+2) ) <= data(15 downto 8) ;
                mem( to_integer(unsigned(address)+3) ) <= data(7 downto 0) ;
        else
              if ( to_integer(unsigned(address)) < 8001 ) then
                dataOut <= mem( to_integer(unsigned(address)) ) & mem( to_integer(unsigned(address) + 1)) & mem( to_integer(unsigned(address)  + 2) ) & mem( to_integer(unsigned(address)  + 3));
            else
                dataOut <= x"0";
            end if;
        end if;
  end process;
address <= std_logic_vector(unsigned(unsigned(Actualaddress) - MemStart)) ;

end memory_main;
