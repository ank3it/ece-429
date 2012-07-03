-- execute.vhd
-- Group: 13

library ieee;
use ieee.std_logic_1164.all;

entity execute is
	port (
	-- Inputs
	clock			: in std_logic;
	pc				: in std_logic_vector(31 downto 0);
	insn			: in std_logic_vector(31 downto 0);
	stall			: in std_logic;
	controlSignal	: in std_logic_vector(123 downto 0);
	
	-- Outputs
	output			: out std_logic_vector(31 downto 0)
	);
end execute;

architecture main of execute is 
begin

end main;