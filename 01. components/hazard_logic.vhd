library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity RR_hazard_unit is 	
	port( 
		ID_RR_RF_A3, ID_RR_used : in std_logic_vector(2 downto 0);
		ID_RR_EXT, ID_RR_RF_D1: in std_logic_vector(15 downto 0);
		opcode: in std_logic_vector(3 downto 0);
		clk: in std_logic;
		MUX_IN: out std_logic_vector(15 downto 0);
		clear_pip_reg, sel_RR_hazard_MUX : out std_logic);
end entity;

architecture hazard2 of RR_hazard_unit is
	signal flush_LLI, flush_JLR : std_logic;
	signal temp_clear :std_logic;
begin
	clear_pip_reg <= temp_clear;
	sel_RR_hazard_MUX <= temp_clear;
	flush_LLI <= '1' when (opcode = "0011" and ID_RR_RF_A3 = "000" and ID_RR_used(0) = '1') else '0';
	flush_JLR  <= '1' when(opcode = "1101") else '0';
	MUX_IN  <= ID_RR_RF_D1 when (flush_LLI = '0') else ID_RR_EXT;
	temp_clear <= flush_JLR or flush_LLI;
end architecture;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity stall_unit is 
	port( 
		RF_A1, RF_A2, RF_A3, RF_used : in std_logic_vector(2 downto 0);
		IF_ID_enc_addnand: in std_logic_vector(1 downto 0);
		clk, ID_RR_LW_control : in std_logic;
		ID_RR_opcode, IF_ID_opcode: in std_logic_vector(3 downto 0);
		disable, clear, SM_control: out std_logic);
end entity;

architecture hazard of stall_unit is 
	signal temp_disable : std_logic;
begin 
	process(ID_RR_LW_control, IF_ID_opcode, clk, RF_A2, RF_A1, RF_A3, ID_RR_opcode, IF_ID_enc_addnand, RF_used)
	begin
		if(ID_RR_LW_control /= '0') then
			if (IF_ID_opcode = "0101" and (RF_A2 = RF_A3)) then
				SM_control <= '0';
				temp_disable <= '0';
			elsif(IF_ID_opcode = "0111") then
				if(RF_A1 = RF_A3) then
					SM_control <= '1';
					temp_disable <= '1';
				else
					SM_control <= '0';
					temp_disable <= '0';
				end if;
			elsif (((RF_A2 = RF_A3) and RF_used(1) /= '0') or ((RF_A1 = RF_A3) and (RF_used(2) /= '0'))) then
				SM_control <= '0';
				temp_disable <= '1';
			elsif (((IF_ID_opcode = "0000") or (IF_ID_opcode = "0010")) and (IF_ID_enc_addnand = "01")) then
				SM_control <= '0';
				temp_disable <= '1';
			else
				SM_control <= '0';
				temp_disable <= '0';
			end if;
		else
			SM_control <= '0';
			temp_disable <= '0';
		end if;	
	end process;
	
	disable <= temp_disable;
	clear <= temp_disable;	

end architecture;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity EX_hazard_unit is 
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
end entity;

architecture hazard3 of EX_hazard_unit is 
	signal update_R0, RF_A_ins, RF_A_enc, Not_enc: std_logic;
	signal flags_used : std_logic_vector(1 downto 0);
	signal tmp_BEQ_table_twitch, tmp_BLT_table_twitch, tmp_BLE_table_twitch : std_logic := '0';
begin 
	RF_A_ins <= '1' when ((RR_EX_opcode = "0000") or (RR_EX_opcode = "0001") or (RR_EX_opcode = "0010")); 
	RF_A_enc <= '1' when ((RR_EX_enc_addnand /= "00") and (RF_A_ins = '1')) else '0';
	clear <= '1' when ((RF_A_enc /= '0') and (((RR_EX_enc_addnand = "01") and (flags_used(0) /= '1')) or ((RR_EX_enc_addnand = "10") and (flags_used(1) /= '1')))) else '0';	
	Not_enc <= '1' when ((RF_A_enc /= '0') and (((RR_EX_enc_addnand = "01") and (flags_used(0) /= '1')) or ((RR_EX_enc_addnand = "10") and (flags_used(1) /= '1')))) else '0';
	sel_EX_hazard_MUX <= update_R0;
	flush <= update_R0;
	BEQ_table_twitch <= tmp_BEQ_table_twitch;
	BLT_table_twitch <= tmp_BLT_table_twitch;
	BLE_table_twitch <= tmp_BLE_table_twitch;
	table_BEQ_taken_in <= BEQ_is_taken xor tmp_BEQ_table_twitch;
	table_BLE_taken_in <= BLE_is_taken xor tmp_BLE_table_twitch;
	table_BLT_taken_in <= BLT_is_taken xor tmp_BLT_table_twitch;
	
	process(EX_MM_Flags, EX_MM_FC, Flags, clk, MM_WB_Flags, MM_WB_FC)
	begin
		if (EX_MM_FC /= '0') then
			flags_used <= EX_MM_Flags;
		elsif (MM_WB_FC /= '0') then
			flags_used <= MM_WB_Flags;
		else
			flags_used <= Flags;
		end if;
	end process;
		
	process(RR_EX_RF_A3, sel_RR_EX_MUX, RF_A_ins, Not_enc, RR_EX_used, ALU_OUT, BEQ_is_taken, BLT_is_taken, BLE_is_taken, BEQ_bit, BLT_bit, BLE_bit, alu_Compare, INCPC, EXT_PC)
	begin
		if(RR_EX_RF_A3 = "000" and RR_EX_used(0) /= '0' and RF_A_ins = '1') then
			if (Not_enc /= '1') then
				update_R0 <= '1';
				tmp_BEQ_table_twitch <= '0';
				tmp_BLT_table_twitch <= '0';
				tmp_BLE_table_twitch <= '0';
				MUX_IN <= ALU_OUT;
			else
				update_R0 <= '0';
				tmp_BEQ_table_twitch <= '0';
				tmp_BLT_table_twitch <= '0';
				tmp_BLE_table_twitch <= '0';
				MUX_IN <= (others => '0');
			end if;
		elsif (BEQ_bit = '1') then
			if (BEQ_is_taken = '1' and alu_Compare(0) = '0') then 
				update_R0 <= '1';
				MUX_IN <= INCPC;
				tmp_BEQ_table_twitch <= '1';
				tmp_BLT_table_twitch <= '0';
				tmp_BLE_table_twitch <= '0';
			elsif (BEQ_is_taken = '0' and alu_Compare(0) = '1') then 
				update_R0 <= '1';
				MUX_IN <= EXT_PC;
				tmp_BEQ_table_twitch <= '1';
				tmp_BLT_table_twitch <= '0';
				tmp_BLE_table_twitch <= '0';
			else
				update_R0 <= '0';
				tmp_BEQ_table_twitch <= '0';
				tmp_BLT_table_twitch <= '0';
				tmp_BLE_table_twitch <= '0';
				MUX_IN <= (others => '0');
			end if;
		elsif (BLT_bit = '1') then
			if (BLT_is_taken = '1' and alu_Compare(1) = '0') then 
				update_R0 <= '1';
				MUX_IN <= INCPC;
				tmp_BLT_table_twitch <= '1';
				tmp_BEQ_table_twitch <= '0';
				tmp_BLE_table_twitch <= '0';
			elsif (BLT_is_taken = '0' and alu_Compare(1) = '1') then 
				update_R0 <= '1';
				MUX_IN <= EXT_PC;
				tmp_BLT_table_twitch <= '1';
				tmp_BEQ_table_twitch <= '0';
				tmp_BLE_table_twitch <= '0';
			else
				update_R0 <= '0';
				tmp_BEQ_table_twitch <= '0';
				tmp_BLT_table_twitch <= '0';
				tmp_BLE_table_twitch <= '0';
				MUX_IN <= (others => '0');
			end if;
		elsif (BLE_bit = '1') then
			if (BLE_is_taken = '1' and alu_Compare(2) = '0') then 
				update_R0 <= '1';
				MUX_IN <= INCPC;
				tmp_BLE_table_twitch <= '1';
				tmp_BLT_table_twitch <= '0';
				tmp_BEQ_table_twitch <= '0';
			elsif (BLE_is_taken = '0' and alu_Compare(2) = '1') then 
				update_R0 <= '1';
				MUX_IN <= EXT_PC;
				tmp_BLE_table_twitch <= '1';
				tmp_BLT_table_twitch <= '0';
				tmp_BEQ_table_twitch <= '0';
			else
				update_R0 <= '0';
				tmp_BEQ_table_twitch <= '0';
				tmp_BLT_table_twitch <= '0';
				tmp_BLE_table_twitch <= '0';
				MUX_IN <= (others => '0');
			end if;
		else
			update_R0 <= '0';
			tmp_BEQ_table_twitch <= '0';
			tmp_BLT_table_twitch <= '0';
			tmp_BLE_table_twitch <= '0';
			MUX_IN <= (others => '0');
		end if;
	end process;
	
end architecture;
                                                                                      

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity MM_hazard_unit is 
	port(
		MEM_OUT : in std_logic_vector(15 downto 0);
		EX_MM_RF_A3, EX_MM_used: in std_logic_vector(2 downto 0);
		EX_MM_Flags, sel_EX_MM_MUX: in std_logic_vector(1 downto 0);
		MM_Flags : out std_logic_vector(1 downto 0);
		clear, sel_MM_hazard_MUX : out std_logic);
end entity;

architecture hazard4 of MM_hazard_unit is 
begin 
	sel_MM_hazard_MUX <= '1' when (sel_EX_MM_MUX = "00" and EX_MM_RF_A3 = "000" and EX_MM_used(0) /= '0') else '0';
	clear <= '1' when (sel_EX_MM_MUX = "00" and EX_MM_RF_A3 = "000" and EX_MM_used(0) /= '0') else '0';
	MM_Flags(1) <= EX_MM_Flags(1);
	MM_Flags(0) <= '1' when (sel_EX_MM_MUX = "00" and MEM_OUT = "0000000000000000") else '0';
end architecture;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity WB_hazard_unit is 
	port( 
		MM_WB_RF_A3, MM_WB_used: in std_logic_vector(2 downto 0);
		MM_WB_INCPC: in std_logic_vector(15 downto 0);
		WRITE_R0, clear, sel_WB_hazard_MUX: out std_logic;
		select_R0: out std_logic_vector(1 downto 0);
		MUX_IN : out std_logic_vector(15 downto 0);
		BEQ_is_taken, BLT_is_taken, BLE_is_taken: in std_logic;
		opcode: in std_logic_vector(3 downto 0)
		);
end entity;

architecture hazard5 of WB_hazard_unit is
	signal JLR_flush, JAL_flush, flush: std_logic;
begin 

	JLR_flush      <= '1' when ( opcode = "1101" and MM_WB_RF_A3 = "000" and MM_WB_used(0) = '1') else '0';
	JAL_flush      <= '1' when ( opcode = "1100" and MM_WB_RF_A3 = "000" and MM_WB_used(0) = '1') else '0';
	flush <= (JLR_flush or JAL_flush);
	clear <= (JLR_flush or JAL_flush);
	sel_WB_hazard_MUX <= (JLR_flush or JAL_flush);
	MUX_IN <= (others => '0') when (flush = '0') else MM_WB_INCPC;
  	select_R0	  <= "00"  when(opcode = "1101") else "10" when(BEQ_is_taken = '1' or BLT_is_taken = '1' or BLE_is_taken = '1' or opcode = "1100" or opcode = "1111") else "01";
	WRITE_R0	   <= '0'  when(MM_WB_RF_A3 = "000" and MM_WB_used(0) /= '0') else '1';

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MM_Forward_unit is
	port(clk : in std_logiC;
		  EX_MM_RF_A2, MM_WB_RF_A3 : in std_logic_vector(2 downto 0);
		  MM_WB_opcode, EX_MM_opcode : in std_logic_vector(3 downto 0);
		  EX_MM_RF_A2_used:in std_logic; 
		  MM_WB_RF_A3_used: in std_logic;
		  sel_forward_MUX : out std_logic);
end entity;

architecture hazard6 of MM_Forward_unit is
	signal Equal_Addr : std_logic;
begin
	Equal_Addr <= (EX_MM_RF_A2_used and MM_WB_RF_A3_used)  when (EX_MM_RF_A2 = MM_WB_RF_A3) else '0';
	sel_forward_MUX <= Equal_Addr when((MM_WB_opcode = "0100") and (EX_MM_opcode = "0101")) else '0';
end architecture;