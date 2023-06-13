library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extend is
  port(
   SE_op, extend_zero: in std_logic;
   inp_16bit : in std_logic_vector(15 downto 0);
	outp_16bit : out std_logic_vector(15 downto 0)) ;
end entity ; 

architecture SE of sign_extend is

begin
	SE:process(SE_op,inp_16bit, extend_zero)
	begin 
		if(SE_op='0') then --sign extender 9
			outp_16bit(8 downto 0) <= inp_16bit(8 downto 0);
			outp_16bit(9)  <= inp_16bit(8) and (not extend_zero);
			outp_16bit(10) <= inp_16bit(8) and (not extend_zero);
			outp_16bit(11) <= inp_16bit(8) and (not extend_zero);
			outp_16bit(12) <= inp_16bit(8) and (not extend_zero);
			outp_16bit(13) <= inp_16bit(8) and (not extend_zero);
			outp_16bit(14) <= inp_16bit(8) and (not extend_zero);
			outp_16bit(15) <= inp_16bit(8) and (not extend_zero);
		else --sign extender 6
			outp_16bit(5 downto 0) <= inp_16bit(5 downto 0);
			outp_16bit(6) <= inp_16bit(5) and (not extend_zero);
			outp_16bit(7) <= inp_16bit(5) and (not extend_zero);
			outp_16bit(8) <= inp_16bit(5) and (not extend_zero);
			outp_16bit(9) <= inp_16bit(5) and (not extend_zero);
			outp_16bit(10) <= inp_16bit(5) and (not extend_zero);
			outp_16bit(11) <= inp_16bit(5) and (not extend_zero);
			outp_16bit(12) <= inp_16bit(5) and (not extend_zero);
			outp_16bit(13) <= inp_16bit(5) and (not extend_zero);
			outp_16bit(14) <= inp_16bit(5) and (not extend_zero);
			outp_16bit(15) <= inp_16bit(5) and (not extend_zero);
	   end if;
	end process;
end SE ;
