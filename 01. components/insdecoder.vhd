library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity inst_decoder is
	port(instruc: in std_logic_vector(15 downto 0);
	SE6_9, LM, SM, BEQ_en, BLT_en, BLE_en, LW, LLI, SE_RF_D2, ID_PC :out std_logic;
	CZ, WR, WB_mux : out std_logic_vector(1 downto 0);
	enc_addnand, RF_A1, RF_A2, RF_A3, used: out std_logic_vector(2 downto 0);
	alu_control: out std_logic_vector(3 downto 0));
end entity;

architecture inst of inst_decoder is

signal RA: std_logic_vector(2 downto 0);
signal RB: std_logic_vector(2 downto 0);
signal RC: std_logic_vector(2 downto 0);

begin
	RA <= instruc(11 downto 9);
	RB <= instruc(8 downto 6);
	RC <= instruc(5 downto 3);
	
	process (instruc, RA, RB, RC)
	begin
		if (instruc(15 downto 12) = "0001") then
			SE6_9 <= '0';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '0';
			ID_PC <= '0';
			CZ <= "11";
			WR <= "10";
			WB_mux <= "10";
			used <= "111";
			enc_addnand <= instruc(2 downto 0);
			RF_A1 <= RA;
			RF_A2 <= RB;
			RF_A3 <= RC;
			if(instruc(2 downto 0) = "011") then 
				alu_control <= "0010";
			elsif((instruc(2 downto 0) = "101") or (instruc(2 downto 0) = "110") or (instruc(2 downto 0) = "100")) then 
				alu_control <= "0001";
			elsif(instruc(2 downto 0) = "111") then 
				alu_control <= "0011";
			else 
				alu_control <= "0000";
			end if;
			
		elsif (instruc(15 downto 12)= "0000") then
			SE6_9 <= '1';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '1';
			ID_PC <= '0';
			CZ <= "11";
			WR <= "10";
			WB_mux <= "10";
			RF_A1 <= RA;
			RF_A2 <= "000";
			RF_A3 <= RB;
			used <= "101";
			alu_control <= "0000";
			enc_addnand <= "000";
				
		elsif (instruc(15 downto 12)= "0010") then
			SE6_9 <= '0';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '0';
			ID_PC <= '0';
			CZ <= "11";
			WR <= "10";
			WB_mux <= "10";
			used <= "111";
			enc_addnand <= instruc(2 downto 0);
			RF_A1 <= RA;
			RF_A2 <= RB;
			RF_A3 <= RC;			
			if((instruc(2 downto 0) = "001") or (instruc(2 downto 0) = "010") or (instruc(2 downto 0) = "000")) then 
				alu_control <= "0100";
			else
				alu_control <= "0101";
			end if;
			
		elsif (instruc(15 downto 12)= "0011") then
			SE6_9 <= '0';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '1';
			SE_RF_D2 <= '0';
			ID_PC <= '0';
			CZ <= "00";
			WR <= "10";
			WB_mux <= "11";
			RF_A1 <= "000";
			RF_A2 <= "000";
			RF_A3 <= RA;
			used <= "001";
			alu_control <= "0000";
			enc_addnand <= "000";
			
		elsif (instruc(15 downto 12)= "0100") then
			SE6_9 <= '1';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '1';
			LLI <= '0';
			SE_RF_D2 <= '1';
			ID_PC <= '0';
			CZ <= "01";
			WR <= "10";
			WB_mux <= "00";
			RF_A1 <= RB;
			RF_A2 <= "000";
			RF_A3 <= RA;
			used <= "101";
			alu_control <= "0000";
			enc_addnand <= "000";
	
		elsif (instruc(15 downto 12)= "0101") then
			SE6_9 <= '1';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '1';
			ID_PC <= '0';
			CZ <= "00";
			WR <= "01";
			WB_mux <= "10";
			RF_A1 <= RB;
			RF_A2 <= RA;
			RF_A3 <= "000";
			used <= "110";
			alu_control <= "0000";
			enc_addnand <= "000";
			
		elsif (instruc(15 downto 12)= "0110") then
			SE6_9 <= '0';
			LM <= '1';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '0';
			ID_PC <= '0';
			CZ <= "00";
			WR <= "10";
			WB_mux <= "00";
			RF_A1 <= RA;
			RF_A2 <= "000";
			RF_A3 <= "000";
			used <= "101";
			alu_control <= "0000";
			enc_addnand <= "000";
								
		elsif (instruc(15 downto 12)= "0111") then
			SE6_9 <= '0';
			LM <= '0';
			SM <= '1';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '0';
			ID_PC <= '0';
			CZ <= "00";
			WR <= "01";
			WB_mux <= "10";
			RF_A1 <= RA;
			RF_A2 <= "000";
			RF_A3 <= "000";
			used <= "110";
			alu_control <= "0000";
			enc_addnand <= "000";
				
		elsif (instruc(15 downto 12)= "1000") then
			SE6_9 <= '1';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '1';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '0';
			ID_PC <='0';
			CZ <= "00";
			WR <= "00";
			WB_mux <= "10";
			RF_A1 <= RA;
			RF_A2 <= RB;
			RF_A3 <= "000";
			used <= "110";
			alu_control <= "1000";
			enc_addnand <= "000";
		
		elsif (instruc(15 downto 12)= "1001") then
			SE6_9 <= '1';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '1';
			BLE_en <= '0'; 
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '0';
			ID_PC <= '0';
			CZ <= "00";
			WR <= "00";
			WB_mux <= "10";
			RF_A1 <= RA;
			RF_A2 <= RB;
			RF_A3 <= "000";
			used <= "110";
			alu_control <= "1100";
			enc_addnand <= "000";
				
		elsif (instruc(15 downto 12)= "1010") then
			SE6_9 <= '1';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '1';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '0';
			ID_PC <= '0';
			CZ <= "00";
			WR <= "00";
			WB_mux <= "10";
			RF_A1 <= RA;
			RF_A2 <= RB;
			RF_A3 <= "000";
			used <= "110";
			alu_control <= "1010";
			enc_addnand <= "000";
		
		elsif (instruc(15 downto 12)= "1100") then
			SE6_9 <= '0';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '0';
			ID_PC <= '1';
			CZ <= "00";
			WR <= "10";
			WB_mux <= "01";
			RF_A1 <= "000";
			RF_A2 <= "000";
			RF_A3 <= RA;
			used <= "001";
			alu_control <= "0000";
			enc_addnand <= "000";
				
		elsif (instruc(15 downto 12)= "1101") then
			SE6_9 <= '0';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '0';
			ID_PC <= '0';
			CZ <= "00";
			WR <= "10";
			WB_mux <= "01";
			RF_A1 <= RB;
			RF_A2 <= "000";
			RF_A3 <= RA;
			used <= "101";
			alu_control <= "0000";
			enc_addnand <= "000";
		
		elsif (instruc(15 downto 12)= "1111") then
			SE6_9 <= '0';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE_RF_D2 <= '0';
			ID_PC <= '1';
			CZ <= "00";
			WR <= "00";
			WB_mux <= "01";
			RF_A1 <= "000";
			RF_A2 <= "000";
			RF_A3 <= RA;
			used <= "001";
			alu_control <= "0000";
			enc_addnand <= "000";
				
		else
			SE_RF_D2 <= '0';
			LM <= '0';
			SM <= '0';
			BEQ_en <= '0';
			BLT_en <= '0';
			BLE_en <= '0';
			LW <= '0';
			LLI <= '0';
			SE6_9 <= '0';
			ID_PC <= '0';
			CZ <= "00";
			WR <= "00";
			WB_mux <= "00";
			enc_addnand <= "000";
			RF_A1 <= "000";
			RF_A2 <= "000";
			RF_A3 <= "000";
			used <= "000";
			alu_control <= "0000";
		end if;
	end process;
end architecture;