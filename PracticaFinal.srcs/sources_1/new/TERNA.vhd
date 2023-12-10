
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.PIC_pkg.all;

entity TERNA is
  port (
    Reset       : in  std_logic;           -- Asynchronous, active low
    Clk         : in  std_logic;           -- System clock, 20 MHz, rising_edge
	
	RS232_RX    : in  std_logic;           -- RS232 RX line
    i_write_en  : in  std_logic;                            -- Signals needed to access directly to the RAM (read/write)
    i_oe        : in  std_logic;                            -- Signals needed to access directly to the RAM (read/write)
    i_address   : in std_logic_vector(7 downto 0);          -- Signals needed to access directly to the RAM (read/write)
    databus     : inout std_logic_vector(7 downto 0);       -- Signals needed to access directly to the RAM (read/write)
	DMA_ACK		: in std_logic;
	Send_comm	: in std_logic;
	
    RS232_TX    : out std_logic;           -- RS232 TX line
    switches    : out std_logic_vector(7 downto 0);   -- Switch status bargraph
    Temp_L      : out std_logic_vector(6 downto 0);   -- Display value for TL
    Temp_H      : out std_logic_vector(6 downto 0);  -- Display value for TH
	DMA_RQ		: out std_logic;
	READY		: out std_logic);
end TERNA;


architecture behavior of TERNA is

  -----------------------------------------------------------------------
  --  RS232
  ------------------------------------------------------------------------
  
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
		Empty     : out std_logic);
	end component;

  ------------------------------------------------------------------------
  -- RAM
  ------------------------------------------------------------------------
  
	component RAM_top
    port (
		Clk      : in    std_logic;
		Reset    : in    std_logic;
		databus  : inout std_logic_vector(7 downto 0);
		address  : in std_logic_vector(7 downto 0);
		write_en : in std_logic;
		oe       : in std_logic;
		switches : out std_logic_vector(7 downto 0);
		temp_l   : out std_logic_vector(6 downto 0);
		temp_h   : out std_logic_vector(6 downto 0));
	end component;
  
  ------------------------------------------------------------------------
  --  DMA
  ------------------------------------------------------------------------
  
	component DMA
    port ( 
		Reset 		: in STD_LOGIC;
		Clk 	 	: in STD_LOGIC;
		RCVD_Data 	: in STD_LOGIC_VECTOR (7 downto 0);
		RX_Full 	: in STD_LOGIC;
		RX_Empty    : in STD_LOGIC;
		Data_Read 	: out STD_LOGIC;
		ACK_out 	: in STD_LOGIC;
		TX_RDY 		: in STD_LOGIC;
		Valid_D 	: out STD_LOGIC;
		TX_Data 	: out STD_LOGIC_VECTOR (7 downto 0);
		Address 	: out STD_LOGIC_VECTOR (7 downto 0);
		Databus 	: inout STD_LOGIC_VECTOR (7 downto 0);
		Write_en 	: out STD_LOGIC;
		OE 			: out STD_LOGIC;
		DMA_RQ 		: out STD_LOGIC;
		DMA_ACK 	: in STD_LOGIC;
		Send_comm 	: in STD_LOGIC;
		READY 		: out STD_LOGIC	);
	end component;
  

  -- RS232 y DMA 
  
    signal TX_Data      : STD_LOGIC_VECTOR (7 downto 0);
	signal RCVD_Data    : STD_LOGIC_VECTOR (7 downto 0);
	signal address      : STD_LOGIC_VECTOR (7 downto 0);
	signal Valid_D      : STD_LOGIC;
	signal Ack_out      : STD_LOGIC;
	signal TX_RDY       : STD_LOGIC;
	signal Data_Read    : STD_LOGIC;
	signal Full         : STD_LOGIC;
	signal Empty        : STD_LOGIC;
	signal Write_en     : STD_LOGIC;
	signal OE           : STD_LOGIC;

    signal write_en_mem, oe_mem, i_address_req  : STD_LOGIC;
    signal address_mem  : STD_LOGIC_VECTOR(7 downto 0);


begin  -- behavior

	RS232_PHY: RS232top
    port map (
        Reset     => Reset,
        Clk       => Clk,
        Data_in   => TX_Data,
        Valid_D   => Valid_D,
        Ack_in    => Ack_out,
        TX_RDY    => TX_RDY,
        TD        => RS232_TX,
        RD        => RS232_RX,
        Data_out  => RCVD_Data,
        Data_read => Data_Read,
        Full      => Full,
        Empty     => Empty);

	RAM_PHY: RAM_top
    port map (
        Clk      => Clk,
        Reset    => Reset,
        write_en => write_en_mem,
        oe       => oe_mem,
        address  => address_mem,
        databus  => databus,
        switches => switches,
        temp_L   => Temp_L,
        temp_H   => Temp_H );
        
	DMA_PHY: DMA
    port map (
        Clk       => Clk,
        Reset     => Reset,
        RCVD_Data => RCVD_Data,
        RX_Full   => Full,
        RX_Empty  => Empty,
        Data_Read => Data_Read,
        ACK_out   => ACK_out,
        TX_RDY    => TX_RDY,
        Valid_D   => Valid_D,
        TX_Data   => TX_Data,
        Address   => address,
        Databus   => databus,
        Write_en  => Write_en,
        OE        => OE,
        DMA_RQ    => DMA_RQ,
        DMA_ACK   => DMA_ACK,
        Send_comm => Send_comm,
        READY     => READY );
      

	i_address_req <= i_write_en or (i_oe);
	address_mem <= i_address when (i_address_req = '1') else address;
	write_en_mem <= i_write_en or Write_en;
	oe_mem <= ( (i_oe or OE) and (not write_en_mem) );

   
end behavior;

