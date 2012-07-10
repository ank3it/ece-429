-- writeback.vhd
-- Group: 13

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;


entity writeback is
	port (
		-- Inputs
		clk			: in std_logic;
		i_stall			: in std_logic;
		i_control_signal	: in std_logic_vector(6 downto 0);
		i_execute_output	: in std_logic_vector(31 downto 0);
		i_memory_output		: in std_logic_vector(31 downto 0);
		
		-- Outputs
		o_write_enable		: out std_logic;
		o_write_address		: out std_logic_vector(4 downto 0);
		o_data			: out std_logic_vector(31 downto 0)
	);
end writeback;

architecture main of writeback is
	signal write_address		: std_logic_vector(4 downto 0);
	signal data			: std_logic_vector(31 downto 0);
	signal wb_select		: std_logic;
	signal wb_disable		: std_logic;
	signal write_enable		: std_logic;
	signal check_we			: std_logic;
begin

process
	begin
		wait until rising_edge(clk);
		if ( i_stall = '0' ) then
			o_write_enable <= write_enable;
		else
			o_write_enable <= '0';	
		end if;	
		o_write_address <= write_address;
		o_data <= data;
	end process;
	
	-- Control bits extraction
	write_address <= i_control_signal(4 downto 0);
	wb_select <= i_control_signal(5);
	wb_disable <= i_control_signal(6);
	
	-- Writeback logic here
	write_enable <= '1' when (wb_disable = '0') else '0';
	data <= i_execute_output when (wb_select = '0') else i_memory_output;


	--if (wb_disable = '0') then
	--	write_enable <= '1';
	--	
	--	if wb_select = '0' then -- output from execute stage
	--		data <= i_execute_output;
	--	else 	
	--		data <= i_memory_output;
	--	end if;	
	--else
	--	write_enable <= '0';
	--end if;
		

end main;
