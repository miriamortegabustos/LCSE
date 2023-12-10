
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

entity PICtop is
 port (
 Reset : in std_logic; -- Asynchronous, active low
 Clk : in std_logic; -- System clock, 20 MHz, rising_edge
 RS232_RX : in std_logic; -- RS232 RX line
 RS232_TX : out std_logic; -- RS232 TX line
 Switches : out std_logic_vector(7 downto 0); -- switch status bargraph
 Temp_L : out std_logic_vector(6 downto 0); -- Less significant figure of T_STAT
 Temp_H : out std_logic_vector(6 downto 0) -- Most significant figure of T_STAT
 
--    byte0    : out std_logic_vector(7 downto 0);
--   byte1    : out std_logic_vector(7 downto 0);
--   byte2    : out std_logic_vector(7 downto 0);
--   byte3    : out std_logic_vector(7 downto 0);
--   byte4    : out std_logic_vector(7 downto 0);
--   byte5    : out std_logic_vector(7 downto 0)
 );
end PICtop; 
    --switches : out std_logic_vector(7 downto 0);   -- Switch status bargraph
    --Temp     : out std_logic_vector(7 downto 0);   -- Display value for T_STAT
    --Disp     : out std_logic_vector(1 downto 0));  -- Display activation for T_STAT

architecture behavior of PICtop is

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
       
--          byte0    : out std_logic_vector(7 downto 0);
--   byte1    : out std_logic_vector(7 downto 0);
--   byte2    : out std_logic_vector(7 downto 0);
--   byte3    : out std_logic_vector(7 downto 0);
--   byte4    : out std_logic_vector(7 downto 0);
--   byte5    : out std_logic_vector(7 downto 0)
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
  
  component CPU is
    port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           ROM_Data : in  STD_LOGIC_VECTOR (11 downto 0);
           ROM_Addr : out  STD_LOGIC_VECTOR (11 downto 0);
           RAM_Addr : out  STD_LOGIC_VECTOR (7 downto 0);
           RAM_Write : out  STD_LOGIC;
           RAM_OE : out  STD_LOGIC;
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           DMA_RQ : in  STD_LOGIC;
           DMA_ACK : out  STD_LOGIC;
           SEND_comm : out  STD_LOGIC;
           DMA_READY : in  STD_LOGIC;
           Alu_op : out  alu_op;
           Index_Reg : in  STD_LOGIC_VECTOR (7 downto 0);
           FlagZ : in  STD_LOGIC;
           FlagC : in  STD_LOGIC;
           FlagN : in  STD_LOGIC;
           FlagE : in  STD_LOGIC
   );
   end component;

   component ROM is
     port (
       Instruction     : out std_logic_vector(11 downto 0);  -- Instruction bus
       Program_counter : in  std_logic_vector(11 downto 0)
       );    
   end component;  
   
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
    ------------------------------------------------------------------------
    -- Internal Signals
    ------------------------------------------------------------------------
      signal Data_in   :  std_logic_vector(7 downto 0);
      signal Valid_D   :  std_logic;
      signal Ack_in    :  std_logic;
      signal TX_RDY    :  std_logic;
      signal TD        :  std_logic;
      signal RD        :  std_logic;
      signal Data_out  :  std_logic_vector(7 downto 0);
      signal Data_read :  std_logic;
      signal Full      :  std_logic;
      signal Empty     :  std_logic;
--      signal databus   :  std_logic_vector(7 downto 0);
--      signal address   :  std_logic_vector(7 downto 0);
--      signal write_en  :  std_logic;
--      signal oe        :  std_logic;
      signal RCVD_Data:     std_logic_vector(7 downto 0); 
      signal RX_Full:     std_logic; 
      signal RX_Empty:     std_logic; 
      signal ACK_out:     std_logic;     
      signal TX_Data:     std_logic_vector(7 downto 0);

      signal ROM_Data : STD_LOGIC_VECTOR (11 downto 0);
      signal ROM_Addr : STD_LOGIC_VECTOR (11 downto 0);
      signal RAM_Addr : STD_LOGIC_VECTOR (7 downto 0);
      signal Databus :  STD_LOGIC_VECTOR (7 downto 0);
      signal DMA_RQ :  STD_LOGIC;
      signal DMA_ACK :  STD_LOGIC;
      signal SEND_comm :  STD_LOGIC;
      signal DMA_READY : STD_LOGIC;
      signal Alu_op :  alu_op;
      signal Index_Reg :  STD_LOGIC_VECTOR (7 downto 0);
      signal FlagZ :  STD_LOGIC;
      signal FlagC :  STD_LOGIC;
      signal FlagN :  STD_LOGIC;
      signal FlagE :  STD_LOGIC;
      
      signal Write_en:  std_logic;
      --signal Write_en_ram:  std_logic; 
      --signal Write_en_dma:  std_logic;  
      signal oe:  std_logic;
      --signal oe_ram:  std_logic;
      --signal oe_dma:  std_logic;

begin  -- behavior

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
       address   =>RAM_Addr,
       write_en  =>Write_en,
       oe        =>oe,
       switches  =>switches,
       temp_l    =>temp_l,
       temp_h    =>temp_h
       
--          byte0    => byte0,
--   byte1    => byte1,
--   byte2    => byte2,
--   byte3    => byte3,
--   byte4    => byte4,
--   byte5    => byte5
    );
    
     ALU_PHY: ALU 
     port MAP(
         Reset => Reset, -- asynnchronous, active low
         Clk => Clk, -- Sys clock, 20MHz, rising_edge
         u_instruction => Alu_op, -- u-instructions from CPU
         FlagZ => FlagZ, -- Zero flag
         FlagC => FlagC, -- Carry flag
         FlagN => FlagN, -- Nibble carry bit
         FlagE => FlagE, -- Error flag
         Index_Reg_out => Index_Reg, -- Index register
         Databus => Databus -- System Data bus
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
            Address=>RAM_Addr,
            Databus=>Databus,
            Write_en=>Write_en,
            OE=>oe,
            DMA_RQ =>DMA_RQ,
            READY =>DMA_READY 
            );
    
    CPU_PHY: CPU
       port map (
           Reset =>Reset,
           Clk =>Clk,
           ROM_Data =>ROM_Data,
           ROM_Addr =>ROM_Addr,
           RAM_Addr =>RAM_Addr,
           RAM_Write =>Write_en,
           RAM_OE =>oe,
           Databus =>Databus,
           DMA_RQ =>DMA_RQ,
           DMA_ACK =>DMA_ACK,
           SEND_comm =>SEND_comm,
           DMA_READY =>DMA_READY,
           Alu_op =>Alu_op,
           Index_Reg =>Index_Reg,
           FlagZ =>FlagZ,
           FlagC =>FlagC,
           FlagN =>FlagN,
           FlagE =>FlagE
       );
    
    ROM_PHY: ROM 
      port map(
        Instruction     => ROM_Data,  -- Instruction bus
        Program_counter => ROM_Addr 
    );
    
    ------ (1) SIGNALS USED TO GIVE CONTROL OF THE DATABUS TO THE DMA WHEN NEEDED 
--    process(reset, clk)
--    begin
--      if reset='0' then
--        DMA_ACK <= '0';
--        Send_comm <= '0';
--      elsif clk'event and clk='1' then
--        DMA_ACK <= DMA_RQ;
--        Send_comm <= i_send and (READY);
--      end if;
--    end process;  

------ (2) ADDITIONAL MULTIPLEXERS TO READ/WRITE DIRECTLY IN RAM
--   i_address_req <= i_write_en or not(i_oe);
--   address_mem <= i_address when (i_address_req = '1') else address;
   --write_en_ram <= write_en_dma or write_en_cpu;
   --oe_ram <= oe_dma or not oe_cpu;   -- oe is active low (expression has been simplified)
         --oe_mem <= not( (not(i_oe) or not(oe)) and not(write_en_mem) );


end behavior;

