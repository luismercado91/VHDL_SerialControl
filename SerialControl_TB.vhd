library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SerialControl_TB is
end SerialControl_TB;

architecture SerialControl_TB_ARCH of SerialControl_TB is

    -- Constants
    constant CLOCK_PERIOD : time := 10 ns;
    constant ACTIVE : std_logic := '1';
    constant INACTIVE : std_logic := '0';

    -- Component Declaration for SerialControl
    component SerialControl
        port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            serialIn : in STD_LOGIC;
            leds : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    -- Signals to connect to the Unit Under Test (UUT)
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal serialIn : STD_LOGIC := '1';
    signal leds : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal dataReady : STD_LOGIC := '0';
    signal dataOut : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Commands for LED On and Off
    constant LED_ON_COMMAND : std_logic_vector(7 downto 0) := X"4C";  -- ASCII 'L'
    constant LED_OFF_COMMAND : std_logic_vector(7 downto 0) := X"4D"; -- ASCII 'M'
    
   -- Function to convert integer to ASCII (for LED number 0-9)
    function getAsciiDigit(value: integer) return STD_LOGIC_VECTOR is
        variable ascii_value: STD_LOGIC_VECTOR(7 downto 0);
    begin
        -- Ensure the input is within the range 0-9
        if value >= 0 and value <= 9 then
            ascii_value := std_logic_vector(to_unsigned(value + 48, 8));  -- '0' ASCII is 48
        else
            ascii_value := X"30";  -- Default to ASCII '0' if out of range
        end if;
        return ascii_value;
    end function;

begin

    -- Instantiate the SerialControl Unit Under Test (UUT)
    UUT: SerialControl
        port map (
            clk => clk,
            reset => reset,
            serialIn => serialIn,
            leds => leds
        );

    -- Clock Generation Process: Generates a 100 MHz clock signal
    CLOCK_GEN: process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD / 2;
        clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process CLOCK_GEN;

    -- Reset Process: Initialize the system reset at the beginning of the simulation
    RESET_GEN: process
    begin
        reset <= ACTIVE;
        wait for 20 ns;
        reset <= INACTIVE;
        wait;
    end process RESET_GEN;

    -- Signal Driver Process: Sends commands to turn on and then turn off LEDs one at a time
    SIGNAL_DRIVER: process
        variable count: integer range 0 to 15;
    begin
        -- Wait for reset to complete
        wait for 10 ns;

        -- Turn on LEDs one at a time using the "L" command
        count := 0;
        dataReady <= INACTIVE;  -- Initial state for dataReady
        for i in 0 to 15 loop
            -- Send LED on command "L"
            dataOut <= LED_ON_COMMAND;
            wait until rising_edge(clk);
            dataReady <= ACTIVE;
            wait until rising_edge(clk);
            dataReady <= INACTIVE;

            -- Wait between commands
            wait for 100 ns;

            -- Send LED number as ASCII
            dataOut <= getAsciiDigit(count);  -- Get the ASCII representation of the LED index
            wait until rising_edge(clk);
            dataReady <= ACTIVE;
            wait until rising_edge(clk);
            dataReady <= INACTIVE;

            count := count + 1;  -- Increment LED index
        end loop;

        -- Turn off LEDs one at a time using the "M" command
        count := 0;
        for i in 0 to 15 loop
            -- Send LED off command "M"
            dataOut <= LED_OFF_COMMAND;
            wait until rising_edge(clk);
            dataReady <= ACTIVE;
            wait until rising_edge(clk);
            dataReady <= INACTIVE;

            -- Wait between commands
            wait for 10 ns;

            -- Send LED number as ASCII
            dataOut <= getAsciiDigit(count);  -- Get the ASCII representation of the LED index
            wait until rising_edge(clk);
            dataReady <= ACTIVE;
            wait until rising_edge(clk);
            dataReady <= INACTIVE;

            count := count + 1;  -- Increment LED index
        end loop;

        wait;
    end process SIGNAL_DRIVER;

end SerialControl_TB_ARCH;

