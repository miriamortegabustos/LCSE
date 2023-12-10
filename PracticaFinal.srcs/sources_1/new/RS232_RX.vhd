----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.09.2023 17:25:40
-- Design Name: 
-- Module Name: RS232_RX - Behavioral
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

entity RS232_RX is
generic(
  word_size: integer:=8;
  PulseEndOfCount: integer:=174;
  stopbit_number: integer:=1
);
  Port (
    reset: in std_logic; --Entrada Reset asíncrono y activo a nivel bajo.
    clk: in std_logic; --Entrada Reloj del sistema.
    lineRD_in: in std_logic; --Entrada Línea de recepción RS232.
    valid_out: out std_logic; --Salida Indica que el dato muestreado es válido y debe ser almacenado en el
    code_out: out std_logic; --Salida Dato de salida (la línea RS232 es directamente pasada a la salida).
    store_out: out std_logic 
  );
end RS232_RX;

architecture Behavioral of RS232_RX is
TYPE estados IS (IDLE, START_BIT, RCV_DATA, STOP_BIT);
  signal current_state: estados;

begin

process(clk, reset)
  variable data_count: integer:=0;
  variable pulse_width: integer:=0; --BitCounter
begin
--variable BitCounter: integer 0 to 
  if reset = '0' then
    current_state <= IDLE;
    valid_out<='0';
    code_out<='0';
    store_out<='0';
    data_count:=0;
    pulse_width:=0;    
  elsif rising_edge(clk) then 
    CASE current_state IS
    WHEN IDLE =>
      --Outputs
      valid_out<='0';
      code_out<='0';
      store_out<='0';
      --Start receiving
      if lineRD_in = '0' then
        current_state<=START_BIT;
      end if; 
         
    WHEN START_BIT =>
       --Output
      valid_out<='0';
      code_out<='0';
      store_out<='0';
      --Counter for half bit length
      pulse_width:=pulse_width+1;
      if pulse_width = PulseEndOfCount/2 then --HalfBitCounter
        pulse_width:= 0;
        current_state <= RCV_DATA;
      end if;
    WHEN RCV_DATA =>
      --Output
      valid_out<='0';
      code_out<='0';
      store_out<='0';
      --Counter for bit length
      pulse_width:=pulse_width+1;
      if pulse_width = PulseEndOfCount then
        pulse_width:= 0;
        code_out<=LineRD_in;
        valid_out<='1';
        data_count:= data_count+1;     
      end if;
      --Counter for word bit
      if data_count = word_size then
        data_count:=0;
        current_state <= STOP_BIT;
      end if;
    WHEN STOP_BIT =>
      --Output
      valid_out<='0';
      code_out<='0';
      store_out<='0';
      --Counter for bit length
      pulse_width:=pulse_width+1;
      if pulse_width = PulseEndOfCount then
        pulse_width:= 0;
        --Check that stop bit is '1'
        if lineRD_in ='0' then
            current_state <=IDLE;
        else
            data_count:= data_count+1;
        end if;
      end if;
      --Counter for word bit
      if data_count = stopbit_number then
        data_count:=0;
        store_out<='1';
        current_state <= IDLE;
      end if;
    WHEN OTHERS =>
      current_state <=IDLE;
    end case;
  end if;
end process;
end Behavioral;
