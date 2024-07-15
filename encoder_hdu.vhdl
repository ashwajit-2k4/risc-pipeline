library ieee;
use ieee.std_logic_1164.all;

entity encoder_hdu is
    port(
        input : in std_logic_vector(7 downto 0);
		  enable: in std_logic;
        output : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behav of encoder_hdu is
	begin
	output(0) <= enable and (input(0) or input(1) or input(5) or input(7)); -- 1, 3, 5, 7
	output(1) <= enable and (input(2) or input(3) or input(6) or input(7)); -- 2 ,3, 6, 7
	output(2) <= enable and (input(4) or input(5) or input(6) or input(7)); -- 4, 5, 6, 7
	 
end architecture;