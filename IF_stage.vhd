library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_stage is
	port(pc_w_sel: in std_logic;
		  alu_pc_out, ir_mux_out, pc : in std_logic_vector(15 downto 0);
		  instr, pc_4_out : out std_logic_vector(15 downto 0));
end entity;

architecture behav of IF_stage is
	signal mem_out, pc_4, pc_out: std_logic_vector(15 downto 0) := (others => '0');
	
	component AS16 is
   port (A16,B16 : in std_logic_vector(15 downto 0); M1: in std_logic;
			S16 : out std_logic_vector(15 downto 0); Cout1: out std_logic);	
	end component AS16;
	
	component Mux2to1_16 is
	port(
		i0_16, i1_16: in std_logic_vector(15 downto 0);
		sel1: in std_logic;
		o_16: out std_logic_vector(15 downto 0)
	);
	end component;
	
	component Imem  is
		port (mem_radd: in std_logic_vector(15 downto 0);
				mem_out: out std_logic_vector(15 downto 0)); -- testing remove
	end component;

	begin

	PlusFour: AS16 port map
	(A16 => pc, B16 => "0000000000000010", M1 => '0', S16 => pc_4, Cout1 => open);
		
	InstMem: IMem port map (mem_radd => pc_out, mem_out => instr);
	
	PC_Source_Mux: Mux2to1_16 port map (i0_16 => pc, i1_16 => alu_pc_out, sel1 => pc_w_sel, o_16 => pc_out);
	
	pc_4_out <= pc_4;
end architecture;


