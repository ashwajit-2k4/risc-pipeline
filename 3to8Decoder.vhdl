library ieee;
use ieee.std_logic_1164.all;

entity decoder_3to8 is
    port(
        input : in std_logic_vector(2 downto 0);
        output : out std_logic_vector(7 downto 0)
    );
end decoder_3to8;

architecture gate_level of decoder_3to8 is
begin
    output(0) <= (not input(2)) and (not input(1)) and (not input(0));
    output(1) <= (not input(2)) and (not input(1)) and input(0);
    output(2) <= (not input(2)) and input(1) and (not input(0));
    output(3) <= (not input(2)) and input(1) and input(0);
    output(4) <= input(2) and (not input(1)) and (not input(0));
    output(5) <= input(2) and (not input(1)) and input(0);
    output(6) <= input(2) and input(1) and (not input(0));
    output(7) <= input(2) and input(1) and input(0);
end gate_level;