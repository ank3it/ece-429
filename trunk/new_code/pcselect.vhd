library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

-- The clock process has been based on the testbench code given in ECE 327 by Prof. Mark Aagaard
-- This file has both parsing and testBench code
entity pcselect is
			
      port (
                pcInFromExec : in std_logic_vector(31 downto 0);
                branchTaken : in std_logic;
            --    currPc : in std_logic_vector(31 downto 0);
                clk : in std_logic;
                reset : in std_logic;
                stall : in std_logic;
                pcOut  	: out std_logic_vector(31 downto 0)
                --stall_out : out std_logic;         
        );
        
end pcselect;

architecture main of pcselect is
	
	signal currPc : std_logic_vector(31 downto 0);
	signal pcOut_Temp:  std_logic_vector(31 downto 0);
	signal counter : integer := 0;
begin	
	--process
	--	begin
	--wait until rising_edge(clk);
		 pcOut <= pcOut_Temp;
	--end process; 
	
	process
		begin
		wait until rising_edge(clk);
		if ( reset = '1' ) then
		 currPc <= x"8001FFFC";
		 counter <= 0;
		elsif ( counter < 4 ) then
		 currPc <= pcOut_Temp;
		 counter <= counter + 1;
		else
		 currPc <= pcOut_Temp;
		end if; 
	end process; 
	
	pcOut_Temp <= currPc when (stall = '1' or reset = '1')
			else pcInFromExec when branchTaken = '1' AND counter = 4
			else std_logic_vector(unsigned(currPc) + 4);
end main;




