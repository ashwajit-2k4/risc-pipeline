library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity TopLevel  is
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
			pc_con: out std_logic;
			instro : out std_logic_vector(15 downto 0)
			
			);
end entity;

architecture behav of TopLevel is
	component Reg1b is
		port(Clk, Reset, Enable : in std_logic;
				data_in : in std_logic;
				data_out : out std_logic);
	end component;

		component Reg1c is
		port(Clk, Reset, Enable : in std_logic;
				data_in : in std_logic;
				data_out : out std_logic);
	end component;

	component IF_stage is
		port(pc_w_sel: in std_logic;
			  alu_pc_out, ir_mux_out, pc : in std_logic_vector(15 downto 0);
			  instr, pc_4_out : out std_logic_vector(15 downto 0));
	end component;
	
	component Reg16 is
		port(Clk, Reset, Enable : in std_logic;
				data_in : in std_logic_vector(15 downto 0);
				data_out : out std_logic_vector(15 downto 0));
	end component;
	component Reg32 is
		port(Clk, Reset, Enable : in std_logic;
				data_in : in std_logic_vector(31 downto 0);
				data_out : out std_logic_vector(31 downto 0));
	end component;
	
	component Reg32_IFID is
		port(Clk, Reset,  Enable : in std_logic;
				init,data_in : in std_logic_vector(31 downto 0);
				data_out : out std_logic_vector(31 downto 0));
	end component;
	
	
	component ID_stage is
		port(Clk, reset: in std_logic;
			  instr_in, pc_inp   : in std_logic_vector(15 downto 0);
			  lmsm_disable: out std_logic;
			  code_out: out std_logic_vector(27 downto 0);
			  pc_out  : out std_logic_vector(15 downto 0);
			  data_out: out std_logic_vector(11 downto 0));
	end component;
	
	component OpRead is
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
	end component OpRead;

	component Dmem  is
		port (clk, mem_w: in std_logic; 
					mem_wadd: in std_logic_vector(15 downto 0); 
					mem_val: in std_logic_vector(15 downto 0); 
					mem_radd: in std_logic_vector(15 downto 0);
					mem_out: out std_logic_vector(15 downto 0)); -- testing remove
	end component;
	
	component memstage is
		port (clk, mem_w: in std_logic; 
					pc_mem_in, mem_wadd: in std_logic_vector(15 downto 0); 
					mem_val: in std_logic_vector(15 downto 0); 
					mem_radd: in std_logic_vector(15 downto 0);
					mem_out: out std_logic_vector(15 downto 0);
					pc_mem_out: out std_logic_vector(15 downto 0)); -- testing remove
	end component;
	
	component Mux2to1_32 is
		port(
			i0_32, i1_32: in std_logic_vector(31 downto 0);
			sel1: in std_logic;
			o_32: out std_logic_vector(31 downto 0)
		);
	end component;

	component Mux2to1_16 is
		port(
			i0_16, i1_16: in std_logic_vector(15 downto 0);
			sel1: in std_logic;
			o_16: out std_logic_vector(15 downto 0)
		);
	end component;


	component WriteBack is
		port (
				hazard: in std_logic_vector(2 downto 0);
				pc_in: in std_logic_vector(15 downto 0);
				alu_in: in std_logic_vector(15 downto 0);
				mem_in: in std_logic_vector(15 downto 0);
				r_d_in: out std_logic_vector(15 downto 0)
			);
	end component WriteBack;

	component EX_stage is
		port(Clk, Reset : in std_logic;
			  alu_a, alu_b, pc_in, rega, regb : in std_logic_vector(15 downto 0);
			  check_control: in std_logic_vector(1 downto 0);
			  alu_control : in std_logic_vector(3 downto 0);
			  alu_c, pc_out_ex : out std_logic_vector(15 downto 0);
			  carry, zero, branch_control: out std_logic;
			  rf_w_in : in std_logic;
			  rf_w_out : out std_logic);
	end component;
	
	
	component hdu  is
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
	end component;	
	
	component jump_handler  is
		port 
			(
				branch_control: in std_logic;
				imm9_id: in std_logic_vector(8 downto 0);
				imm9_or: in std_logic_vector(8 downto 0);
				alu_out_ex: in std_logic_vector(15 downto 0);
				alua : in std_logic_vector(15 downto 0);
				pcplus2_if: in std_logic_vector(15 downto 0);
				
				haz_code_id: in std_logic_vector(2 downto 0);
				haz_code_or: in std_logic_vector(2 downto 0);
				haz_code_ex: in std_logic_vector(2 downto 0);
				
				pc_cont_jump: out std_logic;
				pc_out_if: out std_logic_vector(15 downto 0);
				pr_id_cs, pr_or_cs: out std_logic);
				-- pc_out_mux_cs: out std_logic
			 
	end component;
	


	--signal outp is the Dmem
	--signal pc_brc : std_logic_vector(15 downto 0);
	signal pc_cont : std_logic;
	signal pc_w_sel: std_logic;
	signal br_ip_out, br_instr_out, pc, instr: std_logic_vector(15 downto 0);
	signal pc_if, pc_id, pc_or, pc_ex, pc_me, pc_wb: std_logic_vector(15 downto 0);
	signal if_id_pr: std_logic_vector(31 downto 0);
	signal instr_11: std_logic_vector(11 downto 0);
	signal control_signals: std_logic_vector(27 downto 0);
	signal control_or, data_or, control_ex, aluin_ex, data_ex: std_logic_vector(31 downto 0);
	signal pc_w, lmsm_disable, rf_w_ex: std_logic;
	signal wb_add: std_logic_vector(2 downto 0);
	signal wb_data, alua_op, alub_op, rega: std_logic_vector(15 downto 0);
	signal reg1, reg2, reg3, reg4, reg5, reg6, reg7, alu_c_out, mem_out, regb: std_logic_vector(15 downto 0);
	signal control_mem, mem_pr_out, control_wb, wb_pr_out: std_logic_vector(31 downto 0);
	signal wb_pc, mem_pc: std_logic_vector(15 downto 0);
	
	signal ifid_pr_en, idor_pr_en, orex_pr_en, exme_pr_en, mewb_pr_en : std_logic := '1';
	
	signal wb_reg : std_logic;
	signal branch_control : std_logic;
	signal pred_bit : std_logic;
	
	signal haz_add1, haz_add2: std_logic_vector(2 downto 0) := (others => '0');
	signal haz_data1, haz_data2: std_logic_vector(15 downto 0) := (others => '0');
	signal haz_flag1, haz_flag2: std_logic := '0';
	
	signal orex_stall_data, orex_con_in: std_logic_vector(31 downto 0);
	signal orex_stall_sel_hdu, orex_stall_sel_jump, orex_stall_sel: std_logic;
	signal idor_stall_data, idor_con_in: std_logic_vector(31 downto 0);
	signal idor_stall_sel_jump, idor_stall_sel: std_logic;
	
	signal branch_pred_sel : std_logic_vector(1 downto 0);
	signal branch_pred_data : std_logic_vector(15 downto 0);
	
	signal ifid_pr_enable : std_logic;
	
	signal id_or_pr_cs, orex_pr_cs_in, exme_pr_cs_in, mewb_pr_cs_in: std_logic_vector(31 downto 0);
	
	signal data_in_ifid_pr, idor_data_pr_data_in, orex_pr_data_in, 
				exme_pr_data_in, mewb_pr_data_in, orex_alu_pr_data_in: std_logic_vector(31 downto 0);
	
	-- use this data for "output" of each stage that goes into hdu
	signal ex_data, mem_data, pc_out_ex: std_logic_vector(15 downto 0) := (others => '0');
	signal pc_stalls : std_logic := '0';
	
	--jump
	signal pc_out_jump: std_logic_vector(15 downto 0) := (others => '0');
	signal branch_control_bit: std_logic;
	
	begin
		
		ifid_pr_enable <= ((not lmsm_disable) and ifid_pr_en); 
		data_in_ifid_pr <= (pc_if & instr) when (pc_cont = '0') else ( (std_logic_vector(unsigned(pc_out_jump) + 2)) & instr); -- change the instruction being loaded when jump is active
		
		pred_bit <= '0'; --branch control signal
		id_or_pr_cs <= pred_bit & "000" & control_signals;
		idor_data_pr_data_in <= "0000" & instr_11 & pc_id;
		
		orex_pr_cs_in <= control_or(31) & "000000000" &  control_or(25 downto 20) & control_or(15 downto 0);
		orex_pr_data_in <= rega & data_or(15 downto 0);
		
		orex_alu_pr_data_in <= alua_op & alub_op;
		
		exme_pr_cs_in <= control_ex(31) & "0000000000000" &  control_ex(21 downto 20) & control_ex(15 downto 13) & rf_w_ex & control_ex(11 downto 0);
		exme_pr_data_in <= alu_c_out & data_ex(31 downto 16);
		
		mewb_pr_cs_in <= control_mem(31) & "00000000000000" &  control_mem(17 downto 12) & control_mem(10 downto 0);
		mewb_pr_data_in <= mem_pr_out(31 downto 16) & mem_out;
		
		pc_con <= pc_cont;
		pc_out_j <= pc_out_jump;
		
		IF_module: IF_stage port map (pc_w_sel => pc_cont, --needs to be changed for branch and jump
												alu_pc_out => pc_out_jump,  -- change this
												ir_mux_out => br_instr_out, 
												pc => pc, 
												instr => instr, 
												pc_4_out => pc_if);
		instro <= instr;
												
		--pc_w_sel, br_ip_out, br_instr_out come from branch
		-- pc comes from RF, pc_out goes there
		
		ifid_pr: Reg32_IFID port map (clk => clk, 
										reset => rst, 
										 --intialise with NOP
										Enable => ifid_pr_enable , --needs to be changed for branch
										init => "00000000000000001110000000000000",
										data_in => data_in_ifid_pr, 
										data_out => if_id_pr);
		
		ID_module: ID_stage port map (clk => clk, 
												reset => rst, 
												instr_in => if_id_pr(15 downto 0), 
												lmsm_disable=>lmsm_disable,
												pc_inp => if_id_pr(31 downto 16), 
												pc_out => pc_id, 
												data_out => instr_11, 
												code_out => control_signals);
		
		-- feed regular control signals or NOP when you want to stall into pr after id
		idor_stall_sel <= idor_stall_sel_jump;
		idor_con_mux: Mux2to1_32 port map (id_or_pr_cs, -- inp1
														"00000000000000001110000000000000", -- inp2
														idor_stall_sel, -- select
														idor_con_in); -- output
								
		---RIJ(25-24)ALU_CODE(23-20)ALU_SEL(19-16)HAZARD(15-13)RF_W(12)MEM_W(11)REG_W(10-8)REG_R(7-0)
		idor_con_pr: Reg32 port map (clk => clk, 
												reset => rst, 
												data_in => idor_con_in, 
												data_out => control_or, 
												Enable => idor_pr_en);
												
		idor_data_pr: Reg32 port map (clk => clk, 
												reset => rst, 
												data_in => idor_data_pr_data_in, 
												data_out => data_or, 
												Enable => idor_pr_en);
		
		--pc_cont <= or_reduce(branch_pred_sel);
		
		OR_module: OpRead port map (clk => clk, 
											 rst => rst, 
											 pc_w => pc_w, 
											 inst => data_or(27 downto 16), 
											 wb_reg => wb_reg, 
											 pc_inc => pc_if, 
											 pc_brc => pc_out_jump,--branch_pred_data, 
											 pc_cont => pc_cont, -- '0'
											 reg_sel => control_or(19 downto 16),
											 wb_data => wb_data, 
											 wb_add => wb_add, 
											 pc => pc,
											 r1_out => reg1, 
											 r2_out => reg2, 
											 r3_out => reg3, 
											 r4_out => reg4,
											 r5_out => reg5, 
											 r6_out => reg6, 
											 r7_out => reg7,
											 alu_a_out => alua_op, 
											 alu_b_out => alub_op, 
											 rega => rega,
											 regb => regb,
											 haz_add1 => haz_add1,
											 haz_add2 => haz_add2, 
											 haz_data1 => haz_data1,
											 haz_data2 => haz_data2, 
											 haz_flag1 => haz_flag1,
											 haz_flag2 => haz_flag2);
											 
		br_instr_out <= pc;
		
		-- stall select for orex pipeline register
		orex_stall_sel <= orex_stall_sel_hdu or orex_stall_sel_jump;
		
		orex_con_mux: Mux2to1_32 port map ( orex_pr_cs_in , 
														"00000000000000001110000000000000", --orex_stall_data, or NOP 
														orex_stall_sel,--orex_stall_sel,--'0',--pc_cont--orex_stall_sel, 
														orex_con_in);
		
		---RIJ(21-20)ALU_CODE(19-16)HAZARD(15-13)RF_W(12)MEM_W(11)REG_W(10-8)REG_R(7-0)
		orex_con_pr: Reg32 port map (clk => clk, 
											  reset => rst, 
											  data_in => orex_con_in, 
											  data_out => control_ex,
											  Enable => orex_pr_en);
											  
		orex_alu_pr: Reg32 port map (clk => clk, 
												reset => rst, 
												data_in => orex_alu_pr_data_in, 
												data_out => aluin_ex, 
												Enable => orex_pr_en);
												
		orex_data_pr: Reg32 port map (clk => clk, 
												reset => rst, 
												data_in => orex_pr_data_in, 
												data_out => data_ex, 
												Enable => orex_pr_en);
		
		EX_module: EX_stage port map (clk => clk, 
												reset => rst, 
												alu_a => aluin_ex(31 downto 16), 
												alu_b => aluin_ex(15 downto 0), 
												pc_in => data_ex(15 downto 0),	
										      check_control => control_ex(21 downto 20), 
												alu_control => control_ex(19 downto 16), 
												rega => rega,
												regb => regb,
												
												alu_c => alu_c_out,
												pc_out_ex => pc_out_ex,
												carry => carry, 
												zero => zero, 
												branch_control => branch_control_bit, 
												rf_w_in => control_ex(12), 
												rf_w_out => rf_w_ex);
		
		
		---RIJ(17-16)HAZARD(15-13)RF_W(12)MEM_W(11)REG_W(10-8)REG_R(7-0)
		exme_con_pr: Reg32 port map (clk => clk, 
											  reset => rst, 
											  data_in => exme_pr_cs_in,
											  data_out => control_mem, 
											  Enable => exme_pr_en);
											  
		exme_data_pr: Reg32 port map (clk => clk, 
												reset => rst, 
												data_in => exme_pr_data_in, 
												data_out => mem_pr_out, 
												Enable => exme_pr_en);
												
		exme_pc_pr: Reg16 port map (clk => clk, 
											reset => rst, 
											data_in => data_ex(15 downto 0), 
											data_out => mem_pc, 
											Enable => exme_pr_en);
		
		--Mem_Stage: memstage port map(	clk => clk,
		--										mem_w => control_mem(11), 
		--										pc_mem_in => 
		--										mem_wadd => mem_pr_out(31 downto 16), 
		--										mem_val => mem_pr_out(15 downto 0),
		--										mem_radd => mem_pr_out(31 downto 16), 
		--										mem_out => mem_out,
		--										pc_mem_out => pc_mem_out);
		

		
		Mem_module: Dmem port map (clk => clk, 
											mem_w => control_mem(11), 
											mem_wadd => mem_pr_out(31 downto 16), 
											mem_val => mem_pr_out(15 downto 0),
											mem_radd => mem_pr_out(31 downto 16), 
											mem_out => mem_out);

		---RIJ(16-15)HAZARD(14-12)RF_W(11)REG_W(10-8)REG_R(7-0)
		mewb_con_pr: Reg32 port map (clk => clk, 
											  reset => rst, 
											  data_in => mewb_pr_cs_in,
											  data_out => control_wb, 
											  Enable => mewb_pr_en);
											  
		mewb_data_pr: Reg32 port map (clk => clk, 
												reset => rst, 
												data_in => mewb_pr_data_in, 
												data_out => wb_pr_out, 
												Enable => mewb_pr_en);
												
		mewb_pc_pr: Reg16 port map (clk => clk, 
											reset => rst, 
											data_in => mem_pc, 
											data_out => wb_pc, 
											Enable => mewb_pr_en);
		
		WB_module: WriteBack port map (hazard => control_wb(14 downto 12), 
												pc_in => wb_pc, 
												alu_in => wb_pr_out(31 downto 16),
												mem_in => wb_pr_out(15 downto 0), 
												r_d_in => wb_data);
		
		wb_add <= control_wb(10 downto 8);
		wb_reg <= control_wb(11);
		rfw <= wb_reg; -- rf write output
		
		--idor_pr_en <= '1';
		--ifid_pr_en <= '1';
		--orex_pr_en <= '1';
		--exme_pr_en <= '1';
		--mewb_pr_en <= '1';
		
		ip_out <= pc;
		r1_out <= reg1;
		r2_out <= reg2;
		r3_out <= reg3;
		r4_out <= reg4;
		r5_out <= reg5;
		r6_out <= reg6;
		r7_out <= reg7;
		pc_w <= (not lmsm_disable);-- and (not pc_stalls);
		
		ifid_data_out <= if_id_pr;
		
		idor_con_out <= control_or(31) & control_or(27 downto 0);
		idor_instr_out <= data_or(27 downto 16);
		idor_pc_out <= data_or(15 downto 0);
		
		orex_con_out <= control_ex(31) & control_ex(23 downto 0);
		orex_alua_out <= aluin_ex(31 downto 16);
		orex_alub_out <= aluin_ex(15 downto 0);
		orex_rega_out <= data_ex(31 downto 16);
		orex_pc_out <= data_ex(15 downto 0);
		pc_w1 <= pc_w;
		exme_con_out <= control_mem(31) & control_mem(19 downto 0);
		exme_aluc_out <= mem_pr_out(31 downto 16);
		exme_rega_out <= mem_pr_out(15 downto 0);
		exme_pc_out <= mem_pc;
		
		mewb_con_out <= control_wb(31) & control_wb(18 downto 0);
		mewb_aluc_out <= wb_pr_out(31 downto 16);
		mewb_mem_out <= wb_pr_out(15 downto 0);
		mewb_pc_out <= wb_pc;
		lmsm_disable1 <= lmsm_disable;
		
		-- Hazard detection unit port mapping	
		
		HDU_unit : hdu port map (reg_w_wb_cs =>  control_wb(11),
								  reg_w_mem_cs =>  control_mem(12),
								  reg_w_ex_cs =>  control_ex(12),
								 
								  reg_w_ex_code =>  control_ex(10 downto 8),
								  reg_w_mem_code =>  control_mem(10 downto 8),
								  reg_w_wb_code =>  control_wb(10 downto 8),
								  reg_r_or => control_or(7 downto 0),
								  
								  pc_ex_out => data_ex(15 downto 0), --orex_pc_out
								  aluc_ex => alu_c_out, -- decide between pc+2 and aluc_out
								  mem_data => mem_out,
								  mem_pc => mem_pc, --exme_pc_out,
								  mem_alu_data => mem_pr_out(31 downto 16),--exme_aluc_out,							  
								  wb_out => wb_data,
								  
								  haz_code_ex => control_ex(15 downto 13),
								  haz_code_mem => control_mem(15 downto 13),
								  haz_code_wb => control_wb(14 downto 12),
								  
								  pr_id_w => idor_pr_en,
								  pr_if_w => ifid_pr_en,
								  pr_or_w => orex_pr_en,
								  pc_w => pc_stalls,
								 
								  haz_data1 => haz_data1,
								  haz_data2 => haz_data2,
								  haz_add1 => haz_add1,
								  haz_add2 => haz_add2,
								  haz_flag1 => haz_flag1,
								  haz_flag2 => haz_flag2,
								  stall => orex_stall_sel_hdu
								  );
				
			
		jump_unit: jump_handler port map(
				branch_control => branch_control_bit,
				imm9_id => instr_11(8 downto 0),
				imm9_or => data_or(24 downto 16),
				alu_out_ex => alu_c_out,
				alua => alua_op,
				pcplus2_if => pc_if,
				
				haz_code_id => control_signals(15 downto 13),
				haz_code_or => control_or(15 downto 13),
				haz_code_ex => control_ex(15 downto 13),
				
				pc_cont_jump => pc_cont,
				pc_out_if => pc_out_jump,
				pr_id_cs => idor_stall_sel_jump, 
				pr_or_cs => orex_stall_sel_jump
				
				-- pc_out_mux_cs: out std_logic
			); 
	
		-- map hdu signals out for debugging
		haz_add1s <= haz_add1;
		haz_data1s <= haz_data1;
		haz_flag1s <= haz_flag1;
		haz_add2s <= haz_add2;
		haz_data2s <= haz_data2;
		haz_flag2s <= haz_flag2;
		stalls <= orex_stall_sel_hdu;
		
end behav;