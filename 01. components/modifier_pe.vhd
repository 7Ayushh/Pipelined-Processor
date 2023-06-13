library ieee;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

entity mp_encoder is
	port(
		MPE_IN: in std_logic_vector(7 downto 0);
		MPE_ENB: in std_logic;
		MPE_OUT: out std_logic_vector(7 downto 0));
end entity;

architecture behave_ov of mp_encoder is
	signal output_temp: std_logic_vector(7 downto 0);
begin

	main: process(MPE_IN, MPE_ENB)
	begin
		output_temp <= MPE_IN;
		for i in 7 downto 0 loop
			if MPE_IN(i) = '1' then
				output_temp(i) <= '0';
				exit;
			end if;
		end loop;
	end process;
	
	MPE_OUT <= output_temp;
	
end architecture;

