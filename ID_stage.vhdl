library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_stage is
	port(Clk, reset: in std_logic;
		  instr_in, pc_inp   : in std_logic_vector(15 downto 0);
		  lmsm_disable: out std_logic;
		  code_out: out std_logic_vector(27 downto 0);
		  pc_out  : out std_logic_vector(15 downto 0);
		  data_out: out std_logic_vector(11 downto 0));
end entity;

architecture behav of ID_stage is
	signal mem_out: std_logic_vector(15 downto 0) := (others => '0');
	signal pc_in: std_logic_vector(15 downto 0) := (others => '0');
	signal decode_out: std_logic_vector(27 downto 0) := "1000000011110000000000000000";
	signal lmsm_dis : std_logic;
	signal lmsm_state: std_logic_vector(2 downto 0);
	component idecoder is
	port(
		reset, clk: in std_logic;
		instr: in std_logic_vector(15 downto 0);
		code: out std_logic_vector(27 downto 0);
		lmsm_dis : out std_logic;
		lmsm_state : out std_logic_vector(2 downto 0)
	);
	end component;
	
	begin
	decoder: idecoder port map(reset => reset, clk => Clk, instr => instr_in, code => decode_out, lmsm_dis => lmsm_dis, lmsm_state => lmsm_state);
	data_out(11 downto 0) <= "000000000" & lmsm_state when instr_in(15 downto 13) = "011" else
								    instr_in(11 downto 0);
	pc_out <= pc_inp;
	lmsm_disable <= lmsm_dis;
	code_out <= decode_out;
end architecture;


