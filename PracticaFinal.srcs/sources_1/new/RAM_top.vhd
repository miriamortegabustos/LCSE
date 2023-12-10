
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE work.PIC_pkg.all;


entity RAM_top is
 Port ( 
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   databus  : inout std_logic_vector(7 downto 0);
   address  : in std_logic_vector(7 downto 0);
   write_en : in std_logic;
   oe       : in std_logic;
   switches : out std_logic_vector(7 downto 0);
   temp_l   : out std_logic_vector(6 downto 0);
   temp_h   : out std_logic_vector(6 downto 0)
   );
   
end RAM_top;

architecture Behavioral of RAM_top is

--SIGNAL contents_ram : array8_ram(255 downto 0);
--SIGNAL CS:						std_logic;

SIGNAL databus_e, databus_g: 	std_logic_vector(7 downto 0);
SIGNAL address_e, address_g:	std_logic_vector(7 downto 0);
--SIGNAL address_in:				std_logic_vector(7 downto 0);
--SIGNAL write_en_in:				std_logic;
--SIGNAL oe_in:					std_logic;
SIGNAL write_en_e, write_en_g:	std_logic;
SIGNAL oe_e, oe_g:				std_logic;

component RAM_e 
port (
   Clk        : in    std_logic;
   Reset      : in    std_logic;
   databus_e  : inout std_logic_vector(7 downto 0);
   address    : in std_logic_vector(7 downto 0);
   write_en   : in std_logic;
   oe         : in std_logic;
   switches   : out std_logic_vector(7 downto 0);
   temp_l     : out std_logic_vector(6 downto 0);
   temp_h     : out std_logic_vector(6 downto 0)
   );
end component;

component RAM_g 
port (
   Clk        : in    std_logic;
   Reset      : in    std_logic;
   databus_g  : inout std_logic_vector(7 downto 0);
   address    : in std_logic_vector(7 downto 0);
   write_en   : in std_logic;
   oe         : in std_logic);
end component;
 
 
BEGIN

	ram_e_PHY: RAM_e
	port map ( 
		Clk       => Clk,
		Reset     => Reset,
		databus_e => databus_e,
		address   => address_e,
		write_en  => write_en_e,
		oe        => oe_e,
	    switches  => switches,
		temp_l 	  => temp_l,
		temp_h    => temp_h);
   
	ram_g_PHY: RAM_g
	port map ( 
		Clk       => Clk,
		Reset     => Reset,
		databus_g => databus_g,
		address   => address_g,
		write_en  => write_en_g,
		oe        => oe_g);
	
	process(write_en,oe,address,databus_e,databus_g,databus)
	begin
	   
		--ESCRITURA
		if(write_en = '1') then
			if (unsigned(address) <= 63) then
				databus_e <= databus;
			else 
				databus_g <= databus;
				
			end if;
		
		--LECTURA
		elsif(oe = '1') then
		
			if (unsigned(address) <= 63) then
				databus <= databus_e;
			else 
				databus <= databus_g;
			end if;
			
		else 
			databus <= "ZZZZZZZZ";
			databus_e <= "ZZZZZZZZ";
	        databus_g <= "ZZZZZZZZ";
			
		end if;
	end process;
	
	address_e <= address WHEN (unsigned(address) <= 63) else "00000000";
	address_g <= address WHEN (unsigned(address) > 63) else "11111111";
	
	write_en_e <= write_en WHEN (unsigned(address) <= 63) else '0';
	write_en_g <= write_en WHEN (unsigned(address) > 63) else '0';
	
	oe_e <= oe WHEN (unsigned(address) <= 63) else '0';
	oe_g <= oe WHEN (unsigned(address) > 63) else '0';

end Behavioral;
























