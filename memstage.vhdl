library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity memstage is
port (clk, mem_w: in std_logic; 
			pc_mem_in, mem_wadd: in std_logic_vector(15 downto 0); 
			mem_val: in std_logic_vector(15 downto 0); 
			mem_radd: in std_logic_vector(15 downto 0);
			mem_out: out std_logic_vector(15 downto 0);
			pc_mem_out: out std_logic_vector(15 downto 0)); -- testing remove
end entity;

architecture behav of memstage is
		component Dmem is
		port (
			clk, mem_w: in std_logic; 
			mem_wadd: in std_logic_vector(15 downto 0); 
			mem_val: in std_logic_vector(15 downto 0); 
			mem_radd: in std_logic_vector(15 downto 0);
			mem_out: out std_logic_vector(15 downto 0)
		);
		end component;
		
		begin
		
		Dmem_1: Dmem port map (
			clk => clk,
			mem_w => mem_w,
			mem_wadd => mem_wadd,
			mem_val => mem_val,
			mem_radd => mem_radd,
			mem_out => mem_out
		);
		
		pc_mem_out <= pc_mem_in;
	
end behav;