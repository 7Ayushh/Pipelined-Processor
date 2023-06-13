library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity control_path is
	port(
		reset, clk: in std_logic; 
		op_code: in std_logic_vector(3 downto 0);
		condition: in std_logic_vector(1 downto 0);
		O: out std_logic_vector(22 downto 0);				--MUX Control Signals
		en: out std_logic_vector(21 downto 0);				--Enables and Operation for ALUs
		C, Z, PE_0, eq: in std_logic);
end entity;

architecture fsm of control_path is
	type fsm_state is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S10);
	signal Q, nQ: fsm_state := S0;
begin

	clocked:
	process(clk, nQ)
	begin
		if (clk'event and clk = '1') then
			Q <= nQ;
		end if;
	end process;
	
	outputs:
	process(op_code, Q, PE_0)
	begin
		O <= (others => '0');
		en(21) <= '0';
		case Q is
		   when S0 => 
				O <= (others => '0');
				en <= (others => '0');
			when S1 =>
				O(9 downto 0) <= "0111000000";
				O(13 downto 12) <= "00";
				O(18) <= '0';
				O(22) <= '1';
				en(0) <= ((not op_code(3)) and ((not op_code(2)) or (not op_code(0))));
				en(3 downto 1) <= "110";
				en(4) <= ((op_code(3)) and (not op_code(2)));
				en(8 downto 5) <= "0000";
				en(9) <= (not op_code(3));
				en(19 downto 10) <= "0000000000";
				en(20) <= '1';
			when S2 =>
				O(11 downto 10) <= "00";
				O(18) <= '0';
				O(21) <= '0';
				en(4 downto 0) <= "10000";
				en(5) <= (((not op_code(3)) and (not op_code(2)) and (not op_code(0))) or ((not op_code(3)) and op_code(2) and (not op_code(1))) or (op_code(2) and (not op_code(1)) and (not op_code(0))));
				en(13 downto 6) <= "00000000";
				en(14) <= ((not op_code(3)) and op_code(2) and op_code(1));
				en(19 downto 15) <= "00000";
				en(20) <= '0';
			when S3 =>
				O(0) <= ((not op_code(2)) or (op_code(1)) or (op_code(3)));
				O(1) <= ((not op_code(3)) and (op_code(2)) and (not op_code(1)));
				O(2) <= (((not op_code(2)) and (not op_code(0))) or ((op_code(2)) and (not op_code(1))));
				O(3) <= ((not op_code(2)) and op_code(0));
				O(20 downto 18) <= "101";
				en(3 downto 0) <= "0000";
				en(4) <= ((not op_code(3)) and op_code(2) and op_code(1));
				en(5) <= '0';
				en(6) <= (((not op_code(3)) and (not op_code(1))) or ((not op_code(3)) and (not op_code(2)) and (not op_code(0))));
				en(8 downto 7) <= "00";
				en(9) <= (not op_code(3));
				en(10) <= op_code(3);
				en(11) <= ((not op_code(2)) and op_code(1));
				en(12) <= ((not op_code(2)) and (not op_code(1)));
				en(13) <= ((not op_code(2)) or ((not op_code(3)) and (not op_code(1)) and (not op_code(0))));
				en(19 downto 14) <= "000000";
				en(20) <= '0';
				en(21) <= ((op_code(3)) or (op_code(2) and op_code(0)) or (op_code(2) and op_code(0)));
			when S4 =>
				O(4) <= (((not op_code(3)) and (not op_code(2)) and (not op_code(1)) and op_code(0)) or ((not op_code(3)) and op_code(2) and op_code(1) and (not op_code(0))));
				O(5) <= (((not op_code(3)) and op_code(2) and (not op_code(0))) or (op_code(3) and (not op_code(2)) and (not op_code(1))) or ((not op_code(3)) and (not op_code(2)) and op_code(1) and op_code(0)));
				O(6) <= '0';
				O(7) <= ((not op_code(3)) and (not op_code(2)) and op_code(1) and op_code(0));
				O(8) <= op_code(3);
				O(9) <= '0';
				O(21) <= '0';
				en(0) <= ((not op_code(2)) or (not op_code(1)) or (op_code(0)) or ((PE_0) and (not op_code(3)) and (op_code(2)) and (op_code(1)) and (not op_code(0))));
				en(6 downto 1) <= "000000";
				en(7) <= ((not op_code(3)) and op_code(2) and op_code(1) and (not op_code(0)));
				en(19 downto 8) <= "000010000000";
				en(20) <= '0';
			when S5 =>
				O(10) <= ((not op_code(3)) and op_code(2) and op_code(1) and op_code(0));
				O(11) <= (op_code(3) and (not op_code(2)) and (not op_code(1)) and op_code(0));
				O(19) <= '0';
				O(20) <= '0';
				en(5 downto 0) <= "000000";
				en(6) <= ((PE_0 and (not op_code(3))) or (op_code(3)));
				en(7) <= ((not op_code(3)) and op_code(2) and op_code(1) and op_code(0));
				en(19 downto 8) <= "000000000000";
				en(20) <= '0';
			when S6 =>
				O(12) <= ((not op_code(3)) and op_code(2) and op_code(1) and op_code(0));
				O(13) <= ((not op_code(3)) and op_code(2) and (not op_code(1)) and op_code(0));
				O(14) <= ((not op_code(3)) and op_code(2) and op_code(1) and op_code(0));
				en(19 downto 0) <= "00000000000000000010";
				en(20) <= '0';
			when S7 =>
				O(12) <= ((not op_code(3)) and op_code(2) and op_code(1) and (not op_code(0)));
				O(13) <= ((not op_code(3)) and op_code(2) and (not op_code(1)) and (not op_code(0)));
				O(19) <= '1';
				O(20) <= '0';
				en(19 downto 0) <= "00000000000001000100";
				en(20) <= '0';
			when S8 =>
				O(21) <= '1';
				en(19 downto 0) <= "00000100000100000000";
				en(20) <= '0';
			when S10 =>
				O(9 downto 4) <= "100100";
				O(15) <= ((not op_code(0)) or (not op_code(3)));
				O(16) <= ((not op_code(2)) and (not op_code(0)));
				O(17) <= ((not op_code(2)) and op_code(0));
				O(19) <= '1';
				O(20) <= '0';
				en(19 downto 16) <= "1000";
				en(15) <= (not op_code(2));
				en(14 downto 0) <= "000000000000001";
				en(20) <= '0';
			when others =>
				O <= (others => 'Z');
				en <= (others => 'Z');
		end case;
	end process;
	
	
	next_state:
	process(op_code, condition, C, Z, reset, Q, PE_0)
	begin
		nQ <= Q;
		case Q is
			when S0 => nQ <= S1;
			when S1 =>
				case op_code is
					when "0011" => nQ <= S4;	--LHI
					when "1000" => nQ <= S10;	--JAL
					when "1001" => nQ <= S5;	--JLR
					when "1111" => nQ <= S1;	--dummy
					when others =>	nQ <= S2;
				end case;
			when S2 =>
				case op_code is
					when "0000" | "0010"=>
						case condition is
							when "00" => nQ <= S3;
							when "10" =>
								if (C = '1') then	nQ <= S3;
									else	nQ <= S1;
								end if;
							when "01" =>
								if (Z = '1') then	nQ <= S3;
									else nQ <= S1;
								end if;
							when others =>	nQ <= S1;
						end case;
					when "0001" | "0100" | "0101" | "1100" =>	nQ <= S3;
					when "0110" => nQ <= S7;
					when "0111" => nQ <= S5;
					when others =>	nQ <= S1;
				end case;
			when S3 =>	
				case op_code is
					when "0000" | "0001" | "0010" => nQ <= S4;
					when "0100" => nQ <= S7;
					when "0101" => nQ <= S6;
					when "0110" => nQ <= S7;
					when "0111" => nQ <= S5;
					when "1100" => nQ <= S10;
					when others => nQ <= S1;
				end case;
			when S4 => 	
				case op_code is
					when "0110" => 
						if (PE_0 = '1') then
							nQ <= S8;
						else 
							nQ <= S1;
						end if;
					when others => nQ <= S1;
				end case;
			when S5 =>		
				case op_code is
					when "0111" => 
						if (PE_0 = '1') then
							nQ <= S6;
						else 
							nQ <= S10;
						end if;
					when "1001" => nQ <= S10;
					when others => nQ <= S1;
				end case;
			when S6 =>	
				case op_code is
					when "0101" => nQ <= S10; 
					when "0111" => nQ <= S8;
					when others => nQ <= S1;
				end case;
			when S7 =>
				case op_code is
					when "0100" | "0110" => nQ <= S4;
					when others => nQ <= S1;
				end case;
			when S8 =>
				case op_code is
					when "0110" | "0111" => nQ <= S3;
					when others => nQ <= S1;
				end case;
			when S10 => 
				case op_code is
					when "0111" => nQ <= S1;
					when others => nQ <= S4;
				end case;
			when others => 
				nQ <= S0;
		end case;
		if (reset = '1') then
			nQ <= S0;
		end if;
	end process;
		
end architecture;
