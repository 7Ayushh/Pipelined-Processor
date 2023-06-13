	library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
	port(
		a, b, cin: in std_logic;
		s, p, g: out std_logic);
end entity;

architecture basic of full_adder is
begin
	
	g <= a and b;
	p <= a or b;
	s <= a xor b xor cin;
	
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity carry_generate is
	port(
		P, G: in std_logic_vector(3 downto 0);
		cin: in std_logic;
		Cout: out std_logic_vector(3 downto 0));
end entity;

architecture basic of carry_generate is
	signal C: std_logic_vector(4 downto 0);
begin
	C(0) <= cin;
	logic:
	for i in 1 to 4 generate
		C(i) <= G(i-1) or (P(i-1) and C(i-1)); 
	end generate;

	Cout <= C(4 downto 1);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity adder is
	port(
		A, B: in std_logic_vector(15 downto 0);
		S: out std_logic_vector(15 downto 0);
		cin: in std_logic;
		Cout: out std_logic_vector(15 downto 0));
end entity;

architecture look_ahead of adder is
	signal C: std_logic_vector(16 downto 0);
	signal P, G: std_logic_vector(15 downto 0);
	
	component full_adder is
		port(
			a, b, cin: in std_logic;
			s, p, g: out std_logic);
	end component;
	
	component carry_generate is
		port(
			P, G: in std_logic_vector(3 downto 0);
			cin: in std_logic;
			Cout: out std_logic_vector(3 downto 0));
	end component;
	
begin

	C(0) <= cin;
	
	ADDER:
	for i in 0 to 15 generate
		ADDX: full_adder
			port map(a => A(i), b => B(i), cin => C(i),
				s => S(i), p => P(i), g => G(i));
	end generate ADDER;
	
	CARRIER:
	for i in 0 to 3 generate
		CARRYX: carry_generate
			port map(P => P((i+1)*4-1 downto i*4),
				G => G((i+1)*4-1 downto i*4),
				cin => C(i*4), Cout => C((i+1)*4 downto i*4+1));
	end generate CARRIER;
	
	Cout <= C(16 downto 1);
	
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port(
		ALU_A, ALU_B: in std_logic_vector(15 downto 0);
		ALU_C: out std_logic_vector(15 downto 0);
		ALU_op: in std_logic_vector(3 downto 0);
		ALU_Carry_In: in std_logic;
		ALU_Compare: out std_logic_vector(2 downto 0);
		ALU_Z, ALU_Carry : out std_logic);
end entity;

architecture behave of alu is
	signal output_temp, ALU_B_temp: std_logic_vector(15 downto 0);
	signal output_add: std_logic_vector(15 downto 0);
	signal C: std_logic_vector(16 downto 1);
	signal cin_temp: std_logic;
	component adder is
		port(
			A, B: in std_logic_vector(15 downto 0);
			S: out std_logic_vector(15 downto 0);
			cin: in std_logic;
			Cout: out std_logic_vector(15 downto 0));
	end component;
	
begin
	
	ALU_B_temp <= ALU_B when (ALU_op(0) = '0') else (not ALU_B);
	cin_temp <= ALU_Carry_In when ((ALU_op = "0010") or (ALU_op = "0011")) else '0';
	
	adder1: adder
		port map(
			A => ALU_A, B => ALU_B_temp,
			cin =>cin_temp, S => output_add, Cout => C);
	ALU_Carry <= C(16);
	
	process(ALU_A, ALU_B, output_add, ALU_op, ALU_B_temp)
	begin
		if ((ALU_op = "0000") or (ALU_op = "0010") or (ALU_op = "0001") or (ALU_op = "0011")) then
			output_temp <= output_add;
			ALU_Compare <= "000";
		elsif (ALU_op = "0110") then
			output_temp <= ALU_A xor ALU_B_temp;
			ALU_Compare <= "000";
		elsif ((ALU_op = "0100") or (ALU_op = "0101")) then
			output_temp <= ALU_A nand ALU_B_temp;
			ALU_Compare <= "000";
		elsif (ALU_op = "1000") then
			output_temp <= (others => '0');
			if (ALU_A = ALU_B) then
				ALU_Compare <= "001";
			else
				ALU_Compare <= "000";
			end if;
		elsif (ALU_op = "1110") then
			output_temp <= (others => '0');
			if (to_integer(unsigned(ALU_A)) < to_integer(unsigned(ALU_B))) then
				ALU_Compare <= "010";
			else
				ALU_Compare <= "000";
			end if;
		elsif (ALU_op = "1010") then
			output_temp <= (others => '0');
			if (to_integer(unsigned(ALU_A)) <= to_integer(unsigned(ALU_B))) then
				ALU_Compare <= "100";
			else
				ALU_Compare <= "000";
			end if;
		else
			output_temp <= (others => '0');
			ALU_Compare <= "000";
		end if;
	end process;
	
	ALU_Z <= '1' when (to_integer(unsigned(output_temp)) = 0) else '0';
	ALU_C <= output_temp;

		
end architecture;
	