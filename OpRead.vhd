library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity OpRead is
port (
		clk, rst, pc_w: in std_logic; -- clock, write, reset signals
		inst: in std_logic_vector(11 downto 0);
		wb_reg, haz_flag1, haz_flag2: in std_logic;
		pc_inc, pc_brc: in std_logic_vector(15 downto 0);
		pc_cont: in std_logic;
		reg_sel: in std_logic_vector(3 downto 0);
		wb_data, haz_data1, haz_data2: in std_logic_vector(15 downto 0);
		wb_add: in std_logic_vector(2 downto 0);
		pc, r1_out, r2_out, r3_out,
		r4_out, r5_out, r6_out, r7_out: out std_logic_vector(15 downto 0);
		haz_add1, haz_add2: in std_logic_vector(2 downto 0);
		alu_a_out, alu_b_out, rega, regb: out std_logic_vector(15 downto 0)
	);
end entity OpRead;

architecture Struct of OpRead is
	
	component Mux2to1_16 is
	port(
		i0_16, i1_16: in std_logic_vector(15 downto 0);
		sel1: in std_logic;
		o_16: out std_logic_vector(15 downto 0)
	);
	end component Mux2to1_16;
	
	component Mux4to1_16 is
		port(
			i0_16, i1_16, i2_16, i3_16: in std_logic_vector(15 downto 0);
			sel2: in std_logic_vector(1 downto 0);
			o_16: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component SE6 is
		port
		(
			i6: in std_logic_vector(5 downto 0);
			o16: out std_logic_vector(15 downto 0)
		);
	end component;

	component SE9 is
		port
		(
			i9: in std_logic_vector(8 downto 0);
			o16: out std_logic_vector(15 downto 0)
		);
	end component;

	component RF is
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
	end component RF;

	signal se9_temp, se6_temp, rega_out, regb_out, pc_temp, pc_in, rega_out2, regb_out2: std_logic_vector(15 downto 0);
	signal mux1_sel, mux2_sel : std_logic_vector(1 downto 0);

	begin
	
	signex_6: SE9 port map (inst(8 downto 0), se9_temp);
	signex_9: SE6 port map (inst(5 downto 0), se6_temp);
	
	mux_rb_out: Mux4to1_16 port map (se9_temp, se6_temp, regb_out2, "0000000000000000", reg_sel(1 downto 0), alu_b_out);
	mux_ra_out: Mux4to1_16 port map (rega_out2, regb_out2, pc_temp, "0000000000000000", reg_sel(3 downto 2), alu_a_out);
	
	mux1_sel <= (haz_flag2 and (not or_reduce(inst(11 downto 9) xor haz_add2))) &
					(haz_flag1 and (not or_reduce(inst(11 downto 9) xor haz_add1)));
					
	mux2_sel <= (haz_flag2 and (not or_reduce(inst(8 downto 6) xor haz_add2))) &
					(haz_flag1 and (not or_reduce(inst(8 downto 6) xor haz_add1)));
	
	mux_haza: Mux4to1_16 port map (rega_out, haz_data1, haz_data2, haz_data1, mux1_sel, rega_out2);
	mux_hazb: Mux4to1_16 port map (regb_out, haz_data1, haz_data2, haz_data1, mux2_sel, regb_out2);
	regb <= regb_out;
	pc <= pc_temp;
	rega <= rega_out;
	Register_File: RF port map (  clk => clk, rf_w => wb_reg, rst => rst,
											r_d_in => wb_data,
											r_a_in => wb_add,
											pc_in => pc_in,
											pc_w => pc_w,
											r_a1_out => inst(11 downto 9),
											r_a2_out => inst(8 downto 6),
											r_d1_out => rega_out,
											r_d2_out => regb_out,
											pc => pc_temp, 
											r1_out => r1_out, 
											r2_out => r2_out, 
											r3_out => r3_out,
											r4_out => r4_out, 
											r5_out => r5_out, r6_out => r6_out, r7_out => r7_out);
											
	pc_mux: Mux2to1_16 port map (pc_inc, pc_brc, pc_cont , pc_in);
	
end architecture;