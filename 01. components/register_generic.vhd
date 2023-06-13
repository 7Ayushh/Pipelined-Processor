library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_generic is
	generic (data_width : integer);
	port(
		clk, en, reset: in std_logic;
		Din: in std_logic_vector(data_width-1 downto 0);
		init: in std_logic_vector(data_width-1 downto 0);
		Dout: out std_logic_vector(data_width-1 downto 0));
end entity;

architecture reg of reg_generic is
begin
	process(clk, reset)	
	begin
		if(clk'event and clk='1') then
			if (en='1') then
				Dout <= Din;
			end if;
		end if;
		if(reset = '1') then
			Dout <= init;
		end if;
	end process;
	
end reg;		