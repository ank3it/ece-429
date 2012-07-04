-- execute.vhd
-- Group: 13

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute is
	port (
	-- Inputs
	clock			 : in std_logic;
	pc				 : in std_logic_vector(31 downto 0);
	insn			  : in std_logic_vector(31 downto 0);
	stall			 : in std_logic;
	controlSignal	: in std_logic_vector(123 downto 0);
	rs       : in std_logic_vector(31 downto 0);
	rt       : in std_logic_vector(31 downto 0);
	destreg  : in std_logic_vector( 4 downto 0);
	
	-- Outputs
	output			: out std_logic_vector(31 downto 0)
	);
end execute;

architecture main of execute is 
    signal imme_control : std_logic;
    signal sign_extended_control : std_logic;
    signal alu_signed_ctl : std_logic;
    signal alu_op_ctl : std_logic;
    signal shift_dir_ctl : std_logic;
    signal shift_sign_ctl : std_logic;
    signal branch_ctl : std_logic;
    
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
    
    
    signal shift_lt : std_logic_vector( 31 downto 0); 
    signal shift_rt_u : std_logic_vector( 31 downto 0);
    signal shift_rt_s : std_logic_vector( 31 downto 0);
    signal shift_amt : unsigned(4 downto 0);
    signal shift_sign : std_logic;
    signal temp_alu_out : unsigned( 32 downto 0);
    signal alu_out : std_logic_vector( 31 downto 0);
    signal alu_sr1 : unsigned ( 31 downto 0);
    signal alu_sr2 : unsigned ( 31 downto 0);
    signal sign: std_logic;
    signal temp_sign_extended : std_logic_vector( 31 downto 0);
    signal sign_extended : unsigned( 31 downto 0);
    signal imme_field : std_logic_vector(15 downto 0);
  --signal aluout
begin
  
    shift_sign <= rt(15) when (( shift_sign_ctl AND shift_dir_ctl) = '1') else '0';
    shift_amt <= unsigned(insn(10 downto 6));
    --shift_lt <= ( rt sll 1);
    shift_rt_u <= std_logic_vector( srl(unsigned(rt), to_integer(shift_amt)) );
    shift_rt_s <= std_logic_vector( sra(unsigned(rt), to_integer(shift_amt)) );
    
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
    
    
    
end main;
