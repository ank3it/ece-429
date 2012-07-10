-- writeback.vhd
-- Group: 13

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity writeback is
	port (
		-- Inputs
		clk					: in std_logic;
		i_stall				: in std_logic;
		i_control_signal	: in std_logic_vector(6 downto 0);
		i_execute_output	: in std_logic_vector(31 downto 0);
		i_memory_output		: in std_logic_vector(31 downto 0);
		
		-- Outputs
		o_write_enable		: out std_logic;
		o_write_address		: out std_logic_vector(4 downto 0);
		o_data				: out std_logic_vector(31 downto 0)
	);
end writeback;

architecture main of writeback is
	signal write_address	: std_logic_vector(4 downto 0);
	signal data				: std_logic_vector(31 downto 0);
	signal wb_select		: std_logic;
	signal wb_disable		: std_logic;
begin

	process
	begin
		wait until rising_edge(clk);
		o_write_address <= write_address;
		o_data <= data;
	end process;
	
	-- Control bits extraction
	write_address <= i_control_signal(4 downto 0);
	wb_select <= i_control_signal(5);
	wb_disable <= i_control_signal(6);
	
	-- Writeback logic here

end main;