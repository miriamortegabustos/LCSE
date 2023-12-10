
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.PIC_pkg.all;

entity MICRO is
port (
    RESET       : in  std_logic;           						-- Asynchronous, active low
    CLK         : in  std_logic;           						-- System clock, 20 MHz, rising_edge
	RS232_RX    : in  std_logic;           						-- RS232 RX line
	
	RS232_TX    : out std_logic;           						-- RS232 TX line
	SWITCHES    : out std_logic_vector(7 downto 0);   			-- Switch status bargraph
    TEMP_L      : out std_logic_vector(6 downto 0);   			-- Display value for TL
    TEMP_H      : out std_logic_vector(6 downto 0)  			-- Display value for TH
	);
end MICRO;


architecture behavior of MICRO is

  -----------------------------------------------------------------------
  --  TERNA
  ------------------------------------------------------------------------
  
	component TERNA
    port (
		Reset       : in  std_logic;           					-- Asynchronous, active low
		Clk         : in  std_logic;           					-- System clock, 20 MHz, rising_edge
		
		RS232_RX    : in  std_logic;           					-- RS232 RX line
		i_write_en  : in  std_logic;                            -- SIGNALs needed to access directly to the RAM (read/write)
		i_oe        : in  std_logic;                            -- SIGNALs needed to access directly to the RAM (read/write)
		i_address   : in std_logic_vector(7 downto 0);          -- SIGNALs needed to access directly to the RAM (read/write)
		databus     : inout std_logic_vector(7 downto 0);       -- SIGNALs needed to access directly to the RAM (read/write)
		DMA_ACK		: in std_logic;
		Send_comm	: in std_logic;
		
		RS232_TX    : out std_logic;           					-- RS232 TX line
		switches    : out std_logic_vector(7 downto 0);   		-- Switch status bargraph
		Temp_L      : out std_logic_vector(6 downto 0);   		-- Display value for TL
		Temp_H      : out std_logic_vector(6 downto 0);  		-- Display value for TH
		DMA_RQ		: out std_logic;
		READY		: out std_logic
		);
	end component;

  ------------------------------------------------------------------------
  -- ALU
  ------------------------------------------------------------------------
  
	component ALU
    port (
		Reset 	 	: in std_logic; 							-- asynnchronous, active low 
		Clk 	 	: in std_logic; 							-- Sys clock, 20MHz, rising_edge 
		Alu_op  	: in std_logic_vector(5 downto 0); 			-- u-instructions from CPU
		
		Databus 	: inout std_logic_vector(7 downto 0); 		-- System Databus
		
		Index_Reg 	: out std_logic_vector(7 downto 0);			-- Index register 
		FlagZ 		: out std_logic; 							-- Zero flag 
		FlagC 		: out std_logic; 							-- Carry flag 
		FlagN 		: out std_logic; 							-- Nibble carry bit 
		FlagE 		: out std_logic);
	end component;
  
  ------------------------------------------------------------------------
  --  CPU
  ------------------------------------------------------------------------
  
	component CPU
    port ( 
		Reset 		: in  std_logic;
		Clk 		: in  std_logic;
		ROM_Data 	: in  std_logic_vector (11 downto 0);
		ROM_Addr 	: out  std_logic_vector (11 downto 0);
		RAM_Addr 	: out  std_logic_vector (7 downto 0);
		RAM_Write 	: out  std_logic;
		RAM_OE 		: out  std_logic;
		Databus 	: inout  std_logic_vector (7 downto 0);
		DMA_RQ 		: in  std_logic;
		DMA_ACK 	: out  std_logic;
		SEND_comm 	: out  std_logic;
		DMA_READY 	: in  std_logic;
		Alu_op 		: out  std_logic_vector(5 downto 0);
		Index_Reg 	: in  std_logic_vector (7 downto 0);
		FlagZ 		: in  std_logic;
		FlagC 		: in  std_logic;
		FlagN 		: in  std_logic;
		FlagE 		: in  std_logic);
	end component; 
  
  ------------------------------------------------------------------------
  --  ROM
  ------------------------------------------------------------------------
  
	component ROM
    port ( 
		Instruction     : out std_logic_vector(11 downto 0);  -- Instruction bus
		Program_counter : in  std_logic_vector(11 downto 0));
	end component;
  


  ------------------------------------------------------------------------
  --  SIGNALS
  ------------------------------------------------------------------------
	SIGNAL RAM_Write      	: std_logic;
	SIGNAL RAM_OE      		: std_logic;
	SIGNAL RAM_Addr     	: std_logic_vector (7 downto 0);
	SIGNAL DMA_ACK      	: std_logic;
	SIGNAL Send_comm      	: std_logic;
	SIGNAL DMA_RQ     		: std_logic;
	SIGNAL DMA_READY      	: std_logic;
	
	SIGNAL Alu_op      		: std_logic_vector(5 downto 0);
	SIGNAL Index_Reg      	: std_logic_vector(7 downto 0);
	SIGNAL FlagZ      		: std_logic;
	SIGNAL FlagC      		: std_logic;
	SIGNAL FlagN      		: std_logic;
	SIGNAL FlagE      		: std_logic;
	
	SIGNAL ROM_Addr      	: std_logic_vector (11 downto 0);
	SIGNAL ROM_Data      	: std_logic_vector (11 downto 0);
	
	SIGNAL databus      	: std_logic_vector (7 downto 0);


begin  -- behavior

	TERNA_PHY: TERNA
    port map (
        Reset		=> RESET, 
		Clk      	=> CLK, 
		RS232_RX  	=> RS232_RX,
		i_write_en  => RAM_Write,
		i_oe       	=> RAM_OE,
		i_address   => RAM_Addr,
		databus    	=> databus,
		DMA_ACK		=> DMA_ACK,
		Send_comm	=> Send_comm,
		RS232_TX    => RS232_TX,
		switches    => SWITCHES,
		Temp_L     	=> TEMP_L,
		Temp_H      => TEMP_H,
		DMA_RQ		=> DMA_RQ,
		READY		=> DMA_READY
		);

	ALU_PHY: ALU
    port map (
        Reset 	 	=> RESET,	
		Clk 	 	=> CLK,
		Alu_op  	=> Alu_op,
		Databus 	=> databus,
		Index_Reg 	=> Index_Reg,
		FlagZ 		=> FlagZ,
		FlagC 		=> FlagC,
		FlagN 		=> FlagN,
		FlagE 		=> FlagE
		);
        
	CPU_PHY: CPU
    port map (
        Reset 		=> RESET,
		Clk 		=> CLK,
		ROM_Data 	=> ROM_Data,
		ROM_Addr 	=> ROM_Addr,
		RAM_Addr 	=> RAM_Addr,
		RAM_Write 	=> RAM_Write,
		RAM_OE 		=> RAM_OE,
		Databus 	=> databus,
		DMA_RQ 		=> DMA_RQ,
		DMA_ACK 	=> DMA_ACK,
		SEND_comm 	=> Send_comm,
		DMA_READY 	=> DMA_READY,
		Alu_op 		=> Alu_op,
		Index_Reg 	=> Index_Reg,
		FlagZ 		=> FlagZ,
		FlagC 		=> FlagC,
		FlagN 		=> FlagN,
		FlagE 		=> FlagE 
		);
    
	ROM_PHY: ROM
    port map (
        Program_counter => ROM_Addr,
		Instruction		=> ROM_Data
		);

   
end behavior;

