library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
	generic(
		data_width		: integer := 32;
		addr_width		: integer := 32;
		dataOut_width	: integer := 32;
		memSize 		: integer := 2**23;
		MemStart 		: integer := 8002000
	);

	port (
		Actualaddress	: in std_logic_vector(addr_width - 1 downto 0);
		data 			: in std_logic_vector(data_width - 1 downto 0);
		clock 			: in std_logic;
		write 			: in std_logic;
		dataOut 		: out std_logic_vector(dataOut_width - 1 downto 0)
	);
end Memory ;

architecture memory_main of memory is
	type total_mem is array ( 0 to memSize -1) of std_logic_vector(data_width - 1 downto 0);
	signal mem 		: total_mem ;
	signal address	: std_logic_vector(addr_width - 1 downto 0);

begin
 	read:process begin
		wait until rising_edge(clock);
		if write = '1' then
			mem( to_integer(unsigned(address)) ) <= data(31 downto 24);
			mem( to_integer(unsigned(address)) ) <= data(23 downto 16);
			mem( to_integer(unsigned(address)) ) <= data(15 downto 8);
			mem( to_integer(unsigned(address)) ) <= data(7 downto 0);
		else
			dataOut <= mem( to_integer(unsigned(address)) ) 
				& mem( to_integer(unsigned(address) + 2)) 
				& mem( to_integer(unsigned(address) + 3) ) 
				& mem( to_integer(unsigned(address) + 4) );
		end if;
	end process;

	address <= std_logic_vector(unsigned(Actualaddress) + MemStart) ;

end memory_main;
