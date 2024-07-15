library ieee;
use ieee.std_logic_1164.all;

entity lmsm_controller is
	port (rst, clock: in std_logic;
			code: in std_logic_vector(3 downto 0);
			lmsm_bits: in std_logic_vector(7 downto 0);
			mem_w, rf_w: out std_logic; 
			reg_c: out std_logic_vector(2 downto 0);
			reg_r: out std_logic_vector(7 downto 0);
			lmsm_disable: out std_logic;
			state : out std_logic_vector(2 downto 0)
			);
end entity lmsm_controller;



architecture Struct of lmsm_controller is
	type state_lmsm is (rsts, s0, s1, s2, s3, s4, s5, s6, s7); 
	signal y_present, y_next: state_lmsm:=rsts;
	signal rm_w: std_logic;
	signal inp: std_logic_vector(7 downto 0);
begin
	clock_proc:process(clock,rst)
		begin
			if(rst='0') then
			if(rising_edge(clock)) then
				y_present <= y_next;
				end if;
			else
				y_present<=rsts; 
			end if;
		end process;
	
	state_transition_proc:process(code, y_present, inp)
	begin
	case y_present is
	when rsts=>
		if (code = "0110" or code = "0111") then
			y_next <= s0;
		else
			y_next <= rsts;
		end if;
		reg_c <= "000";
		state <= "000";
		rm_w <= '0';
		lmsm_disable <= '0';
		
	when s0=>
		y_next <= s1;
	
		reg_c <= "111";
		state <= "000";
		rm_w <= inp(0);
		lmsm_disable <= '1';
		
	when s1=>
		y_next <= s2;
	
		reg_c <= "110";
		state <= "001";
		rm_w <= inp(1);
		lmsm_disable <= '1';

	when s2=>
		y_next <= s3;
	
		reg_c <= "101";
		state <= "010";
		rm_w <= inp(2);
		lmsm_disable <= '1';

	when s3=>
		y_next <= s4;
	
		reg_c <= "100";
		state <= "011";
		rm_w <= inp(3);
		lmsm_disable <= '1';

	when s4=>
		y_next <= s5;
	
		reg_c <= "011";
		state <= "100";
		rm_w <= inp(4);
		lmsm_disable <= '1';

	when s5=>
		y_next <= s6;
	
		reg_c <= "010";
		state <= "101";
		rm_w <= inp(5);
		lmsm_disable <= '1';

	when s6=>
		y_next <= s7;
	
		reg_c <= "001";
		state <= "110";
		rm_w <= inp(6);
		lmsm_disable <= '1';

	when s7=>
		y_next <= rsts;
	
		reg_c <= "000";
		state <= "111";
		rm_w <= inp(7);
		lmsm_disable <= '0';
	end case;
	end process;

	reg_r <= "00000000" when (code = "0110") else
				inp;
	
	mem_w <= '0' when (code = "0110") else
				rm_w;
	
	rf_w <= rm_w when (code = "0110") else
			  '0';
	
	inp <= lmsm_bits;
end architecture;