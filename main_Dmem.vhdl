library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity Dmem  is
port (clk, mem_w: in std_logic; 
			mem_wadd: in std_logic_vector(15 downto 0); 
			mem_val: in std_logic_vector(15 downto 0); 
			mem_radd: in std_logic_vector(15 downto 0);
			mem_out: out std_logic_vector(15 downto 0)); -- testing remove
end entity;

architecture behav of Dmem is
		
	-- 8 bits * 128 memory
	constant ram_depth : natural := 128;
	constant ram_width : natural := 8;
	
	type mem_array is array (0 to ram_depth - 1)
		of std_logic_vector(ram_width - 1 downto 0);
	
	--signal outp is the Dmem
	signal outp: mem_array := (others => "00000000");
	
	signal en: std_logic_vector(ram_depth - 1 downto 0);
	begin 	
	memproc:process(clk, mem_w, mem_wadd, mem_val, mem_radd, outp) 
	variable r_add, r_add1: integer := 0;
	begin
		r_add := (to_integer(unsigned(mem_radd))) mod 128;
		r_add1 := (to_integer(unsigned(mem_radd)+1)) mod 128;
		if (mem_w = '1' and falling_edge(clk)) then
			outp(r_add1) <= mem_val(15 downto 8);
			outp(r_add) <= mem_val(7 downto 0);
		end if;
		mem_out <= outp(r_add1) & outp(r_add);
	end process;
	
	
end behav;