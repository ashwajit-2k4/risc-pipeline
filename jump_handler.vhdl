library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity jump_handler  is
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
		pr_id_cs, pr_or_cs: out std_logic
		-- pc_out_mux_cs: out std_logic
	); 
end entity;

architecture behav of jump_handler is
	-- case based on jal, jlr, jri haz code from id, or and ex stage resp
	-- jump priority to jri -> jlr -> jal -> 0 (everything else) (earliest instruction jumps first)
	-- calculate jump address
	-- mux jump address based on haz code and priority
	-- make control signals for pr_id, pr_or = 0 for jri
	-- make control signals for pr_or = 0 for jlr
	signal imm16_id, imm16_or: std_logic_vector(15 downto 0) := (others => '0');
	
	begin
	
	jump_proc: process(imm9_id, imm9_or, alu_out_ex, pcplus2_if, haz_code_id, haz_code_or, haz_code_ex, branch_control)
		begin
		imm16_id <= std_logic_vector( resize(signed(imm9_id), 16) );
		imm16_or <= std_logic_vector( resize(signed(imm9_or), 16) );
		
		--branching
		if ((haz_code_ex = "011") and branch_control = '1') then
			pc_out_if <= alu_out_ex;
			pr_id_cs <= '1';
			pr_or_cs <= '1';
			pc_cont_jump <= '1';
			
		-- jri
		elsif (haz_code_ex = "110") then
			pc_out_if <= alu_out_ex;
			pr_id_cs <= '1';
			pr_or_cs <= '1';
			pc_cont_jump <= '1';
			
		--jlr
		elsif (haz_code_or = "101" and not(haz_code_ex = "011")) then
			pc_out_if <= alua;
			pr_id_cs <= '1';
			pr_or_cs <= '0';
			pc_cont_jump <= '1';
		
		--jal
		elsif (haz_code_id = "100" and not(haz_code_or = "011") and not(haz_code_ex = "011")) then
			pc_out_if <= std_logic_vector(to_unsigned(
							to_integer(unsigned(pcplus2_if)) - 4 + 2*to_integer(unsigned(imm16_id)) -- ***** -4 in the final version, it's incrementing after this once for some reason
							, 16 ));
			
			pr_id_cs <= '0';
			pr_or_cs <= '0';
			pc_cont_jump <= '1';
		
		else
			pc_out_if <= pcplus2_if;
			pr_id_cs <= '0';
			pr_or_cs <= '0';
			pc_cont_jump <= '0';
			
		end if;
		
		
	end process;
	
end architecture;