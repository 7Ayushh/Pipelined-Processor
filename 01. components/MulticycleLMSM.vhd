library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity modifier_pe is
	port(
		IMM: in std_logic_vector(7 downto 0);
		MPE_ENB, clk, MPE_ZERO, reset: in std_logic;
		PE_0, MPE_0: out std_logic;
		MPE_OUT: out std_logic_vector(2 downto 0));
end entity;

architecture MULTIPLE of modifier_pe is
	signal in_temp : std_logic_vector(7 downto 0);
	signal out_temp : std_logic_vector(7 downto 0);
	signal buffer_temp: std_logic_vector(7 downto 0);
	signal ENB:  std_logic; 
	signal ZERO: std_logic;
	signal addr: std_logic_vector(2 downto 0);
	
	component p_encoder is
		port(
			PE_IN: in std_logic_vector(7 downto 0);
			PE_ENB: in std_logic;
			PE_OUT: out std_logic_vector(2 downto 0);
			PE_0: out std_logic);
	end component;
	
	component reg_generic is
		generic (data_width : integer);
		port(
			clk, en, reset: in std_logic;
			Din: in std_logic_vector(data_width-1 downto 0);
			init: in std_logic_vector(data_width-1 downto 0);
			Dout: out std_logic_vector(data_width-1 downto 0));
	end component;

begin	
	PE1: p_encoder
		port map(PE_IN => out_temp, PE_OUT => addr, PE_0 => PE_0, PE_ENB => '1');
		
	MPE_OUT <= addr;	
	ENB <= MPE_ZERO or MPE_ENB;
	
	data_in: process(IMM, MPE_ZERO, out_temp, buffer_temp, addr)
	begin
		buffer_temp <= out_temp;
		buffer_temp(to_integer(unsigned(addr))) <= '0';
		
		if(unsigned(buffer_temp) /= 0) then
			MPE_0 <= '0';
		else
			MPE_0 <= '1';
		end if;
		
		if (MPE_ZERO /= '1') then
			in_temp <= IMM;
		else
			in_temp <= buffer_temp;
		end if;
	end process;
	
	Temp_register: reg_generic
		generic map(8)
		port map(Din => in_temp, Dout => out_temp, init => "00000000", clk => clk, en => ENB, reset => reset);
			
end architecture;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity LM_SM is 
	port(
		IMM: in std_logic_vector(7 downto 0);
		LM, SM ,clk, reset: in std_logic;
		RF_A2 : out std_logic_vector(2 downto 0);
		RF_A3 : out std_logic_vector(2 downto 0);
		clr, disable, sel_RF_D1, sel_ALUB, sel_RF_A3, sel_MEM_IN, sel_RF_A2, sel_IMM: out std_logic);
end entity;

architecture fsm of LM_SM is
type fsm_state is (S1, S2, S3,S4);
signal Q, nQ: fsm_state;
signal MPE_ZERO :std_logic := '0';
signal PE_0 :std_logic := '0';
signal MPE_0 :std_logic := '0';
signal MPE_ENB :std_logic := '0';
signal address :std_logic_vector(2 downto 0) := "000";

component modifier_pe is
	port(
		IMM: in std_logic_vector(7 downto 0);
		MPE_ENB, clk, MPE_ZERO, reset: in std_logic;
		PE_0, MPE_0: out std_logic;
		MPE_OUT: out std_logic_vector(2 downto 0));
end component;

begin
 	MPE1: modifier_pe
		port map(IMM => IMM, MPE_ENB => MPE_ENB, clk => clk, reset => reset, MPE_ZERO => MPE_ZERO, PE_0 => PE_0, MPE_0 => MPE_0, MPE_OUT => address);
		
	clock: process(clk)
	begin
		if (clk'event and clk = '1') then
			Q <= nQ;
		end if;
	end process;
	
	fsm_lmsm: process(clk,reset,Q,LM,SM, address, PE_0, MPE_0)
	begin
		MPE_ZERO <= '0';
		sel_IMM <= '0';
		case Q is 
		
			when S1 =>
				MPE_ZERO <= '0';
				disable <= '0';
				MPE_ENB <= LM or SM;
				RF_A2 <= address;
				RF_A3 <= address;
				clr <= '0';
				if(LM = '1') then 
					nQ <= S2;
				elsif(SM = '1') then
					nQ <= S3;	
				else 
					nQ <= S1;
					RF_A2 <= (others => '0');
					RF_A3 <= (others => '0');
				end if;
				
				sel_RF_D1 <= '0';
				sel_RF_A2 <= '0';
				
				if(LM = '1') then 
					sel_MEM_IN <= '1'; 
					sel_ALUB <= '1';
					sel_RF_A3 <= '1'; 
					sel_IMM <= '1';
					disable <= '1';  
				else     	
					sel_MEM_IN <= '0'; 
					sel_ALUB <= '0';
					sel_RF_A3 <= '0';
					sel_IMM <= '0';
				end if; 
				
			when S2 => 
				if(PE_0 = '1') then
					MPE_ZERO <= '1';
					clr <= '0';
					nQ <= S2;
					disable <= '1';
					MPE_ENB <= '0';	
					sel_IMM <= '1';
					RF_A3 <= address;
					sel_RF_D1 <= '1';
					sel_RF_A2 <= '0';
					sel_MEM_IN <= '1';
					sel_ALUB <= '1';
					sel_RF_A3 <= '1';
					RF_A2 <= (others => '0');
				
				elsif(SM = '1') then
					MPE_ENB <= '1';
					MPE_ZERO <= '0';
					clr <= '0';
					disable <= '0';
					nQ <= S3;
					sel_IMM <= '0';
					sel_RF_D1 <= '1';
					sel_RF_A2 <= '0';
					sel_MEM_IN <= '1';
					sel_ALUB <= '1';
					sel_RF_A3 <= '1';
					RF_A2 <= address;
					RF_A3 <= address;
					
				else  
					nQ <= S1;
					clr <= '1';
					disable <= '0';			
					MPE_ENB <= '0';
					MPE_ZERO <= '1';
					sel_RF_D1 <= '0';
					sel_RF_A2 <= '0';
					sel_MEM_IN <= '0';
					sel_ALUB <= '0';
					SEL_RF_A3 <= '0';
					sel_IMM <= '0';
					RF_A2 <= (others => '0');
					RF_A3 <= (others => '0');
				
				end if;
				
			when S3 =>  
				MPE_ZERO <= '1';
				nQ <= S4;
				MPE_ENB <= '0';
				clr <= '0';
				disable <= '0';
				sel_RF_D1 <= '0';
				sel_RF_A2 <= '1';
				sel_MEM_IN <= '1';
				sel_ALUB <= '1';
				sel_RF_A3 <= '0';
				RF_A2 <= address;
				RF_A3 <= (others => '-');
				
			when S4 => 
				if(PE_0 = '1') then
					MPE_ZERO <= '1' ;
					clr <= '0';
					sel_RF_D1 <= '1';
					MPE_ENB <= '0';
					sel_RF_A2 <= '1';
					sel_MEM_IN <= '1';
					sel_ALUB <= '1';
					disable <= '1';
					sel_RF_A3 <= '0';
					nQ <= S4;
					RF_A2 <= address;
					RF_A3 <= (others => '0');
				else  
					nQ <= S1;
					clr <= '0';
					disable <= '0';
					MPE_ENB <= '0';
					sel_RF_D1 <= '0';
					sel_RF_A2 <= '0';
					sel_MEM_IN <= '0';
					sel_ALUB <= '0';
					sel_RF_A3 <= '0';
					RF_A2 <= (others => '0');
					RF_A3 <= (others => '0');
				end if;
		end case;
	end process;
end architecture;

