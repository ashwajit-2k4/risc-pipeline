library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SE6 is
	port
	(
		i6: in std_logic_vector(5 downto 0);
		o16: out std_logic_vector(15 downto 0)
	);
end entity;

architecture behav of SE6 is
	signal so10 : std_logic_vector(9 downto 0) := (others => '0');
	begin
	
	gen0: for i in 0 to 9 generate
		so10(i) <= i6(5);
	end generate;
	
	o16 <= so10 & i6;
end architecture behav;

-- X --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SE8 is
	port
	(
		i8: in std_logic_vector(7 downto 0);
		o16: out std_logic_vector(15 downto 0)
	);
end entity;

architecture behav of SE8 is
	signal so8 : std_logic_vector(7 downto 0) := (others => '0');
	begin
	
	gen0: for i in 0 to 7 generate
		so8(i) <= i8(7);
	end generate;
	
	o16 <= so8 & i8;
end architecture behav;

-- X -- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SE9 is
	port
	(
		i9: in std_logic_vector(8 downto 0);
		o16: out std_logic_vector(15 downto 0)
	);
end entity;

architecture behav of SE9 is
	signal so7 : std_logic_vector(6 downto 0) := (others => '0');
	begin
	
	gen0: for i in 0 to 6 generate
		so7(i) <= i9(8);
	end generate;
	
	o16 <= so7 & i9;
end architecture behav;

-- X --


library ieee;
use ieee.std_logic_1164.all;

entity SE6_Module is
	port (ir_out: in std_logic_vector(15 downto 0); se6_out, mux_out: out std_logic_vector(15 downto 0));
end entity SE6_Module;

architecture Struct of SE6_Module is
	
	component Mux2to1_16 is
	port(
		i0_16, i1_16: in std_logic_vector(15 downto 0);
		sel1: in std_logic;
		o_16: out std_logic_vector(15 downto 0)
	);
	end component Mux2to1_16;

	component SE9 is
	port (
		i9: in std_logic_vector(8 downto 0);
		o16: out std_logic_vector(15 downto 0));
	end component;
	
	component SE6 is
		port (
			i6: in std_logic_vector(5 downto 0);
			o16: out std_logic_vector(15 downto 0));
	end component;

	signal se9_temp, se6_temp, mux_temp: std_logic_vector(15 downto 0);

begin
	signex_1: SE9 port map (ir_out(8 downto 0), se9_temp);
	signex_2: SE6 port map (ir_out(5 downto 0), se6_temp);
	
	-- if s7 s5 do it normally if s11 do it funny
	
	mux_se: Mux2to1_16 port map (se6_temp, se9_temp, ir_out(12), mux_temp);
	
	se6proc: process(se6_temp, ir_out)
	begin
		if (ir_out(15 downto 12) = "1100") then
			se6_out <= se6_temp(14 downto 0) & '0';
		else
			
			se6_out <= se6_temp;
		end if;
	end process;
	-- end of weird changes i made
	
	lsb_1:process(mux_temp)
	begin
		mux_out(0) <= '0';
		for i in 0 to 14 loop
			mux_out(i+1) <= mux_temp(i);
		end loop;
	end process;

end Struct;

--


	
	
									 