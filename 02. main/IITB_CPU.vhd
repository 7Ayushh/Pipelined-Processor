library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;


entity IITB_CPU is
	port(
		clk, reset: in std_logic);
end entity;

architecture piped of IITB_CPU is

	component reg_generic is
		generic (data_width : integer);
		port(
			clk, en, reset: in std_logic;
			Din: in std_logic_vector(data_width-1 downto 0);
			init: in std_logic_vector(data_width-1 downto 0);
			Dout: out std_logic_vector(data_width-1 downto 0));
	end component;
	
	component ROM is
		port(
			IM_A: in std_logic_vector(15 downto 0);
			IM_DO: out std_logic_vector(15 downto 0);
			IM_RD ,clk : in std_logic);
	end component;

	component sign_extend is
		port(
			SE_op, extend_zero: in std_logic;
			inp_16bit: in std_logic_vector(15 downto 0);
			outp_16bit: out std_logic_vector(15 downto 0));
	end component;
	
	component modifier_pe is
	port(
		IMM: in std_logic_vector(7 downto 0);
		MPE_ENB, clk, MPE_ZERO, reset: in std_logic;
		PE_0, MPE_0: out std_logic;
		MPE_OUT: out std_logic_vector(2 downto 0));
	end component;

	component LM_SM is 
	port(
		IMM: in std_logic_vector(7 downto 0);
		LM, SM ,clk, reset: in std_logic;
		RF_A2 : out std_logic_vector(2 downto 0);
		RF_A3 : out std_logic_vector(2 downto 0);
		clr, disable, sel_RF_D1, sel_ALUB, sel_RF_A3, sel_MEM_IN, sel_RF_A2, sel_IMM: out std_logic);
	end component;
	
	component memory is		
	port(
		MEM_DI: in std_logic_vector(15 downto 0);
		MEM_DO: out std_logic_vector(15 downto 0);
		MEM_A: in std_logic_vector(15 downto 0);
		clk, MEM_WR, MEM_RD, reset: in std_logic);
	end component; 
	
	component alu is
	port(
		ALU_A, ALU_B: in std_logic_vector(15 downto 0);
		ALU_C: out std_logic_vector(15 downto 0);
		ALU_op: in std_logic_vector(3 downto 0);
		ALU_Carry_In: in std_logic;
		ALU_Compare: out std_logic_vector(2 downto 0);
		ALU_Z, ALU_Carry : out std_logic);
	end component;
	
	component register_file is		
	port(
		RF_D3, R0_IN: in std_logic_vector(15 downto 0);
		RF_D1, RF_D2, R0_O: out std_logic_vector(15 downto 0);
		RF_A1, RF_A2, RF_A3: in std_logic_vector(2 downto 0);
		clk, RF_WR, R0_WR, reset: in std_logic);
	end component;
	
	component inst_decoder is
	port(instruc: in std_logic_vector(15 downto 0);
		SE6_9, LM, SM, BEQ_en, BLT_en, BLE_en, LW, LLI, SE_RF_D2, ID_PC :out std_logic;
		CZ, WR, WB_mux : out std_logic_vector(1 downto 0);
		enc_addnand, RF_A1, RF_A2, RF_A3, used: out std_logic_vector(2 downto 0);
		alu_control: out std_logic_vector(3 downto 0));
	end component;
	
	component b_predict is
	port(
		clk, reset, Bra_en, twitch: in std_logic;
		ADDR_IN: in std_logic_vector(2 downto 0);
		PC_ID: in std_logic_vector(15 downto 0);
		PC_IN: in std_logic_vector(15 downto 0);
		BA_IN: in std_logic_vector(15 downto 0);
		BA: out std_logic_vector(15 downto 0);
		is_taken: out std_logic;
		ADDR_OUT: out std_logic_vector(2 downto 0));
	end component;
	
	component forward_controller is
		port(
			ID_RR_RF_A, RR_EX_RF_A3, EX_MM_RF_A3, MM_WB_RF_A3:in std_logic_vector(2 downto 0);
			sel_RR_EX_MUX, sel_EX_MM_MUX: in std_logic_vector(1 downto 0);
			ID_RR_PC, RR_EX_ALU_C, EX_MM_ALU_C, RR_EX_EXT, EX_MM_EXT, RR_EX_INCPC, EX_MM_INCPC, EX_MM_MEM_OUT, MM_WB_toforward:in std_logic_vector(15 downto 0);
			clk, ID_RR_RF_A_used, RR_EX_RF_A3_used, EX_MM_RF_A3_used, MM_WB_RF_A3_used: in std_logic;
			forward_CONTROL : out std_logic;
			forward_DATA: out std_logic_vector(15 downto 0));
	end component;
	
	component RR_hazard_unit is 	
	port( 
		ID_RR_RF_A3, ID_RR_used : in std_logic_vector(2 downto 0);
		ID_RR_EXT, ID_RR_RF_D1: in std_logic_vector(15 downto 0);
		opcode: in std_logic_vector(3 downto 0);
		clk: in std_logic;
		MUX_IN: out std_logic_vector(15 downto 0);
		clear_pip_reg, sel_RR_hazard_MUX : out std_logic);
	end component;
	
	component stall_unit is 
	port( 
		RF_A1, RF_A2, RF_A3, RF_used: in std_logic_vector(2 downto 0);
		IF_ID_enc_addnand : in std_logic_vector(1 downto 0);
		clk, ID_RR_LW_control : in std_logic;
		ID_RR_opcode, IF_ID_opcode: in std_logic_vector(3 downto 0);
		disable, clear, SM_control: out std_logic);
	end component;

	component EX_hazard_unit is 
	port(		
		ALU_OUT, INCPC, EXT_PC : in  std_logic_vector(15 downto 0);
		RR_EX_RF_A3, alu_Compare, RR_EX_used: in std_logic_vector(2 downto 0);
		RR_EX_enc_addnand, EX_MM_Flags, sel_RR_EX_MUX, MM_WB_Flags, Flags: in std_logic_vector(1 downto 0);
		RR_EX_opcode : in std_logic_vector(3 downto 0);
		clk, EX_MM_FC, MM_WB_FC, BEQ_is_taken, BLT_is_taken, BLE_is_taken, BEQ_bit, BLT_bit, BLE_bit : in std_logic;
		BEQ_table_twitch, BLT_table_twitch, BLE_table_twitch  : out std_logic;
		table_BEQ_taken_in, table_BLT_taken_in, table_BLE_taken_in : out std_logic;
		MUX_IN : out std_logic_vector(15 downto 0);
		sel_EX_hazard_MUX, flush, clear: out std_logic);
	end component;
	
	component MM_hazard_unit is 
	port(
		MEM_OUT: in std_logic_vector(15 downto 0);
		EX_MM_RF_A3, EX_MM_used: in std_logic_vector(2 downto 0);
		EX_MM_Flags, sel_EX_MM_MUX: in std_logic_vector(1 downto 0);
		MM_Flags : out std_logic_vector(1 downto 0);
		clear, sel_MM_hazard_MUX : out std_logic);
	end component;
	
	component WB_hazard_unit is 
	port( 
		MM_WB_RF_A3, MM_WB_used: in std_logic_vector(2 downto 0);
		MM_WB_INCPC: in std_logic_vector(15 downto 0);
		WRITE_R0, clear, sel_WB_hazard_MUX: out std_logic;
		select_R0: out std_logic_vector(1 downto 0);
		MUX_IN : out std_logic_vector(15 downto 0);
		BEQ_is_taken, BLT_is_taken, BLE_is_taken: in std_logic;
		opcode: in std_logic_vector(3 downto 0));
	end component;
	
	component MM_Forward_unit is
	port(clk : in std_logiC;
		  EX_MM_RF_A2, MM_WB_RF_A3 : in std_logic_vector(2 downto 0);
		  MM_WB_opcode, EX_MM_opcode : in std_logic_vector(3 downto 0);
		  EX_MM_RF_A2_used:in std_logic; 
		  MM_WB_RF_A3_used : in std_logic;
		  sel_forward_MUX : out std_logic);
	end component;
	
	component IF_ID is
	port(PC_IN: in std_logic_vector(15 downto 0);
		INST_IN: in std_logic_vector(15 downto 0);
		INCPC_IN:in std_logic_vector(15 downto 0);
		clk: in std_logic;
		CLR: in std_logic;
		CONTROL_CLR : in std_logic;
		disable : in std_logic;		
  		BEQ_PRED_IN: in std_logic_vector(3 downto 0);
		BEQ_PRED_OUT: out std_logic_vector(3 downto 0);
  		BLT_PRED_IN: in std_logic_vector(3 downto 0);
		BLT_PRED_OUT: out std_logic_vector(3 downto 0);
  		BLE_PRED_IN: in std_logic_vector(3 downto 0);
		BLE_PRED_OUT: out std_logic_vector(3 downto 0);
		PC_OUT: out std_logic_vector(15 downto 0);
		INST_OUT: out std_logic_vector(15 downto 0);
		INCPC_OUT:out std_logic_vector(15 downto 0);
		NOFLUSH_OUT : out std_logic_vector(0 downto 0));
	end component;
	
	
	component ID_RR is  
		port(PC_IN: in std_logic_vector(15 downto 0);
			EXTPC_IN: in std_logic_vector(15 downto 0);
			EXT_IN: in std_logic_vector(15 downto 0);
			CONTROL_IN : in std_logic_vector(11 downto 0);
			ALU_CONTROL_IN: in std_logic_vector(3 downto 0);
			FC_IN: in std_logic_vector(1 downto 0);
			CONDITION_IN: in std_logic_vector(2 downto 0); 
			WRITE_CONTROL_IN: in std_logic_vector(1 downto 0);
			RF_A1_IN: in std_logic_vector(2 downto 0);
			RF_A2_IN: in std_logic_vector(2 downto 0);
			RF_A3_IN: in std_logic_vector(2 downto 0);
			INCPC_IN:in std_logic_vector(15 downto 0);
			LM_IN : std_logic_vector(7 downto 0);
			clk: in std_logic;
			CLR: in std_logic;
			CONTROL_CLR : in std_logic;
			disable : in std_logic;
			PC_OUT: out std_logic_vector(15 downto 0);
			EXTPC_OUT: out std_logic_vector(15 downto 0);
			EXT_OUT: out std_logic_vector(15 downto 0);
			CONTROL_OUT : out std_logic_vector(11 downto 0);
			ALU_CONTROL_OUT: out std_logic_vector(3 downto 0);
			FC_OUT: out std_logic_vector(1 downto 0);
			CONDITION_OUT: out std_logic_vector(2 downto 0);
			WRITE_CONTROL_OUT: out std_logic_vector(1 downto 0);
			RF_A1_OUT: out std_logic_vector(2 downto 0);
			RF_A2_OUT: out std_logic_vector(2 downto 0);
			RF_A3_OUT: out std_logic_vector(2 downto 0);
			INCPC_OUT:out std_logic_vector(15 downto 0);
			LM_OUT : out std_logic_vector(7 downto 0);	
			BEQ_PRED_IN: in std_logic_vector(3 downto 0);
			BEQ_PRED_OUT: out std_logic_vector(3 downto 0);
			BLT_PRED_IN: in std_logic_vector(3 downto 0);
			BLT_PRED_OUT: out std_logic_vector(3 downto 0);
			BLE_PRED_IN: in std_logic_vector(3 downto 0);
			BLE_PRED_OUT: out std_logic_vector(3 downto 0);
			OPCODE_IN: in std_logic_vector(3 downto 0);
			OPCODE_OUT: out std_logic_vector(3 downto 0));
	end component;
	
	component RR_EX is  
	port(
		EXT_IN: in std_logic_vector(15 downto 0);
		EXT_PC_IN: in std_logic_vector(15 downto 0);
		CONTROL_IN : in std_logic_vector(13 downto 0);
		ALU_CONTROL_IN: in std_logic_vector(3 downto 0);
		FC_IN: in std_logic_vector(1 downto 0);
		CONDITION_IN: in std_logic_vector(2 downto 0);
		WRITE_CONTROL_IN: in std_logic_vector(1 downto 0);
		RF_D1_IN: in std_logic_vector(15 downto 0);
		RF_D2_IN: in std_logic_vector(15 downto 0);
		RF_A2_IN: in std_logic_vector(2 downto 0);
		RF_A3_IN: in std_logic_vector(2 downto 0);
		INCPC_IN:in std_logic_vector(15 downto 0);
		clk: in std_logic;
		CLR: in std_logic;
		CONTROL_CLR : in std_logic;
		disable : in std_logic;
		ENB_LMSM : in std_logic;
		EXT_OUT: out std_logic_vector(15 downto 0);
		EXT_PC_OUT: out std_logic_vector(15 downto 0);
		CONTROL_OUT : out std_logic_vector(13 downto 0);
		ALU_CONTROL_OUT: out std_logic_vector(3 downto 0);
		FC_OUT: out std_logic_vector(1 downto 0);
		CONDITION_OUT: out std_logic_vector(2 downto 0);
		WRITE_CONTROL_OUT: out std_logic_vector(1 downto 0);
		RF_D1_OUT: out std_logic_vector(15 downto 0);
		RF_D2_OUT: out std_logic_vector(15 downto 0);
		RF_A2_OUT: out std_logic_vector(2 downto 0);
		RF_A3_OUT: out std_logic_vector(2 downto 0);
		INCPC_OUT: out std_logic_vector(15 downto 0);
  		BEQ_PRED_IN: in std_logic_vector(3 downto 0);
		BEQ_PRED_OUT: out std_logic_vector(3 downto 0);
  		BLT_PRED_IN: in std_logic_vector(3 downto 0);
		BLT_PRED_OUT: out std_logic_vector(3 downto 0);
  		BLE_PRED_IN: in std_logic_vector(3 downto 0);
		BLE_PRED_OUT: out std_logic_vector(3 downto 0);
		OPCODE_IN: in std_logic_vector(3 downto 0);
		OPCODE_OUT: out std_logic_vector(3 downto 0));
	end component;
	
	component EX_MM is 
	port(
		EXT_IN: in std_logic_vector(15 downto 0);
		EXT_PC_IN: in std_logic_vector(15 downto 0);
		CONTROL_IN : in std_logic_vector(9 downto 0);
		ALU_OUTPUT_IN: in std_logic_vector(15 downto 0);
		FC_IN: in std_logic_vector(1 downto 0);
		WRITE_CONTROL_IN: in std_logic_vector(1 downto 0);
		RF_D1_IN: in std_logic_vector(15 downto 0);
		RF_D2_IN: in std_logic_vector(15 downto 0);
		RF_A2_IN: in std_logic_vector(2 downto 0);
		RF_A3_IN: in std_logic_vector(2 downto 0);
		INCPC_IN:in std_logic_vector(15 downto 0);
		UPDATED_FLAGS_IN: in std_logic_vector(1 downto 0);
		clk: in std_logic;
		CONDITIONAL_CLR, CLR: in std_logic;
		CONTROL_CLR : in std_logic;
		EXT_OUT: out std_logic_vector(15 downto 0);
		EXT_PC_OUT: out std_logic_vector(15 downto 0);
		CONTROL_OUT : out std_logic_vector(9 downto 0);
		ALU_OUTPUT_OUT: out std_logic_vector(15 downto 0);
		FC_OUT: out std_logic_vector(1 downto 0);
		UPDATED_FLAGS_OUT: out std_logic_vector(1 downto 0);
		WRITE_CONTROL_OUT: out std_logic_vector(1 downto 0);
		RF_D1_OUT: out std_logic_vector(15 downto 0);
		RF_D2_OUT: out std_logic_vector(15 downto 0);
		RF_A2_OUT: out std_logic_vector(2 downto 0);
		RF_A3_OUT: out std_logic_vector(2 downto 0);
		INCPC_OUT: out std_logic_vector(15 downto 0);
  		BEQ_PRED_IN: in std_logic_vector(3 downto 0);
		BEQ_PRED_OUT: out std_logic_vector(3 downto 0);
  		BLT_PRED_IN: in std_logic_vector(3 downto 0);
		BLT_PRED_OUT: out std_logic_vector(3 downto 0);
  		BLE_PRED_IN: in std_logic_vector(3 downto 0);
		BLE_PRED_OUT: out std_logic_vector(3 downto 0);
		OPCODE_IN: in std_logic_vector(3 downto 0);
		OPCODE_OUT: out std_logic_vector(3 downto 0));
	end component;
	
	component MM_WB is 
	port(
		EXT_IN: in std_logic_vector(15 downto 0);
		EXT_PC_IN: in std_logic_vector(15 downto 0);
		CONTROL_IN : in std_logic_vector(8 downto 0);
		ALU_OUTPUT_IN: in std_logic_vector(15 downto 0);
		MEM_OUTPUT_IN: in std_logic_vector(15 downto 0);
		FC_IN: in std_logic_vector(1 downto 0);
		WRITE_CONTROL_IN: in std_logic_vector(1 downto 0);
		RF_D1_IN: in std_logic_vector(15 downto 0);
		RF_A3_IN: in std_logic_vector(2 downto 0);
		INCPC_IN:in std_logic_vector(15 downto 0);
		UPDATED_FLAGS_IN: in std_logic_vector(1 downto 0);
		clk: in std_logic;
		CLR: in std_logic;
		CONTROL_CLR : in std_logic;
		EXT_OUT: out std_logic_vector(15 downto 0);
		EXT_PC_OUT: out std_logic_vector(15 downto 0);
		CONTROL_OUT : out std_logic_vector(8 downto 0);
		ALU_OUTPUT_OUT: out std_logic_vector(15 downto 0);
		MEM_OUTPUT_OUT: out std_logic_vector(15 downto 0);
		FC_OUT: out std_logic_vector(1 downto 0);
		UPDATED_FLAGS_OUT: out std_logic_vector(1 downto 0);
		WRITE_CONTROL_OUT: out std_logic_vector(1 downto 0);
		RF_D1_OUT: out std_logic_vector(15 downto 0);
		RF_A3_OUT: out std_logic_vector(2 downto 0);
		INCPC_OUT: out std_logic_vector(15 downto 0);
  		BEQ_PRED_IN: in std_logic_vector(3 downto 0);
		BEQ_PRED_OUT: out std_logic_vector(3 downto 0);
  		BLT_PRED_IN: in std_logic_vector(3 downto 0);
		BLT_PRED_OUT: out std_logic_vector(3 downto 0);
  		BLE_PRED_IN: in std_logic_vector(3 downto 0);
		BLE_PRED_OUT: out std_logic_vector(3 downto 0);
		OPCODE_IN: in std_logic_vector(3 downto 0);
		OPCODE_OUT: out std_logic_vector(3 downto 0));
	end component;
	
	signal PC_IN, PC_OUT, INCPC, IM_A, IM_DO: std_logic_vector(15 downto 0);
	signal PC_ID, INST_ID, INCPC_ID, EXT_ID, EXT_PC_ID, BEQ_BA, BLT_BA, BLE_BA, BEQ_PC, BLE_PC, BLT_PC, JAL_PC: std_logic_vector(15 downto 0);
	signal PC_ENB, staller_disable, disable_LMSM: std_logic := '0';
	signal BEQ_twitch, BEQ_is_taken, BLE_twitch, BLE_is_taken, BLT_twitch, BLT_is_taken, BEQ_is_taken_EX, BLT_is_taken_EX, BLE_is_taken_EX: std_logic;
	signal BEQP_index_in, BEQP_index_out, BLEP_index_in, BLEP_index_out, BLTP_index_in, BLTP_index_out : std_logic_vector(2 downto 0); 
	signal BEQ_en, BLE_en, BLT_en, sel_MM_hazard_MUX: std_logic := '0';
	signal concat_BEQP_IF_ID, concat_BLEP_IF_ID, concat_BLTP_IF_ID, BEQP_ID, BLTP_ID, BLEP_ID: std_logic_vector(3 downto 0);
	signal CONTROL_CLR_IF_ID, disable_IF_ID, disable_ID_RR, ID_PC, CONTROL_CLR_MM_WB: std_logic;
	signal NOFLUSH_OUT: std_logic_vector(0 downto 0);
	signal hazard_RR_clear, hazard_EX_flush, hazard_EX_clear, hazard_MM_clear, hazard_WB_clear, staller_clear: std_logic;
	signal SE6_9, LLI, SM, sel_LMSM_IN: std_logic;
	signal RF_A1_ID, RF_A2_ID, RF_A3_ID, COND_ID: std_logic_vector(2 downto 0);
	signal FC_ID, WR_ID, sel_EX_MM_MUX, sel_RR_EX_MUX: std_logic_vector(1 downto 0);
	signal ALU_CONTROL_ID, concat_BEQP_EX_MM, concat_BLEP_EX_MM, concat_BLTP_EX_MM: std_logic_vector(3 downto 0);
	signal LMSM_ID_RR, LM_ID, LM_RR: std_logic_vector(7 downto 0);
	signal CL_ID, CL_RR: std_logic_vector(11 downto 0);
	
	signal CONTROL_CLR_ID_RR, sel_RR_hazard_MUX: std_logic;
	signal PC_RR, EXT_PC_RR, EXT_RR, INCPC_RR, ALU_OUT_EX, D3_data, EXT_EX, EXT_PC_EX, INCPC_EX, ALU_OUT_MM, EXT_MM, INCPC_MM, MEM_OUT: std_logic_vector(15 downto 0);
	signal ALU_CONTROL_RR, ALU_CONTROL_EX, BEQP_EX, BLEP_EX, BLTP_EX, OP_EX, BEQP_RR, BLEP_RR, BLTP_RR, OP_RR,BEQP_MM, BLEP_MM, BLTP_MM, OP_MM, BEQP_WB, BLEP_WB, BLTP_WB, OP_WB: std_logic_vector(3 downto 0);
	signal FC_RR, WR_RR, FC_EX, WR_EX, flags_EX, flags_MM, FC_MM, flags_WB, FC_WB, WR_MM, WR_WB, flags_present, hazard_flags_MM, select_R0: std_logic_vector(1 downto 0);
	signal COND_RR, COND_EX, RF_A1_RR, RF_A2_RR, RF_A3_RR, RF_A3_WB, Compare_Flags: std_logic_vector(2 downto 0);
	
	signal SM_Inp, SM_control, clr_LMSM, sel_RF_D1, sel_RF_A2, sel_RF_A3, sel_MEM_IN, sel_ALUB, tp1_forward_CONTROL, tp2_forward_CONTROL: std_logic;
	signal RF_A2_DD, RF_A3_DD, RF_A3_EX, RF_A3_MM, RF_A2: std_logic_vector(2 downto 0);
	signal tp2_forward_DATA, tp1_forward_DATA, RF_D1_EX, RF_D2_EX, RF_D1_RR, RF_D2_RR, RF_D1, RF_D2, Forward_MUX, MUX_IN_RR, RR_hazrad_MUX: std_logic_vector(15 downto 0);
	signal concat_CL_RR_EX, CL_EX: std_logic_vector(13 downto 0);
	signal concat_CL_EX_MM, CL_MM: std_logic_vector(9 downto 0);
	signal concat_CL_MM_WB, CL_WB: std_logic_vector(8 downto 0);
	signal CONTROL_CLR_RR_EX, disable_RR_EX, sel_EX_hazard_MUX, CONTROL_CLR_EX_MM, sel_forward_MUX_MM, tp_WRITE_R0, WRITE_R0, sel_WB_hazard_MUX: std_logic;
	signal tp_RF_A3_EX, RF_A2_EX, RF_A2_MM: std_logic_vector(2 downto 0);
	signal EXT_D2_MUX, ALUB_Input, EX_hazard_MUX, MUX_IN_EX, EXT_PC_MM, RF_D1_MM, RF_D2_MM, MEM_A, MEM_DI, MEM_OUT_WB, MM_hazard_MUX, MUX_IN_MM: std_logic_vector(15 downto 0);
	signal EXT_WB, EXT_PC_WB, ALU_OUT_WB, RF_D1_WB, INCPC_WB, MUX_IN_WB, RR_hazard_MUX, R0_IN, R0_O, display: std_logic_vector(15 downto 0);   
	
	
begin
	---------------------------------
	---- Instruction Fetch Stage ----
	---------------------------------
	PC: reg_generic
		generic map(16)
		port map(clk => clk, reset => reset, en => PC_ENB, init => "0000000000000000", Din => PC_IN, Dout => PC_OUT);
	PC_ENB <= not(staller_disable or disable_LMSM);
	INCPC <= std_logic_vector(unsigned(PC_OUT) + to_unsigned(1,16));
	IM_A <= PC_out;
	
	IM: ROM
		port map(
			IM_A => IM_A, IM_DO => IM_DO, IM_RD => '1', clk => clk);
	
	BEQ_predict: b_predict
		port map(
		clk => clk, reset => reset, Bra_en => BEQ_en, twitch => BEQ_twitch,
		PC_ID => PC_ID, PC_IN => PC_OUT, BA_IN => EXT_PC_ID, is_taken => BEQ_is_taken, 
		BA => BEQ_BA, ADDR_IN => BEQP_index_in, ADDR_OUT => BEQP_index_out);	
		
	BLT_predict: b_predict
		port map(
		clk => clk, reset => reset, Bra_en => BLT_en, twitch => BLT_twitch,
		PC_ID => PC_ID, PC_IN => PC_OUT, BA_IN => EXT_PC_ID, is_taken => BLT_is_taken, 
		BA => BLT_BA, ADDR_IN => BLTP_index_in, ADDR_OUT => BLTP_index_out);
	
	BLE_predict: b_predict
		port map(
		clk => clk, reset => reset, Bra_en => BLE_en, twitch => BLE_twitch,
		PC_ID => PC_ID, PC_IN => PC_OUT, BA_IN => EXT_PC_ID, is_taken => BLE_is_taken, 
		BA => BLE_BA, ADDR_IN => BLEP_index_in, ADDR_OUT => BLEP_index_out);
		
	BEQ_PC <= INCPC when (BEQ_is_taken = '0') else  BEQ_BA;
	BLE_PC <= INCPC when (BLE_is_taken = '0') else  BLE_BA;
	BLT_PC <= INCPC when (BLT_is_taken = '0') else  BLT_BA;
	
	---------------------------------
	---- IF/ID Pipeline Register ----
	---------------------------------
	
	concat_BEQP_IF_ID <= BEQP_index_out & BEQ_is_taken;
	concat_BLEP_IF_ID <= BLEP_index_out & BLE_is_taken;
	concat_BLTP_IF_ID <= BLTP_index_out & BLT_is_taken;
	
	piped_IF_ID: IF_ID
		port map(
		PC_IN => PC_OUT,
		INST_IN => IM_DO,
		INCPC_IN => INCPC,
		clk => clk,
		CLR => reset,
		CONTROL_CLR => CONTROL_CLR_IF_ID,
		disable => disable_IF_ID,
  		BEQ_PRED_IN => concat_BEQP_IF_ID,
		BEQ_PRED_OUT => BEQP_ID,
  		BLT_PRED_IN => concat_BLTP_IF_ID,
		BLT_PRED_OUT => BLTP_ID,
  		BLE_PRED_IN => concat_BLEP_IF_ID,
		BLE_PRED_OUT => BLEP_ID,
		PC_OUT => PC_ID,
		INST_OUT => INST_ID,
		INCPC_OUT => INCPC_ID,
		NOFLUSH_OUT => NOFLUSH_OUT);

	CONTROL_CLR_IF_ID <= (not disable_ID_RR) and (ID_PC or hazard_RR_clear or hazard_EX_flush or hazard_MM_clear or hazard_WB_clear);
	disable_IF_ID	    <= staller_disable or disable_LMSM;
	
	----------------------------------
	---- Instruction Decode Stage ----
	----------------------------------
	
	--Control Bits are 
	-- LM(0), LW(1), SE_or_RFD2(2), BEQ_en(3), BLT_en(4), BLE_en(5), WB_mux(6,7), used(8,9,10), noflush(11)
	
	INST_DECODE: inst_decoder
		port map(
			instruc => INST_ID, SE6_9 => SE6_9, ID_PC => ID_PC, LLI => LLI, LM => CL_ID(0), SM => SM, LW => CL_ID(1), 
			SE_RF_D2 => CL_ID(2), BEQ_en => CL_ID(3), BLT_en => CL_ID(4), BLE_en => CL_ID(5), WB_mux => CL_ID(7 downto 6),
			RF_A1 => RF_A1_ID, RF_A2 => RF_A2_ID, RF_A3 => RF_A3_ID, used => CL_ID(10 downto 8),
			alu_control => ALU_CONTROL_ID, CZ => FC_ID, enc_addnand => COND_ID, WR => WR_ID);
	
	SE: sign_extend
		port map(inp_16bit => INST_ID, outp_16bit => EXT_ID, SE_op => SE6_9, extend_zero => LLI);
	
	LMSM_ID_RR <= LM_ID when  (sel_LMSM_IN = '0') else LM_RR; 			
	EXT_PC_ID <= std_logic_vector(unsigned(PC_ID) + unsigned(EXT_ID));
	JAL_PC <= BEQ_PC when ((ID_PC = '0')) else
					BLT_PC when ((ID_PC = '0') and (BLT_en = '1')) else
					BLE_PC when ((ID_PC = '0') and (BLE_en = '1'))
					else EXT_PC_ID;
	BEQ_en <= CL_ID(3);
	BLT_en <= CL_ID(4);
	BLE_en <= CL_ID(5);
	CL_ID(11) <= NOFLUSH_OUT(0);
		
	---------------------------------
	---- ID/RR Pipeline Register ----
	---------------------------------
	
	LM_ID <= INST_ID(7 downto 0);
	
	piped_ID_RR: ID_RR  
	port map(
		PC_IN => PC_ID,
		EXTPC_IN => EXT_PC_ID,
		EXT_IN => EXT_ID,
		CONTROL_IN => CL_ID,
		ALU_CONTROL_IN => ALU_CONTROL_ID,
		FC_IN => FC_ID,
		CONDITION_IN => COND_ID, 
		WRITE_CONTROL_IN => WR_ID,
		RF_A1_IN => RF_A1_ID,
		RF_A2_IN => RF_A2_ID,
		RF_A3_IN => RF_A3_ID,
		INCPC_IN => INCPC_ID,
		LM_IN => LM_ID,
		clk => clk,
		CLR => reset,
		CONTROL_CLR => CONTROL_CLR_ID_RR,
		disable => disable_ID_RR,
		PC_OUT => PC_RR,
		EXTPC_OUT => EXT_PC_RR,
		EXT_OUT => EXT_RR,
		CONTROL_OUT => CL_RR,
		ALU_CONTROL_OUT => ALU_CONTROL_RR,
		FC_OUT => FC_RR,
		CONDITION_OUT => COND_RR,
		WRITE_CONTROL_OUT => WR_RR,
		RF_A1_OUT => RF_A1_RR,
		RF_A2_OUT => RF_A2_RR,
		RF_A3_OUT => RF_A3_RR,
		INCPC_OUT => INCPC_RR,
		LM_OUT => LM_RR,	
  		BEQ_PRED_IN => BEQP_ID,
		BEQ_PRED_OUT => BEQP_RR,
  		BLT_PRED_IN => BLTP_ID,
		BLT_PRED_OUT => BLTP_RR,
  		BLE_PRED_IN => BLEP_ID,
		BLE_PRED_OUT => BLEP_RR,
		OPCODE_IN => INST_ID(15 downto 12),
		OPCODE_OUT => OP_RR);
	
	CONTROL_CLR_ID_RR <= (	not disable_RR_EX) and (hazard_RR_clear or staller_clear or hazard_EX_flush or hazard_MM_clear or hazard_WB_clear); 
	disable_ID_RR <= disable_LMSM;
	
	-----------------------------
	---- Register Read Stage ----
	-----------------------------
	
	--CL_ID, CL_RR 
	-- LM(0), LW(1), SE_or_RFD2(2), BEQ_en(3), BLT_en(4), BLE_en(5), WB_mux(6,7), used(8,9,10), noflush(11)
	-- LS_PC(0), BEQ(1) , LM (2) , LW(3) , SE_DO2(4) , WB_mux(5,6,7), valid(8,9,10), unflush(11)  (SM is removed since decoder directly provides)
	
	--CL_EX --> 
	-- LW(0), SE_or_RFD2(1), BEQ_en(2), BLT_en(3), BLE_en(4), WB_mux(5,6), used(7,8,9), LMSM_control(10,11,12), noflush(13)
	--BEQ(0) , LW(1) , SE_DO2(2) , WB_mux(3,4,5), valid(6,7,8), LM_SM_control(9,10,11), unflush(12) -> Generated from the LM SM block
	
	--CL_MM -->
	--BEQ_en(0), BLT_en(1), BLE_en(2), WB_mux(3,4), used(5,6,7), LMSM_control(8), unflush(9)
	--BEQ(0) , WB_mux(1,2,3), valid(4,5,6), LM_SM_control(7), unflush(8)
	
	--CL_WB -->
	--BEQ_en(0), BLT_en(1), BLE_en(2), WB_mux(3,4), used(5,6,7), unflush(8)
	--BEQ(0) , WB_mux(1,2,3), valid(4,5,6), unflush(7) 
		
	-- LM SM Block
	SM_Inp <= SM and (not SM_control);
	LMSM_Block: LM_SM
		port map(
		IMM => LMSM_ID_RR, LM => CL_RR(0), SM => SM_Inp, clk => clk,
		reset => reset, RF_A2 => RF_A2_DD , RF_A3 => RF_A3_DD , clr => clr_LMSM, disable => disable_LMSM,
		sel_IMM => sel_LMSM_IN, sel_RF_D1 => sel_RF_D1, sel_RF_A2 => sel_RF_A2, sel_RF_A3 => sel_RF_A3, sel_MEM_IN => sel_MEM_IN, sel_ALUB => sel_ALUB);
	
	--Forwarding Block
	ForwardingBlock1 : forward_controller
		port map(
		ID_RR_RF_A => RF_A1_RR, ID_RR_RF_A_used => CL_RR(10), ID_RR_PC => PC_RR, clk => clk, 
		sel_RR_EX_MUX => CL_EX(6 downto 5), RR_EX_RF_A3_used => CL_EX(7), RR_EX_RF_A3 => RF_A3_EX, 
		RR_EX_ALU_C => ALU_OUT_EX, RR_EX_EXT => EXT_EX, RR_EX_INCPC => INCPC_EX,
		sel_EX_MM_MUX => CL_MM(4 downto 3), EX_MM_RF_A3_used => CL_MM(5), EX_MM_RF_A3 => RF_A3_MM,
		EX_MM_ALU_C => ALU_OUT_MM, EX_MM_EXT => EXT_MM, EX_MM_INCPC => INCPC_MM, EX_MM_MEM_OUT => MEM_OUT,
		MM_WB_RF_A3_used => CL_WB(5), MM_WB_RF_A3 => RF_A3_WB, MM_WB_toforward => D3_data,
		forward_CONTROL => tp1_forward_CONTROL, forward_DATA => tp1_forward_DATA);
	
	ForwardingBlock2 : forward_controller
		port map(
		ID_RR_RF_A => RF_A2_RR, ID_RR_RF_A_used => CL_RR(9), ID_RR_PC => PC_RR, clk => clk, 
		sel_RR_EX_MUX => CL_EX(6 downto 5), RR_EX_RF_A3_used => CL_EX(7), RR_EX_RF_A3 => RF_A3_EX, 
		RR_EX_ALU_C => ALU_OUT_EX, RR_EX_EXT => EXT_EX, RR_EX_INCPC => INCPC_EX,
		sel_EX_MM_MUX => CL_MM(4 downto 3), EX_MM_RF_A3_used => CL_MM(5), EX_MM_RF_A3 => RF_A3_MM,
		EX_MM_ALU_C => ALU_OUT_MM, EX_MM_EXT => EXT_MM, EX_MM_INCPC => INCPC_MM, EX_MM_MEM_OUT => MEM_OUT,
		MM_WB_RF_A3_used => CL_WB(5), MM_WB_RF_A3 => RF_A3_WB, MM_WB_toforward => D3_data,
		forward_CONTROL => tp2_forward_CONTROL, forward_DATA => tp2_forward_DATA);

	-- Hazard RR
	hazard_RR_inst: RR_hazard_unit
		port map(
		ID_RR_RF_A3 => RF_A3_RR, ID_RR_used => CL_RR(10 downto 8), ID_RR_EXT => EXT_RR, 
		ID_RR_RF_D1 => RF_D1_RR, opcode => OP_RR, clk => clk, clear_pip_reg => hazard_RR_clear, sel_RR_hazard_MUX => sel_RR_hazard_MUX,
		MUX_IN => MUX_IN_RR);

	-- Staller
	staller_inst: stall_unit
		port map(
		RF_A1 => RF_A1_ID, RF_A2 => RF_A2_ID, ID_RR_LW_control => CL_RR(1),
		IF_ID_enc_addnand => COND_ID(1 downto 0), RF_A3 => RF_A3_RR, RF_used => CL_ID(10 downto 8),
		ID_RR_opcode => OP_RR, IF_ID_opcode => INST_ID(15 downto 12),
		clk => clk, disable => staller_disable, SM_control => SM_control, clear => staller_clear);
	
	RR_hazard_MUX <= JAL_PC when (sel_RR_hazard_MUX = '0') else MUX_IN_RR;
	RF_A2 <= RF_A2_RR when (sel_RF_A2 = '0') else RF_A2_DD;
	Forward_MUX <= RF_D1 when(tp1_forward_control = '0') else tp1_forward_DATA;
	RF_D2_RR <= RF_D2 when (tp2_forward_control = '0') else tp2_forward_DATA;
	RF_D1_RR <= Forward_MUX when(sel_RF_D1 = '0') else ALU_OUT_EX;
	
	--Register File
	RegisterFile: register_file
		port map(RF_D3 => D3_data, R0_IN => R0_IN, RF_D1 => RF_D1,
				 RF_D2 => RF_D2, R0_O => display, RF_A3 => RF_A3_WB, RF_A1 => RF_A1_RR,
				 RF_A2 => RF_A2 , clk => clk, RF_WR => WR_WB(1), R0_WR => WRITE_R0, reset => reset);

	---------------------------------
	---- RR/EX Pipeline Register ----
	---------------------------------
		
	concat_CL_RR_EX <= (CL_RR(11) & sel_ALUB & sel_MEM_IN & sel_RF_A3 & CL_RR(10 downto 1));
	
	piped_RR_EX: RR_EX   
	port map(
		EXT_IN => EXT_RR,
		EXT_PC_IN => EXT_PC_RR,
		CONTROL_IN => concat_CL_RR_EX,
		ALU_CONTROL_IN => ALU_CONTROL_RR,
		FC_IN => FC_RR,
		CONDITION_IN => COND_RR,
		WRITE_CONTROL_IN => WR_RR,
		RF_D1_IN => RF_D1_RR,
		RF_D2_IN => RF_D2_RR,
		RF_A2_IN => RF_A2_RR,
		RF_A3_IN => RF_A3_RR,
		INCPC_IN => INCPC_RR,
		clk => clk,
		CLR => reset,
		CONTROL_CLR => CONTROL_CLR_RR_EX,
		disable => disable_RR_EX,
		ENB_LMSM => sel_RF_D1,
		EXT_OUT => EXT_EX,
		EXT_PC_OUT => EXT_PC_EX,
		CONTROL_OUT => CL_EX,
		ALU_CONTROL_OUT =>ALU_CONTROL_EX,
		FC_OUT => FC_EX,
		CONDITION_OUT => COND_EX,
		WRITE_CONTROL_OUT => WR_EX,
		RF_D1_OUT => RF_D1_EX,
		RF_D2_OUT => RF_D2_EX,
		RF_A2_OUT => RF_A2_EX,
		RF_A3_OUT => tp_RF_A3_EX,
		INCPC_OUT => INCPC_EX,
  		BEQ_PRED_IN => BEQP_RR,
		BEQ_PRED_OUT => BEQP_EX,
  		BLT_PRED_IN => BLTP_RR,
		BLT_PRED_OUT => BLTP_EX,
  		BLE_PRED_IN => BLEP_RR,
		BLE_PRED_OUT => BLEP_EX,
		OPCODE_IN => OP_RR,
		OPCODE_OUT => OP_EX);
	
	disable_RR_EX <= (not CL_RR(0)) and disable_LMSM;
	CONTROL_CLR_RR_EX <= clr_LMSM or hazard_MM_clear or hazard_WB_clear;

	-------------------------
	---- Execution Stage ----
	-------------------------
	EXT_D2_MUX <= RF_D2_EX when (CL_EX(1) = '0') else EXT_EX;
	ALUB_Input <= EXT_D2_MUX when (CL_EX(12) = '0') else "0000000000000001";

	ALU_ex: alu
		port map(
			ALU_A => RF_D1_EX, ALU_B => ALUB_Input,
			ALU_C => ALU_OUT_EX,
			ALU_op => ALU_CONTROL_EX,
			ALU_Carry_In => flags_MM(1),
			ALU_Compare => Compare_Flags,
			ALU_Z => flags_EX(0), ALU_Carry => flags_EX(1));
			
	EX_hazard_MUX <= RR_hazard_MUX when (sel_EX_hazard_MUX = '0') else MUX_IN_EX;
		
	-- LM SM MUX
	RF_A3_EX <= tp_RF_A3_EX when(CL_EX(10) = '0') else RF_A3_DD;
	
	-- Hazard EX block
	Hazard_EX_instance: EX_hazard_unit
		port map(
			RR_EX_RF_A3 => RF_A3_EX, RR_EX_used => CL_EX(9 downto 7), sel_RR_EX_MUX => CL_EX(6 downto 5), 
			RR_EX_opcode => OP_EX, EX_MM_FC => FC_MM(0), MM_WB_FC => FC_WB(0), RR_EX_enc_addnand => COND_EX(1 downto 0), EX_MM_Flags => flags_MM,
			MM_WB_Flags => flags_WB, Flags => flags_present, alu_Compare => Compare_Flags, ALU_OUT => ALU_OUT_EX, INCPC => INCPC_EX, EXT_PC => EXT_PC_EX, 
			BEQ_is_taken => BEQP_EX(0), BEQ_bit => CL_EX(2), BLE_is_taken => BLEP_EX(0), BLE_bit => CL_EX(4), BLT_is_taken => BLTP_EX(0), BLT_bit => CL_EX(3),
			BEQ_table_twitch => BEQ_twitch, BLE_table_twitch => BLE_twitch, BLT_table_twitch => BLT_twitch, 
			table_BEQ_taken_in => BEQ_is_taken_EX, table_BLE_taken_in => BLE_is_taken_EX, table_BLT_taken_in => BLT_is_taken_EX,
			MUX_IN => MUX_IN_EX , sel_EX_hazard_MUX => sel_EX_hazard_MUX, flush => hazard_EX_flush , clear => hazard_EX_clear, clk => clk);
	
	BEQP_index_in <= BEQP_EX(3 downto 1);
	BLEP_index_in <= BLEP_EX(3 downto 1);
	BLTP_index_in <= BLTP_EX(3 downto 1);
	
	---------------------------------
	---- EX/MM Pipeline Register ----
	---------------------------------
	concat_CL_EX_MM <= (CL_EX(13) & CL_EX(11) & CL_EX(9 downto 7) & CL_EX(6 downto 2));
	concat_BEQP_EX_MM <= (BEQP_EX(3 downto 1) & BEQ_is_taken_EX);
	concat_BLEP_EX_MM <= (BLEP_EX(3 downto 1) & BLE_is_taken_EX);
	concat_BLTP_EX_MM <= (BLTP_EX(3 downto 1) & BLT_is_taken_EX);
	
	piped_EX_MM: EX_MM 
	port map(
		EXT_IN => EXT_EX,
		EXT_PC_IN => EXT_PC_EX,
		CONTROL_IN => concat_CL_EX_MM,
		ALU_OUTPUT_IN => ALU_OUT_EX,
		FC_IN => FC_EX,
		WRITE_CONTROL_IN => WR_EX,
		RF_D1_IN => RF_D1_EX,
		RF_D2_IN => RF_D2_EX,
		RF_A2_IN => RF_A2_EX,
		RF_A3_IN => RF_A3_EX,
		INCPC_IN => INCPC_EX,
		UPDATED_FLAGS_IN => flags_EX,
		clk => clk,
		CONDITIONAL_CLR => hazard_EX_clear, 
		CLR => reset,
		CONTROL_CLR => CONTROL_CLR_EX_MM,
		EXT_OUT => EXT_MM,
		EXT_PC_OUT => EXT_PC_MM,
		CONTROL_OUT => CL_MM,
		ALU_OUTPUT_OUT => ALU_OUT_MM,
		FC_OUT => FC_MM,
		UPDATED_FLAGS_OUT => flags_MM,
		WRITE_CONTROL_OUT => WR_MM,
		RF_D1_OUT => RF_D1_MM,
		RF_D2_OUT => RF_D2_MM,
		RF_A2_OUT => RF_A2_MM,
		RF_A3_OUT => RF_A3_MM,
		INCPC_OUT => INCPC_MM,
  		BEQ_PRED_IN => concat_BEQP_EX_MM,
		BEQ_PRED_OUT => BEQP_MM,
  		BLT_PRED_IN => concat_BLTP_EX_MM,
		BLT_PRED_OUT => BLTP_MM,
  		BLE_PRED_IN => concat_BLEP_EX_MM,
		BLE_PRED_OUT => BLEP_MM,
		OPCODE_IN => OP_EX,
		OPCODE_OUT => OP_MM);
	
	CONTROL_CLR_EX_MM <= hazard_MM_clear or hazard_WB_clear;
	
	---------------------------------
	---- Memory Read/Write Stage ----
	---------------------------------
	MEM_A <= ALU_OUT_MM when(CL_MM(8) = '1') else RF_D1_MM;
	MEM_DI <= RF_D2_MM when(sel_forward_MUX_MM = '1') else MEM_OUT_WB;
	
	MM_hazard_MUX <= EX_hazard_MUX when(sel_MM_hazard_MUX = '0') else MEM_OUT;
	
	data_memory: memory
		port map(
			MEM_DI => MEM_DI, MEM_DO => MEM_OUT, MEM_A => MEM_A, clk => clk,
			MEM_WR => WR_MM(0), MEM_RD => '1', reset => reset);

	hazard_MM : MM_hazard_unit
		port map(
			EX_MM_RF_A3 => RF_A3_MM, EX_MM_used => CL_MM(7 downto 5), sel_EX_MM_MUX => CL_MM(4 downto 3), sel_MM_hazard_MUX => sel_MM_hazard_MUX, 
			EX_MM_Flags => flags_MM, MEM_OUT => MEM_OUT, MM_flags => hazard_flags_MM, clear => hazard_MM_clear);

	memory_forwarding : MM_Forward_unit
		port map(
			EX_MM_RF_A2 => RF_A2_MM, MM_WB_RF_A3 => RF_A3_WB, MM_WB_opcode => OP_WB, EX_MM_opcode => OP_MM,
			EX_MM_RF_A2_used => CL_MM(6), MM_WB_RF_A3_used => CL_WB(5), sel_forward_MUX => sel_forward_MUX_MM,
			clk => clk);
	
	---------------------------------
	---- MM/WB Pipeline Register ----
	---------------------------------
	
	concat_CL_MM_WB <= CL_MM(9) & CL_MM(7 downto 0);
	piped_MM_WB: MM_WB
		port map(
			EXT_IN => EXT_MM,
			EXT_PC_IN => EXT_PC_MM,
			CONTROL_IN => concat_CL_MM_WB,
			ALU_OUTPUT_IN => ALU_OUT_MM,
			MEM_OUTPUT_IN => MEM_OUT,
			FC_IN => FC_MM,
			WRITE_CONTROL_IN => WR_MM,
			RF_D1_IN => RF_D1_MM,
			RF_A3_IN => RF_A3_MM,
			INCPC_IN => INCPC_MM,
			UPDATED_FLAGS_IN => hazard_flags_MM,
			clk => clk,
			CLR => reset,
			CONTROL_CLR => CONTROL_CLR_MM_WB,
			EXT_OUT => EXT_WB,
			EXT_PC_OUT => EXT_PC_WB,
			CONTROL_OUT => CL_WB,
			ALU_OUTPUT_OUT => ALU_OUT_WB,
			MEM_OUTPUT_OUT => MEM_OUT_WB,
			FC_OUT => FC_WB,
			UPDATED_FLAGS_OUT => flags_WB,
			WRITE_CONTROL_OUT => WR_WB,
			RF_D1_OUT => RF_D1_WB,
			RF_A3_OUT =>  RF_A3_WB,
			INCPC_OUT => INCPC_WB,
			BEQ_PRED_IN => BEQP_MM,
			BEQ_PRED_OUT => BEQP_WB,
			BLT_PRED_IN => BLTP_MM,
			BLT_PRED_OUT => BLTP_WB,
			BLE_PRED_IN => BLEP_MM,
			BLE_PRED_OUT => BLEP_WB,
			OPCODE_IN => OP_MM,
			OPCODE_OUT => OP_WB);
	
	CONTROL_CLR_MM_WB <= hazard_WB_clear;
	
	--------------------------
	---- Write Back Stage ----
	--------------------------
	-- Write back mux
	D3_data <= ALU_OUT_WB when(CL_WB(4 downto 3) = "10") else
			   EXT_WB when(CL_WB(4 downto 3) = "11") else INCPC_WB when(CL_WB(4 downto 3) = "01") else MEM_OUT_WB;
	
	-- R0 input mux
	R0_IN <= RF_D1_WB when (select_R0 = "00") else 
		EXT_PC_WB when (select_R0 = "10") else
		INCPC_WB;		
	
	WRITE_R0 <= CL_WB(8) and tp_WRITE_R0;
	
	-- Hazard WB block
	hazard_WB :WB_hazard_unit
		port map(
			MM_WB_RF_A3 => RF_A3_WB, MM_WB_INCPC => INCPC_WB, MM_WB_used => CL_WB(7 downto 5),
			WRITE_R0 => tp_WRITE_R0, select_R0 => select_R0, sel_WB_hazard_MUX => sel_WB_hazard_MUX, clear => hazard_WB_clear,  
			MUX_IN => MUX_IN_WB, BEQ_is_taken => BEQP_WB(0), BLT_is_taken => BLTP_WB(0), BLE_is_taken => BLEP_WB(0), opcode => OP_WB); 
		
	PC_IN <= MM_hazard_MUX when (sel_WB_hazard_MUX = '0') else MUX_IN_WB;
		
	C_instance: reg_generic
		generic map(1)
		port map(
			clk => clk, reset => reset, en => FC_WB(1), init => "0",
			Din => flags_WB(1 downto 1), Dout => flags_present(1 downto 1));
			
	Z_instance: reg_generic
		generic map(1)
		port map(
			clk => clk, reset => reset, en => FC_WB(0), init => "0",
			Din => flags_WB(0 downto 0), Dout => flags_present(0 downto 0));
		
end architecture;
