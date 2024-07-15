library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Testbench is
end entity;

architecture behav of Testbench is
	
component TopLevel  is
	port (clk, rst: in std_logic;
			ip_out, r1_out, r2_out, r3_out, 
			r4_out, r5_out, r6_out, r7_out: out std_logic_vector(15 downto 0);
			carry, zero, pc_w1, lmsm_disable1 : out std_logic;
			ifid_data_out : out std_logic_vector(31 downto 0);
			idor_con_out : out std_logic_vector(28 downto 0);
			idor_instr_out : out std_logic_vector(11 downto 0);
			idor_pc_out : out std_logic_vector(15 downto 0);
			orex_con_out : out std_logic_vector(24 downto 0);
			orex_alua_out, orex_alub_out, orex_rega_out, orex_pc_out : out std_logic_vector(15 downto 0);
			exme_con_out : out std_logic_vector(20 downto 0);
			exme_aluc_out, exme_rega_out, exme_pc_out : out std_logic_vector(15 downto 0);
			mewb_con_out : out std_logic_vector(19 downto 0);
			mewb_aluc_out, mewb_mem_out, mewb_pc_out : out std_logic_vector(15 downto 0);

			rfw, pc_stall: out std_logic;
			haz_data1s, haz_data2s: out std_logic_vector(15 downto 0);
			haz_add1s, haz_add2s: out std_logic_vector(2 downto 0);
			haz_flag1s, haz_flag2s: out std_logic;
			stalls: out std_logic;
			
			pc_out_j: out std_logic_vector(15 downto 0);
			pc_con: out std_logic);
end component;
		
	signal reset, clock: std_logic;
	--signal reg1, reg2, reg3, reg7, ir_o_test: std_logic_vector(15 downto 0);
	signal ip, reg1, reg2, reg3, reg4, reg5, reg6, reg7: std_logic_vector(15 downto 0);
	signal zero, carry, pc_w1, lmsm_disable1, pc_stall: std_logic;
	signal ifid_data_out : std_logic_vector(31 downto 0);
	signal idor_con_out : std_logic_vector(28 downto 0);
	signal idor_instr_out : std_logic_vector(11 downto 0);
	signal idor_pc_out : std_logic_vector(15 downto 0);
	signal orex_con_out : std_logic_vector(24 downto 0);
	signal orex_alua_out, orex_alub_out, orex_rega_out, orex_pc_out : std_logic_vector(15 downto 0);
	signal exme_con_out : std_logic_vector(20 downto 0);
	signal exme_aluc_out, exme_rega_out, exme_pc_out : std_logic_vector(15 downto 0);
	signal mewb_con_out : std_logic_vector(19 downto 0);
	signal mewb_aluc_out, mewb_mem_out, mewb_pc_out : std_logic_vector(15 downto 0);
			
	signal rfw, stall, haz_flag1, haz_flag2: std_logic;
	signal haz_add1, haz_add2: std_logic_vector(2 downto 0);
	signal haz_data1, haz_data2: std_logic_vector(15 downto 0);
	signal pc_out_jump: std_logic_vector(15 downto 0);
	signal pc_cont: std_logic;

	--signal alu_t: std_logic_vector(4 downto 0);
	--signal testa, testb, testc, testd, teste, testf, 
		--	 testg, testh, testi, testj, testk, testl: std_logic_vector(15 downto 0);
	
	begin
	
		CKP: process 
			begin 
				CLOCK <= '1'; 
				wait for 10 ns; 
				CLOCK <= '0'; 
				wait for 10 ns;
				--assert (NOW < 2000000 ns) 
					--report "Simulation completed successfully.";
					--severity ERROR;
		end process CKP; 
	RESET <= '1', '0' after 15ns; 
	-- Apply to entity under test: 	
	
	test: TopLevel port map(clk => clock, rst => reset, 
									ip_out => ip, 
									r1_out => reg1, r2_out => reg2, r3_out => reg3,
									r4_out => reg4, r5_out => reg5, r6_out => reg6, 
									r7_out => reg7, carry => carry, zero => zero,
									
									ifid_data_out => ifid_data_out, 
									idor_con_out => idor_con_out, idor_instr_out => idor_instr_out,idor_pc_out => idor_pc_out, 
									
									orex_con_out => orex_con_out, orex_alua_out => orex_alua_out, orex_alub_out => orex_alub_out, 
									orex_rega_out => orex_rega_out, orex_pc_out => orex_pc_out,
									
									exme_con_out => exme_con_out, exme_aluc_out => exme_aluc_out, exme_rega_out => exme_rega_out, 
									exme_pc_out => exme_pc_out, mewb_con_out => mewb_con_out, mewb_aluc_out => mewb_aluc_out,
									
									mewb_mem_out => mewb_mem_out, mewb_pc_out => mewb_pc_out,
									
									pc_w1 => pc_w1, lmsm_disable1 => lmsm_disable1, pc_stall => pc_stall, rfw => rfw, stalls => stall, 
									haz_add1s => haz_add1, haz_data1s => haz_data1, haz_flag1s => haz_flag1, 
									haz_add2s => haz_add2, haz_data2s => haz_data2, haz_flag2s => haz_flag2,
									pc_out_j => pc_out_jump, pc_con => pc_cont);
	
end architecture;