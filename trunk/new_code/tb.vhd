library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

-- The clock process has been based on the testbench code given in ECE 327 by Prof. Mark Aagaard
-- This file has both parsing and testBench code
entity tb is 
end tb;

architecture main of tb is
		    signal clock2 		:  std_logic;
			  signal reset 		:  std_logic;
		    constant period  	: time := 2000 ms;
		    signal addr_load  	: std_logic_vector(31 downto 0);
        signal address     : std_logic_vector(31 downto 0);
        signal addr_fetch 	: std_logic_vector(31 downto 0);
        signal data_load   : std_logic_vector(31 downto 0);
        signal data_FromFetch : std_logic_vector(31 downto 0);
        signal data     	: std_logic_vector(31 downto 0);
        signal writeReady   : std_logic;
        signal writeReady_load  : std_logic;
        signal writeReady_fetch  : std_logic;
        signal dataOut  	: std_logic_vector(31 downto 0);
        signal address2  	: std_logic_vector(31 downto 0);
        signal pc : std_logic_vector(31 downto 0);
        signal stall : std_logic;
       	signal opType		: std_logic_vector(11 downto 0);
		    signal source		: std_logic_vector(31 downto 0);
		    signal destination	: std_logic_vector(31 downto 0);
		    signal insnOut		: std_logic_vector(31 downto 0);
		    signal pcOut		: std_logic_vector(31 downto 0);
   begin

     load : entity work.load(main)
      port map(
          clk => clock2,
          address => addr_load,
          data => data_load,
          writeReady => writeReady_load,
          reset => reset
      );

   fet : entity work.fetch(main)
      port map (
			   clk => clock2,
         reset => reset,
         address => addr_fetch,
         insn => dataOut,
         insnDecode => data_FromFetch,
         rw => writeReady_fetch,
         pc => pc,
         stall => stall
      );
      
     mem2 : entity work.Memory(memory_main)
      port map (
			ActualAddress => address,
			data => data,
			clock => clock2,
			writeEnable => writeReady,
			dataOut => dataOut
        );  
     
     decode : entity work.decode(main)
      port map (
        clk => clock2,
        insn => data_FromFetch,
        pc => pc,
        stall => stall,
       	opType		=> opType,
		    source		=> source,
		    destination	=> destination,
		    insnOut		=> insnOut,
		    pcOut		=> pcOut
		    );
     
    ----------------------------------------------------
     
      fetch2:process
        variable my_line : line;  -- type 'line' comes from textio
        variable counter : integer := 50;
      begin
        stall <= '0';
        wait until rising_edge(clock2);
        if reset = '0' then
          wait until rising_edge(clock2);
          wait until rising_edge(clock2);
                while (counter /= 0) loop                 
                  counter := counter - 1;
                  hwrite( my_line , pc);
                  write( my_line, string'(" :::: "));
                  hwrite( my_line, data_FromFetch);
                  writeline(output, my_line);
                  if ( counter < 40 ) then
                    stall <= '1';
                  end if;
                  if ( counter < 20 ) then
                    stall <= '0';
                  end if;
                wait until rising_edge(clock2);
              end loop;
        end if;
      end process;

    process
    begin
     clock2 <= '0';
     wait for period/2;
     clock2 <= '1';
     wait for period/2;
    end process;
    
    data <= data_load;
    address <= addr_load when reset = '1' else addr_fetch when reset = '0';
    writeReady <= writeReady_load when reset = '1' else writeReady_fetch when reset = '0';
end main;



