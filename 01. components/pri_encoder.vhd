library ieee;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

entity p_encoder is
	port(
		PE_IN: in std_logic_vector(7 downto 0);
		PE_ENB: in std_logic;
		PE_OUT: out std_logic_vector(2 downto 0);
		PE_0: out std_logic);
end entity;

architecture behave_ov of p_encoder is
	signal output_temp: std_logic_vector(2 downto 0);
begin

	main: process(PE_IN, PE_ENB)
	begin
		output_temp <= (others => '1');
		for i in 0 to 7 loop
			if PE_IN(i) = '1' then
				output_temp <= std_logic_vector(to_unsigned(i,3));
			end if;
		end loop;
	end process;
	
	PE_OUT <= (not output_temp);
	PE_0 <= '0' when (to_integer(unsigned((output_temp))) = 7 and PE_IN(7) = '0') else '1';
	
end architecture;