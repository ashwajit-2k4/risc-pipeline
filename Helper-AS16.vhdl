--16 bit adder subtractor AS16(A16, B16, M1, S16, Cout1) and full adder fa1(A1, B1, Cin1, S1, Cout1) 


-- full adder 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity fa1 is
	port(A1, B1, Cin1: in std_logic;
    	S1, Cout1: out std_logic);
end entity fa1;

architecture behav of fa1 is
    
    begin
    S1 <= A1 xor B1 xor Cin1;
    Cout1 <= (A1 and B1) or (Cin1 and (A1 xor B1));
    
end architecture behav;

-- 16 bit adder subtractor (<a15... a3 a2 a1 a0> <b15... b3 b2 b1 b0> M) (<Cout> <s15... s3 s2 s1 s0>)

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity AS16 is
   port (A16,B16 : in std_logic_vector(15 downto 0); M1: in std_logic;
	S16 : out std_logic_vector(15 downto 0); Cout1: out std_logic);	
end entity AS16;

architecture behav of AS16 is 
	signal Bnew16: std_logic_vector(15 downto 0) := (others => '0');
	signal csum17: std_logic_vector(16 downto 0) := (others => '0');
	
	component fa1
		port(A1, B1, Cin1: in std_logic;
    	S1, Cout1: out std_logic);
	end component fa1;
	
	begin
	csum17(0) <= M1;
	
	gen0: for i in 0 to 15 generate
		Bnew16(i) <= B16(i) xor M1;
		add0: fa1 port map (A16(i), Bnew16(i), csum17(i), S16(i), csum17(i+1));
	end generate gen0;
	
	Cout1 <= csum17(16);
	
end behav; 



