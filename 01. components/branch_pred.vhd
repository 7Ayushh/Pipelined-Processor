library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity b_predict is
	port(
		clk, reset, Bra_en, twitch: in std_logic;
		ADDR_IN: in std_logic_vector(2 downto 0);
		PC_ID: in std_logic_vector(15 downto 0);
		PC_IN: in std_logic_vector(15 downto 0);
		BA_IN: in std_logic_vector(15 downto 0);
		BA: out std_logic_vector(15 downto 0);
		is_taken: out std_logic;
		ADDR_OUT: out std_logic_vector(2 downto 0));
end entity;

architecture predict of b_predict is
	type branch_table is array (0 to 7) of std_logic_vector(15 downto 0);
	signal PC_table_OUT, PC_table_IN: branch_table := (others => (others => '0'));
	signal BA_table_IN, BA_table_OUT: branch_table := (others => (others => '0'));
	signal is_taken_IN, is_taken_OUT : std_logic_vector(7 downto 0) := (others => '0');
	signal is_taken_ENB, PC_ENB, BA_ENB: std_logic_vector(7 downto 0) := (others => '0');
	signal table_counter_IN, table_counter_OUT: std_logic_vector(2 downto 0) := "000";
	signal table_counter_ENB: std_logic := '0';
	
	component reg_generic is
		generic (data_width : integer);
		port(
			clk, en, reset: in std_logic;
			Din: in std_logic_vector(data_width-1 downto 0);
			init: in std_logic_vector(data_width-1 downto 0);
			Dout: out std_logic_vector(data_width-1 downto 0));
	end component;
	
begin
	table_counter: reg_generic
		generic map(3)
		port map(
			clk => clk, en => table_counter_ENB, init => "000", reset => reset, Din => table_counter_IN, Dout => table_counter_OUT);
	
	REG: for i in 0 to 7 generate
		PC_table: reg_generic
			generic map(16)
			port map(clk => clk, en => PC_ENB(i), init => "0000000000000000", reset => reset, Din => PC_ID, Dout => PC_table_OUT(i));
		BA_table: reg_generic
			generic map(16)
			port map(clk => clk, en => BA_ENB(i), reset => reset, init => "0000000000000000", Din => BA_IN, Dout => BA_table_OUT(i));	
		is_taken_table: reg_generic
			generic map(1)
			port map(clk => clk, en => is_taken_ENB(i), init => "0", reset => reset, Din => is_taken_IN(i downto i), Dout => is_taken_OUT(i downto i));
	end generate;
	
	is_taken_IN <= not is_taken_OUT;
	table_counter_IN <= std_logic_vector(unsigned(table_counter_OUT) + to_unsigned(1, 3));

	process(PC_IN, PC_table_OUT, BA_table_OUT, is_taken_OUT)
	begin
		for i in 0 to 7 loop
			if (PC_IN = PC_table_OUT(i)) then
				BA <= BA_table_OUT(i);
				is_taken <= is_taken_out(i);
				ADDR_OUT <= std_logic_vector(to_unsigned(i, 3));
				exit;
			else
				BA <= (others => '0');
				is_taken <= '0';
				ADDR_OUT <= "000";
			end if;
		end loop;
	end process;

	process(PC_table_OUT, PC_ID, table_counter_OUT, Bra_en)
	variable temp: boolean := true;
	begin
		
		table_counter_ENB <= '0';
		PC_ENB <= (others => '0');
		BA_ENB <= (others => '0');
		
		for i in 0 to 7 loop
			if (PC_ID = PC_table_OUT(i)) then
				temp := true;
				exit;
			else
				temp := false;
			end if;
		end loop;
			
		if (Bra_en /= '0') and (temp /= true) then
			table_counter_ENB <= '1';
			PC_ENB(to_integer(unsigned(table_counter_OUT))) <= '1';
			BA_ENB(to_integer(unsigned(table_counter_OUT))) <= '1';
		end if;
	end process;
	
	process(twitch, ADDR_IN)
	begin
		is_taken_ENB <= (others => '0');
		if(twitch = '1') then
			is_taken_ENB(to_integer(unsigned(ADDR_IN))) <= '1';
		end if;
	end process;
end architecture;