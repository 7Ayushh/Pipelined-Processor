library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_ID is
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
end entity;

architecture pipreg1 of IF_ID is

signal inst_t: std_logic_vector(15 downto 0);

component reg_generic is
	generic (data_width : integer);
	port(
		clk, en, reset: in std_logic;
		Din: in std_logic_vector(data_width-1 downto 0);
		init: in std_logic_vector(data_width-1 downto 0);
		Dout: out std_logic_vector(data_width-1 downto 0));
end component;

signal enable, CLR_tp: std_logic;
begin	
	enable <= (not disable);
	CLR_tp <= (CLR or CONTROL_CLR);
	PC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => PC_IN, Dout => PC_OUT, en => enable);
		
	inst_t <= "0001000000000000" when (CONTROL_CLR = '1') else INST_IN; 
	
	INST_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => inst_t, Dout => INST_OUT, en => enable);
		
	INCPC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => INCPC_IN, Dout => INCPC_OUT, en => enable);
	        	 				 
	BEQ_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR, init => "0000", Din => BEQ_PRED_IN, Dout => BEQ_PRED_OUT, en => enable);
	BLE_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR, init => "0000", Din => BLE_PRED_IN, Dout => BLE_PRED_OUT, en => enable);
	BLT_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR, init => "0000", Din => BLT_PRED_IN, Dout => BLT_PRED_OUT, en => enable);
			
	NOFLUSH_register: reg_generic
		generic map(1)
		port map(clk => clk, reset => CLR_tp, init => "0", Din => "1", Dout => NOFLUSH_OUT, en => enable);

end architecture; 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_RR is  
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
end entity;

architecture pipreg2 of ID_RR is 

component reg_generic is
	generic (data_width : integer);
	port(
		clk, en, reset: in std_logic;
		Din: in std_logic_vector(data_width-1 downto 0);
		init: in std_logic_vector(data_width-1 downto 0);
		Dout: out std_logic_vector(data_width-1 downto 0));
end component;

signal enable, CLR_tp: std_logic;
begin	
	enable <= (not disable);
	CLR_tp <= (CLR or CONTROL_CLR);
	PC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => PC_IN, Dout => PC_OUT, en => enable);
	
	EXTPC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => EXTPC_IN, Dout => EXTPC_OUT, en => enable);
		
	EXT_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => EXT_IN, Dout => EXT_OUT, en => enable);
	
	INCPC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => INCPC_IN, Dout => INCPC_OUT, en => enable);
	        	 				 
	CONTROL_register: reg_generic
		generic map(12)
		port map(clk => clk, reset => CLR_tp, init => "000000000000", Din => CONTROL_IN, Dout => CONTROL_OUT, en => enable);
	
	ALU_CONTROL_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR, init => "0000", Din => ALU_CONTROL_IN, Dout => ALU_CONTROL_OUT, en => enable);
		
	FC_register: reg_generic
		generic map(2)
		port map(clk => clk, reset =>CLR_tp, init => "00", Din => FC_IN, Dout => FC_OUT, en => enable);
		
	CONDITION_register: reg_generic
		generic map(3)
		port map(clk => clk, reset => CLR, init => "000", Din => CONDITION_IN, Dout => CONDITION_OUT, en => enable);
		
	WRITE_CONTROL_register: reg_generic
		generic map(2)
		port map(clk => clk, reset => CLR_tp, init => "00", Din => WRITE_CONTROL_IN, Dout => WRITE_CONTROL_OUT, en => enable);
	    
	RF_A1_register: reg_generic
		generic map(3)
		port map(clk => clk, reset => CLR, init => "000", Din => RF_A1_IN, Dout => RF_A1_OUT, en => enable);
		
	RF_A2_register: reg_generic
		generic map(3)
		port map(clk => clk, reset => CLR, init => "000", Din => RF_A2_IN, Dout => RF_A2_OUT, en => enable);
		
	RF_A3_register: reg_generic
		generic map(3)
		port map(clk => clk, reset => CLR, init => "000", Din => RF_A3_IN, Dout => RF_A3_OUT, en => enable);	
 
	LM_register: reg_generic
		generic map(8)
		port map(clk => clk, reset => CLR, init => "00000000", Din => LM_IN, Dout => LM_OUT, en => enable);
	BEQ_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR_tp, init => "0000", Din => BEQ_PRED_IN, Dout => BEQ_PRED_OUT, en => enable);
	BLE_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR_tp, init => "0000", Din => BLE_PRED_IN, Dout => BLE_PRED_OUT, en => enable);
	BLT_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR_tp, init => "0000", Din => BLT_PRED_IN, Dout => BLT_PRED_OUT, en => enable);
	
	OPCODE_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR, init => "0000", Din => OPCODE_IN, Dout => OPCODE_OUT, en => enable);
			
end architecture; 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RR_EX is  
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
end entity;

architecture pipreg3 of RR_EX is

component reg_generic is
	generic (data_width : integer);
	port(
		clk, en, reset: in std_logic;
		Din: in std_logic_vector(data_width-1 downto 0);
		init: in std_logic_vector(data_width-1 downto 0);
		Dout: out std_logic_vector(data_width-1 downto 0));
end component;
signal enable, CLR_tp, enb_temp: std_logic;
begin	
	enable <= (not disable);
	CLR_tp <= (CLR or CONTROL_CLR);
	enb_temp <= (enable OR ENB_LMSM);
	
	EXT_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => EXT_IN, Dout => EXT_OUT, en => enable);
		
	EXTPC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => EXT_PC_IN, Dout => EXT_PC_OUT, en => enable);     	 				 
	CONTROL_register: reg_generic
		generic map(14)
		port map(clk => clk, reset => CLR_tp, init => "00000000000000", Din => CONTROL_IN, Dout => CONTROL_OUT, en => enb_temp);
	
	ALU_CONTROL_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR, init => "0000", Din => ALU_CONTROL_IN, Dout => ALU_CONTROL_OUT, en => enable);
		
	INCPC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => INCPC_IN, Dout => INCPC_OUT, en => enable);
	        	
	FC_register: reg_generic
		generic map(2)
		port map(clk => clk, reset =>CLR_tp, init => "00", Din => FC_IN, Dout => FC_OUT, en => enable);
		
	CONDITION_register: reg_generic
		generic map(3)
		port map(clk => clk, reset => CLR, init => "000", Din => CONDITION_IN, Dout => CONDITION_OUT, en => enable);
		
	WRITE_CONTROL_register: reg_generic
		generic map(2)
		port map(clk => clk, reset => CLR_tp, init => "00", Din => WRITE_CONTROL_IN, Dout => WRITE_CONTROL_OUT, en => enable);
	    
	RF_D1_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => RF_D1_IN, Dout => RF_D1_OUT, en => enb_temp);
		
	RF_D2_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => RF_D2_IN, Dout => RF_D2_OUT, en => enb_temp);
		
	RF_A3_register: reg_generic
		generic map(3)
		port map(clk => clk, reset => CLR, init => "000", Din => RF_A3_IN, Dout => RF_A3_OUT, en => enable);	
	
	RF_A2_register: reg_generic
		generic map(3)
		port map(clk => clk, reset => CLR, init => "000", Din => RF_A2_IN, Dout => RF_A2_OUT, en => enable);	
 	BEQ_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR_tp, init => "0000", Din => BEQ_PRED_IN, Dout => BEQ_PRED_OUT, en => enable);
	BLE_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR_tp, init => "0000", Din => BLE_PRED_IN, Dout => BLE_PRED_OUT, en => enable);
	BLT_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR_tp, init => "0000", Din => BLT_PRED_IN, Dout => BLT_PRED_OUT, en => enable);
	
	OPCODE_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR, init => "0000", Din => OPCODE_IN, Dout => OPCODE_OUT, en => enable);
		
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_MM is 
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
end entity;

architecture pipreg4 of EX_MM is 

component reg_generic is
	generic (data_width : integer);
	port(
		clk, en, reset: in std_logic;
		Din: in std_logic_vector(data_width-1 downto 0);
		init: in std_logic_vector(data_width-1 downto 0);
		Dout: out std_logic_vector(data_width-1 downto 0));
end component;

signal enable, CLR_tp, CLR_tp1: std_logic;
begin	
	CLR_tp <= (CLR or CONTROL_CLR);
	CLR_tp1 <= (CLR_tp or CONDITIONAL_CLR);

	EXT_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => EXT_IN, Dout => EXT_OUT, en => '1');
	
	EXT_PC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => EXT_PC_IN, Dout => EXT_PC_OUT, en => '1');
	        	 				 
	CONTROL_register: reg_generic
		generic map(9)
		port map(clk => clk, reset => CLR_tp1, init => "000000000", Din => CONTROL_IN(8 downto 0), Dout => CONTROL_OUT(8 downto 0), en => '1');
	
	NOFLUSH_register: reg_generic
		generic map(1)
		port map(clk => clk, reset => CLR_tp, init => "0", Din => CONTROL_IN(9 downto 9), Dout => CONTROL_OUT(9 downto 9), en => '1');
		
	ALU_OUTPUT_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => ALU_OUTPUT_IN, Dout => ALU_OUTPUT_OUT, en => '1');
		
	INCPC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => INCPC_IN, Dout => INCPC_OUT, en => '1');
	        	
	FC_register: reg_generic
		generic map(2)
		port map(clk => clk, reset =>CLR_tp1, init => "00", Din => FC_IN, Dout => FC_OUT, en => '1');
		
	UPDATED_FLAGS_register: reg_generic
		generic map(2)
		port map(clk => clk, reset => CLR, init => "00", Din => UPDATED_FLAGS_IN, Dout => UPDATED_FLAGS_OUT, en => '1');
		
	WRITE_CONTROL_register: reg_generic
		generic map(2)
		port map(clk => clk, reset =>CLR_tp1, init => "00", Din => WRITE_CONTROL_IN, Dout => WRITE_CONTROL_OUT, en => '1');
	    
	RF_D1_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => RF_D1_IN, Dout => RF_D1_OUT, en => '1');
		
	RF_D2_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => RF_D2_IN, Dout => RF_D2_OUT, en => '1');
		
	RF_A3_register: reg_generic
		generic map(3)
		port map(clk => clk, reset => CLR, init => "000", Din => RF_A3_IN, Dout => RF_A3_OUT, en => '1');	
	
	RF_A2_register: reg_generic
		generic map(3)
		port map(clk => clk, reset => CLR, init => "000", Din => RF_A2_IN, Dout => RF_A2_OUT, en => '1');	
 	BEQ_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR_tp1, init => "0000", Din => BEQ_PRED_IN, Dout => BEQ_PRED_OUT, en => '1');
	BLE_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR_tp1, init => "0000", Din => BLE_PRED_IN, Dout => BLE_PRED_OUT, en => '1');
	BLT_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR_tp1, init => "0000", Din => BLT_PRED_IN, Dout => BLT_PRED_OUT, en => '1');
	
	OPCODE_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR, init => "0000", Din => OPCODE_IN, Dout => OPCODE_OUT, en => '1');
		
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MM_WB is 
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
end entity;

architecture pipreg5 of MM_WB is 

component reg_generic is
	generic (data_width : integer);
	port(
		clk, en, reset: in std_logic;
		Din: in std_logic_vector(data_width-1 downto 0);
		init: in std_logic_vector(data_width-1 downto 0);
		Dout: out std_logic_vector(data_width-1 downto 0));
end component;

signal enable, CLR_tp: std_logic;
begin	
	CLR_tp <= (CLR or CONTROL_CLR);

	EXT_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => EXT_IN, Dout => EXT_OUT, en => '1');
	
	EXT_PC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => EXT_PC_IN, Dout => EXT_PC_OUT, en => '1');
	        	 				 
	CONTROL_register: reg_generic
		generic map(9)
		port map(clk => clk, reset => CLR_tp, init => "000000000", Din => CONTROL_IN, Dout => CONTROL_OUT, en => '1');
	
	ALU_OUTPUT_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => ALU_OUTPUT_IN, Dout => ALU_OUTPUT_OUT, en => '1');
	
	MEM_OUTPUT_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => MEM_OUTPUT_IN, Dout => MEM_OUTPUT_OUT, en => '1');
		
	INCPC_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => INCPC_IN, Dout => INCPC_OUT, en => '1');
	        	
	FC_register: reg_generic
		generic map(2)
		port map(clk => clk, reset =>CLR_tp, init => "00", Din => FC_IN, Dout => FC_OUT, en => '1');
		
	UPDATED_FLAGS_register: reg_generic
		generic map(2)
		port map(clk => clk, reset => CLR, init => "00", Din => UPDATED_FLAGS_IN, Dout => UPDATED_FLAGS_OUT, en => '1');
		
	WRITE_CONTROL_register: reg_generic
		generic map(2)
		port map(clk => clk, reset =>CLR_tp, init => "00", Din => WRITE_CONTROL_IN, Dout => WRITE_CONTROL_OUT, en => '1');
	    
	RF_D1_register: reg_generic
		generic map(16)
		port map(clk => clk, reset => CLR, init => "0000000000000000", Din => RF_D1_IN, Dout => RF_D1_OUT, en => '1');
		
	RF_A3_register: reg_generic
		generic map(3)
		port map(clk => clk, reset => CLR, init => "000", Din => RF_A3_IN, Dout => RF_A3_OUT, en => '1');		
 
	BEQ_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CONTROL_CLR, init => "0000", Din => BEQ_PRED_IN, Dout => BEQ_PRED_OUT, en => '1');
	BLE_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CONTROL_CLR, init => "0000", Din => BLE_PRED_IN, Dout => BLE_PRED_OUT, en => '1');
	BLT_PRED_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CONTROL_CLR, init => "0000", Din => BLT_PRED_IN, Dout => BLT_PRED_OUT, en => '1');
	OPCODE_register: reg_generic
		generic map(4)
		port map(clk => clk, reset => CLR, init => "0000", Din => OPCODE_IN, Dout => OPCODE_OUT, en => '1');

end architecture;
