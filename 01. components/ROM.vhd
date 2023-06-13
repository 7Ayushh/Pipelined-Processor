library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity ROM is
	port(
		IM_A: in std_logic_vector(15 downto 0);
		IM_DO: out std_logic_vector(15 downto 0);
		IM_RD ,clk : in std_logic);
end entity;

architecture behave of ROM is

	type rom_type is array (0 to 255) of std_logic_vector(15 downto 0);
	impure function init_rom return rom_type is
		file text_file : text open read_mode is "rom_init.txt";
		variable text_line : line;
		variable rom_content : rom_type;
		begin
			for i in 0 to 255 loop
				readline(text_file, text_line);
				read(text_line, rom_content(i));
			end loop;
		return rom_content;
	end function;

	signal memory: rom_type:= (others => "1111111111111111");
	
begin
	memory <= init_rom;
	
	IM_DO <= memory(to_integer(unsigned(IM_A))) when (IM_RD = '1') else (others => 'Z');
	
end architecture;