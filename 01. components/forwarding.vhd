library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forward_controller is 

	port(
		ID_RR_RF_A, RR_EX_RF_A3, EX_MM_RF_A3, MM_WB_RF_A3:in std_logic_vector(2 downto 0);
		sel_RR_EX_MUX, sel_EX_MM_MUX: in std_logic_vector(1 downto 0);
		ID_RR_PC, RR_EX_ALU_C, EX_MM_ALU_C, RR_EX_EXT, EX_MM_EXT, RR_EX_INCPC, EX_MM_INCPC, EX_MM_MEM_OUT, MM_WB_toforward:in std_logic_vector(15 downto 0);
		clk, ID_RR_RF_A_used, RR_EX_RF_A3_used, EX_MM_RF_A3_used, MM_WB_RF_A3_used: in std_logic;
		forward_CONTROL : out std_logic;
		forward_DATA: out std_logic_vector(15 downto 0));
end entity;

architecture hazard1 of forward_controller is
	signal EX_MM_getforward, RR_EX_getforward : std_logic_vector(15 downto 0);
begin

	process(clk, ID_RR_RF_A_used, RR_EX_RF_A3_used, RR_EX_getforward, EX_MM_getforward, MM_WB_toforward, RR_EX_RF_A3, EX_MM_RF_A3, MM_WB_RF_A3, EX_MM_RF_A3_used, MM_WB_RF_A3_used, ID_RR_RF_A, ID_RR_PC)
	
	begin
		if(ID_RR_RF_A_used = '1') then
			if(ID_RR_RF_A = "000") then
				forward_CONTROL <= '1';
				forward_DATA <= ID_RR_PC;
			elsif ((RR_EX_RF_A3_used /= '0') and (ID_RR_RF_A = RR_EX_RF_A3)) then
				forward_CONTROL <= '1';
				forward_DATA <= RR_EX_getforward;
			elsif ((EX_MM_RF_A3_used /= '0') and (ID_RR_RF_A = EX_MM_RF_A3)) then
				forward_CONTROL <= '1';
				forward_DATA <= EX_MM_getforward;
			elsif((MM_WB_RF_A3_used /= '0') and (MM_WB_RF_A3 = ID_RR_RF_A)) then
				forward_CONTROL <= '1';
				forward_DATA <= MM_WB_toforward;
			else
				forward_CONTROL <= '0';
				forward_DATA <= (others => '0');
			end if;
		else
			forward_CONTROL <= '0';
			forward_DATA <= (others => '0');
		end if;
	end process;
	
	EX_MM_getforward <= EX_MM_MEM_OUT when (sel_EX_MM_MUX = "00") else
		EX_MM_INCPC when (sel_EX_MM_MUX = "01") else
		EX_MM_ALU_C when (sel_EX_MM_MUX = "10") else
		EX_MM_EXT;
		
	RR_EX_getforward <= RR_EX_INCPC when (sel_RR_EX_MUX = "01") else
		RR_EX_ALU_C when (sel_RR_EX_MUX = "10") else
		RR_EX_EXT;

end architecture;
