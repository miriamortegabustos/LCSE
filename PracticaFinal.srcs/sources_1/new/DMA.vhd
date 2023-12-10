----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.10.2023 16:16:42
-- Design Name: 
-- Module Name: DMA - Behavioral
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

entity DMA is
 Port (
    Reset: in    std_logic; --Entrada Reset asíncrono y activo a nivel bajo
    Clk: in    std_logic; --Entrada Reloj principal del sistema (20MHz)
    RCVD_Data: in    std_logic_vector(7 downto 0); --Entrada Dato recibido por la línea RS232
    RX_Full: in    std_logic; --Entrada Señal de estado de la memoria interna del receptor
    RX_Empty: in    std_logic; --Entrada Señal de estado de la memoria interna del receptor
 
    ACK_out: in    std_logic; --Entrada Señal de reconocimiento de llegada de datos al transmisor RS232
    TX_RDY: in    std_logic; --Entrada Estado de la máquina de transmisión serie
    DMA_ACK: in std_logic; --Entrada Reconocimiento y préstamo de buses por parte del procesador principal
    Send_comm: in std_logic; --Entrada Señal de comienzo de envío de datos, controlada por elprocesador principal
    
    Data_Read: out    std_logic; --Salida Petición de lectura de un nuevo dato de los recibidos
    Valid_D: out    std_logic; --Salida Validación del dato enviado al transmisor RS232
    TX_Data: out    std_logic_vector(7 downto 0); --Salida Dato para enviar por línea serie
    Address: out std_logic_vector(7 downto 0); --Salida Direcciones del bus de datos del sistema
    Databus: inout std_logic_vector(7 downto 0);  --Bidireccional Bus de datos del sistema
    Write_en: out std_logic; --Salida Indicación de escritura para la RAM
    OE: out std_logic; --Salida Habilitación de la salida de la RAM
    DMA_RQ: out std_logic; --Salida Petición de buses al procesador principal
    READY: out std_logic --Salida Señal a nivel alto únicamente cuando el procesador se
    
  );
end DMA;

architecture Behavioral of DMA is
    TYPE estados IS (IDLE, WAIT_ACK_RX, RECEIVE_RX, SAVE_RX, WAIT_NEXT_RX, READ_TX, TRANSMIT_TX, WAIT_TX);
    signal current_state: estados;
    signal iterator: integer := 0;


begin

p_ram : process (clk, Reset)  -- no reset
begin
  if Reset = '0' then 
  --TODO
    Data_Read<='0'; 
    Valid_D<='1';
    TX_Data<=(others=>'0');
    -- Outputs
    databus <= (others => 'Z');
    DMA_RQ<='0'; 
    READY<='1';
    OE<='0';
    
  elsif clk'event and clk = '1' then
  Write_en <= '0';
  OE <= '0';
  
  CASE current_state IS
    WHEN IDLE =>
        Write_en <= '0';
        OE <= '0';
    
        Databus <= (others=>'Z');
        Address <= (others=>'Z');
        
        DMA_RQ<='0';
        
        if RX_Empty = '0' then
            DMA_RQ<='1';
            current_state <= WAIT_ACK_RX;
        elsif Send_comm = '1' then
            READY <= '0';
            current_state <= READ_TX;
        end if;
       
    --Estados de recepcion
    WHEN WAIT_ACK_RX =>
        if DMA_ACK = '1' then
            Data_Read<='1';
            current_state <= RECEIVE_RX;
        end if;
        
    WHEN RECEIVE_RX =>
        Write_en <= '1';
        databus <= RCVD_Data;
        Address <= std_logic_vector(to_unsigned(iterator, 8));
        Data_Read<='0';
        current_state <= SAVE_RX;
              
    WHEN SAVE_RX =>      
        if iterator = 2 then
            Write_en <= '1';
            databus <= X"FF";
            Address <= std_logic_vector(to_unsigned(3, 8)); -- Command flag is in 0x03
            iterator<=0;   
            current_state <= IDLE;
            
        elsif RX_Empty = '0' then
            iterator<=iterator + 1;
            Write_en <= '0'; --No este activo todo el rato
            Data_Read<='1'; 
            current_state <= RECEIVE_RX;
        end if;
    
    --Estados de transmision
    WHEN READ_TX =>
        OE <= '1';
        Valid_D <= '1';
        current_state <= TRANSMIT_TX;
        address <= std_logic_vector(to_unsigned(iterator+4, 8));
        
    WHEN TRANSMIT_TX =>
        TX_Data <= Databus;
        Valid_D <= '0';
        current_state <= WAIT_TX;
        
    WHEN WAIT_TX =>
        if  TX_RDY ='1' and ACK_out = '1' and iterator = 1 then
            iterator <= 0;
            Valid_D <= '1';
            OE<='0';
            READY <= '1'; 
            current_state <= IDLE;
        elsif TX_RDY ='1' and ACK_out = '1' then
            iterator <= iterator + 1;
            Valid_D <= '1';
            current_state <= READ_TX;
        end if;
    WHEN OTHERS =>
      current_state <=IDLE;  
    end case;
    
  end if;

end process;

end Behavioral;
