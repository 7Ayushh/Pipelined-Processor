library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity register_file is		
	port(
		RF_D3, R0_IN: in std_logic_vector(15 downto 0);
		RF_D1, RF_D2, R0_O: out std_logic_vector(15 downto 0);
		RF_A1, RF_A2, RF_A3: in std_logic_vector(2 downto 0);
		clk, RF_WR, R0_WR, reset: in std_logic);
end entity;

architecture trial of register_file is
	type rf_type is array(7 downto 0) of std_logic_vector(15 downto 0);
	signal rf_data, init_data: rf_type;
	signal tp_r0_in: std_logic_vector(15 downto 0);
	signal en: std_logic_vector(7 downto 0);
	signal enb_temp: std_logic;
	
	impure function init_rf return rf_type is
		file text_file : text open read_mode is "rf_init.txt";
		variable text_line : line;
		variable rf_content : rf_type;
		begin
			for i in 0 to 7 loop
				readline(text_file, text_line);
				read(text_line, rf_content(i));
			end loop;
		return rf_content;
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
	init_data <= init_rf;
	enb_temp <= (en(0) or R0_WR);
	REG:
	for i in 1 to 7 generate
		REG: reg_generic
			generic map(16)
			port map(clk => clk, en => en(i), init => init_data(i),
				Din => RF_D3, Dout => rf_data(i), reset => reset);
	end generate REG;
	
	PC: reg_generic
			generic map(16)
			port map(clk => clk, en =>enb_temp, init => init_data(0),
				Din => tp_r0_in, Dout => rf_data(0), reset => reset);
	
	tp_r0_in <= R0_IN when (R0_WR = '1')
		else RF_D3;
				
	process(RF_A3, RF_WR)
	begin
		en <= (others => '0');
		en(to_integer(unsigned(RF_A3))) <= RF_WR;
	end process;
	
	RF_D1 <= rf_data(to_integer(unsigned(RF_A1)));
	RF_D2 <= rf_data(to_integer(unsigned(RF_A2)));
	R0_O <= rf_data(0);
	
end architecture;