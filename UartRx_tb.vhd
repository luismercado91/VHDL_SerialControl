library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--*****************************************************************************
--*
--* Name: UartRx Test Bench
--* Designer: Scott Tippens
--*
--*     Test the UartRx component by simulating the reception of three values
--*     (X"A5", X"5A", and X"FF").  The test conditions are for a clock rate
--*     of 100 MHz and baud rate of 115200.
--*
--*****************************************************************************

entity UartRx_tb is
end UartRx_tb;



architecture UartRx_tb_ARCH of UartRx_tb is

    ----general-definitions--------------------------------------------CONSTANTS--
    constant ACTIVE: std_logic := '1';
    constant CLOCK_FREQ:  integer := 100_000_000;
    constant BAUD_RATE:   integer := 6_250_000;  --115_200;
    constant BIT_TIME:    time    := (1_000_000_000/BAUD_RATE) * 1 ns;

    
    ----connections--------------------------------------------------UUT-SIGNALS--
    signal clock:      std_logic;
    signal reset:      std_logic;
    signal rxData:     std_logic;
    signal dataReady:  std_logic;
    signal dataOut:    std_logic_vector(7 downto 0);

    component UartRx
        generic (
            BAUD_RATE:  positive := 115200;
            CLOCK_FREQ: positive := 100_000_000
            ); 
        port (
            clock:      in  std_logic;
            reset:      in  std_logic;
            rxData:     in  std_logic;
             dataReady:  out std_logic;
            dataOut:    out std_logic_vector(7 downto 0)
            );
    end component UartRx;

begin

    --============================================================================
    --  UUT
    --============================================================================
    UUT: UartRx
        generic map (
            BAUD_RATE  =>  BAUD_RATE,
            CLOCK_FREQ =>  CLOCK_FREQ
            )
        port map (
            clock     => clock,
            reset     => reset,
            rxData    => rxData,
            dataReady => dataReady,
            dataOut   => dataOut
            );


    --============================================================================
    --  Reset
    --============================================================================
    SYSTEM_RESET: process
    begin
        reset <= ACTIVE;
        wait for 15 ns;
        reset <= not ACTIVE;
        wait;
    end process SYSTEM_RESET;

    
    --============================================================================
    --  Clock
    --============================================================================
    SYSTEM_CLOCK: process
    begin
        clock <= not ACTIVE;
        wait for 5 ns;
        clock <= ACTIVE;
        wait for 5 ns;
    end process SYSTEM_CLOCK;


    --============================================================================
    --  Signal Driver
    --============================================================================
    SIGNAL_DRIVER: process
    begin
        ----set serial line to idle-----------------------------------------------
        rxData <= '1';
        wait for 316 ns;

        
        ----transmit 0xA5---------------------------------------------------------
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;

        
        ----transmit 0x5A---------------------------------------------------------
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;

                
        ----transmit 0xFF---------------------------------------------------------
        rxData <= '0';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;
        rxData <= '1';
        wait for BIT_TIME;

        wait;
    end process SIGNAL_DRIVER;


end UartRx_tb_ARCH;
 

 