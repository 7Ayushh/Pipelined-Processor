library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity;

architecture bhv of testbench is
   component IITB_CPU is
		port(reset, clk: in std_logic);
	end component;
   signal clk, reset: std_logic := '1';
	
begin
    process
    begin
        wait for 1000 ns;
        clk <= not clk;
		  report "Switch" severity note;
    end process;
    
    process
    begin
        reset <= '1';
        wait until (clk = '0');
        wait until (clk = '1');
        reset <= '0';
        wait;
    end process;

    risc_instance: IITB_CPU
    port map(reset => reset, clk => clk);
    
end architecture;