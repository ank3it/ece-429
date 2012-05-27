-- decode.vhd
-- Group: 13
-- TODO:
-- [ ] Implement proper input/output signals
-- [x] Add logic to break up instruction
-- [x] Add logic to select instruction parts
-- [ ] Generate output signals
-- [ ] Add logic to deal with NOP

library IEEE;
use ieee.std_logic_1164.all;

entity decode is
	port (
		-- Inputs
		clk			: in std_logic;
		insn		: in std_logic_vector(31 downto 0);
		pc			: in std_logic_vector(31 downto 0);
		stall		: in std_logic;
		
		-- Outputs
		opType		: out std_logic_vector(11 downto 0);
		source		: out std_logic_vector(31 downto 0);
		destination	: out std_logic_vector(31 downto 0);
		insnOut		: out std_logic_vector(31 downto 0);
		pcOut		: out std_logic_vector(31 downto 0)
	);
end entity;

architecture main of decode is

	signal opcode, funct	: std_logic_vector(5 downto 0);
	signal rs, rt, rd, shamt: std_logic_vector(4 downto 0);
	signal immediate		: std_logic_vector(15 downto 0);
	signal address			: std_logic_vector(25 downto 0);
	
begin

	-- Break up instruction into parts
	opcode <= insn(31 downto 26);	-- For all instruction types
	rs <= insn(25 downto 21);		-- R and I type
	rt <= insn(20 downto 16);		-- R and I type
	rd <= insn(15 downto 11);		-- R type
	shamt <= insn(10 downto 6);		-- R type
	funct <= insn(5 downto 0);		-- R type
	immediate <= insn(15 downto 0);	-- I type
	address <= insn(25 downto 0);	-- J type
	
	-- Select correct instruction parts
	process(opcode) begin
		if opcode = "000000" then
			if funct = "000000" then		-- sll
			elsif funct = "000010" then		-- srl
			elsif funct = "000011" then		-- sra
			elsif funct = "100000" then		-- add
			elsif funct = "100001" then		-- addu
			elsif funct = "100010" then		-- sub
			elsif funct = "100011" then		-- subu
			elsif funct = "100100" then		-- and
			elsif funct = "100101" then		-- or
			elsif funct = "100110" then		-- xor
			elsif funct = "100111" then		-- nor
			elsif funct = "101010" then		-- slt
			elsif funct = "101011" then		-- sltu
			end if;
		elsif opcode = "000001" then
			if rt = "00000" then			-- bltz
			elsif rt = "00001" then			-- bgez
			end if;
		elsif opcode = "000010" then		-- j
		elsif opcode = "000100" then		-- beq
		elsif opcode = "000101" then		-- bne
		elsif opcode = "000110" then		-- blez
		elsif opcode = "000111" then		-- bgtz
		elsif opcode = "001000" then		-- addi
		elsif opcode = "001001" then		-- addiu
		elsif opcode = "001010" then		-- slti
		elsif opcode = "100011" then		-- lw
		elsif opcode = "101011" then		-- sw
		end if;
	end process;
	
end architecture;
