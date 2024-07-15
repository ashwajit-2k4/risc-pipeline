library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WriteBack is
port (
		hazard: in std_logic_vector(2 downto 0);
		pc_in: in std_logic_vector(15 downto 0);
		alu_in: in std_logic_vector(15 downto 0);
		mem_in: in std_logic_vector(15 downto 0);
		r_d_in: out std_logic_vector(15 downto 0)
	);
end entity WriteBack;

architecture Struct of WriteBack is
begin
	r_d_in <= pc_in when (hazard = "100" or hazard = "101") else
				 mem_in when (hazard = "001") else
				 alu_in;
end architecture;