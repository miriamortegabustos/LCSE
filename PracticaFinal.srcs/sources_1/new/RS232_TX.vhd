----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.09.2023 16:03:27
-- Design Name: 
-- Module Name: RS232_TX - Behavioral
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

entity RS232_TX is
generic(
  word_size: integer:=8;
  PulseEndOfCount: integer:=174;
  stopbit_number: integer:=1
);
Port (
  reset: in std_logic; --Entrada Reset asíncrono y activo a nivel bajo.
  clk: in std_logic; --Entrada Reloj del sistema.
  start: in std_logic; --Entrada Comando de comienzo de transmisión, activa a nivel alto.
  data: in std_logic_vector(word_size-1 downto 0); --[7..0] Entrada Byte de datos a transmitir.
  EOT: out std_logic:='1'; --Salida Indica el final de una transmisión, activa a nivel alto.
  TX: out std_logic:='1' --Salida Línea de transmisión RS232
);
end RS232_TX;

architecture Behavioral of RS232_TX is
TYPE estados IS (IDLE, START_BIT, SEND_DATA, STOP_BIT);

  signal current_state: estados;
  signal word: std_logic_vector(word_size-1 downto 0);

begin

process(clk,reset)

  variable data_count: integer:=0;
  variable pulse_width: integer:=0;
  
begin
  if reset = '0' then
    current_state <= IDLE;
    EOT<='1';
    TX<='1';
    data_count:=0;
    pulse_width:=0;
  elsif rising_edge(clk) then
    CASE current_state IS
    WHEN IDLE =>
      --Output
      EOT<='1';
      TX<='1';
      --Start transmission
      if (start='1') then
        word <= data; --Save data input
        current_state <=START_BIT ;
      end if;
      
    WHEN START_BIT =>
      --Output
      EOT<='0';
      TX<='0'; --start bit    
      --Counter for bit length
      pulse_width:=pulse_width+1;
      if pulse_width = PulseEndOfCount then
        pulse_width:= 0;
        current_state <= SEND_DATA;
      end if;
      
    WHEN SEND_DATA =>
      --Output
      EOT<='0';
      TX<=word(data_count);
      --Counter for bit length
      pulse_width:=pulse_width+1;
      if pulse_width = PulseEndOfCount then
        pulse_width:= 0;
        data_count:= data_count+1;     
      end if;
      --Counter for word bit
      if data_count = word_size then
        data_count:=0;
        current_state <= STOP_BIT;
      end if;
    WHEN STOP_BIT =>
      --Output
      EOT<='0';
      TX<='1'; --Stop bit
      --Counter for bit length
      pulse_width:=pulse_width+1;
      if pulse_width = PulseEndOfCount then
        pulse_width:= 0;
        data_count:= data_count+1;
      end if;
      --Counter for stopbit number
      if data_count = stopbit_number then
        data_count:=0;
        current_state <= IDLE;
      end if;
    WHEN OTHERS =>
      current_state <=IDLE;  
    end case;
  end if;
end process;

end Behavioral;
