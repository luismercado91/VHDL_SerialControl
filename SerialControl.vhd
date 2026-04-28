--*****************************************************************************************

--*

--* Name: FinalProject

--* Designers: Braiden Gnagey & Rachnicha Rojjhanarittikorn & Luis Mercado

--* Kennesaw State University

--* 11/**/2024

--* For the purpose of reading reading inputs over serial

--* Must connect to board using a program such as putty and then type the folling commands

--* 'L' followed by a two digit number, 00 to 15, turns corresponding LED on

--* 'M' followed by a two digit number, 00 to 15, turns corresponding LED off

--*

--*****************************************************************************************
 
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

use IEEE.numeric_std.all;
 
entity SerialControl is

    Port (

        clock : in STD_LOGIC;               -- Clock signal

        reset : in STD_LOGIC;               -- System reset

        dataOut : in STD_LOGIC_VECTOR(7 downto 0);                  -- Serial input signal

        dataReady : in std_logic;

        leds : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0') -- LED output

    );

end SerialControl;
 
architecture SerialControl_ARCH of SerialControl is

    ----general definitions--------------------------------------CONSTANTS

    constant ACTIVE : std_logic := '1';

    -- LED control signals

    signal ledOnEn, ledOffEn : STD_LOGIC;               -- Enable signals for turning LEDs on or off

    --signal ledValue : STD_LOGIC_VECTOR(3 downto 0); -- integer indicating which LED to control
 
    -- Internal signals for state machine and digit storage

    signal commandEn, tensEn, onesEn : STD_LOGIC;    -- Enables for different commands

    signal firstDigit, secondDigit : STD_LOGIC_VECTOR(7 downto 0); -- Digit values for LED selection

    signal letter : character;

    ----state-machine-declarations---------------------------------SIGNALS

    type States_t is(IDLE, LATCH_COMMAND, WAIT_FOR_TENS, LATCH_TENS, WAIT_FOR_ONES, LATCH_ONES, EXECUTE_COMMAND);

    signal currentState: States_t;

    signal nextState: States_t;

	signal ledValue: integer range 0 to 15;

	signal ledState : std_logic_vector (15 downto 0) := (others => '0');

    ----Serial to integer declarations---------------------------CONSTANTS

	constant CHAR_0: std_logic_vector(7 downto 0) := X"30";

	constant CHAR_1: std_logic_vector(7 downto 0) := X"31";

	constant CHAR_2: std_logic_vector(7 downto 0) := X"32";

	constant CHAR_3: std_logic_vector(7 downto 0) := X"33";

	constant CHAR_4: std_logic_vector(7 downto 0) := X"34";

	constant CHAR_5: std_logic_vector(7 downto 0) := X"35";

	constant CHAR_6: std_logic_vector(7 downto 0) := X"36";

	constant CHAR_7: std_logic_vector(7 downto 0) := X"37";

	constant CHAR_8: std_logic_vector(7 downto 0) := X"38";

	constant CHAR_9: std_logic_vector(7 downto 0) := X"39";

	signal digits: std_logic_vector(15 downto 0);

 


begin

    --===============================================================PROCESS

    --  State register

    --======================================================================

    STATE_REGISTER: PROCESS(reset, clock)

    begin

        if reset = ACTIVE then

            currentState <= IDLE;

        elsif rising_edge(clock) then

            currentState <= nextState;

        end if;

    end process;

    --===============================================================PROCESS

    --  State Transistions

    --======================================================================

--    STATE_TRANSITIONS: process(dataReady, dataOut, letter)

--    begin

--        commandEn <= not ACTIVE;

--        tensEn <= not ACTIVE;

--        onesEn <= not ACTIVE;

--        ledOnEn <= not ACTIVE;

--        ledOffEn <= not ACTIVE;

--        case currentState is

--            when IDLE =>

--                if dataReady = ACTIVE then

--                    if dataOut = X"4C" or dataOut = X"4D" then

--                        nextState <= LATCH_COMMAND;

--                    else

--                        nextState <= IDLE;

--                    end if;

--                else

--                    nextState <= IDLE;

--                end if;

--            when LATCH_COMMAND => --'L' or 'M' gets stored

--                commandEn <= ACTIVE;

--                nextState <= WAIT_FOR_TENS;

--            when WAIT_FOR_TENS =>

--                if dataReady = ACTIVE then

--                    if dataOut = CHAR_0 or dataOut = CHAR_1 then -- has to be 0 or 1 to advance state

--                        nextState <= LATCH_TENS;

--                    end if;

--                else

--                    nextState <= IDLE;

--                end if;

--            when LATCH_TENS =>

--                tensEn <= ACTIVE;

--                nextState <= WAIT_FOR_ONES;

--            when WAIT_FOR_ONES =>

--                if dataReady = ACTIVE then

--                    if dataOut >= CHAR_0 and dataOut <= CHAR_9 then

--                        nextState <= LATCH_ONES;

--                    else

--                        nextState <= IDLE;

--                    end if;

--                end if;

--            when LATCH_ONES =>

--                onesEn <= ACTIVE;

--                nextState <= EXECUTE_COMMAND;

--            when EXECUTE_COMMAND =>

--                if letter = 'L' then

--                    ledOnEn <= ACTIVE;

--                elsif letter = 'M' then

--                    ledOffEn <= ACTIVE;

--                end if;

--                nextState <= IDLE;

--        end case;

--    end process;
 
 
 
STATE_TRANSITIONS: process(currentState, dataReady, dataOut, letter)

begin

    case currentState is

        when IDLE =>

            if dataReady = ACTIVE then

                if dataOut = X"4C" or dataOut = X"4D" then  -- 'L' or 'M'

                    nextState <= LATCH_COMMAND;

                else

                    nextState <= IDLE;

                end if;

            else

                nextState <= IDLE;

            end if;

        when LATCH_COMMAND =>

            nextState <= WAIT_FOR_TENS;

        when WAIT_FOR_TENS =>

            if dataReady = ACTIVE then

                if dataOut = CHAR_0 or dataOut = CHAR_1 then

                    nextState <= LATCH_TENS;

                else

                    nextState <= IDLE;

                end if;

            else

                nextState <= WAIT_FOR_TENS;

            end if;

        when LATCH_TENS =>

            nextState <= WAIT_FOR_ONES;

        when WAIT_FOR_ONES =>

            if dataReady = ACTIVE then

                if dataOut >= CHAR_0 and dataOut <= CHAR_9 then

                    nextState <= LATCH_ONES;

                else

                    nextState <= IDLE;

                end if;

            else

                nextState <= WAIT_FOR_ONES;

            end if;

        when LATCH_ONES =>

            nextState <= EXECUTE_COMMAND;

        when EXECUTE_COMMAND =>

            nextState <= IDLE;

        when others =>

            nextState <= IDLE;

    end case;

end process;

 


--======================================================================

--  Control Signal Generation (Synchronous)

--======================================================================

CONTROL_SIGNALS: process(clock, reset)

begin

    if reset = ACTIVE then

        commandEn <= '0';

        tensEn    <= '0';

        onesEn    <= '0';

        ledOnEn   <= '0';

        ledOffEn  <= '0';

    elsif rising_edge(clock) then

        -- Default assignments

        commandEn <= '0';

        tensEn    <= '0';

        onesEn    <= '0';

        ledOnEn   <= '0';

        ledOffEn  <= '0';

        -- Generate enable signals based on the current state

        case currentState is

            when LATCH_COMMAND =>

                commandEn <= ACTIVE;

            when LATCH_TENS =>

                tensEn <= ACTIVE;

            when LATCH_ONES =>

                onesEn <= ACTIVE;

            when EXECUTE_COMMAND =>

                if letter = 'L' then

                    ledOnEn <= ACTIVE;

                elsif letter = 'M' then

                    ledOffEn <= ACTIVE;

                end if;

            when others =>

                null;  -- No action needed

        end case;

    end if;

end process;
 
 
    --======================================================================

    --  COMMAND_REG

    --  Decodes commands 'L' (Turn on LED) and 'M' (Turn off LED)

    --======================================================================

    COMMAND_REG: process(clock, reset)

    begin

        if reset = ACTIVE then

            letter <= ' ';

        elsif rising_edge(clock) then

            if commandEn = ACTIVE then

                -- Using ASCII codes: "L" = 0x4C, "M" = 0x4D

                if dataOut = X"4C" then           -- ASCII for 'L'

                    letter <= 'L';

                elsif dataOut = X"4D" then        -- ASCII for 'M'

                    letter <= 'M';

                end if;

            end if;

        end if;

    end process;
 
    --======================================================================

    --  TENS_DIGIT

    --  Latches the tens digit when tensEn is enabled

    --======================================================================

    TENS_DIGIT: process(clock, reset)

    begin

        if reset = ACTIVE then

            firstDigit <= (others => '0');

        elsif rising_edge(clock) then

            if tensEn = ACTIVE then

                firstDigit <= dataOut;

            end if;

        end if;

    end process;
 
    --======================================================================

    --  ONES_DIGIT

    --  Latches the ones digit when onesEn is enabled

    --======================================================================

    ONES_DIGIT: process(clock, reset)

    begin

        if reset = ACTIVE then

            secondDigit <= (others => '0');

        elsif rising_edge(clock) then

            if onesEn = ACTIVE then

                secondDigit <= dataOut;

            end if;

        end if;

    end process;
 
    --======================================================================

    --  SERIAL_TO_INTEGER

    --  Converts ASCII digits to an integer for led position

    --======================================================================

	digits <= firstDigit & secondDigit;

	SERIAL_TO_INTEGER: with digits select

		ledValue  <= 0 when CHAR_0 & CHAR_0,

						 1 when CHAR_0 & CHAR_1,

						 2 when CHAR_0 & CHAR_2,

					   	 3 when CHAR_0 & CHAR_3,

						 4 when CHAR_0 & CHAR_4,

						 5 when CHAR_0 & CHAR_5,

						 6 when CHAR_0 & CHAR_6,

						 7 when CHAR_0 & CHAR_7,

						 8 when CHAR_0 & CHAR_8,

						 9 when CHAR_0 & CHAR_9,

						 10 when CHAR_1 & CHAR_0,

						 11 when CHAR_1 & CHAR_1,

						 12 when CHAR_1 & CHAR_2,

						 13 when CHAR_1 & CHAR_3,

						 14 when CHAR_1 & CHAR_4,

						 15 when others;

    --======================================================================

    --  LED_DRIVER

    --  Controls the LEDs based on binaryValue, ledOnEn, and ledOffEn

    --======================================================================

--    LED_DRIVER: process(clock, reset)

--    begin

--        if reset = ACTIVE then

--            leds <= (others => '0'); -- Reset all LEDs

--        elsif rising_edge(clock) then

--            if ledOnEn = ACTIVE  and ledOffEn = not ACTIVE then

--                leds(ledValue) <= '1'; -- turn on specified LED

--            elsif ledOffEn = ACTIVE and ledOnEn = not ACTIVE then

--                leds(ledValue) <= '0'; -- Turn off specified LED

--            end if;

--        end if;

--    end process;

    LED_DRIVER: process(clock, reset)

        --variable temp_leds: STD_LOGIC_VECTOR(15 downto 0);

    begin

        if reset = ACTIVE then

            ledState <= (others => '0');

            --leds <= (others => '0'); -- Reset all LEDs

        elsif rising_edge(clock) then

            --temp_leds := leds; -- Copy current LED states

            if ledOnEn = ACTIVE and ledOffEn = not ACTIVE then

                ledState(ledValue) <= '1'; -- Turn on specified LED

            elsif ledOffEn = ACTIVE and ledOnEn = not ACTIVE then

                ledState(ledValue) <= '0'; -- Turn off specified LED

            end if;

            --leds <= temp_leds; -- Update LEDs with modified state

        end if;

    end process;

    leds<= ledState;
 
end SerialControl_ARCH;
 