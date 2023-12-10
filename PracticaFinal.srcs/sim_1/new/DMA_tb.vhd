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

 component RS232top
    port (
      Reset     : in  std_logic;
      Clk       : in  std_logic;
      Data_in   : in  std_logic_vector(7 downto 0);
      Valid_D   : in  std_logic;
      Ack_in    : out std_logic;
      TX_RDY    : out std_logic;
      TD        : out std_logic;
      RD        : in  std_logic;
      Data_out  : out std_logic_vector(7 downto 0);
      Data_read : in  std_logic;
      Full      : out std_logic;
      Empty     : out std_logic
      );
  end component;
  
    
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
  
      component DMA is
        Port (
        Reset: in    std_logic; 
        Clk: in    std_logic; 
        RCVD_Data: in    std_logic_vector(7 downto 0); 
        RX_Full: in    std_logic; 
        RX_Empty: in    std_logic; 
     
        ACK_out: in    std_logic; 
        TX_RDY: in    std_logic;
        DMA_ACK: in std_logic;
        Send_comm: in std_logic; 
        
        Data_Read: out    std_logic; 
        Valid_D: out    std_logic; 
        TX_Data: out    std_logic_vector(7 downto 0);
        Address: out std_logic_vector(7 downto 0);
        Databus: inout std_logic_vector(7 downto 0); 
        Write_en: out std_logic; 
        OE: out std_logic;
        DMA_RQ: out std_logic;
        READY: out std_logic  
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
    
    signal RS232_RX : std_logic;
    signal RS232_TX : std_logic;
    signal Send_comm : std_logic; 
    signal DMA_ACK  : std_logic; 
    signal READY    : std_logic; 
    signal DMA_RQ   : std_logic;
  
    signal Valid_D   :  std_logic;
    signal TX_RDY    :  std_logic;
    signal Data_read :  std_logic;
    --      signal databus   :  std_logic_vector(7 downto 0);
    --      signal address   :  std_logic_vector(7 downto 0);
    --      signal write_en  :  std_logic;
    --      signal oe        :  std_logic;
    signal RCVD_Data:     std_logic_vector(7 downto 0); 
    signal RX_Full:     std_logic; 
    signal RX_Empty:     std_logic; 
    signal ACK_out:     std_logic;     
    signal TX_Data:     std_logic_vector(7 downto 0);
    
    SIGNAL clk_priority: std_logic:='0';
    
    constant Tclk: time := 50 ns;  -- Clock Period 
        
begin

  RS232_PHY: RS232top
    port map (
        Reset     => Reset,
        Clk       => clk,
        Data_in   => TX_Data,
        Valid_D   => Valid_D,
        Ack_in    => Ack_out,
        TX_RDY    => TX_RDY,
        TD        => RS232_TX,
        RD        => RS232_RX,
        Data_out  => RCVD_Data,
        Data_read => Data_read,
        Full      => RX_Full,
        Empty     => RX_Empty
        );
        
  RAM_PHY: RAM_RST
    port map (
       Clk       =>clk,
       Reset     =>Reset,
       databus   =>databus,
       address   =>address,
       write_en  =>write_en,
       oe        =>oe,
       switches  =>switches,
       temp_l    =>temp_l,
       temp_h    =>temp_h
    );
    
    DMA_PHY: DMA    
        port map (
            Reset=>Reset,
            Clk=>Clk,
            RCVD_Data=>RCVD_Data,
            RX_Full=>RX_Full,
            RX_Empty=>RX_Empty,         
            ACK_out=>Ack_out,
            TX_RDY=>TX_RDY,
            DMA_ACK=>DMA_ACK,
            Send_comm=>Send_comm,
            
            Data_Read=>Data_Read,
            Valid_D=>Valid_D,
            TX_Data=>TX_Data,
            Address=>Address,
            Databus=>Databus,
            Write_en=>Write_en,
            OE=>OE,
            DMA_RQ =>DMA_RQ,
            READY =>READY 
            );
            
    clk_priority <= Clk;  --Clk no en portmap para forzar prioridad

  
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
      DMA_ACK <= '1';
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
