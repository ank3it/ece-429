-- execute.vhd
-- Group: 13

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

entity execute is
	port (
	-- Inputs
	clk			 : in std_logic;
	pc				 : in std_logic_vector(31 downto 0);
	insn			  : in std_logic_vector(31 downto 0);
	stall			 : in std_logic;
	controlSignal	: in std_logic_vector(19 downto 0);
	rs       : in std_logic_vector(31 downto 0);
	rt       : in std_logic_vector(31 downto 0);
	--destreg  : in std_logic_vector( 4 downto 0);
	
	-- Outputs
	output_exec			: out std_logic_vector(31 downto 0);
	output_branch_taken   : out std_logic
	);
end execute;

architecture main of execute is 
    signal imme_control : std_logic; -- set if we need immediate field
    signal sign_extended_control : std_logic; -- set if you need to pad imme with sign extension .. will set zero for ORI
    signal alu_signed_ctl : std_logic; --
    signal alu_op_ctl : std_logic; -- 0 ADD, 1 SUB
    signal shift_dir_ctl : std_logic; -- 0 LEFT, 1 RIGHT
    signal shift_sign_ctl : std_logic; -- 0 UNSIGNED, 1 SIGNED
    signal branch_ctl : std_logic_vector( 2 downto 0 ); -- 100 beq, 101 bgez, 111 BGTZ , 110 BLEZ , 001 BLTZ, 101 BNE, else 0 
    signal logical_op_ctl : std_logic_vector( 1 downto 0); -- 00 AND, 01 OR , 10 XOR, 11 NOR -- last 2 bits of instr
    signal slt_ctl : std_logic ; -- 1 SLT, 0 SLTU .. for SLTI, use SLT but with imme_control and sign_extended_control set
    signal shift_amt_ctl : std_logic_vector( 4 downto 0 );
    signal output_select_ctl :  std_logic_vector( 2 downto 0 );
       
    --signal shift_rt_16 : std_logic_vector(31 downto 0);
    --signal shift_rt_8 : std_logic_vector(31 downto 0);
    --signal shift_rt_4 : std_logic_vector(31 downto 0);
    --signal shift_rt_2 : std_logic_vector(31 downto 0);
    --signal shift_rt_1 : std_logic_vector(31 downto 0);
    
    --signal shift_lt_16 : std_logic_vector(31 downto 0);
    --signal shift_lt_8 : std_logic_vector(31 downto 0);
    --signal shift_lt_4 : std_logic_vector(31 downto 0);
    --signal shift_lt_2 : std_logic_vector(31 downto 0);
    --signal shift_lt_1 : std_logic_vector(31 downto 0);
    
    signal pcOut : std_logic_vector( 31 downto 0);
    signal insnOut: std_logic_vector( 31 downto 0);
    signal slt_s : std_logic;
    signal slt_u : std_logic;
    signal pcplus4 : std_logic_vector( 31 downto 0 );
    signal shift_rt : std_logic_vector( 31 downto 0 );
    signal shift_lt : std_logic_vector( 31 downto 0); 
    signal shift_rt_u : std_logic_vector( 31 downto 0);
    signal shift_rt_s : std_logic_vector( 31 downto 0);
    signal shift_amt : unsigned(4 downto 0);
    signal shift_sign : std_logic;
    signal temp_alu_out : unsigned( 31 downto 0);
    signal alu_sr1 : unsigned ( 31 downto 0);
    signal alu_sr2 : unsigned ( 31 downto 0);
    signal sign: std_logic;
    signal temp_sign_extended : std_logic_vector( 31 downto 0);
    signal sign_extended : unsigned( 31 downto 0);
    signal imme_field : std_logic_vector(15 downto 0);
    signal bt_BEQ : std_logic;
    signal bt_BGEZ: std_logic;
    signal bt_BGTZ : std_logic;
    signal bt_BLEZ : std_logic;
    signal bt_BLTZ : std_logic;
    signal bt_BNE : std_logic;

    
    signal branch_taken_out : std_logic;
    signal branch_addr_out : std_logic_vector( 31 downto 0);
    signal slt_out : std_logic_vector( 31 downto 0);
    signal logical_out : std_logic_vector( 31 downto 0);
    signal jump_out : std_logic_vector( 31 downto 0 );
    signal shift_out : std_logic_vector( 31 downto 0);
    signal alu_out : std_logic_vector( 31 downto 0);
    
    signal output1 : std_logic_vector( 31 downto 0);
  --signal aluout
begin
  
  	process
	  begin
	 wait until rising_edge(clk);
	 	insnOut <= insn;
	  	pcOut <= pc;
	  	output_exec <= output1;
	  	output_branch_taken <= branch_taken_out;
	 end process;
	 
    process(pc) 
    	variable my_line : line;  -- type 'line' comes from textio
      begin
      
      	--write( my_line, string'(" rs =  "));
      	-- hwrite( my_line, rs);
      	--write( my_line, string'(" rt =  "));
      	-- hwrite( my_line, rt);
        --wait until rising_edge(clk);
                 -- write( my_line, string'(" Execute "));
                  write( my_line, string'("E: "));
                  hwrite( my_line, pcOut);
                  write( my_line, string'(" : "));
                  hwrite( my_line, insnOut);
     			  write( my_line, string'("    "));
                  hwrite( my_line, output1);
                  writeline(output, my_line);      
    end process;
        
  
  	output1 <= alu_out when output_select_ctl = "001"
			else logical_out when output_select_ctl = "011"
			else slt_out when output_select_ctl = "100"
			else shift_out when output_select_ctl = "010"
			else branch_addr_out when  output_select_ctl = "101"
			else jump_out when output_select_ctl = "110"
			else (others => '0');		
    imme_control <= controlSignal(0);
    sign_extended_control <= controlSignal(1);
    alu_signed_ctl <= controlSignal(2);
    alu_op_ctl <= controlSignal(3);
    shift_dir_ctl <= controlSignal(4);
    shift_sign_ctl <= controlSignal(5); 
    branch_ctl <= controlSignal(8 downto 6);
    logical_op_ctl <= controlSignal(10 downto 9);
    slt_ctl <= controlSignal(11);
    shift_amt_ctl <= controlSignal(16 downto 12);
    output_select_ctl <= controlSignal(19 downto 17);
  
    pcplus4 <= std_logic_vector(unsigned(pc) + 4);
    jump_out( 1 downto 0) <= (1 downto 0 => '0');
    jump_out( 27 downto 2) <= insn(25 downto 0);
    jump_out( 31 downto 28 ) <= pcplus4 ( 31 downto 28 ); 
    
    shift_sign <= rt(15) when (( shift_sign_ctl AND shift_dir_ctl) = '1') else '0';
    shift_amt <= unsigned(shift_amt_ctl);
    shift_lt <= std_logic_vector( unsigned(rt) sll to_integer(shift_amt));
    shift_rt_u <= std_logic_vector( unsigned(rt) srl to_integer(shift_amt));
    shift_rt_s <= std_logic_vector( signed(rt) srl to_integer(shift_amt));
    shift_rt <= shift_rt_u when shift_sign_ctl = '0' else shift_rt_s;
    shift_out <= shift_lt when shift_dir_ctl = '0' else shift_rt;
    
    --shift_rt_16( 15 downto 0) <= ( rt(31 downto 16 ) )  when shift_amt(4) = '1' else rt( 15 downto 0); 
    --shift_rt_16( 31 downto 15) <= (31 downto 15 => shift_sign) when shift_amt(4) = '1' else rt( 31 downto 15);
    --shift_rt_8( 23 downto 0) <= ( shift_rt_16(31 downto 8 ) )  when shift_amt(3) = '1' else shift_rt_16( 23 downto 0); 
    --shift_rt_8( 31 downto 24) <= (31 downto 24 => shift_sign) when shift_amt(3) = '1' else rt( 31 downto 24);  
    --shift_rt_4( 27 downto 0) <= ( shift_rt_8(31 downto 4 ) )  when shift_amt(2) = '1' else shift_rt_8( 27 downto 0); 
    --shift_rt_4( 31 downto 28) <= (31 downto 28 => shift_sign) when shift_amt(2) = '1' else rt( 31 downto 28);
    --shift_rt_2( 27 downto 0) <= ( shift_rt_8(31 downto 4 ) )  when shift_amt(1) = '1' else shift_rt_8( 27 downto 0); 
    --shift_rt_2( 31 downto 28) <= (31 downto 28 => shift_sign) when shift_amt(1) = '1' else rt( 31 downto 28);
    
    
    imme_field <= insn(15 downto 0);
    sign <= imme_field(15) when sign_extended_control = '1' else '0';
    temp_sign_extended( 15 downto 0 ) <= imme_field;
    temp_sign_extended(31 downto 16) <= (31 downto 16 => sign);
    sign_extended <= unsigned(temp_sign_extended);
    
    alu_sr1 <= unsigned(rs);
    alu_sr2 <= unsigned(rt) when imme_control = '0' else sign_extended;
    temp_alu_out <= (alu_sr1 + alu_sr2) when alu_op_ctl = '0' else (alu_sr1 - alu_sr2);
    alu_out <= std_logic_vector(temp_alu_out(31 downto 0));
    
    logical_out <= (std_logic_vector(alu_sr1) AND std_logic_vector(alu_sr2)) when logical_op_ctl = "00"
            else   (std_logic_vector(alu_sr1) OR std_logic_vector(alu_sr2)) when logical_op_ctl = "01"
            else   (std_logic_vector(alu_sr1) XOR std_logic_vector(alu_sr2)) when logical_op_ctl = "10"
            else   (std_logic_vector(alu_sr1) NOR std_logic_vector(alu_sr2));  
    
     slt_s <= '1' when ( signed(rs) < signed(rt) ) else '0';
     slt_u <= '1' when ( unsigned(rs) < unsigned(rt) ) else '0';
     slt_out( 31 downto 1 ) <= ( 31 downto 1 => '0' );
     slt_out(0) <= slt_s when slt_ctl = '1' else '0';
     
     bt_BEQ <= '1' when (rs = rt ) else '0';
     bt_BGEZ<= '1' when (rs >= "0") else '0';
     bt_BGTZ <= '1' when (rs > "0" ) else '0';
     bt_BLEZ <= '1' when (rs <= "0" ) else '0';
     bt_BLTZ <= '1' when (rs < "0" ) else '0';
     bt_BNE <= '0' when (rs = rt ) else '1';
     
     branch_addr_out <= std_logic_vector(unsigned(pcplus4)+ unsigned(signed(sign_extended) sll 2));   
     branch_taken_out <= bt_BEQ when  (branch_ctl = "100" AND output_select_ctl = "101")
                  else   bt_BGEZ when (branch_ctl = "101" AND output_select_ctl = "101")
                  else   bt_BGTZ when (branch_ctl = "111" AND output_select_ctl = "101")
                  else   bt_BLEZ when (branch_ctl = "110" AND output_select_ctl = "101")
                  else   bt_BLTZ when (branch_ctl = "001" AND output_select_ctl = "101")
                  else   bt_BNE when  (branch_ctl = "101" AND output_select_ctl = "101")
                  else   '0';
                      
     
     
end main;
