library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--*****************************************************************************
--*
--* Name: UartRx_Basys3 Test Wrapper
--* Designer: Scott Tippens
--*
--*     Connected through USB-Serial to the Basys3 Board.  All 8-bit values 
--*     sent to board will display in binary on lower 8 LEDs.  Just connect
--*     via a terminal and start hitting keys.  Each key will send an 8-bit
--*     ASCII code to display.  Serial interface should be set for 115200 baud, 
--*     no parity, and 1 stop bit.
--*
--*****************************************************************************

entity UartRx_Basys3 is
    port(
        clk:   in   std_logic;
        btnD:  in   std_logic;
        RsRx:  in   std_logic;
        led:   out  std_logic_vector(7 downto 0)
        );
end UartRx_Basys3;



architecture UartRx_Basys3_ARCH of UartRx_Basys3 is

    ----general-definitions--------------------------------------------CONSTANTS--
    constant ACTIVE: std_logic := '1';
    constant CLOCK_FREQ:  integer := 100_000_000;
    constant BAUD_RATE:   integer := 115_200;

    
    ----connections--------------------------------------------------UUT-SIGNALS--
    signal dataReady:  std_logic;

    component UartRx
        generic (
            BAUD_RATE:  positive;
            CLOCK_FREQ: positive
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
            clock     => clk,
            reset     => btnD,
            rxData    => RsRx,
            dataReady => dataReady,
            dataOut   => led
            );


end UartRx_Basys3_ARCH;
 

 