----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.11.2023 18:23:11
-- Design Name: 
-- Module Name: ALU_tb - Behavioral
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

entity ALU_tb is
--  Port ( );
end ALU_tb;

architecture Behavioral of ALU_tb is
component ALU is
 port (
 Reset : in std_logic; -- asynnchronous, active low
 Clk : in std_logic; -- Sys clock, 20MHz, rising_edge
 u_instruction : in alu_op; -- u-instructions from CPU
 FlagZ : out std_logic; -- Zero flag
 FlagC : out std_logic; -- Carry flag
 FlagN : out std_logic; -- Nibble carry bit
 FlagE : out std_logic; -- Error flag
 Index_Reg_out : out std_logic_vector(7 downto 0); -- Index register
 Databus : inout std_logic_vector(7 downto 0) -- System Data bus
 );
end component; 




 signal Reset :  std_logic:='0'; -- asynnchronous, active low
 signal Clk :  std_logic; -- Sys clock, 20MHz, rising_edge
 signal u_instruction :  alu_op; -- u-instructions from CPU
 signal FlagZ :  std_logic; -- Zero flag
 signal FlagC :  std_logic; -- Carry flag
 signal FlagN :  std_logic; -- Nibble carry bit
 signal FlagE :  std_logic; -- Error flag
 signal Index_Reg_out :  std_logic_vector(7 downto 0); -- Index register
 signal Databus :  std_logic_vector(7 downto 0); -- System Data bus
 
 constant Tclk: time := 50 ns;  -- Clock Period 

begin

alu_PHY: ALU
   port map ( 
     Reset => Reset,
     Clk  => Clk,
     u_instruction  => u_instruction,
     FlagZ  => FlagZ,
     FlagC  => FlagC,
     FlagN  => FlagN,
     FlagE  => FlagE,
     Index_Reg_out  => Index_Reg_out,
     Databus  => Databus
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
      
    databus <= (others => 'Z');
    u_instruction <= nop;
    reset <= '1';
    
    wait for 100 ns;
    reset <= '0';
    wait for 100 ns;
    reset <= '1';
    wait for 100 ns;
     
    -- Test load 
    u_instruction <= op_ldacc;
    databus <= std_logic_vector(to_signed(125, 8));
    wait for 50 ns;
    
    u_instruction <= op_mvacc2id;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_mvacc2a;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_mvacc2b;
    databus <= (others => 'Z');
    wait for 50 ns;
     
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_signed(10, 8));
    wait for 50 ns;
    
    u_instruction <= op_ldb;
    databus <= std_logic_vector(to_signed(2, 8));
    wait for 50 ns;
    
    u_instruction <= op_ldid;
    databus <= std_logic_vector(to_signed(84, 8));
    wait for 100 ns;
    
    -- Test addition
    u_instruction <= op_add;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_signed(0, 8));
    wait for 50 ns;
    
    u_instruction <= op_ldb;
    databus <= std_logic_vector(to_signed(0, 8));
    wait for 50 ns;
    
    u_instruction <= op_add;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_unsigned(136, 8));
    wait for 50 ns;
    
    u_instruction <= op_ldb;
    databus <= std_logic_vector(to_unsigned(136, 8));
    wait for 50 ns;
    
    u_instruction <= op_add;
    databus <= (others => 'Z');
    wait for 100 ns;
    
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_unsigned(16, 8));
    wait for 50 ns;
    
    u_instruction <= op_ldb;
    databus <= std_logic_vector(to_unsigned(0, 8));
    wait for 50 ns;
    
    u_instruction <= op_add;
    databus <= (others => 'Z');
    wait for 100 ns;
    
    -- Test subtraction
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_signed(10, 8));
    wait for 50 ns;
    
    u_instruction <= op_ldb;
    databus <= std_logic_vector(to_signed(2, 8));
    wait for 50 ns;
    
    u_instruction <= op_sub;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_signed(64, 8));
    wait for 50 ns;
    
    u_instruction <= op_ldb;
    databus <= std_logic_vector(to_signed(64, 8));
    wait for 50 ns;
    
    u_instruction <= op_sub;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_unsigned(0, 8));
    wait for 50 ns;
    
    u_instruction <= op_ldb;
    databus <= std_logic_vector(to_unsigned(125, 8));
    wait for 50 ns;
    
    u_instruction <= op_sub;
    databus <= (others => 'Z');
    wait for 100 ns;
    
    -- Test shifts
    u_instruction <= op_shiftl;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_shiftr;
    databus <= (others => 'Z');
    wait for 100 ns;
    
    -- Test logic operators
    u_instruction <= op_and;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_or;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_xor;
    databus <= (others => 'Z');
    wait for 100 ns;
    
    -- Test comparator
    u_instruction <= op_cmpe;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_cmpl;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_cmpg;
    databus <= (others => 'Z');
    wait for 100 ns;
    
    -- Test ascii2bin
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_signed(57, 8));
    wait for 50 ns;
    
    u_instruction <= op_ascii2bin;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_signed(24, 8));
    wait for 50 ns;
    
    u_instruction <= op_ascii2bin;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    -- Test bin2ascii
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_signed(9, 8));
    wait for 50 ns;
    
    u_instruction <= op_bin2ascii;
    databus <= (others => 'Z');
    wait for 50 ns;
    
    u_instruction <= op_lda;
    databus <= std_logic_vector(to_signed(24, 8));
    wait for 50 ns;
    
    u_instruction <= op_bin2ascii;
    databus <= (others => 'Z');
    wait for 100 ns;
    
    -- Test output
    u_instruction <= op_oeacc;
    databus <= (others => 'Z');
    wait for 100 ns;
      
  END PROCESS;


end Behavioral;
