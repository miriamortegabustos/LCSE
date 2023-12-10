----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.10.2023 10:37:09
-- Design Name: 
-- Module Name: RAM_RST - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM_RST is
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
   
end RAM_RST;

architecture Behavioral of RAM_RST is

SIGNAL contents_ram : array8_ram(63 downto 0);

component ram 
port (
   Clk      : in    std_logic;
   --Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0)
   );
END component;
 
begin

ram_PHY: ram
   port map ( 
       Clk      =>clk,
       write_en  =>write_en,
       oe        =>oe,
       address   =>address,
       databus   =>databus
   );

p_ram : process (clk, Reset)  -- no reset
begin
  if Reset = '0' then 
  --TODO
    -- Memory all to zero except termostat
    contents_ram <= (others=>(others => '0')); 
    -- temperature to ten on reset
    contents_ram(49) <= "00010000";
    -- Outputs
    databus <= (others => 'Z');
  elsif clk'event and clk = '1' then
    -- Escritura
    if write_en = '1' then
        if to_integer(unsigned(address)) < 64 then
            contents_ram(to_integer(unsigned(address))) <= databus;
        end if;
    end if;
  end if;

end process;
-- Lectura

--databus <= (others => 'Z') when oe /= '1' else
--           contents_ram(to_integer(unsigned(address))) when to_integer(unsigned(address)) < 64 else
--           (others => 'Z');

process (databus, oe, address)  -- no reset
begin
    if oe /= '1' then
        databus <= (others => 'Z');
    elsif to_integer(unsigned(address)) < 64 then
        databus <=contents_ram(to_integer(unsigned(address)));
    else
        databus <= (others => 'Z');
    end if;

end process;

-- Outputs

switches(7) <= contents_ram(23)(0);
switches(6) <= contents_ram(22)(0);
switches(5) <= contents_ram(21)(0);
switches(4) <= contents_ram(20)(0);
switches(3) <= contents_ram(19)(0);
switches(2) <= contents_ram(18)(0);
switches(1) <= contents_ram(17)(0);
switches(0) <= contents_ram(16)(0);


with contents_ram(49)(7 downto 4) select
Temp_H <=
    "0111111" when "0000",  -- 0
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1111001" when others;  -- E (error)
    
with contents_ram(49)(3 downto 0) select
Temp_L <=
    "0111111" when "0000",  -- 0
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1111001" when others;  -- E (error)

-- databus <= contents_ram(to_integer(unsigned(address))) when oe = '0' else (others => 'Z');

end Behavioral;