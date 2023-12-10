----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.11.2023 12:30:36
-- Design Name: 
-- Module Name: PICtop_tb - Behavioral
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


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DMA_tb is
--  Port ( );
end DMA_tb;

architecture Behavioral of DMA_tb is

component TERNA is
  port (
    Reset       : in  std_logic;           -- Asynchronous, active low
    Clk         : in  std_logic;           -- System clock, 20 MHz, rising_edge
	
	RS232_RX    : in  std_logic;           -- RS232 RX line
    i_write_en  : in  std_logic;                            -- Signals needed to access directly to the RAM (read/write)
    i_oe        : in  std_logic;                            -- Signals needed to access directly to the RAM (read/write)
    i_address   : in std_logic_vector(7 downto 0);          -- Signals needed to access directly to the RAM (read/write)
    databus     : inout std_logic_vector(7 downto 0);       -- Signals needed to access directly to the RAM (read/write)
	DMA_ACK		: in std_logic;
	Send_comm	: in std_logic;
	
    RS232_TX    : out std_logic;           -- RS232 TX line
    switches    : out std_logic_vector(7 downto 0);   -- Switch status bargraph
    Temp_L      : out std_logic_vector(6 downto 0);   -- Display value for TL
    Temp_H      : out std_logic_vector(6 downto 0);  -- Display value for TH
	DMA_RQ		: out std_logic;
	READY		: out std_logic);
end component;
      
    signal clk: std_logic;
    signal reset: std_logic:='0';
    signal databus  : std_logic_vector(7 downto 0);
    signal address  : std_logic_vector(7 downto 0);
    signal write_en : std_logic;
    signal oe       : std_logic;
    signal switches : std_logic_vector(7 downto 0);
    signal temp_l   : std_logic_vector(6 downto 0);
    signal temp_h   : std_logic_vector(6 downto 0);
    
    signal RS232_RX : std_logic;
    signal RS232_TX : std_logic;
    signal Send_comm : std_logic; 
    signal DMA_ACK  : std_logic; 
    signal READY    : std_logic; 
    signal DMA_RQ   : std_logic;
    
    constant Tclk: time := 50 ns;  -- Clock Period 
        
begin

TERNAA: TERNA 
  port map(
    Reset       =>Reset,
    Clk         =>Clk,
	
	RS232_RX   =>RS232_RX,
    i_write_en  =>write_en,
    i_oe        =>oe,
    i_address   =>address,
    databus     =>databus,
	DMA_ACK		=>DMA_ACK,
	Send_comm	=>Send_comm,
	
    RS232_TX    =>RS232_TX,
    switches    =>switches,
    Temp_L      =>Temp_L,
    Temp_H      =>Temp_H,
	DMA_RQ		=>DMA_RQ,
	READY		=>READY
   );
   -- Clock generator
  p_clk : PROCESS
  BEGIN
     Clk <= '1';
     wait for Tclk/2;
     Clk <= '0';
     wait for Tclk/2;
  END PROCESS;

  p_reset : PROCESS
  BEGIN
  
      -- Initial value
      RS232_RX <= '1'; 
      Send_comm <= '0';
      DMA_ACK <= '0';
      address <= (others=>'Z');
      databus <= (others=>'Z');
      write_en <= 'Z';  
  
      reset <= '0';
      wait for 100 ns;
      reset <= '1';
      wait for 100 ns;
      
      --Receive 255
      wait for 8650 ns;
      RS232_RX <= '0';  -- StartBit
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '1';  -- Stop bit
      
      --Receive 7
      wait for 8650 ns;
      RS232_RX <= '0';  -- StartBit
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '1';  -- Stop bit
      
      --Receive 2
      wait for 8650 ns;
      RS232_RX <= '0';  -- StartBit
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '1';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '0';
      wait for 8650 ns;
      RS232_RX <= '1';  -- Stop bit
      wait for 8650 ns;
      
      --corta aqui
      
      -- Simulate processor DMA acknowledge
      wait for 500 ns;
      DMA_ACK <= '1';
      wait for 2000 ns;
      DMA_ACK <= '0';
      wait for 100 ns;
      
      --TRANSMISSION
      write_en <= '1';  
      address <=x"04";
      databus <=std_logic_vector(to_unsigned(10,8));
      wait for 100 ns;
      write_en <= '0';
      address <= (others=>'Z');
      databus <= (others=>'Z');
      wait for 400 ns;  
      
      write_en <= '1';  
      address <=x"05";
      databus <=std_logic_vector(to_unsigned(16,8));
      wait for 100 ns;
      write_en <= '0';
      address <= (others=>'Z');
      databus <= (others=>'Z');
      wait for 400 ns; 
           
      wait for 100 ns; 
      Send_comm <= '1';
      wait for 100 ns; 
      Send_comm <= '0';
      wait for 300000 ns; 
  end process; 

end Behavioral;
