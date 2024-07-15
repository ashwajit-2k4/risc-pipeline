library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux4to1_16 is
	port(
		i0_16, i1_16, i2_16, i3_16: in std_logic_vector(15 downto 0);
		sel2: in std_logic_vector(1 downto 0);
		o_16: out std_logic_vector(15 downto 0)
	);
end entity;

architecture behav of Mux4to1_16 is
	begin
	o_16 <= i0_16 when (sel2 = "00") else
			  i1_16 when (sel2 = "01") else
			  i2_16 when (sel2 = "10") else
			  i3_16 when (sel2 = "11") else
			  (others => '0');
end architecture;

--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux4to1_3 is
	port(
		i0_3, i1_3, i2_3, i3_3: in std_logic_vector(2 downto 0);
		sel2: in std_logic_vector(1 downto 0);
		o_3: out std_logic_vector(2 downto 0)
	);
end entity;

architecture behav of Mux4to1_3 is
	begin
	o_3 <= i0_3 when (sel2 = "00") else
			  i1_3 when (sel2 = "01") else
			  i2_3 when (sel2 = "10") else
			  i3_3 when (sel2 = "11") else
			  (others => '0');
end architecture;

--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux8to1_16 is
	port(
		i0_16, i1_16, i2_16, i3_16, i4_16, i5_16, i6_16, i7_16: in std_logic_vector(15 downto 0);
		sel3: in std_logic_vector(2 downto 0);
		o_16: out std_logic_vector(15 downto 0)
	);
end entity;

architecture behav of Mux8to1_16 is
	begin
	o_16 <= i0_16 when (sel3 = "000") else
			  i1_16 when (sel3 = "001") else
			  i2_16 when (sel3 = "010") else
			  i3_16 when (sel3 = "011") else
			  i4_16 when (sel3 = "100") else
			  i5_16 when (sel3 = "101") else
			  i6_16 when (sel3 = "110") else
			  i7_16 when (sel3 = "111") else
			  (others => '0');
end architecture;

--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux2to1_16 is
	port(
		i0_16, i1_16: in std_logic_vector(15 downto 0);
		sel1: in std_logic;
		o_16: out std_logic_vector(15 downto 0)
	);
end entity;

architecture behav of Mux2to1_16 is
	begin
	o_16 <= i0_16 when (sel1 = '0') else
			  i1_16 when (sel1 = '1') else
			  (others => '0');
end architecture;

--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux2to1_32 is
	port(
		i0_32, i1_32: in std_logic_vector(31 downto 0);
		sel1: in std_logic;
		o_32: out std_logic_vector(31 downto 0)
	);
end entity;

architecture behav of Mux2to1_32 is
	begin
	o_32 <= i0_32 when (sel1 = '0') else
			  i1_32 when (sel1 = '1') else
			  (others => '0');
end architecture;

--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux2to1_3 is
	port(
		i0_3, i1_3: in std_logic_vector(2 downto 0);
		sel1: in std_logic;
		o_16: out std_logic_vector(2 downto 0)
	);
end entity;

architecture behav of Mux2to1_3 is
	begin
	o_16 <= i0_3 when (sel1 = '0') else
			  i1_3 when (sel1 = '1') else
			  (others => '0');
end architecture;