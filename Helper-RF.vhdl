library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF is
port (
		clk, rf_w, rst: in std_logic; -- clock, write, reset signals
		r_d_in: in std_logic_vector(15 downto 0);
		r_a_in: in std_logic_vector(2 downto 0);
		pc_in: in std_logic_vector(15 downto 0);
		pc_w: in std_logic;
		r_a1_out: in std_logic_vector(2 downto 0);
		r_a2_out: in std_logic_vector(2 downto 0);
		r_d1_out: out std_logic_vector(15 downto 0);
		r_d2_out: out std_logic_vector(15 downto 0);
		pc, r1_out, r2_out, r3_out,
		r4_out, r5_out, r6_out, r7_out: out std_logic_vector(15 downto 0)
	);
end entity RF;

architecture behav of RF is

	type reg_arr is array(0 to 7) of std_logic_vector(15 downto 0);
	signal regf, reg_in : reg_arr := (others => "0000000000000000");
	
	begin
	pc <= regf(0);
	r1_out <= regf(1);
	r2_out <= regf(2);
	r3_out <= regf(3);
	r4_out <= regf(4);
	r5_out <= regf(5);
	r6_out <= regf(6);
	r7_out <= regf(7);
	r_d1_out <= regf(to_integer(unsigned(r_a1_out)));
	r_d2_out <= regf(to_integer(unsigned(r_a2_out)));
	
	behv: process(clk, rf_w, rst)
		begin
		if (rst = '1') then
			regf <= (others => "0000000000000000");
		else
			if (falling_edge(clk)) then
				if (not(r_a_in = "000")) then
					if (rf_w = '1') then
						regf(to_integer(unsigned(r_a_in))) <= r_d_in;
					end if;
					if (pc_w = '1') then
						regf(0) <= pc_in;
					end if;
				else 
					if (rf_w = '1') then
						regf(0) <= r_d_in;
					elsif (pc_w = '1') then
						regf(0) <= pc_in;
					else
						regf(0) <= regf(0);
					end if;
				end if;
			end if;
		end if;
	end process;
	

end architecture;