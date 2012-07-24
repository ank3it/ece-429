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
		constant period  	: time := 20 ns;
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
		signal finish		: std_logic;
		--signal address2  	: std_logic_vector(31 downto 0);
		signal pc : std_logic_vector(31 downto 0);
		signal stall : std_logic;
		signal insnOut		: std_logic_vector(31 downto 0);
		signal pcOut		: std_logic_vector(31 downto 0);
		signal rsOut		: std_logic_vector(31 downto 0);
		signal rtOut		: std_logic_vector(31 downto 0);
		signal controlSignal		: std_logic_vector(27 downto 0);
		signal output_fromExec : std_logic_vector(31 downto 0);
		signal output_branch_taken : std_logic;
		signal controlSignal_fromExec	: std_logic_vector(7 downto 0);
		signal controlSignal_fromMem	: std_logic_vector(6 downto 0);
		signal stall_fromExec			: std_logic;
		signal stall_fromMem			: std_logic;
		signal execDataOut_fromMem		: std_logic_vector(31 downto 0);
		signal rt_fromExec				: std_logic_vector(31 downto 0);
		signal pcFromExec				: std_logic_vector(31 downto 0);
		signal pcFromSelecter			: std_logic_vector(31 downto 0);
		signal stall_fromDecode			: std_logic;
		signal stall_fetchFromDecode	: std_logic;
		signal stall_toPCs	: std_logic;
		signal flush_fromExec : std_logic;
		
		-- Signals for register file
		signal rf_read_address1		: std_logic_vector(4 downto 0);
		signal rf_read_address2		: std_logic_vector(4 downto 0);
		signal rf_write_address		: std_logic_vector(4 downto 0);
		signal rf_write_enable		: std_logic;
		signal rf_data_in			: std_logic_vector(31 downto 0);
		signal rf_data_out1			: std_logic_vector(31 downto 0);
		signal rf_data_out2			: std_logic_vector(31 downto 0);
		
		-- Signal for mem2
		signal mem2_address			: std_logic_vector(31 downto 0);
		signal mem2_data			: std_logic_vector(31 downto 0);
		signal mem2_writeReady		: std_logic;
		signal mem2_dataOut			: std_logic_vector(31 downto 0);
		signal execDataOut_fromMem2 : std_logic_vector(31 downto 0);
   begin

	--rf_write_enable <= '0';
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
			flush =>output_branch_taken,
			insn => dataOut,
			insnDecode => data_FromFetch,
			rw => writeReady_fetch,
			pc => pc,
			pcIn => pcFromSelecter,
			finish => finish,
			stall => stall
		);
      
	mem1 : entity work.Memory(memory_main)
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
			finish => finish,
			
			-- Outputs
			data_out1 => rf_data_out1,
			data_out2 => rf_data_out2
		);
     
	decode : entity work.decode(main)
		port map (
			clk => clock2,
			insn => data_FromFetch,
			pc => pc,
			flush => output_branch_taken,
			stall => stall,
			stall_fetch => stall_fetchFromDecode,
			reset => reset,
			rsOut2 => rsOut,
			rtOut2 => rtOut,
			insnOut		=> insnOut,
			pcOut		=> pcOut,
			controlSignal2 => controlSignal,
			stall_out => stall_fromDecode,
			

			rf_ra1_out => rf_read_address1,
			rf_ra2_out => rf_read_address2,
			rf_data1 => rf_data_out1,
			rf_data2 => rf_data_out2
		);
		
	pcS : entity work.pcselect(main)
 		port map (
 			pcInFromExec => pcFromExec,
 			branchTaken =>  output_branch_taken,
 			--currPc => pc,
 			clk => clock2,	
 			reset => reset,
 			stall => stall_toPCs,
 			pcOut => pcFromSelecter
 			);
	
	execute : entity work.execute(main)
		port map (
			clk => clock2,
			reset => reset,
			insn => insnOut,
			pc => pcOut,
			pcOut => pcFromExec,
			stall => stall_fromDecode,
			controlSignal		=> controlSignal,
			finish => finish,
			rs		=> rsOut,
			rt		=> rtOut,
			output_exec => output_fromExec,
			output_branch_taken => output_branch_taken,
			controlSignalOut => controlSignal_fromExec,
			stallOut => stall_fromExec,
			flush => flush_fromExec,
			rtOut => rt_fromExec
		);

	mem2 : entity work.memory2(main)
		port map (
			ActualAddress => mem2_address,
			reset	=> reset,
			data => mem2_data,
			clock => clock2,
			writeEnable => mem2_writeReady,
			stall => stall_fromExec,
			controlSignal => controlSignal_fromExec,
			dataOut => mem2_dataOut,
			stallOut => stall_fromMem,
			controlSignalOut => controlSignal_fromMem,
			MemExecInput => output_fromExec,
			MemExecOutput => execDataOut_fromMem2, 
			finish => finish,
			execDataOut => execDataOut_fromMem,
			i_pc => pcFromExec
		);
		
	wb : entity work.writeback(main)
		port map (
			clk => clock2,
			i_stall => stall_fromMem,
			i_control_signal => controlSignal_fromMem,
			i_execute_output =>  execDataOut_fromMem2,
			i_memory_output => mem2_dataOut,
			o_write_enable => rf_write_enable,
			o_write_address => rf_write_address,
			o_data => rf_data_in
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
    
    stall_toPCs <= (stall OR stall_fetchFromDecode);
    data <= data_load;
    address <= addr_load when reset = '1' else addr_fetch when reset = '0';
    writeReady <= writeReady_load when reset = '1' else writeReady_fetch when reset = '0';
	
	mem2_data <= data_load when reset = '1' else rt_fromExec when reset = '0';
	mem2_address <= addr_load when reset = '1' else output_fromExec when reset = '0';
	mem2_writeReady <= writeReady_load when reset = '1' else controlSignal_fromExec(0) when reset = '0';
end main;



