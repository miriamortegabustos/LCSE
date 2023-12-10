----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2023 17:35:08
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
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
end ALU; 

architecture Behavioral of ALU is

    signal reg_a, reg_b, reg_acc, reg_indx: std_logic_vector(7 downto 0):=(others=>'0');

begin

Index_Reg_out <= reg_indx;
--Asigning databus on op_acc with dataflow to make it instant, other wise oe_acc operation in CPU doesnt work
databus <= reg_acc when u_instruction = op_oeacc else (others => 'Z');

p_alu : process (clk, Reset)  -- no reset

-- Aux variables to calculate carry falgs
variable aux_9bit: std_logic_vector(8 downto 0);
variable aux_8bit: std_logic_vector(7 downto 0);
variable aux_5bit: std_logic_vector(4 downto 0);

begin
        
  if Reset = '0' then 
    -- Outputs
    reg_a <= (others=>'0');
    reg_b <= (others=>'0');
    reg_acc <= (others=>'0');
    reg_indx <= (others=>'0');
    FlagZ <= '0';
    FlagC <= '0';
    FlagN <= '0';
    FlagE <= '0';
        
  elsif clk'event and clk = '1' then
    case u_instruction is
    when nop =>
        databus <= (others => 'Z');    
    when op_lda =>
        reg_a <= databus;
    when op_ldb =>  
        reg_b <= databus;
    when op_ldacc => 
        reg_acc <= databus;
    when op_ldid => 
        reg_indx <= databus;
    when op_mvacc2id =>
        reg_indx <= reg_acc;
    when op_mvacc2a =>
        reg_a <= reg_acc;
    when op_mvacc2b =>
        reg_b <= reg_acc;
    when op_add =>
        -- Do the operation in the aux variables
        aux_9bit(8 downto 0) := std_logic_vector(resize(signed(reg_a),9) + resize(signed(reg_b),9));
        aux_5bit(4 downto 0) := std_logic_vector(resize(resize(signed(reg_a),4),5) + resize(resize(signed(reg_b),4),5));
        -- Set the result and flags
        reg_acc <= aux_9bit(7 downto 0);
        if aux_9bit = "000000000" then FlagZ <= '1'; else FlagZ <= '0'; end if;
        FlagC <= aux_9bit(8);
        FlagN <= aux_5bit(4);
    when op_sub => 
        -- Do the operation in the aux variables
        aux_9bit(8 downto 0) := std_logic_vector(resize(signed(reg_a),9) - resize(signed(reg_b),9));
        aux_5bit(4 downto 0) := std_logic_vector(resize(resize(signed(reg_a),4),5) - resize(resize(signed(reg_b),4),5));
        -- Set the result and flags
        reg_acc <= aux_9bit(7 downto 0);
        if aux_9bit = "000000000" then FlagZ <= '1'; else FlagZ <= '0'; end if;
        FlagC <= aux_9bit(8);
        FlagN <= aux_5bit(4);
    when op_shiftl => 
        reg_acc(7 downto 1) <= reg_acc(6 downto 0);
        reg_acc(0) <= '0';
    when op_shiftr => 
        reg_acc(6 downto 0) <= reg_acc(7 downto 1);
        reg_acc(7) <= '0';
    when op_and => 
        -- Do the operation in the aux variables
        aux_8bit := reg_a and reg_b;
        -- Set the result and flags
        reg_acc <= aux_8bit(7 downto 0);
        if aux_8bit = "00000000" then FlagZ <= '1'; else FlagZ <= '0'; end if;
    when op_or =>
        -- Do the operation in the aux variables
        aux_8bit := reg_a or reg_b;
        -- Set the result and flags
        reg_acc <= aux_8bit(7 downto 0);
        if aux_8bit = "00000000" then FlagZ <= '1'; else FlagZ <= '0'; end if;
    when op_xor =>
        -- Do the operation in the aux variables
        aux_8bit := reg_a xor reg_b;
        -- Set the result and flags
        reg_acc <= aux_8bit(7 downto 0);
        if aux_8bit = "00000000" then FlagZ <= '1'; else FlagZ <= '0'; end if;
    when op_cmpe => 
        if reg_a = reg_b then FlagZ <= '1'; else FlagZ <= '0'; end if;       
    when op_cmpl =>
        if reg_a < reg_b then FlagZ <= '1'; else FlagZ <= '0'; end if;       
    when op_cmpg => 
        if reg_a > reg_b then FlagZ <= '1'; else FlagZ <= '0'; end if;       
    when op_ascii2bin => 
        if reg_a <= std_logic_vector(to_signed(57,8)) and reg_a >= std_logic_vector(to_signed(48,8)) then
            reg_acc <= std_logic_vector(signed(reg_a) - to_signed(48,8));
            flagE <= '0';
        else
            reg_acc <= x"FF";
            flagE <= '1';
        end if;
    when op_bin2ascii => 
        if reg_a <= std_logic_vector(to_signed(9,8)) and reg_a >= std_logic_vector(to_signed(0,8)) then
            reg_acc <= std_logic_vector(signed(reg_a) + to_signed(48,8));
            flagE <= '0';
        else
            reg_acc <= x"FF";
            flagE <= '1';        
        end if;
    when op_oeacc => 
        databus <= reg_acc;
    when others =>
        report "unreachable" severity failure;
    end case;

  end if;
end process;

end Behavioral;
