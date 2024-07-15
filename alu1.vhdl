library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--sign extending and mux facilities for selecting appropriate input are integrated within this ALU
-- need a better way of reading and writing to register file to make it easy for lm and sm

entity alu1 is
	port (
	--regA, regB, PC_in: in std_logic_vector(15 downto 0);
	
	--imm16: in std_logic_vector(15 downto 0);
	inpA, inpB, rega, regb: in std_logic_vector(15 downto 0);
	carry_in: in std_logic;
	zero_in: in std_logic;
	
	-- x --
	
	--use alu op1 for opcodes of most, and alu op2 for last 3 bits of arithmetic
	alu_op: in std_logic_vector(3 downto 0);
	-- x --
	gen_out: out std_logic_vector(15 downto 0);
	
	carry_out,
	zero_out,
	branch_control: out std_logic
	
	);	
end entity alu1;

	
architecture behav of alu1 is
	signal c_in: std_logic_vector(0 downto 0);
	begin
	c_in(0) <= carry_in;

	process (inpA, inpB, carry_in, alu_op, c_in, zero_in)
	
		-- used for carry and zero flag (17 bit to store carry as well)
		variable temp: std_logic_vector(16 downto 0);
		--variable regAu16, regBu16, PCu: unsigned(15 downto 0);
		variable inpA17, inpB17, cu17: unsigned(16 downto 0);
		variable zflag, cflag: integer;
		variable branch_control_bit: std_logic := '0';

		begin
		-- converting carry_in (std logic) to std_logic_vector(0 downto 0) so i can convert it into unsigned to add
		inpA17 := resize(unsigned(inpA), 17);
		inpB17 := resize(unsigned(inpB), 17);
		cu17 := resize(unsigned(c_in), 17);
	
		
		case alu_op is
		
				-- adding, lli
				when "0001" =>
					temp := std_logic_vector( inpA17 + inpB17 );
					--gen_out <= temp(15 downto 0);
					cflag := 1;
					zflag := 1;
					branch_control_bit := '0';
					
				-- regA + regB + C: AWC
				when "1001" =>
					temp := std_logic_vector( inpA17 + inpB17 + cu17);
					--gen_out <= temp(15 downto 0);
					cflag := 1;
					zflag := 1;
					branch_control_bit := '0';
				
				-- regA + ~regB: ACA, ACC, ACZ
				when "0101" =>
					temp := std_logic_vector(inpA17 + resize(not(inpB17(15 downto 0)), 17));
					--gen_out <= temp(15 downto 0);
					cflag := 1;
					zflag := 1;
					branch_control_bit := '0';
					
				-- regA + ~regB + C: ACW
				when "1101" =>
					temp := std_logic_vector(inpA17 + resize(not(inpB17(15 downto 0)), 17) + cu17);
					--gen_out <= temp(15 downto 0);
					cflag := 1;
					zflag := 1;
					branch_control_bit := '0';
			
			
			-- nanding
				-- nand regA and regB : NDU, NDC, NDZ
				when "0010" => 
					temp := "0" & (inpA nand inpB);
					--gen_out <= temp(15 downto 0);
					zflag := 1;
					cflag := 0;
					branch_control_bit := '0';
					
				-- nand regA and ~regB: NCU, NCC, NCZ
				when "1010" => 
					temp := "0" & inpA nand (std_logic_vector( resize(not(inpB17(15 downto 0)), 17) ) );
					--gen_out <= temp(15 downto 0);
					zflag := 1;
					cflag := 0;
					branch_control_bit := '0';
				
			-- lw, sw, jri, jal
				when "1111" => 
					temp := std_logic_vector( to_unsigned( to_integer(inpA17) -2 + to_integer( signed( inpB17(5 downto 0) ) ) , 17) );
					--gen_out <= temp(15 downto 0);
					zflag := 0;
					cflag := 0;
					branch_control_bit := '0';
					
			-- adi
				when "1110" => 
					temp := std_logic_vector( to_unsigned( to_integer(inpA17) + to_integer( signed( inpB17(5 downto 0) ) ) , 17) );
					--gen_out <= temp(15 downto 0);
					zflag := 1;
					cflag := 1;
					branch_control_bit := '0';
					
			
			-- lli
				when "0011" =>
					temp := std_logic_vector( inpA17 + inpB17 );
				--gen_out <= temp(15 downto 0);
					zflag := 0;
					cflag := 0;
				
			-- lm, sm, jal
			when "0000" =>
				-- gen_out has the memory address,
				temp := "0" & inpA;
				--gen_out <= inpA;
				zflag := 0;
				cflag := 0;
				branch_control_bit := '0';
			
			
			-- beq, ble, blt: PC + Imm*2
			when "1000"|"1011"|"0111"=>
				temp := std_logic_vector( to_unsigned( to_integer(inpA17) -2 + 2*to_integer((signed(inpB17(5 downto 0) ) ) ) , 17));
				--gen_out <= temp(15 downto 0);
				zflag := 0;
				cflag := 0;
				
				case alu_op is
					when "1000" =>
						if(rega = regb) then
							branch_control_bit := '1';
						else
							branch_control_bit := '0';
						end if;
						
					when "1011" =>
						if(rega < regb) then
							branch_control_bit := '1';
						else
							branch_control_bit := '0';
						end if;
						
				when "0111" =>
						if(rega <= regb) then
							branch_control_bit := '1';
						else
							branch_control_bit := '0';
						end if;
						
				when others =>
					branch_control_bit := '0';
				end case;
			
			when others =>
				zflag := 0;
				cflag := 0;
				--gen_out <= (others => 'Z');
				temp := (others => 'Z');
				branch_control_bit := '0';
			
		end case;
		
		gen_out <= temp(15 downto 0);
		branch_control <= branch_control_bit;
		
		-- set zero and carry flag for addition
		if (temp(15 downto 0) = "0000000000000000") and (zflag = 1) then
			zero_out <= '1';
		elsif (not(temp(15 downto 0) = "0000000000000000") ) and (zflag = 1) then
			zero_out <= '0';
		else
			zero_out <= zero_in;
		end if;
		
		if (cflag = 1) then
			carry_out <= temp(16);--(regA(15) and regB(15)) or (temp(15) and (regA(15) xor regB(15)));
		else
			carry_out <= carry_in;
		end if;
		
	end process;
	
end architecture behav;


