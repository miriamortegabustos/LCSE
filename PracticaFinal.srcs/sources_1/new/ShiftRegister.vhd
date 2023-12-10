----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.09.2023 15:36:43
-- Design Name: 
-- Module Name: ShiftRegister - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ShiftRegister is
generic(
  word_size: integer:=8
);

Port ( 
reset: in std_logic; --Entrada Reset asíncrono y activo a nivel bajo.
clk: in std_logic; --Entrada Reloj del sistema.
enable: in std_logic; --Entrada Permiso de carga y desplazamiento, activa a nivel alto y de forma síncrona.
D: in std_logic; --Entrada Dato de llegada.
Q: out std_logic_vector(word_size-1 downto 0)
);
end ShiftRegister;

architecture Behavioral of ShiftRegister is  
begin

process(clk, reset)
  variable word: std_logic_vector(word_size-1 downto 0):=(others=>'0');

begin
  if reset = '0' then
    word:=(others=>'0');
    Q<=(others=>'0');
  elsif rising_edge(clk) and enable= '1' then
    word(6 downto 0):= word(7 downto 1);
    word(7):=D;
    Q<=word;
  end if;
end process;

end Behavioral;
