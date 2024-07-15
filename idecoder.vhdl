library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity idecoder is
	port(
		reset, clk: in std_logic;
		instr: in std_logic_vector(15 downto 0);
		code: out std_logic_vector(27 downto 0);
		lmsm_dis : out std_logic;
		lmsm_state : out std_logic_vector(2 downto 0)
	);
end entity;

architecture behav of idecoder is

	component decoder_3to8 is
    port(
        input : in std_logic_vector(2 downto 0);
        output : out std_logic_vector(7 downto 0)
    );
	end component;
	
	component lmsm_controller is
	port (rst, clock: in std_logic;
			code: in std_logic_vector(3 downto 0);
			lmsm_bits: in std_logic_vector(7 downto 0);
			mem_w, rf_w: out std_logic; 
			reg_c: out std_logic_vector(2 downto 0);
			reg_r: out std_logic_vector(7 downto 0);
			lmsm_disable : out std_logic;
			state : out std_logic_vector(2 downto 0)
			);
	end component;
	
	
	signal decode1, decode2, reg_r_lmsm: std_logic_vector(7 downto 0);
	signal mem_w_lmsm, rf_w_lmsm, lmsm_disable: std_logic;
	signal reg_w_lmsm, lmsm_state_temp: std_logic_vector(2 downto 0);
	begin
	LMSMHandler: lmsm_controller port map(rst => reset, clock => clk, code => instr(15 downto 12), lmsm_bits => instr(7 downto 0), 
	mem_w => mem_w_lmsm, rf_w => rf_w_lmsm, reg_c => reg_w_lmsm, reg_r => reg_r_lmsm, lmsm_disable => lmsm_disable, state => lmsm_state_temp);
	lmsm_dis <= lmsm_disable;
	Decoder1: decoder_3to8 port map(input => instr(11 downto 9), output => decode1);
	Decoder2: decoder_3to8 port map(input => instr(8 downto 6), output => decode2);
	
	lmsm_state <= lmsm_state_temp;
	
	---RIJ(2)CZDep(2)ALU_CODE(4)ALU_SEL(4)HAZARD(3)RF_W(1)MEM_W(1)REG_W(3)REG_R(8)
	code(27 downto 26) <=  "00" when (instr(15 downto 12) = "0001") else
							   "01" when (instr(15 downto 12) = "0000") else
							   "00" when (instr(15 downto 12) = "0010") else
							   "11" when (instr(15 downto 12) = "0011") else
							   "01" when (instr(15 downto 12) = "0100") else
							   "01" when (instr(15 downto 12) = "0101") else
							   "11" when (instr(15 downto 12) = "0110") else
							   "11" when (instr(15 downto 12) = "0111") else
							   "01" when (instr(15 downto 12) = "1000") else
							   "01" when (instr(15 downto 12) = "1001") else
							   "01" when (instr(15 downto 12) = "1010") else
							   "11" when (instr(15 downto 12) = "1100") else
							   "01" when (instr(15 downto 12) = "1101") else
							   "11" when (instr(15 downto 12) = "1111") else
								"10" when (instr(15 downto 12) = "1110") else
							  (others => '0');
						
	code(25 downto 24) <= "01" when (instr(15 downto 12) & instr(2 downto 0) = "0001010") else
							   "10" when (instr(15 downto 12) & instr(2 downto 0) = "0001001") else 
								"01" when (instr(15 downto 12) & instr(2 downto 0) = "0010010") else
							   "10" when (instr(15 downto 12) & instr(2 downto 0) = "0010001") else 
								"01" when (instr(15 downto 12) & instr(2 downto 0) = "0001110") else
							   "10" when (instr(15 downto 12) & instr(2 downto 0) = "0001101") else 
								"01" when (instr(15 downto 12) & instr(2 downto 0) = "0010110") else
							   "10" when (instr(15 downto 12) & instr(2 downto 0) = "0010101") else 
							  (others => '0');
							 
	code(23 downto 20) <=  "0001" when (instr(15 downto 12) & instr(2 downto 0) = "0001000") else
							   "0001" when (instr(15 downto 12) & instr(2 downto 0) = "0001010") else
							   "0001" when (instr(15 downto 12) & instr(2 downto 0) = "0001001") else
							   "1001" when (instr(15 downto 12) & instr(2 downto 0) = "0001011") else
							   "0101" when (instr(15 downto 12) & instr(2 downto 0) = "0001100") else
							   "0101" when (instr(15 downto 12) & instr(2 downto 0) = "0001110") else
							   "0101" when (instr(15 downto 12) & instr(2 downto 0) = "0001101") else
							   "1101" when (instr(15 downto 12) & instr(2 downto 0) = "0001111") else
							   "1110" when (instr(15 downto 12)  = "0000") else
							   "0010" when (instr(15 downto 12) & instr(2 downto 0) = "0010000") else
							   "0010" when (instr(15 downto 12) & instr(2 downto 0) = "0010010") else
							   "0010" when (instr(15 downto 12) & instr(2 downto 0) = "0010001") else
							   "1010" when (instr(15 downto 12) & instr(2 downto 0) = "0010100") else
							   "1010" when (instr(15 downto 12) & instr(2 downto 0) = "0010110") else
							   "1010" when (instr(15 downto 12) & instr(2 downto 0) = "0010101") else
							   "0011" when (instr(15 downto 12)  = "0011") else
							   "1111" when (instr(15 downto 12)  = "0100") else
							   "1111" when (instr(15 downto 12)  = "0101") else
							   "1111" when (instr(15 downto 12)  = "0110") else
							   "1111" when (instr(15 downto 12)  = "0111") else
							   "1000" when (instr(15 downto 12)  = "1000") else
							   "1011" when (instr(15 downto 12)  = "1001") else
							   "0111" when (instr(15 downto 12)  = "1010") else
							   "1111" when (instr(15 downto 12)  = "1100") else
							   "0000" when (instr(15 downto 12)  = "1101") else
							   "1111" when (instr(15 downto 12)  = "1111") else
								"0000" when (instr(15 downto 12)  = "1110") else
							  (others => '0');
							  
	code(19 downto 16) <=  "0010" when (instr(15 downto 12) = "0001") else
							   "0001" when (instr(15 downto 12) = "0000") else
							   "0010" when (instr(15 downto 12) = "0010") else
							   "1100" when (instr(15 downto 12)  = "0011") else
							   "0101" when (instr(15 downto 12)  = "0100") else
							   "0101" when (instr(15 downto 12)  = "0101") else
							   "0000" when (instr(15 downto 12)  = "0110") else
							   "0000" when (instr(15 downto 12)  = "0111") else
							   "1001" when (instr(15 downto 12)  = "1000") else
							   "1001" when (instr(15 downto 12)  = "1001") else
							   "1001" when (instr(15 downto 12)  = "1010") else
							   "1000" when (instr(15 downto 12)  = "1100") else
							   "0100" when (instr(15 downto 12)  = "1101") else
							   "0000" when (instr(15 downto 12)  = "1111") else
								"1111" when (instr(15 downto 12)  = "1110") else
							  (others => '0');
							  
	code(15 downto 13) <=  "000" when (instr(15 downto 12) = "0001") else
						   "000" when (instr(15 downto 12) = "0000") else
						   "000" when (instr(15 downto 12) = "0010") else
						   "111" when (instr(15 downto 12)  = "0011") else
						   "001" when (instr(15 downto 12)  = "0100") else
						   "010" when (instr(15 downto 12)  = "0101") else
						   "001" when (instr(15 downto 12)  = "0110") else
						   "010" when (instr(15 downto 12)  = "0111") else
						   "011" when (instr(15 downto 12)  = "1000") else
				   		"011" when (instr(15 downto 12)  = "1001") else
							"011" when (instr(15 downto 12)  = "1010") else
						   "100" when (instr(15 downto 12)  = "1100") else
						   "101" when (instr(15 downto 12)  = "1101") else
						   "110" when (instr(15 downto 12)  = "1111") else
							"000" when (instr(15 downto 12)  = "1110") else
							(others => '0');
							
							
	code(12 downto 11) <=  "10" when (instr(15 downto 12) = "0001") else
						   "10" when (instr(15 downto 12) = "0000") else
						   "10" when (instr(15 downto 12) = "0010") else
						   "10" when (instr(15 downto 12)  = "0011") else
						   "10" when (instr(15 downto 12)  = "0100") else
						   "01" when (instr(15 downto 12)  = "0101") else
						   rf_w_lmsm & mem_w_lmsm when (instr(15 downto 12)  = "0110") else
						   "01" when (instr(15 downto 12)  = "0111") else
						   "00" when (instr(15 downto 12)  = "1000") else
				   		"00" when (instr(15 downto 12)  = "1001") else
							"00" when (instr(15 downto 12)  = "1010") else
						   "10" when (instr(15 downto 12)  = "1100") else
						   "10" when (instr(15 downto 12)  = "1101") else
						   "00" when (instr(15 downto 12)  = "1111") else
							"00" when (instr(15 downto 12)  = "1110") else
							(others => '0');
							
	code(10 downto 8) <=  instr(5 downto 3) when (instr(15 downto 12) = "0001") else
						   instr(8 downto 6) when (instr(15 downto 12) = "0000") else
						   instr(5 downto 3) when (instr(15 downto 12) = "0010") else
						   instr(11 downto 9) when (instr(15 downto 12)  = "0011") else
						   instr(11 downto 9) when (instr(15 downto 12)  = "0100") else
						   "000" when (instr(15 downto 12)  = "0101") else
						   reg_w_lmsm when (instr(15 downto 12)  = "0110") else
						   "000" when (instr(15 downto 12)  = "0111") else
						   "000" when (instr(15 downto 12)  = "1000") else
				   		"000" when (instr(15 downto 12)  = "1001") else
							"000" when (instr(15 downto 12)  = "1010") else
						   instr(11 downto 9) when (instr(15 downto 12)  = "1100") else
						   instr(11 downto 9) when (instr(15 downto 12)  = "1101") else
						   "000" when (instr(15 downto 12)  = "1111") else
							"000" when (instr(15 downto 12)  = "1110") else
							(others => '0');
							
	code(7 downto 0) <=  (decode1 or decode2) when (instr(15 downto 12) = "0001") else
						   (decode1) when (instr(15 downto 12) = "0000") else
						   (decode1 or decode2) when (instr(15 downto 12) = "0010") else
						   "00000000" when (instr(15 downto 12)  = "0011") else
						   decode2 when (instr(15 downto 12)  = "0100") else
						   (decode1 or decode2) when (instr(15 downto 12)  = "0101") else
						   decode1 when (instr(15 downto 12)  = "0110") else
						   reg_r_lmsm when (instr(15 downto 12)  = "0111") else
						   (decode1 or decode2) when (instr(15 downto 12)  = "1000") else
				   		(decode1 or decode2) when (instr(15 downto 12)  = "1001") else
							(decode1 or decode2) when (instr(15 downto 12)  = "1010") else
						   "00000000" when (instr(15 downto 12)  = "1100") else
						   decode2 when (instr(15 downto 12)  = "1101") else
						   decode1 when (instr(15 downto 12)  = "1111") else
							"00000000" when (instr(15 downto 12)  = "1110") else
							(others => '0');
							

end architecture;