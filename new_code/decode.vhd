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
use ieee.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types

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
	signal target			: std_logic_vector(25 downto 0);
	
begin
	-- Break up instruction into parts
	opcode <= insn(31 downto 26);	-- For all instruction types
	rs <= insn(25 downto 21);		-- R and I type
	rt <= insn(20 downto 16);		-- R and I type
	rd <= insn(15 downto 11);		-- R type
	shamt <= insn(10 downto 6);		-- R type
	funct <= insn(5 downto 0);		-- R type
	immediate <= insn(15 downto 0);	-- I type
	target <= insn(25 downto 0);	-- J type
	
	-- Select correct instruction parts
	process(pc) 
	    variable my_line : line;  -- type 'line' comes from textio
            variable rd_line : string(1 to 5);
	    variable rs_line : string(1 to 5);
	    variable rt_line : string(1 to 5);		
	begin
	          hwrite( my_line , pc);
                  write( my_line, string'(" :: "));
                  hwrite( my_line, insn);
                  writeline(output, my_line);
		
		-- REGISTERS MAPPING		
		-- 0  	  --> $zero
		-- 2-3    --> $v0-$v1		
		-- 4-7    --> $a0-$a3 		
		-- 8-15   --> $t0-$t7		
		-- 16-23  --> $s0-$s7		
		-- 24-25  --> $t8-$t9		
		-- 28	  --> $gp		
		-- 29     --> $sp		
		-- 30	  --> $fp	
		-- 31     --> $ra				
	
		-- COMMON FORMATS
		-- rd, rs, rt 	( for add, and, sub, or, xor, nor, slt, sltu,  )  
		-- rd, rt, <sa>	( for shift instructions )
		-- rs, <offset> ( for bltz, bnez, blez, bgtz,  ) 
		-- target ( for j )
		-- rs, rt, <offset> ( for bne, beq )
		-- rt, rs, <immediate> ( for addi, addiu, slti, )	
		-- rt, <offset>(rs) ( for lw, sw )		
	
		-- NOP (manual pg 216) -- SLL r0
	
		case rd is
			when "00000"  => rd_line := string'("$zero");--write( rd_line, string'("$zero") );
			when "00010"  => rd_line := string'("$v0  "); 
			when "00011"  => rd_line := string'("$v1  ");
			when "00100"  => rd_line := string'("$a0  ");
			when "00101"  => rd_line := string'("$a1  ");
			when "00110"  => rd_line := string'("$a2  ");
			when "00111"  => rd_line := string'("$a3  ");
			when "01000"  => rd_line := string'("$t0  ");
			when "01001"  => rd_line := string'("$t1  ");
			when "01010"  => rd_line := string'("$t2  ");
			when "01011"  => rd_line := string'("$t3  ");
			when "01100"  => rd_line := string'("$t4  ");
			when "01101"  => rd_line := string'("$t5  ");
			when "01110"  => rd_line := string'("$t6  ");
			when "01111"  => rd_line := string'("$t7  ");
			when "10000"  => rd_line := string'("$s0  ");
			when "10001"  => rd_line := string'("$s1  ");
			when "10010"  => rd_line := string'("$s2  ");
			when "10011"  => rd_line := string'("$s3  ");
			when "10100"  => rd_line := string'("$s4  ");
			when "10101"  => rd_line := string'("$s5  ");
			when "10110"  => rd_line := string'("$s6  ");
			when "10111"  => rd_line := string'("$s7  ");
			when "11000"  => rd_line := string'("$t8  ");
			when "11001"  => rd_line := string'("$t9  ");
			when "11100"  => rd_line := string'("$gp  ");
			when "11101"  => rd_line := string'("$sp  ");
			when "11110"  => rd_line := string'("$fp  ");
			when "11111"  => rd_line := string'("$ra  ");
			when others =>
		end case;
		
		case rs is
			when "00000"  => rs_line := string'("$zero");--write( rd_line, string'("$zero") );
			when "00010"  => rs_line := string'("$v0  "); 
			when "00011"  => rs_line := string'("$v1  ");
			when "00100"  => rs_line := string'("$a0  ");
			when "00101"  => rs_line := string'("$a1  ");
			when "00110"  => rs_line := string'("$a2  ");
			when "00111"  => rs_line := string'("$a3  ");
			when "01000"  => rs_line := string'("$t0  ");
			when "01001"  => rs_line := string'("$t1  ");
			when "01010"  => rs_line := string'("$t2  ");
			when "01011"  => rs_line := string'("$t3  ");
			when "01100"  => rs_line := string'("$t4  ");
			when "01101"  => rs_line := string'("$t5  ");
			when "01110"  => rs_line := string'("$t6  ");
			when "01111"  => rs_line := string'("$t7  ");
			when "10000"  => rs_line := string'("$s0  ");
			when "10001"  => rs_line := string'("$s1  ");
			when "10010"  => rs_line := string'("$s2  ");
			when "10011"  => rs_line := string'("$s3  ");
			when "10100"  => rs_line := string'("$s4  ");
			when "10101"  => rs_line := string'("$s5  ");
			when "10110"  => rs_line := string'("$s6  ");
			when "10111"  => rs_line := string'("$s7  ");
			when "11000"  => rs_line := string'("$t8  ");
			when "11001"  => rs_line := string'("$t9  ");
			when "11100"  => rs_line := string'("$gp  ");
			when "11101"  => rs_line := string'("$sp  ");
			when "11110"  => rs_line := string'("$fp  ");
			when "11111"  => rs_line := string'("$ra  ");
			when others =>
		end case;

		case rt is
			when "00000"  => rt_line := string'("$zero");--write( rd_line, string'("$zero") );
			when "00010"  => rt_line := string'("$v0  "); 
			when "00011"  => rt_line := string'("$v1  ");
			when "00100"  => rt_line := string'("$a0  ");
			when "00101"  => rt_line := string'("$a1  ");
			when "00110"  => rt_line := string'("$a2  ");
			when "00111"  => rt_line := string'("$a3  ");
			when "01000"  => rt_line := string'("$t0  ");
			when "01001"  => rt_line := string'("$t1  ");
			when "01010"  => rt_line := string'("$t2  ");
			when "01011"  => rt_line := string'("$t3  ");
			when "01100"  => rt_line := string'("$t4  ");
			when "01101"  => rt_line := string'("$t5  ");
			when "01110"  => rt_line := string'("$t6  ");
			when "01111"  => rt_line := string'("$t7  ");
			when "10000"  => rt_line := string'("$s0  ");
			when "10001"  => rt_line := string'("$s1  ");
			when "10010"  => rt_line := string'("$s2  ");
			when "10011"  => rt_line := string'("$s3  ");
			when "10100"  => rt_line := string'("$s4  ");
			when "10101"  => rt_line := string'("$s5  ");
			when "10110"  => rt_line := string'("$s6  ");
			when "10111"  => rd_line := string'("$s7  ");
			when "11000"  => rt_line := string'("$t8  ");
			when "11001"  => rt_line := string'("$t9  ");
			when "11100"  => rt_line := string'("$gp  ");
			when "11101"  => rt_line := string'("$sp  ");
			when "11110"  => rt_line := string'("$fp  ");
			when "11111"  => rt_line := string'("$ra  ");
			when others =>
		end case;

		if opcode = "000000" then
			if funct = "000000" then		-- sll
				write( my_line, string'("SLL ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rt_line );
				write( my_line, string'(", "));
				hwrite( my_line, shamt ); 
				writeline(output, my_line);				
			elsif funct = "000010" then		-- srl
				write( my_line, string'("SRL ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rt_line );
				write( my_line, string'(", "));
				hwrite( my_line, shamt ); 
				writeline(output, my_line);				
			elsif funct = "000011" then		-- sra
				write( my_line, string'("SRA ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rt_line );
				write( my_line, string'(", "));
				hwrite( my_line, shamt ); 
				writeline(output, my_line);				
			elsif funct = "100000" then		-- add
				write( my_line, string'("ADD ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rs_line );
				write( my_line, string'(", "));
				write( my_line, rt_line ); 
				writeline(output, my_line);				
			elsif funct = "100001" then		-- addu
				write( my_line, string'("ADDU ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rs_line );
				write( my_line, string'(", "));
				write( my_line, rt_line ); 
				writeline(output, my_line);				
			elsif funct = "100010" then		-- sub
				write( my_line, string'("SUB ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rs_line );
				write( my_line, string'(", "));
				write( my_line, rt_line ); 
				writeline(output, my_line);				
			elsif funct = "100011" then		-- subu
				write( my_line, string'("SUBU ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rt_line );
				write( my_line, string'(", "));
				write( my_line, shamt ); 
				writeline(output, my_line);				
			elsif funct = "100100" then		-- and
				write( my_line, string'("AND ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rs_line );
				write( my_line, string'(", "));
				write( my_line, rt_line ); 
				writeline(output, my_line);				
			elsif funct = "100101" then		-- or
				write( my_line, string'("OR ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rs_line );
				write( my_line, string'(", "));
				write( my_line, rt_line ); 
				writeline(output, my_line);				
			elsif funct = "100110" then		-- xor
				write( my_line, string'("XOR ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rs_line );
				write( my_line, string'(", "));
				write( my_line, rt_line ); 
				writeline(output, my_line);				
			elsif funct = "100111" then		-- nor
				write( my_line, string'("NOR ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rs_line );
				write( my_line, string'(", "));
				write( my_line, rt_line ); 
				writeline(output, my_line);				
			elsif funct = "101010" then		-- slt
				write( my_line, string'("SLT ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rs_line );
				write( my_line, string'(", "));
				write( my_line, rt_line ); 
				writeline(output, my_line);				
			elsif funct = "101011" then		-- sltu
				write( my_line, string'("SLTU ") );
				write( my_line, rd_line ); 
				write( my_line, string'(", "));	
				write( my_line, rs_line );
				write( my_line, string'(", "));
				write( my_line, rt_line ); 
				writeline(output, my_line);				
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
