
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE work.PIC_pkg.all;

entity RAM_e is
 Port ( 
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   databus_e: inout std_logic_vector(7 downto 0);
   address  : in std_logic_vector(7 downto 0);
   write_en : in std_logic;
   oe       : in std_logic;
   switches : out std_logic_vector(7 downto 0);
   temp_l   : out std_logic_vector(6 downto 0);
   temp_h   : out std_logic_vector(6 downto 0));
end RAM_e;

architecture Behavioral of RAM_e is

SIGNAL contents_ram : array8_ram(63 downto 0);
--SIGNAL addr:        std_logic_vector(7 downto 0);  
 
BEGIN

PROCESS (Clk, Reset)  -- no reset
BEGIN
	if Reset = '0' then 	--INICIALIZACION DE VALORES
		-- TODO A CEROS MENOS TERMOSTATO
		contents_ram <= (others=>(others => '0')); 
		--TEMPERATURA = 10ºC
		contents_ram(49) <= "00010000";

	elsif Clk'event and Clk = '1' then
	-- ESCRITURA SINCRONA
		if write_en = '1' then
			contents_ram(to_integer(unsigned(address))) <= databus_e;
		end if;
	end if;

END PROCESS;

--process(address)
--begin
	--if(unsigned(address) <= 63) then
		--addr <= address;
	--else
		--addr <= "00000000";
	--end if;
--end process;

-- LECTURA ASINCRONA
databus_e <= contents_ram(to_integer(unsigned(address))) WHEN oe = '1' else (others => 'Z');
--databus_e <= contents_ram(to_integer(unsigned(addr))) WHEN oe = '1' else (others => 'Z');

-- Outputs
switches(7) <= contents_ram(23)(0);
switches(6) <= contents_ram(22)(0);
switches(5) <= contents_ram(21)(0);
switches(4) <= contents_ram(20)(0);
switches(3) <= contents_ram(19)(0);
switches(2) <= contents_ram(18)(0);
switches(1) <= contents_ram(17)(0);
switches(0) <= contents_ram(16)(0);


WITH contents_ram(49)(7 downto 4) SELECT
temp_h <=
    "0111111" WHEN "0000",  -- 0
    "0000110" WHEN "0001",  -- 1
    "1011011" WHEN "0010",  -- 2
    "1001111" WHEN "0011",  -- 3
    "1100110" WHEN "0100",  -- 4
    "1101101" WHEN "0101",  -- 5
    "1111101" WHEN "0110",  -- 6
    "0000111" WHEN "0111",  -- 7
    "1111111" WHEN "1000",  -- 8
    "1101111" WHEN "1001",  -- 9
    "1111001" WHEN OTHERS;  -- E (error)
    
with contents_ram(49)(3 downto 0) select
temp_l <=
    "0111111" WHEN "0000",  -- 0
    "0000110" WHEN "0001",  -- 1
    "1011011" WHEN "0010",  -- 2
    "1001111" WHEN "0011",  -- 3
    "1100110" WHEN "0100",  -- 4
    "1101101" WHEN "0101",  -- 5
    "1111101" WHEN "0110",  -- 6
    "0000111" WHEN "0111",  -- 7
    "1111111" WHEN "1000",  -- 8
    "1101111" WHEN "1001",  -- 9
    "1111001" WHEN OTHERS;  -- E (error)

end Behavioral;