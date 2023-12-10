LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

library xil_defaultlib;
use xil_defaultlib.RS232_test.all;

entity PICtop_tb is
end PICtop_tb;

architecture TestBench of PICtop_tb is

  component PICtop
    port (
     Reset : in std_logic; -- Asynchronous, active low
     Clk : in std_logic; -- System clock, 20 MHz, rising_edge
     RS232_RX : in std_logic; -- RS232 RX line
     RS232_TX : out std_logic; -- RS232 TX line
     Switches : out std_logic_vector(7 downto 0); -- switch status bargraph
     Temp_L : out std_logic_vector(6 downto 0); -- Less significant figure of T_STAT
     Temp_H : out std_logic_vector(6 downto 0) -- Most significant figure of T_STAT
      --Disp     : out std_logic_vector(1 downto 0)
      );
  end component;

-----------------------------------------------------------------------------
-- Internal signals
-----------------------------------------------------------------------------

  signal Reset    : std_logic;
  signal Clk      : std_logic;
  signal RS232_RX : std_logic;
  signal RS232_TX : std_logic;
  signal switches : std_logic_vector(7 downto 0);
  signal Temp_L     : std_logic_vector(6 downto 0);
  signal Temp_H     : std_logic_vector(6 downto 0);


begin  -- TestBench

  UUT: PICtop
    port map (
        Reset    => Reset,
        Clk      => Clk,
        RS232_RX => RS232_RX,
        RS232_TX => RS232_TX,
        switches => switches,
        Temp_L     => Temp_L,
        Temp_H     => Temp_H
    );

-----------------------------------------------------------------------------
-- Reset & clock generator
-----------------------------------------------------------------------------

  Reset <= '0', '1' after 75 ns;

  p_clk : PROCESS
  BEGIN
     clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  END PROCESS;

-------------------------------------------------------------------------------
-- Sending some stuff through RS232 port
-------------------------------------------------------------------------------

  SEND_STUFF : process
  begin
     RS232_RX <= '1';
     wait for 40 us;
     --Transmit(RS232_RX, X"49"); -- 'I'
     --Transmit(RS232_RX, X"53"); -- 'S'
     Transmit(RS232_RX, X"54"); -- 'T'
     wait for 40 us;
     --Transmit(RS232_RX, X"34"); -- '4'
     --Transmit(RS232_RX, X"54"); -- 'T'
     Transmit(RS232_RX, X"32"); -- '2'
     wait for 40 us;
     --Transmit(RS232_RX, X"31"); -- '1'
     --Transmit(RS232_RX, X"30"); -- '0'
     Transmit(RS232_RX, X"31"); -- '1'
     wait;
  end process SEND_STUFF;
end TestBench;
