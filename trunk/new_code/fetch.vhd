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
                address  	: out std_logic_vector(31 downto 0);
                insn      : in std_logic_vector(31 downto 0);
                insnDecode: out std_logic_vector(31 downto 0);
                pc      : out std_logic_vector(31 downto 0);
                rw      : out std_logic;
     --           stall_out : out std_logic;
                stall   : in std_logic                  
        );
        
end fetch;

architecture main of fetch is
      signal addr_fetch : std_logic_vector(31 downto 0);
      signal pc_fetch : std_logic_vector(31 downto 0);
   begin
     fetch2:process
        variable my_line : line;  -- type 'line' comes from textio
        variable addressword : unsigned(31 downto 0) := x"00000000";
        variable counter : integer := 230;
      begin
        wait until rising_edge(clk);
        if reset = '0' then
              addressword := x"80020000";
              if stall = '0' then
                addr_fetch <= std_logic_vector(addressword);
              end if;
                wait until rising_edge(clk);
                while (counter /= 0) loop
                  pc_fetch <= addr_fetch;
                  wait until rising_edge(clk);
                  wait until rising_edge(clk);
                  wait until rising_edge(clk);
                  if stall = '0' then
                    addr_fetch <= pcIn;
                  end if;
                  wait until rising_edge(clk);
                  --counter := counter - 1;
              end loop;
              wait;
        end if;
      end process;
          
        
      address <= addr_fetch;
      insnDecode <= insn;
      --pc_fetch <= std_logic_vector(unsigned(addr_fetch)-4);
      pc <= pc_fetch;
      rw <= '0';  -- '0' means read
end main;




