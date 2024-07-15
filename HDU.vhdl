library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity hdu  is
	port (
		reg_w_wb_cs, reg_w_mem_cs, reg_w_ex_cs: in std_logic; -- register write enables
		reg_w_ex_code, reg_w_mem_code, reg_w_wb_code: in std_logic_vector(2 downto 0); -- address of register written to
		reg_r_or: in std_logic_vector(7 downto 0); -- registers being read at the current moment, causing hazard
		
		pc_ex_out, aluc_ex, mem_data, mem_pc, mem_alu_data, wb_out: in std_logic_vector(15 downto 0); -- forwarded data
		haz_code_wb, haz_code_mem, haz_code_ex: in std_logic_vector(2 downto 0); -- hazard codes for the 3 instructions after or
		
		pc_w, pr_if_w, pr_id_w, pr_or_w: out std_logic; -- control signals used to disable pipeline register write in order to stall
		
		haz_data1, haz_data2: out std_logic_vector(15 downto 0);
		haz_add1, haz_add2: out std_logic_vector(2 downto 0);
		haz_flag1, haz_flag2, stall: out std_logic); 
end entity;



architecture behav of hdu is
	-- 8 bits 1 hot encoding for which register you write to 
	signal reg_w_arr_ex, reg_w_arr_mem, reg_w_arr_wb : std_logic_vector(7 downto 0)  := (others => '0'); 
	
	-- 8 bit 1 hot register that is being read (reg_r may have 2 registers being read)
	signal haz_ex_r, haz_mem_r, haz_wb_r : std_logic_vector(7 downto 0)  := (others => '0');
	
	-- address of the two registers being read at the moment
	signal reg1, reg2: std_logic_vector(2 downto 0) := (others => '0');
	
	-- 3 bit address of register being read 
	signal haz_add_ex, haz_add_mem, haz_add_wb: std_logic_vector(2 downto 0) := (others => '0');
	signal ex_out, mem_out: std_logic_vector(15 downto 0) := (others => '0'); --, wb_out
	
	-- check dependancy for that stage
	signal haz_flag_ex_or, haz_flag_mem_or, haz_flag_wb_or, haz_flag_sig: std_logic := '0';
	
	--decide to stall
	signal stallf : std_logic := '0' ;
	
	component decoder_3to8enb is
    port(
        input : in std_logic_vector(2 downto 0);
		  enable: in std_logic;
        output : out std_logic_vector(7 downto 0)
   );
	end component decoder_3to8enb;
	
	
	component hp_encoder is
		 port(
			  input : in std_logic_vector(7 downto 0);
			  output : out std_logic_vector(2 downto 0)
		 );
	end component;
	
	component lp_encoder is
		 port(
			  input : in std_logic_vector(7 downto 0);
			  output : out std_logic_vector(2 downto 0)
		 );
	end component;
	
	
	begin
	
	-- 8 bits 1 hot encoding for which register you write to 
	dec_ex: decoder_3to8enb port map (input => reg_w_ex_code, enable => reg_w_ex_cs,output => reg_w_arr_ex);														
	dec_mem: decoder_3to8enb port map (input => reg_w_mem_code, enable => reg_w_mem_cs, output => reg_w_arr_mem);										
	dec_wb: decoder_3to8enb port map (input => reg_w_wb_code, enable => reg_w_wb_cs, output => reg_w_arr_wb);
										
	hp_enc_1:  hp_encoder port map(input => reg_r_or, output => reg1);
	lp_enc_1:  lp_encoder port map(input => reg_r_or, output => reg2);
	
	haz_ex_r <= reg_w_arr_ex and reg_r_or;
	haz_mem_r <= reg_w_arr_mem and reg_r_or;
	haz_wb_r <= reg_w_arr_wb and reg_r_or;
												 
	-- enable hazard flags for these: compare register you're writing to and register you're reading from
	haz_flag_ex_or <= or_reduce(haz_ex_r);
	haz_flag_mem_or <= or_reduce(haz_mem_r);
	haz_flag_wb_or <= or_reduce(haz_wb_r);

	-- decide what data needs to be forwarded by choosing within each stage and then choosing among each stage
	ex_out <= pc_ex_out when (haz_code_ex = "100" or haz_code_ex = "101") else
				 aluc_ex;
	
	mem_out <= mem_pc when (haz_code_mem = "100" or haz_code_mem = "101") else
				  mem_data when (haz_code_mem = "001") else
				  mem_alu_data;
	
	-- don't need to define wb_out cause ashwajit already did it in wb stage
	
	haz_data1 <=  ex_out    when ( (reg_w_ex_code = reg1) and (reg_w_ex_cs = '1')) else
					  mem_out   when ( (reg_w_mem_code = reg1) and (reg_w_mem_cs = '1') ) else
					  wb_out    when ( (reg_w_wb_code = reg1) and (reg_w_wb_cs = '1')) else
					  (others => 'U');
	
	haz_data2 <=  ex_out    when ( (reg_w_ex_code = reg2) and (reg_w_ex_cs = '1')) else
					  mem_out   when ( (reg_w_mem_code = reg2) and (reg_w_mem_cs = '1')) else
					  wb_out    when ( (reg_w_wb_code = reg2) and (reg_w_wb_cs = '1')) else
					  (others => 'U');
					  
	haz_add1 <= reg1;
	haz_add2 <= reg2;
	
	haz_flag1 <= '1'  when ( (reg_w_ex_code = reg1) and (reg_w_ex_cs = '1') and not(haz_code_ex = "001")) else
					  '0'  when ( (reg_w_ex_code = reg1) and (reg_w_ex_cs = '1') and (haz_code_ex = "001")) else
					  '1' when ( (reg_w_mem_code = reg1) and (reg_w_mem_cs = '1') ) else
					  '1' when ( (reg_w_wb_code = reg1) and (reg_w_wb_cs = '1')) else
					  '0';
					  
	haz_flag2 <= '1'  when ( (reg_w_ex_code = reg2) and (reg_w_ex_cs = '1') and not(haz_code_ex = "001")) else
					  '0'  when ( (reg_w_ex_code = reg2) and (reg_w_ex_cs = '1') and (haz_code_ex = "001")) else
					  '1' when ( (reg_w_mem_code = reg2) and (reg_w_mem_cs = '1') ) else
					  '1' when ( (reg_w_wb_code = reg2) and (reg_w_wb_cs = '1')) else
					  '0';
					  
	-- disable pipeline registers to stall
	stallf <= '1' when (haz_flag_ex_or = '1' and (haz_code_ex = "001")) else '0';
	stall <= stallf;
	--pr_ex_cs<= '0' when (stallf = '1') else '1';
	pc_w    <= '0' when (stallf = '1') else '1';
	pr_if_w <= '0' when (stallf = '1') else '1';
	pr_id_w <= '0' when (stallf = '1') else '1';
	pr_or_w <= '0' when (stallf = '1') else '1'; 
	
end architecture;