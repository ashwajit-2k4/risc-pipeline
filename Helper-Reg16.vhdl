library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg16 is
	port(Clk, Reset, Enable : in std_logic;
			data_in : in std_logic_vector(15 downto 0);
			data_out : out std_logic_vector(15 downto 0));
end entity;

architecture behav of Reg16 is
	signal regdata: std_logic_vector(15 downto 0) := (others => '0');
	
	begin
	
	data_out <= regdata;
	
	regproc: process(clk, Reset, Enable, data_in, regdata)
		begin
		if (Reset = '1' and falling_edge(clk)) then
			regdata <= (others => '0');
		elsif (Enable = '1' and falling_edge(clk)) then
				regdata <= data_in;
		else 
				regdata <= regdata;
		end if;
		
	end process;
	
end architecture;

--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg1b is
	port(Clk, Reset, Enable : in std_logic;
			data_in : in std_logic;
			data_out : out std_logic);
end entity;

architecture behav of Reg1b is
	signal regdata: std_logic := '0';
	
	begin
	
	data_out <= regdata;
	
	regproc: process(clk, Reset, Enable, data_in, regdata)
		begin
		if (Reset = '1' and falling_edge(clk)) then
			regdata <= '0';		
		elsif (Enable = '1' and falling_edge(clk)) then
				regdata <= data_in;
		else 
				regdata <= regdata;
		end if;
		
	end process;
	
end architecture;

--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg32 is
	port(Clk, Reset, Enable : in std_logic;
			data_in : in std_logic_vector(31 downto 0);
			data_out : out std_logic_vector(31 downto 0));
end entity;

architecture behav of Reg32 is
	signal regdata: std_logic_vector(31 downto 0) := (others => '0');
	
	begin
	
	data_out <= regdata;
	
	regproc: process(clk, Reset, Enable, data_in, regdata)
		begin
		if (Reset = '1' and falling_edge(clk)) then
			regdata <= (others => '0');
		elsif (Enable = '1' and falling_edge(clk)) then
				regdata <= data_in;
		else 
				regdata <= regdata;
		end if;
		
	end process;
	
end architecture;
----
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg32_IFID is
	port(Clk, Reset,  Enable : in std_logic;
			init,data_in : in std_logic_vector(31 downto 0);
			data_out : out std_logic_vector(31 downto 0));
end entity;

architecture behav of Reg32_IFID is
	signal regdata: std_logic_vector(31 downto 0) := (others => '0');
	
	begin
	
	data_out <= regdata;
	
	regproc: process(clk, Reset, Enable, data_in, regdata)
		begin
		if (Reset = '1' and falling_edge(clk)) then
			regdata <= init;
		elsif (Enable = '1' and falling_edge(clk)) then
				regdata <= data_in;
		else 
				regdata <= regdata;
		end if;
		
	end process;
	
end architecture;
