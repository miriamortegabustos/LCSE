LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.PIC_pkg.all;

ENTITY DMA IS
PORT(
   Reset    : in    std_logic;
   Clk    	: in    std_logic;
   
   -- RS232 RX	
   RCVD_Data: in    std_logic_vector(7 downto 0);
   RX_Full:   in    std_logic;
   RX_Empty:  in    std_logic;
   Data_Read:  out   std_logic;
   
   -- RS232 TX
   ACK_out:   in    std_logic;
   TX_RDY:    in    std_logic;
   Valid_D:   out   std_logic;
   TX_Data:   out   std_logic_vector(7 downto 0);
   
   -- RAM
   Address:   out   std_logic_vector(7 downto 0);
   Databus:	  inout std_logic_vector(7 downto 0);
   Write_en:  out   std_logic;
   OE:        out   std_logic;
   
   -- PROCESADOR PRINCIPAL
   DMA_RQ:    out   std_logic;
   DMA_ACK:   in    std_logic;
   Send_comm: in    std_logic;
   READY:     out   std_logic
    );
END DMA;

ARCHITECTURE behavior OF DMA IS

TYPE estados IS (IDLE, 
				 PEDIR_BUS, RECIBIR_DATOS, ESCRIBIR_RAM, ESCRIBIR_NEW_INST, DEVOLVER_BUS,
				 IDLE_TX, LISTO, LECTURA_DAT_1, MANDAR_DAT_1, LECTURA_DAT_2, CICLO, MANDAR_DAT_2, FIN_TX);
SIGNAL estado: estados;
SIGNAL count: std_logic_vector(1 downto 0);

BEGIN
	PROCESS(Clk, Reset)
	BEGIN
		if Reset = '0' then --ASINCRONO Y A NIVEL BAJO
			--INICIALIZACION DEL SISTEMA
			--VARIABLES
			count <= "00";
			
			--RX
			Data_Read <= '0';
			
			--TX
			TX_Data <= (others => '0');
			Valid_D <= '1'; 
			
			--RAM
			OE <= '0';
			Write_en <= '0';
			Address <= (others => '0');
			Databus <= (others => 'Z');
			
			--CPU
			READY <= '1';
			DMA_RQ <= '0';
			
			
		elsif rising_edge(Clk) then
			CASE estado IS
			
				WHEN IDLE =>
					if(RX_Empty = '0')then
						estado <= PEDIR_BUS;
						DMA_RQ <= '1';
					elsif(Send_comm = '1')then
						estado <= LISTO;
						Address <= "00000100"; --0x04
						OE <= '1';
						READY <= '0';
					end if;
					
					
					
				-- RX
				WHEN PEDIR_BUS =>
					if(DMA_ACK = '1')then
						estado <= RECIBIR_DATOS;
						Data_Read <= '1';
					end if;
					
				WHEN RECIBIR_DATOS =>
						estado <= ESCRIBIR_RAM;
						Write_en <= '1';
						Databus <= RCVD_Data;
						Data_Read <= '0';--*******************************************************************************
						CASE count IS
							WHEN "00"   => Address <= "00000000";
							WHEN "01"   => Address <= "00000001";
							WHEN "10"   => Address <= "00000010";
							WHEN OTHERS => Address <= "00000000";
						END CASE;
				
				WHEN ESCRIBIR_RAM =>
					if(UNSIGNED(count) = TO_UNSIGNED(2,2))then
						estado <= ESCRIBIR_NEW_INST;
						Write_en <= '1';
						Databus <= "11111111";
						Address <= "00000011";
					else
						estado <= DEVOLVER_BUS;
						DMA_RQ <= '0';
						Write_en <= '0';
						--Data_Read <= '0';--*******************************************************************************
						Databus <= (others => 'Z');
						count <= std_logic_vector(unsigned(count) + TO_UNSIGNED(1,2));
					end if;
					
				WHEN ESCRIBIR_NEW_INST =>
					estado <= DEVOLVER_BUS;
					DMA_RQ <= '0';
					Write_en <= '0';
					--Data_Read <= '0';--*******************************************************************************
					Databus <= (others => 'Z');
					count <= std_logic_vector(unsigned(count) + TO_UNSIGNED(1,2));
				
				WHEN DEVOLVER_BUS =>
					if(DMA_ACK = '0')then
						estado <= IDLE;
						if(UNSIGNED(count) = TO_UNSIGNED(3,2))then
							count <= "00";
						end if;
					end if;
					
					
					
				-- TX
				WHEN LISTO =>
					estado <= LECTURA_DAT_1;
					TX_Data <= Databus;
					OE <= '0';--**************************************************************************************************  -NEW- 
					
				WHEN LECTURA_DAT_1 =>
					if(TX_RDY = '1')then
						if(ACK_out = '1')then
							estado <= MANDAR_DAT_1;
							Valid_D <= '0'; -- ACTIVO BAJO
						end if;
					end if;
				
				WHEN MANDAR_DAT_1 =>
					if(TX_RDY = '0')then
						estado <= LECTURA_DAT_2;
						Valid_D <= '1';
						Address <= "00000101"; --0x05
					end if;
				
				WHEN LECTURA_DAT_2 =>
					if(TX_RDY = '1')then
						if(ACK_out = '1')then
							--estado <= MANDAR_DAT_2;
							estado <= CICLO;
							--Valid_D <= '0';
							OE <= '1';--**************************************************************************************************  -NEW- 
							--TX_Data <= Databus;
						end if;
					end if;	
					
				WHEN CICLO =>
					estado <= MANDAR_DAT_2;
					Valid_D <= '0';
					--OE <= '1';
					TX_Data <= Databus;
						
				
				WHEN MANDAR_DAT_2 =>
						if(TX_RDY = '0')then
							estado <= FIN_TX;
							READY <= '1';
							Databus <= (others => 'Z');
							OE <= '0';
							Valid_D <= '1';
						end if;
				
				WHEN FIN_TX =>
					if(Send_comm = '0')then
						estado <= IDLE;
					end if;
				
				WHEN OTHERS =>
					estado <= IDLE;
			END CASE;
			
		end if;
	END PROCESS;

END behavior;






