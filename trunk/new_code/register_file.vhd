-- register_file.vhd
-- Group: 13

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


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
		data_out1 		: out std_logic_vector(data_width - 1 downto 0);
		data_out2		: out std_logic_vector(data_width - 1 downto 0)
	);
end register_file;

architecture main of register_file is        
        type regfile_type is array (0 to size - 1) of std_logic_vector(data_width - 1 downto 0);
        signal regfile : regfile_type ;
begin
	-- Read
	data_out1 <= regfile(to_integer(unsigned(read_address1)));
	data_out2 <= regfile(to_integer(unsigned(read_address2)));

	process
	begin
		wait until falling_edge(clock);		
		-- Write
		if write_enable = '1' then
			regfile(to_integer(unsigned(write_address))) <= data_in;
		end if;
	end process;

end main;
