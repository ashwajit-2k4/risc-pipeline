library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Imem  is
	port (mem_radd: in std_logic_vector(15 downto 0);
			mem_out: out std_logic_vector(15 downto 0)); -- testing remove
end entity;

architecture behav of Imem is
		
	-- 8 bits * 128 memory
	constant ram_depth : natural := 128;
	constant ram_width : natural := 8;
	
	type mem_array is array (0 to ram_depth - 1)
		of std_logic_vector(ram_width - 1 downto 0);
	

		
		--signal outp: mem_array := (
		--		1 => "00110110", 0 => "00000001",
		--		3 => "00111001", 2 => "11111111",
		--		5 => "00111010", 4 => "00000010",
		--		7 => "00111101", 6 => "11111110",
		--		9 => "11100000", 8 => "00000000",
		--		11 => "11100000", 10 => "00000000",
		--		13 => "11100000", 12 =>"00000000",
		--		15 => "11100000", 14 => "00000000",
		--		17 => "11100000", 16 => "00000000",
		--		19 => "11100000", 18 => "00000000",

			--	21 => "11000010", 20 => "00000101", -- JAL
		--		23 => "11110110", 22 => "00000001", -- JRI
		--		31 => "11010100", 30 => "01000000", -- JLR
		--		others => "11100000");
		
		signal outp: mem_array := (11 => "00001111", 10 => "01000000",
1=> "00110010", 0=> "00000001", 3=> "00110100", 2=> "00000011", 5=> "00010010", 4=> "10011000", 7=> "00010010", 6=> "10100100", 9=> "00001011", 8=> "11000000",   13=> "00010011", 12=> "00110101", 15=> "10001101", 14=> "01000110", 17=> "10010101", 16=> "10000110", 19=> "10010101", 18=> "10000110", 21=> "00111110", 20=> "00100010", 23=> "11011101", 22=> "11000000",   27=> "11001111", 26=> "11111011", 31=> "11001111", 30=> "11111011", 33=> "11111100", 32=> "00000101", 35=> "00110010", 34=> "01000101", others => "11100000");		
	
	begin
		mem_out <= outp(to_integer(unsigned(mem_radd)+1)) & outp(to_integer(unsigned(mem_radd)));

end behav;