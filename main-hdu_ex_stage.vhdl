library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity hdu_ex  is
port (
	reg_w: in std_logic;
	reg_w_ex: in std_logic_vector(2 downto 0);
	reg_r_or: in std_logic_vector(7 downto 0);
	alu_out: in std_logic_vector(15 downto 0);
	haz_code_ex: in std_logic_vector(2 downto 0);
	
	hdu_ex_mux: out std_logic;
	
	pc_w, pr_if_w, pr_id_w, pr_or_w, pr_ex_w, pr_ma_w: out std_logic;
	hdu_ex_out: out std_logic_vector(15 downto 0)
); 
end entity;

architecture behav of hdu_ex is
	
	signal reg_w_arr : std_logic_vector(7 downto 0) := (others => '0');
	signal reg_haz_flag: std_logic := '0';
	signal stall : std_logic := '0' ;
	
	component decoder_3to8enb is
    port(
        input : in std_logic_vector(2 downto 0);
		  enable: in std_logic;
        output : out std_logic_vector(7 downto 0)
    );
	end component decoder_3to8enb;
	
	
	begin
	
	hdu_ex_out <= alu_out;
	
	-- convert the 3 bit code for the register we're writing to into 8 bit one hot, ANDED with reg_w control signal
	decoder_3to8enb_1: decoder_3to8enb port map (input => reg_w_ex,
																enable => reg_w,
																output => reg_w_arr);
	
	-- if there is any hazard -> activate flag 
	reg_haz_flag <= or_reduce( std_logic_vector( unsigned( reg_w_arr and reg_r_or ) ) );
	
	-- if AL instruction and there is a hazard activate mux for forwarding
	hdu_ex_mux <= '1' when ((haz_code_ex = "000") and (reg_haz_flag = '1')) else '0';
	
	-- if AL instruction and there is a hazard activate mux for forwarding
	stall <= '1' when ((haz_code_ex = "010") and (reg_haz_flag = '1')) else '0';
	
	pc_w <= '0' when (stall = '1') else '1';
	pr_if_w <= '0' when (stall = '1') else '1';
	pr_id_w <= '0' when (stall = '1') else '1';
	pr_or_w <= '0' when (stall = '1') else '1';
	pr_ex_w <= '1';
	pr_ma_w <= '1';
	
	
end architecture;