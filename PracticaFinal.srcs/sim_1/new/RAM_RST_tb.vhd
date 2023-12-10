----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.10.2023 20:30:28
-- Design Name: 
-- Module Name: RAM_RST_tb - Behavioral
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

entity RAM_RST_tb is
--  Port ( );
end RAM_RST_tb;

architecture Behavioral of RAM_RST_tb is

component RAM_RST is
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
  
    constant Tclk: time := 50 ns;  -- Clock Period 
  
begin
 UUT: RAM_RST port map (
   Clk      =>Clk,
   Reset    =>Reset,
   databus  =>databus,
   address  =>address,
   write_en =>write_en,
   oe       =>oe,
   switches =>switches,
   temp_l   =>temp_l,
   temp_h   =>temp_h
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
  
      reset <= '1';
      wait for 100 ns;
      reset <= '0';
      wait for 100 ns;
      
     oe <= '0';
     write_en <= '0';  
     wait for 500 ns;     -- Wait for 20-MHz clock signal ready

     write_en <= '1';  
     address <=x"FF";
     databus <=std_logic_vector(to_unsigned(62,8));
     wait for 100 ns;
     write_en <= '0';
     wait for 400 ns;  
       
     write_en <= '1';
     address <=x"12";
     databus <=std_logic_vector(to_unsigned(1,8));
     wait for 100 ns;
     write_en <= '0';
     wait for 400 ns;     -- Wait for 20-MHz clock signal ready

     write_en <= '1';
     address <=x"31";
     databus <=x"21";
     wait for 100 ns;
     write_en <= '0';
     wait for 200 ns;
     databus <= (others=>'Z');
     wait for 200 ns;     -- Wait for 20-MHz clock signal ready
     
      oe <= '1';
      databus <= (others=>'Z');
      address <=x"FF";
      wait for 100 ns;
      oe <= '0';
      wait for 400 ns;
      
      oe <= '1';
      databus <= (others=>'Z');
      address <=x"12";
      wait for 100 ns;
      oe <= '0';
      wait for 400 ns;
      
      reset <= '1';
      wait for 100 ns;
      reset <= '0';
      wait for 400 ns;
      
      oe <= '1'; 
      address <=x"FF";
      wait for 100 ns;
      oe <= '0';
      wait for 400 ns;
      
      oe <= '1';
      databus <= (others=>'Z');
      address <=x"12";
      wait for 100 ns;
      oe <= '0';
      wait for 400 ns;
  END PROCESS;

end Behavioral;
