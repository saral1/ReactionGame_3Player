-- This file needs editing by students

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_divider is
    PORT ( clk      : in  STD_LOGIC;
           reset    : in  STD_LOGIC;
           enable   : in  STD_LOGIC;
           sec_dig1 : out STD_LOGIC_VECTOR(3 downto 0);
           sec_dig2 : out STD_LOGIC_VECTOR(3 downto 0);
           min_dig1 : out STD_LOGIC_VECTOR(3 downto 0);
           min_dig2 : out STD_LOGIC_VECTOR(3 downto 0)
           );
end clock_divider;

architecture Behavioral of clock_divider is
-- Signals:
signal hundredhertz : STD_LOGIC;
signal onehertz, tensseconds, onesminutes, singlesec : STD_LOGIC;
signal singleSeconds, singleMinutes : STD_LOGIC_VECTOR(3 downto 0);
signal tenSeconds, tensMinutes : STD_LOGIC_VECTOR(3 downto 0);

-- Components declarations
component downcounter is
   Generic ( period : integer:= 4;
             WIDTH  : integer:= 3
           );
      PORT (  clk    : in  STD_LOGIC;
              reset  : in  STD_LOGIC;
              enable : in  STD_LOGIC;
              zero   : out STD_LOGIC;
              value  : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
           );
end component;

BEGIN
   
   oneHzClock: downcounter
   generic map(
               period => (100000000),   -- divide by 100_000_000 to divide 100 MHz down to 1 Hz 
--               period => (10),   -- divide by 100_000_000 to divide 100 MHz down to 1 Hz    
               WIDTH  => 28             -- 28 bits are required to hold the binary value of 101111101011110000100000000
              )
   PORT MAP (
               clk    => clk,
               reset  => reset,
               enable => enable,
               zero   => onehertz, -- this is a 1 Hz clock signal
               value  => open  -- Leave open since we won't display this value
            );
   
   singleSecondsClock: downcounter
   generic map(
--               period => (10),   -- Counts numbers between 0 and 9 -> that's 10 values!
               period => (9),
               WIDTH  => 4
              )
   PORT MAP (
               clk    => clk,
               reset  => reset,
               enable => onehertz,
               zero   => singlesec,
               value  => singleSeconds -- binary value of seconds we decode to drive the 7-segment display        
            );
   
-- Students fill in the VHDL code between these two lines
-- The missing code is instantiations of upcounter (like above) as needed.
-- Take a hint from the clock_divider entity description's port map.
--==============================================
    tensSecondsClock: downcounter
       generic map(
                  -- period => (6),   -- Counts numbers between 0 and 9 -> that's 10 values!
                   period => (5),
                   WIDTH  => 4
                  )
       PORT MAP (
                   clk    => clk,
                   reset  => reset,
                   enable => singlesec,
                   zero   => tensseconds,
                   value  => tenSeconds -- binary value of seconds we decode to drive the 7-segment display        
            );
            
            
      singleMinClock: downcounter
           generic map(
                       --period => (10),   -- Counts numbers between 0 and 9 -> that's 10 values!
                       period => (9),
                       WIDTH  => 4
                      )
           PORT MAP (
                       clk    => clk,
                       reset  => reset,
                       enable => tensseconds,
                       zero   => onesminutes,
                       value  => singleMinutes -- binary value of seconds we decode to drive the 7-segment display        
           );
                        
                        
        tensMinClock: downcounter
           generic map(
                       --period => (6),   -- Counts numbers between 0 and 9 -> that's 10 values!
                       period => (5),
                       WIDTH  => 4
                      )
           PORT MAP (
                       clk    => clk,
                       reset  => reset,
                       enable => onesminutes,
                       zero   => open,
                       value  => tensMinutes -- binary value of seconds we decode to drive the 7-segment display        
            );
                   
--============================================== 
   
   -- Connect internal signals to outputs
   sec_dig1 <= singleSeconds;
   
-- Students fill in the VHDL code between these two lines
-- The missing code is internal signal conections to outputs as needed, following the pattern of the previous statement.
-- Take a hint from the signal declarartions below architecture.
--==============================================
   sec_dig2 <= tenSeconds;
   min_dig1 <= singleMinutes;
   min_dig2 <= tensMinutes;
--============================================== 

   
END Behavioral;