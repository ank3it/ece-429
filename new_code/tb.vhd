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
		constant period  	: time := 2 ms;
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
		signal insnOut		: std_logic_vector(31 downto 0);
		signal pcOut		: std_logic_vector(31 downto 0);
		signal rsOut		: std_logic_vector(31 downto 0);
		signal rtOut		: std_logic_vector(31 downto 0);
		signal controlSignal		: std_logic_vector(19 downto 0);
		signal output_fromExec : std_logic_vector(31 downto 0);
		signal output_branch_taken : std_logic;
		
		-- Signals for register file
		signal rf_read_address1		: std_logic_vector(4 downto 0);
		signal rf_read_address2		: std_logic_vector(4 downto 0);
		signal rf_write_address		: std_logic_vector(4 downto 0);
		signal rf_write_enable		: std_logic;
		signal rf_data_in			: std_logic_vector(31 downto 0);
		signal rf_data_out1			: std_logic_vector(31 downto 0);
		signal rf_data_out2			: std_logic_vector(31 downto 0);
   begin

   rf_write_enable <= '0';
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
	
	rf : entity work.register_file(main)
		port map (
			-- Inputs
			clock => clock2,
			read_address1 => rf_read_address1,
			read_address2 => rf_read_address2,
			write_address => rf_write_address,
			write_enable => rf_write_enable,
			data_in => rf_data_in,
			
			-- Outputs
			data_out1 => rf_data_out1,
			data_out2 => rf_data_out2
		);
     
     decode : entity work.decode(main)
      port map (
        clk => clock2,
        insn => data_FromFetch,
        pc => pc,
        stall => stall,
        rsOut => rsOut,
        rtOut => rtOut,
		    insnOut		=> insnOut,
		    pcOut		=> pcOut,
		    controlSignal => controlSignal,
			
			  rf_ra1_out => rf_read_address1,
			  rf_ra2_out => rf_read_address2,
			  rf_data1 => rf_data_out1,
			  rf_data2 => rf_data_out2
		);
		
		execute : entity work.execute(main)
		 port map (
		      clk => clock2,
		      insn => insnOut,
          pc => pcOut,
          stall => stall,
		      controlSignal		=> controlSignal,
		      rs		=> rsOut,
			    rt		=> rtOut,
			    output_exec => output_fromExec,
			    output_branch_taken => output_branch_taken
		);
     
    ----------------------------------------------------

    process
    begin
     stall <= '0';
     clock2 <= '0';
     wait for period/2;
     clock2 <= '1';
     wait for period/2;
    end process;
    
    data <= data_load;
    address <= addr_load when reset = '1' else addr_fetch when reset = '0';
    writeReady <= writeReady_load when reset = '1' else writeReady_fetch when reset = '0';
end main;



