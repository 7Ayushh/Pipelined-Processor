library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity memory is		
	port(
		MEM_DI: in std_logic_vector(15 downto 0);
		MEM_DO: out std_logic_vector(15 downto 0);
		MEM_A: in std_logic_vector(15 downto 0);
		clk, MEM_WR, MEM_RD, reset: in std_logic);
end entity;

architecture struct of memory is
	type ram_type is array(2000 downto 0) of std_logic_vector(15 downto 0);
	signal mem_data, init_data: ram_type;
	signal en: std_logic_vector(2000 downto 0);

	impure function init_ram return ram_type is
		file text_file : text open read_mode is "ram_init.txt";
		variable text_line : line;
		variable ram_content : ram_type;
		begin
			for i in 0 to 2000 loop
				readline(text_file, text_line);
				read(text_line, ram_content(i));
			end loop;
		return ram_content;
	end function;
	
	component reg_generic is
		generic (data_width : integer);
		port(
			clk, en, reset: in std_logic;
			Din: in std_logic_vector(data_width-1 downto 0);
			init: in std_logic_vector(data_width-1 downto 0);
			Dout: out std_logic_vector(data_width-1 downto 0));
	end component;
	
begin
	init_data <= init_ram;
	
	GEN_RAM:
	for i in 0 to 2000 generate
		REG: reg_generic
			generic map(16)
			port map(clk => clk, en => en(i), init => init_data(i),
				Din => MEM_DI, Dout => mem_data(i), reset => reset);	
	end generate GEN_RAM;
	
	process(MEM_A, MEM_WR)
	begin
		en <= (others => '0');
		en (to_integer(unsigned(MEM_A))) <= MEM_WR;	
	end process;
	
	MEM_DO <= mem_data(to_integer(unsigned(MEM_A))) when (MEM_RD = '1')
		else (others => 'Z');
	
end architecture;