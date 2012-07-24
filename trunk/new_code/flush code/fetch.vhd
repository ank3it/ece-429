library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

-- The clock process has been based on the testbench code given in ECE 327 by Prof. Mark Aagaard
-- This file has both parsing and testBench code
entity fetch is
			generic(  
                  filename        : string := "file.txt";
                  line_length     : natural := 50
                  );
                  
      port (
                pcIn : in std_logic_vector(31 downto 0);
                clk : in std_logic;
                reset : in std_logic;
                flush       : in std_logic;
                address  	: out std_logic_vector(31 downto 0);
                insn      : in std_logic_vector(31 downto 0);
                insnDecode: out std_logic_vector(31 downto 0);
                pc      : out std_logic_vector(31 downto 0);
                rw      : out std_logic;
     --           stall_out : out std_logic;
                stall   : out std_logic;     
                finish : out std_logic             
        );
        
end fetch;

architecture main of fetch is
      signal addr_fetch : std_logic_vector(31 downto 0);
      signal pc_fetch : std_logic_vector(31 downto 0);
      signal finish2 : std_logic;
   begin
     fetch2:process
        variable my_line : line;  -- type 'line' comes from textio
        variable addressword : unsigned(31 downto 0) := x"00000000";
        variable counter : integer := 30;
        
      begin
        wait until rising_edge(clk);
        if reset = '1' then
        	stall <= '0';
        end if;	
        if reset = '0' then
              addressword := x"80020000";
              --stall <= '0';
              --wait until rising_edge(clk);
              --if stall = '0' then
                addr_fetch <= pcIn;-- std_logic_vector(addressword);
              --end if;
                wait until rising_edge(clk);
                while (counter /= 0) loop
                  pc_fetch <= addr_fetch;
                  wait until rising_edge(clk);
                  
               --   stall <= '1';
               --   wait until rising_edge(clk);
              --    wait until rising_edge(clk);
               --   wait until rising_edge(clk);
               --   wait until rising_edge(clk);
                --  if stall = '0' then
                --  end if;
                  addr_fetch <= pcIn;
                  if ( finish2 = '1' ) then
                   counter := 0;
                   stall <= '1';
                  end if; 
              end loop;
              wait;
        end if;
      end process;
      
      process( pcIn)
      	variable counter_nops : integer := 15;
		begin
        if ( insn /= x"00000000" ) then
			counter_nops := 15;
		else
			counter_nops := counter_nops - 1;
		end if;
		if ( counter_nops <= 0 ) then
			finish2 <= '1';
		else
			finish2 <= '0';
		end if;
	 end process;			
				
			finish <= finish2;		
		      
          
     process
     begin
     	wait until rising_edge(clk);
     	pc <= pcIn;
     end process;
      insnDecode <= insn;   
      address <= pcIn when flush = '0' else x"00000000"; -- Set to NOP when flush is set
      --pc_fetch <= std_logic_vector(unsigned(addr_fetch)-4);
      rw <= '0';  -- '0' means read
end main;




