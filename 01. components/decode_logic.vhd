library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity decoder_ins is
	port(
		instruc: in std_logic_vector(15 downto 0);
		SE6_or_SE9 , LM, SM, BEQ_en, BLT_en, BLE_en, LW, LLI, SE_or_RFD2 : out std_logic;
		ID_PC, CZ, WR, WB_mux: out std_logic_vector(1 downto 0);		
		enc_addnand, RF_A1, RF_A2, RF_A3, used: out std_logic_vector(2 downto 0);
		alu_control: out std_logic_vector(3 downto 0));
end entity;

architecture dec_arch of decoder_ins is

--signal RA, RB, RC: std_logic_vector(2 downto 0);

begin
--		SE6_or_SE9 <= '0';
--		LM <= '0';
--		SM <= '0';
--		BEQ_en <= '0';
--		BLT_en <= '0';
--		BLE_en <= '0';
--		LW <= '0';
--		LLI <= '0';
--		SE_or_RFD2 <= '0';
--		ID_PC <= "00";
--		CZ <= "00";
--		WR <= "00";
--		WB_mux <= "10";
--		RF_A1 <= "000";
--		RF_A2 <= "000";
--		RF_A3 <= "000";
--		used <= "000";
--		alu_control <= "0000";
----		enc_addnand <= "000";
end architecture;