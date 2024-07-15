library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_stage is
	port(Clk, Reset : in std_logic;
		  alu_a, alu_b, pc_in, regA, regB : in std_logic_vector(15 downto 0);
		  check_control: in std_logic_vector(1 downto 0);
		  alu_control : in std_logic_vector(3 downto 0);
		  alu_c, pc_out_ex : out std_logic_vector(15 downto 0);
		  carry, zero, branch_control: out std_logic;
		  rf_w_in : in std_logic;
		  rf_w_out : out std_logic);
end entity;

architecture behav of EX_stage is
	component Reg1b is
		port(Clk, Reset, Enable : in std_logic;
				data_in : in std_logic;
				data_out : out std_logic);
	end component;
	
	component alu1 is
		port (
		--regA, regB, PC_in: in std_logic_vector(15 downto 0);
		
		--imm16: in std_logic_vector(15 downto 0);
		inpA, inpB, regA, regB: in std_logic_vector(15 downto 0);
		carry_in: in std_logic;
		zero_in : in std_logic;
		-- x --
		
		--use alu op1 for opcodes of most, and alu op2 for last 3 bits of arithmetic
		alu_op: in std_logic_vector(3 downto 0);
		-- x --
		gen_out: out std_logic_vector(15 downto 0);
		
		carry_out,
		zero_out,
		branch_control: out std_logic
		
		);		
	end component alu1;
	
	signal carry_in, carry_out, zero_in, zero_out, clk_n: std_logic; --clk_n to write on rising edge
	
	begin
		clk_n <= (clk);
		alu: alu1 port map (inpA => alu_A, inpB => alu_B, carry_in => carry_out, zero_in => zero_out, alu_op => alu_control, 
								  gen_out => alu_c, carry_out => carry_in, zero_out => zero_in, branch_control => branch_control, regA => regA, regB => regB);
		
		zero_reg: Reg1b port map (clk => clk_n, 
										reset => reset, 
										enable => '1', 
										data_in => 
										zero_in, 
										data_out => zero_out);
		
		carry_reg: Reg1b port map (clk => clk_n, 
											reset => 
											reset, enable => '1', 
											data_in => carry_in, 
											data_out => carry_out);
		
		rf_w_out <= rf_w_in and 
					(( (zero_in and check_control(1)) or 
					   (carry_in and check_control(0)) or 
						(not(check_control(0)) and not(check_control(1)))) ); --Write only if CZ Dep or Both C,Z not dependent
		
		carry <= carry_out;--carry_out;
		zero <= zero_out;--zero_out;
		
		pc_out_ex <= pc_in;
		
end behav;