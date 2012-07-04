-- decode.vhd
-- Group: 13

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
		rsOut		: out std_logic_vector(31 downto 0);
		rtOut		: out std_logic_vector(31 downto 0);
		insnOut		: out std_logic_vector(31 downto 0);
		pcOut		: out std_logic_vector(31 downto 0);
		controlSignal : out std_logic_vector(19 downto 0);
		
		-- Reg file signals
		rf_ra1_out		: out std_logic_vector(4 downto 0);
		rf_ra2_out		: out std_logic_vector(4 downto 0);
		rf_data1	: in std_logic_vector(31 downto 0);
		rf_data2	: in std_logic_vector(31 downto 0)
	);
end entity;

architecture main of decode is
	 signal rs, rt: std_logic_vector(4 downto 0);
begin
	-- Break up instruction into parts
	
	rs <= insn(25 downto 21);		-- R and I type
	rt <= insn(20 downto 16);		-- R and I type
	rf_ra1_out <= rt;
	rf_ra2_out <= rs;
	rsOut <= rf_data2;
	rtOut <= rf_data1;
	
	-- Select correct instruction parts
	process(pc) 
	    variable my_line : line;  -- type 'line' comes from textio
      	variable rd_line : string(1 to 5);
	    variable rs_line : string(1 to 5);
	    variable rt_line : string(1 to 5);		
	    
	    variable opcode, funct	: std_logic_vector(5 downto 0);
	    variable rd, shamt: std_logic_vector(4 downto 0);
	    variable immediate		: std_logic_vector(15 downto 0);
	    variable target			: std_logic_vector(25 downto 0);
	    variable jumpTarget : std_logic_vector(31 downto 0);
	    
	    variable rf_ra1 : std_logic_vector(4 downto 0);
	    variable rf_ra2 : std_logic_vector(4 downto 0);
	    variable rf_data1 : std_logic_vector(31 downto 0);
	    variable rf_data2 : std_logic_vector(31 downto 0);
	    
	begin
	  
	  insnOut <= insn;
	  pcOut <= pc;
	                hwrite( my_line , pc);
                  write( my_line, string'(" : "));
                  hwrite( my_line, insn);
                  write( my_line, string'("    "));
                 -- writeline(output, my_line);
                 
   	   opcode := insn(31 downto 26);	-- For all instruction types
	  
	   rd := insn(15 downto 11);		-- R type
	   shamt := insn(10 downto 6);		-- R type
	   funct := insn(5 downto 0);		-- R type
	   immediate := insn(15 downto 0);	-- I type or OFFSET
	   target := insn(25 downto 0);	-- J type            
		
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
		
		controlSignal <= (others => '0');  -- Create any old control values

	
    write( my_line, string'("    "));
		if opcode = "000000" then
			if funct = "000000" then		-- sll
				if rd = "00000" and rt = "00000" and shamt = "00000" then -- nop
					write( my_line, string'("NOP ") );
				else
					write( my_line, string'("SLL ") );
					write( my_line, to_integer(unsigned(rd)));
					write( my_line, string'(", "));	
					write( my_line, to_integer(unsigned(rt)));
					write( my_line, string'(", "));
					hwrite( my_line, shamt );

					rf_ra1 := rt;
					--rtOut <= rf_data1; -- Get value of rt from register file
					controlSignal(4) <= '0'; -- Set shift direction
					controlSignal(5) <= '0'; -- Set shift sign
					controlSignal(16 downto 12) <= shamt;  -- Set shift amount
					controlSignal(19 downto 17) <= "010";  -- Set output selector
				end if;			
				--writeline(output, my_line);
			elsif funct = "000010" then		-- srl
				write( my_line, string'("SRL ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rt)));
				write( my_line, string'(", "));
				hwrite( my_line, shamt ); 
				
				rf_ra1 := rt;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				controlSignal(4) <= '1'; -- Set shift direction
				controlSignal(5) <= '0'; -- Set shift sign
				controlSignal(16 downto 12) <= shamt;  -- Set shift amount
				controlSignal(19 downto 17) <= "010";  -- Set output selector
			elsif funct = "000011" then		-- sra
				write( my_line, string'("SRA ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rt)));
				write( my_line, string'(", "));
				hwrite( my_line, shamt ); 
				writeline(output, my_line);
				
				rf_ra1 := rt;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				controlSignal(4) <= '1'; -- Set shift direction
				controlSignal(5) <= '1'; -- Set shift sign
				controlSignal(16 downto 12) <= shamt;  -- Set shift amount
				controlSignal(19 downto 17) <= "010";  -- Set output selector
			elsif funct = "100000" then		-- add
				write( my_line, string'("ADD ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(rt))); 
				--writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(3) <= '0';  -- Set ALU op to add
				controlSignal(19 downto 17) <= "001";  -- Set output selector
			elsif funct = "100001" then		-- addu
				write( my_line, string'("ADDU ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(rt))); 
				--writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(3) <= '0';  -- Set ALU op to add
				controlSignal(19 downto 17) <= "001";  -- Set output selector
			elsif funct = "100010" then		-- sub
				write( my_line, string'("SUB ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(rt))); 
				--writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(3) <= '1';  -- Set ALU op to sub
				controlSignal(19 downto 17) <= "001";  -- Set output selector
			elsif funct = "100011" then		-- subu
				write( my_line, string'("SUBU ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(rt))); 
				--writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(3) <= '1';  -- Set ALU op to add
				controlSignal(19 downto 17) <= "001";  -- Set output selector				
			elsif funct = "100100" then		-- and
				write( my_line, string'("AND ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(rt))); 
				writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(10 downto 9) <= "00";  -- Set to logical AND
				controlSignal(19 downto 17) <= "011";  -- Set output selector
			elsif funct = "100101" then		-- or
				write( my_line, string'("OR ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(rt))); 
				--writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(10 downto 9) <= "01";  -- Set to logical AND
				controlSignal(19 downto 17) <= "011";  -- Set output selector
			elsif funct = "100110" then		-- xor
				write( my_line, string'("XOR ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(rt))); 
				--writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(10 downto 9) <= "10";  -- Set to logical AND
				controlSignal(19 downto 17) <= "011";  -- Set output selector
			elsif funct = "100111" then		-- nor
				write( my_line, string'("NOR ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(rt))); 
				--writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(10 downto 9) <= "11";  -- Set to logical AND
				controlSignal(19 downto 17) <= "011";  -- Set output selector
			elsif funct = "101010" then		-- slt
				write( my_line, string'("SLT ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(rt))); 
				--writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(11) <= '1';  -- Set slt control bit
				controlSignal(19 downto 17) <= "100";  -- Set output selector				
			elsif funct = "101011" then		-- sltu
				write( my_line, string'("SLTU ") );
				write( my_line, to_integer(unsigned(rd))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(rt))); 
				--writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(11) <= '0';  -- Set slt control bit
				controlSignal(19 downto 17) <= "100";  -- Set output selector
			end if;
		elsif opcode = "000001" then
			if rt = "00000" then			-- bltz
				write( my_line, string'("BLTZ ") );
				write( my_line, to_integer(unsigned(rs)));  
				write( my_line, string'(", "));	
				hwrite( my_line, immediate ); 
				--writeline(output, my_line);
				
				rf_ra2 := rs;
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '0';  -- Don't sign extend
				controlSignal(4) <= '0';  -- Left shift
				controlSignal(5) <= '0';  -- Logical shift
				controlSignal(16 downto 12) <= "00010"; -- shift amount = 2
				controlSignal(8 downto 6) <= "001";  -- Set branch control bits
				controlSignal(19 downto 17) <= "101";  -- Set output selector
			elsif rt = "00001" then			-- bgez
				write( my_line, string'("BGEZ ") );
				write( my_line, to_integer(unsigned(rs)));  
				write( my_line, string'(", "));	
				hwrite( my_line, immediate ); 
				--writeline(output, my_line);
				
				rf_ra2 := rs;
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '0';  -- Don't sign extend
				controlSignal(4) <= '0';  -- Left shift
				controlSignal(5) <= '0';  -- Logical shift
				controlSignal(16 downto 12) <= "00010"; -- shift amount = 2
				controlSignal(8 downto 6) <= "101";  -- Set branch control bits
				controlSignal(19 downto 17) <= "101";  -- Set output selector
			end if;
		elsif opcode = "000010" then		-- j
				write( my_line, string'("J ") );
				jumpTarget := std_logic_vector((unsigned(pc) + 4));
				jumpTarget(1 downto 0) := "00"; 
				jumpTarget(27 downto 2) := target;
				hwrite( my_line, jumpTarget ); 
				--writeline(output, my_line);
				
				controlSignal(19 downto 17) <= "110";  -- Set output selector
		elsif opcode = "000100" then		-- beq
				write( my_line, string'("BEQ ") );
				write( my_line, to_integer(unsigned(rs)));  
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rt))); 
				write( my_line, string'(", "));	
				hwrite( my_line, immediate ); 
				--writeline(output, my_line);
				
        		rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '0';  -- Don't sign extend
				controlSignal(4) <= '0';  -- Left shift
				controlSignal(5) <= '0';  -- Logical shift
				controlSignal(16 downto 12) <= "00010"; -- shift amount = 2
				controlSignal(8 downto 6) <= "100";  -- Set branch control bits
				controlSignal(19 downto 17) <= "101";  -- Set output selector
		elsif opcode = "000101" then		-- bne
				write( my_line, string'("BNE ") );
				write( my_line, to_integer(unsigned(rs)));  
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rt))); 
				write( my_line, string'(", "));	
				hwrite( my_line, immediate ); 
				--writeline(output, my_line);
				
				rf_ra1 := rt;
				rf_ra2 := rs;
				--rtOut <= rf_data1;  -- Get value of rt from register file
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '0';  -- Don't sign extend
				controlSignal(4) <= '0';  -- Left shift
				controlSignal(5) <= '0';  -- Logical shift
				controlSignal(16 downto 12) <= "00010"; -- shift amount = 2
				controlSignal(8 downto 6) <= "101";  -- Set branch control bits
				controlSignal(19 downto 17) <= "101";  -- Set output selector
		elsif opcode = "000110" then		-- blez
				write( my_line, string'("BLEZ ") );
				write( my_line, to_integer(unsigned(rs)));  
				write( my_line, string'(", "));	
				hwrite( my_line, immediate ); 
				--writeline(output, my_line);
				
				rf_ra2 := rs;
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '0';  -- Don't sign extend
				controlSignal(4) <= '0';  -- Left shift
				controlSignal(5) <= '0';  -- Logical shift
				controlSignal(16 downto 12) <= "00010"; -- shift amount = 2
				controlSignal(8 downto 6) <= "110";  -- Set branch control bits
				controlSignal(19 downto 17) <= "101";  -- Set output selector
		elsif opcode = "000111" then		-- bgtz
				write( my_line, string'("BGTZ ") );
				write( my_line, to_integer(unsigned(rs)));  
				write( my_line, string'(", "));	
				hwrite( my_line, immediate ); 
				--writeline(output, my_line);
				
				rf_ra2 := rs;
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '0';  -- Don't sign extend
				controlSignal(4) <= '0';  -- Left shift
				controlSignal(5) <= '0';  -- Logical shift
				controlSignal(16 downto 12) <= "00010"; -- shift amount = 2
				controlSignal(8 downto 6) <= "111";  -- Set branch control bits
				controlSignal(19 downto 17) <= "101";  -- Set output selector
		elsif opcode = "001000" then		-- addi
				write( my_line, string'("ADDI ") );
				write( my_line, to_integer(unsigned(rt))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs)));  
				write( my_line, string'(", "));	
				write( my_line, to_integer(signed(immediate)) ); 
				--writeline(output, my_line);
				
				rf_ra2 := rs;
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '1';  -- Do sign extend
				controlSignal(3) <= '0';  -- Add
				controlSignal(19 downto 17) <= "001";  -- Set output selector
		elsif opcode = "001001" then		-- addiu
				write( my_line, string'("ADDIU ") );
				write( my_line, to_integer(unsigned(rt))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs)));  
				write( my_line, string'(", "));	
				write( my_line, to_integer(signed(immediate)) ); 
				--writeline(output, my_line);
				
				rf_ra2 := rs;
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '1';  -- Do sign extend
				controlSignal(3) <= '0';  -- Add
				controlSignal(19 downto 17) <= "001";  -- Set output selector
		elsif opcode = "001010" then		-- slti
				write( my_line, string'("SLTI ") );
				write( my_line, to_integer(unsigned(rt))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs)));  
				write( my_line, string'(", "));	
				write( my_line, to_integer(signed(immediate)) ); 
				--writeline(output, my_line);
				
				rf_ra2 := rs;
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '1';  -- Do sign extend
				controlSignal(11) <= '1';  -- slti
				controlSignal(19 downto 17) <= "100";  -- Set output selector
		elsif opcode = "001101" then		-- ori
				write( my_line, string'("ORI ") );
				write( my_line, to_integer(unsigned(rt))); 
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(rs)));  
				write( my_line, string'(", "));	
				write( my_line, to_integer(unsigned(immediate)) );
				
				rf_ra2 := rs;
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '0';  -- Don't sign extend
				controlSignal(10 downto 9)  <= "01";  -- OR
				controlSignal(19 downto 17) <= "011";  -- Set output selector
		elsif opcode = "001111" then		-- lui
				write( my_line, string'("LUI ") );
				write( my_line, to_integer(unsigned(rt))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(unsigned(immediate)) ); 	
				--writeline(output, my_line);

				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '0';  -- Don't sign extend
				controlSignal(4) <= '0';  -- Shift left
				controlSignal(5) <= '0';  -- Logical shift
				controlSignal(16 downto 12) <= "10000";  -- Shift ammount = 16
				controlSignal(19 downto 17) <= "010";  -- Set output selector
		elsif opcode = "100011" then		-- lw
				write( my_line, string'("LW ") );
				write( my_line, to_integer(unsigned(rt))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(signed(immediate)) );
				write( my_line, string'("("));
				write( my_line, to_integer(unsigned(rs))); 
				write(my_line, string'(")")); 	
				--writeline(output, my_line);
				
				rf_ra2 := rs;
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '1';  -- Do sign extend
				controlSignal(3) <= '0';  -- Add
				controlSignal(19 downto 17) <= "001";  -- Set output selector
		elsif opcode = "101011" then		-- sw
				write( my_line, string'("SW ") );
				write( my_line, to_integer(unsigned(rt))); 
				write( my_line, string'(", "));
				write( my_line, to_integer(signed(immediate)) );
				write( my_line, string'("("));
				write( my_line, to_integer(unsigned(rs))); 
				write(my_line, string'(")")); 	
				--writeline(output, my_line);
				
				rf_ra2 := rs;
				--rsOut <= rf_data2;  -- Get value of rs from register file
				controlSignal(0) <= '1';  -- Need to read immediate field
				controlSignal(1) <= '1';  -- Do sign extend
				controlSignal(3) <= '0';  -- Add
				controlSignal(19 downto 17) <= "001";  -- Set output selector
		end if;
		writeline(output, my_line);	
	end process;
	
	--rf_ra1_out <= rf_ra1;

	
end architecture;
