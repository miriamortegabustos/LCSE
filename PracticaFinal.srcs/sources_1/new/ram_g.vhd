
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE work.PIC_pkg.all;

entity RAM_g is
 Port ( 
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   databus_g: inout std_logic_vector(7 downto 0);
   address  : in std_logic_vector(7 downto 0);
   write_en : in std_logic;
   oe       : in std_logic);
end RAM_g;

architecture Behavioral of RAM_g is

SIGNAL contents_ram : array8_ram(255 downto 64);
 
BEGIN

PROCESS (Clk, Reset)  -- no reset
BEGIN
	if Reset = '0' then 	--INICIALIZACION DE VALORES
		-- TODO A CEROS MENOS TERMOSTATO
		contents_ram <= (others=>(others => '0')); 
	
	elsif Clk'event and Clk = '1' then
		-- ESCRITURA SINCRONA
		if write_en = '1' then
			contents_ram(to_integer(unsigned(address))) <= databus_g;
		end if;
	end if;

END PROCESS;

-- LECTURA ASINCRONA
databus_g <= contents_ram(to_integer(unsigned(address))) WHEN oe = '1' else (others => 'Z');

end Behavioral;