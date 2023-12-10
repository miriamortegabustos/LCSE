-------------------------------------------------------------------------
-- Memoria de propósito especifico
-------------------------------------------------------------------------

-- =================================
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.PIC_pkg.all;
-- =================================

-- =================================
ENTITY ram_e IS
    PORT (
        --  INPUTS      --
        Clk         :   in      std_logic;
        Reset       :   in      std_logic;
        write_en    :   in      std_logic;
        oe          :   in      std_logic;
        databus     :   inout   std_logic_vector(7 downto 0);
        --  INOUTPUTS   --
        address     :   in      std_logic_vector(7 downto 0);
        --  OUTPUTS     --
        switches    :   out     std_logic_vector(7 downto 0);
        Temp_L      :   out     std_logic_vector (6 downto 0);
        Temp_H      :   out     std_logic_vector (6 downto 0)  
        );
       
END ram_e;
-- =================================

-- =================================
ARCHITECTURE behavior OF ram_e IS
-----------------------------------
-- DECLARACIONES
-----------------------------------    
    signal contents_ram : array8_ram( 63 downto 0);

    begin
-----------------------------------
-- PROCESOS
-----------------------------------    
    --==== EN UN CLIK DE RELOJ ====--
    p_ram : process (clk)
        begin   
        if reset = '0' then
            --==RESETEO==--
            --  RESETO DE TODOS LOS PUERTOS --
            contents_ram <= (others=>(others => '0')); 
            --  RESETO DE TEMPERATURA       --
            contents_ram(49)    <=  "00010100";
            -- PONER EN ALTA IMPEDANCIA LA SALIDA   --
            databus <= (others => 'Z');
        elsif clk'event and clk = '1' then
            if write_en = '1' then
              contents_ram(to_integer(unsigned(address))) <= databus;
            end if;
        end if;    
    end process;
    
 
-----------------------------------
-- SIEMPRE EN EJECUCIÓN
-----------------------------------
    
    --== Poner en alto la salida cuando no recibe datos ==--
    databus <= contents_ram(to_integer(unsigned(address))) when oe = '1' else (others => 'Z');
    
    --== Leer los valores de los SWITCH en la RAM de la  ==--
    switches(0) <= contents_ram(16)(0);
    switches(1) <= contents_ram(17)(0);
    switches(2) <= contents_ram(18)(0);
    switches(3) <= contents_ram(19)(0);
    switches(4) <= contents_ram(20)(0);
    switches(5) <= contents_ram(21)(0);
    switches(6) <= contents_ram(22)(0);
    switches(7) <= contents_ram(23)(0);
    
    --== Leer los valores de la TEMPERATURA en la RAM de la  ==--
    with contents_ram(49)(7 downto 4) select
        Temp_H <=
            "0111111" when "0000",  -- 0
            "0000110" when "0001",  -- 1
            "1011011" when "0010",  -- 2
            "1001111" when "0011",  -- 3
            "1100110" when "0100",  -- 4
            "1101101" when "0101",  -- 5
            "1111101" when "0110",  -- 6
            "0000111" when "0111",  -- 7
            "1111111" when "1000",  -- 8
            "1101111" when "1001",  -- 9
            "1111001" when others;  -- E (error)
    
    with contents_ram(49)(3 downto 0) select
        Temp_L <=
            "0111111" when "0000",  -- 0
            "0000110" when "0001",  -- 1
            "1011011" when "0010",  -- 2
            "1001111" when "0011",  -- 3
            "1100110" when "0100",  -- 4
            "1101101" when "0101",  -- 5
            "1111101" when "0110",  -- 6
            "0000111" when "0111",  -- 7
            "1111111" when "1000",  -- 8
            "1101111" when "1001",  -- 9
            "1111001" when others;  -- E (error)    
    --===============================--

END behavior;
-- =================================