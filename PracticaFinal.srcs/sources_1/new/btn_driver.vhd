----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.10.2023 19:23:41
-- Design Name: 
-- Module Name: btn_driver - Behavioral
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

entity btn_driver is
  Port ( 
  clk: in std_logic;
  reset: in std_logic;
  btn_in: in std_logic;
  btn_out: out std_logic);
end btn_driver;

architecture Behavioral of btn_driver is

signal edge_detector: std_logic_vector(1 downto 0) :=(others=>'0');
signal debouncer: std_logic_vector(9 downto 0) :=(others=>'0');

begin

process(clk,reset)

begin
  if reset = '0' then
    edge_detector<=(others=>'0');
    debouncer<=(others=>'0');
    btn_out<='0';
  elsif rising_edge(clk) then
    --Debounce signal
    debouncer(9 downto 1)<=debouncer(8 downto 0);
    debouncer(0)<=btn_in;
    
    --Edge detection
    if debouncer = "0000000000" then
        edge_detector(1)<=edge_detector(0);
        edge_detector(0)<='0';
    elsif debouncer = "1111111111" then
        edge_detector(1)<=edge_detector(0);
        edge_detector(0)<='1';
    end if;
    
    if edge_detector = "01" then
        btn_out <= '1';
    else
        btn_out <= '0';
    end if;     
  end if;
end process;


end Behavioral;
