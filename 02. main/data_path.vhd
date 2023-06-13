library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity data_path is
	port(
		op_code: out std_logic_vector(3 downto 0);
		condition: out std_logic_vector(1 downto 0);
		clk, reset: in std_logic;
		O: in std_logic_vector(22 downto 0);
		en: in std_logic_vector(21 downto 0);
		C,Z, PE_0, eq: out std_logic);
end entity;
	
architecture rtl of data_path is

	component LS7  is
		port (LS_IN: in std_logic_vector(15 downto 0); LS_OUT: out std_logic_vector(15 downto 0));
	end component;
	
	component reg_generic is
		generic (data_width : integer);
		port(
			clk, en, reset: in std_logic;
			Din: in std_logic_vector(data_width-1 downto 0);
			init: in std_logic_vector(data_width-1 downto 0);
			Dout: out std_logic_vector(data_width-1 downto 0));
	end component;

	component mp_encoder is
		port(
			MPE_IN: in std_logic_vector(7 downto 0);
			MPE_ENB: in std_logic;
			MPE_OUT: out std_logic_vector(7 downto 0));
	end component;

	component p_encoder is
		port(
			PE_IN: in std_logic_vector(7 downto 0);
			PE_ENB: in std_logic;
			PE_OUT: out std_logic_vector(2 downto 0);
			PE_0: out std_logic);
	end component;

	component sign_extend is
		port(
			SE_op: in std_logic;
			inp_6bit: in std_logic_vector(5 downto 0);
			inp_9bit: in std_logic_vector(8 downto 0);
			outp_16bit: out std_logic_vector(15 downto 0));
	end component;

	component register_file is			
		port(
			RF_D3: in std_logic_vector(15 downto 0);
			RF_D1, RF_D2, R7_O: out std_logic_vector(15 downto 0);
			RF_A1, RF_A2, RF_A3: in std_logic_vector(2 downto 0);
			clk, RF_WR, reset: in std_logic);
	end component;

	component alu is
		port(
			ALU_A, ALU_B: in std_logic_vector(15 downto 0);
			ALU_C: out std_logic_vector(15 downto 0);
			ALU_op: in std_logic_vector(1 downto 0);
			ALU_Z, ALU_Carry: out std_logic);
	end component;

	component ROM is
		port(
			IM_A: in std_logic_vector(15 downto 0);
			IM_DO: out std_logic_vector(15 downto 0);
			IM_RD ,clk : in std_logic);
	end component;

	component memory is		
		port(
			MEM_DI: in std_logic_vector(15 downto 0);
			MEM_DO: out std_logic_vector(15 downto 0);
			MEM_A: in std_logic_vector(15 downto 0);
			clk, MEM_WR, MEM_RD, reset: in std_logic);
	end component;
	
	signal V0: std_logic := 'Z';
	signal V1: std_logic_vector(2 downto 0) := (others => 'Z');
	signal V2: std_logic_vector(7 downto 0) := (others => 'Z');
	signal V3: std_logic_vector(15 downto 0) := (others => 'Z');
	signal PE_OUT, RF_A3, RF_A2, RF_A1: std_logic_vector(2 downto 0) := (others => '0');
	signal PE_IN, MPE_IN, MPE_OUT, Y_IN, Y_OUT: std_logic_vector(7 downto 0):= (others => '0');
	signal C_OUT, Z_OUT, PE0_OUT, C_IN, Z_IN, PE0_IN, eq_IN, eq_OUT: std_logic_vector(0 downto 0) := (others => '0');
	signal ALU1_Z, ALU1_Carry, ALU2_Z, ALU2_Carry, PE0: std_logic;
	signal IR_in, IR_out, RF_D3, RF_D2, RF_D1, R7_O, outp_16bit: std_logic_vector(15 downto 0) := (others => '0');
	signal ALU1_A, ALU1_B, ALU1_C, ALU2_A, ALU2_B, ALU2_C, MEM_DO, MEM_DI, MEM_A: std_logic_vector(15 downto 0) := (others => '0');
	signal IM_A, IM_DO: std_logic_vector(15 downto 0);
	signal T1_IN, T1_OUT, T2_IN, T2_OUT, T3_IN, T3_OUT, LS_IN, LS_OUT: std_logic_vector(15 downto 0) := (others => '0');
	signal inp_6bit: std_logic_vector(5 downto 0):= (others => '0');
	signal inp_9bit: std_logic_vector(8 downto 0):= (others => '0');

begin
	
	--Instruction Register
	instruction_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => reset, init => "0000000000000000", Din => IR_IN, Dout => IR_OUT, en => en(3));
	
	--Register File
	rf: register_file
		port map(clk => clk, reset => reset, RF_WR => en(0), RF_D3 => RF_D3, R7_O => R7_O, 
			RF_D1 => RF_D1, RF_D2 => RF_D2, RF_A3 => RF_A3, RF_A1 => RF_A1, RF_A2 => RF_A2);
	
	--Priority Encoder Block
	pe_block: p_encoder
		port map(PE_IN => PE_IN, PE_ENB => en(7), PE_0 => PE0, PE_OUT => PE_OUT);
		
	--Modifier-PE Block
	mpe_block: mp_encoder
		port map(MPE_IN => MPE_IN, MPE_ENB => en(8), MPE_OUT => MPE_OUT);
					
	--Sign Extend
	sign_extend_1: sign_extend
		port map(SE_op => en(15), inp_6bit => inp_6bit, inp_9bit => inp_9bit, outp_16bit => outp_16bit);
		
	--Arithmetic Logic Unit 1
	alu_instance_1: alu
		port map(ALU_A => ALU1_A, ALU_B => ALU1_B, ALU_C => ALU1_C, ALU_op => en(11 downto 10),
			ALU_Z => ALU1_Z, ALU_Carry => ALU1_Carry);
			
	--Arithmetic Logic Unit 2
	alu_instance_2: alu
		port map(ALU_A => ALU2_A, ALU_B => ALU2_B, ALU_C => ALU2_C, ALU_op => "00",
			ALU_Z => ALU2_Z, ALU_Carry => ALU2_Carry);
			
	--Memory
	mem: memory
		port map(MEM_DO => MEM_DO, MEM_DI => MEM_DI, MEM_A => MEM_A, MEM_WR => en(1), MEM_RD => en(2),
			reset => reset, clk => clk);
	
	--Instruction Memory
	instruct_mem: ROM
		port map(IM_A => IM_A, IM_DO => IM_DO, IM_RD => '1', clk => clk);
		
	--Temporary Register 1
	T1: reg_generic
		generic map(16)
		port map(Din => T1_IN, Dout => T1_OUT, en => en(4), clk => clk, reset => reset, init => "0000000000000000");
		
	--Temporary Register 2
	T2: reg_generic
		generic map(16)
		port map(Din => T2_IN, Dout => T2_OUT, en => en(5), reset => reset, init => "0000000000000000", clk => clk);
	
	--Temporary Register 3
	T3: reg_generic
		generic map(16)
		port map(Din => T3_IN, Dout => T3_OUT, en => en(6), reset => reset, init => "0000000000000000", clk => clk);
	
	--Temporary Register Y
	Y: reg_generic
		generic map(8)
		port map(Din => Y_IN, Dout => Y_OUT, en => en(14), reset => reset, init => "00000000", clk => clk);
		
	--Condtion Code Register: Carry
	Carry_CCR: reg_generic
		generic map(1)
		port map(Din => C_IN, Dout => C_OUT, en => en(12), reset => reset, init => "0", clk => clk);
		
	--Condition Code Register: Zero	
	Zero_CCR: reg_generic
		generic map(1)
		port map(Din => Z_IN, Dout => Z_OUT, en => en(13), reset => reset, init => "0", clk => clk);
	
	--Condition Code Register: PE_0	
	PE_CCR: reg_generic
		generic map(1)
		port map(Din => PE0_IN, Dout => PE0_OUT, en => '1', reset => reset, init => "0", clk => clk);	
	
	--Condition Code Register: eq	
	eq_CCR: reg_generic
		generic map(1)
		port map(Din => eq_IN, Dout => eq_OUT, en => en(21), reset => reset, init => "0", clk => clk);	
	
	--Left Shift 7
	LS_7: LS7
		port map(LS_IN => LS_IN, LS_OUT => LS_OUT);
	
	--MUX
	
	--Input 1 of ALU1
	ALU1_A <= R7_O when (O(1 downto 0)= "00") else
		T1_OUT when (O(1 downto 0)= "01") else
		outp_16bit when (O(1 downto 0)= "10") else
		V3;
		
	--Input 2 of ALU1
	ALU1_B <= "0000000000000001" when (O(3 downto 2)= "00") else
		T2_OUT when (O(3 downto 2)= "01") else
		outp_16bit when (O(3 downto 2)= "10") else
		V3;
   
	--Register File RF_A3
	RF_A3 <= IR_OUT(5 downto 3) when (O(6 downto 4)= "000") else
		IR_OUT(8 downto 6) when (O(6 downto 4)= "001") else
		IR_OUT(11 downto 9) when (O(6 downto 4)= "010") else
		PE_OUT when (O(6 downto 4)= "011") else
		"111" when (O(6 downto 4)= "100") else
		V1;
	
	--Register File RF_D3
	RF_D3 <= T3_OUT when (O(9 downto 7)= "000") else
		LS_OUT when (O(9 downto 7)= "001") else
		T1_OUT when (O(9 downto 7)= "010") else
		ALU1_C when (O(9 downto 7)= "011") else
		ALU2_C when (O(9 downto 7)= "100") else
		V3;
	
	--Register File RF_A1
	RF_A1 <= IR_OUT(11 downto 9) when (O(11 downto 10)= "00") else
		PE_OUT when (O(11 downto 10)= "01") else
		IR_OUT(8 downto 6) when (O(11 downto 10)= "10") else
		V1;
		
	--Register File RF_A2
	RF_A2 <= IR_OUT(8 downto 6);
		
	--Memory Address MEM_A
	MEM_A <= T1_OUT when (O(13 downto 12)= "01") else
		T3_OUT when (O(13 downto 12)= "10") else
		V3;
	
	--Memory Address MEM_DI
	MEM_DI <= T1_OUT when (O(14)= '0') else
		T3_OUT when (O(14) = '1') else
		V3;
		
	--ROM IM_A
	IM_A <= R7_O;
	
	--Priority Enc Input PE_IN
	PE_IN <= Y_OUT;
	
	--Modifier Priority Enc Input MPE_IN
	MPE_IN <= Y_OUT;
	
	--Input 1 of ALU2
	ALU2_A <= T3_OUT when (O(15)= '0') else
		R7_O when (O(15)= '1') else
		V3;
    
	--Input 2 of ALU2
	ALU2_B <= "0000000000000001" when ((O(17 downto 16)= "00") and (eq_OUT(0) = '0')) else
		outp_16bit when ((O(17 downto 16)= "00") and (eq_OUT(0) = '1')) else
		outp_16bit when (O(17 downto 16)= "01") else
		"0000000000000000" when (O(17 downto 16)= "10") else
		V3;

	--Temp Reg T1
	T1_IN <= RF_D1 when ((O(18) = '0') and (O(22) = '0')) else
		ALU1_C when ((O(18) = '1') and (O(22) = '0')) else
		R7_O when ((O(18) = '0') and (O(22) = '1')) else
		V3;
		
	--Temp Reg T2
	T2_IN <= RF_D2;
	
	--Temp Reg T3
	T3_IN <= RF_D1 when (O(20 downto 19) = "00") else
		MEM_DO when (O(20 downto 19) = "01") else
		ALU1_C when (O(20 downto 19) = "10") else
		V3;
	
	--Info Reg IR
	IR_IN <= IM_DO;
	
	--Temp Reg Y
	Y_IN <= IR_OUT(7 downto 0) when (O(21) = '0') else
		MPE_OUT when (O(21) = '1') else
		V2;
	
	--SE16, 6 bit input
	inp_6bit <= IR_OUT(5 downto 0);
	
	--SE16, 9 bit input
	inp_9bit <= IR_OUT(8 downto 0);
	
	--Left Shifter
	LS_IN <= outp_16bit;
	
	--eq_CCR
	eq_IN(0) <= ALU1_Z;
	
	--Zero_CCR
	Z_IN(0) <= ALU1_Z;
	
	--Carry_CCR
	C_IN(0) <= ALU1_Carry;
	
	--PE0_CCR
	PE0_IN(0) <= PE0;
	
	--Flags
	C <= C_OUT(0);
	Z <= Z_OUT(0);
	PE_0 <= PE0;
	eq <= eq_OUT(0);
		
	--Send Operation Code to the control path
	op_code <= IR_OUT(15 downto 12) when (en(20) = '0') else 
		IM_DO(15 downto 12);
	
	--Send the Conditional Execution Data to control path
	condition <= IR_OUT(1 downto 0);
	
end architecture;
