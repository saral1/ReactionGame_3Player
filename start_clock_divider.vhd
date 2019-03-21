----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/29/2018 08:03:19 PM
-- Design Name: 
-- Module Name: start_clock_divider - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity start_clock_divider is
    PORT ( clk      : in  STD_LOGIC;
           reset    : in  STD_LOGIC;
           enable   : in  STD_LOGIC;
           add_en   : in  STD_LOGIC;
           add_mili: in STD_LOGIC_VECTOR (3 downto 0);
           add_ten_mili : in STD_LOGIC_VECTOR (3 downto 0);
           add_deci : in STD_LOGIC_VECTOR (3 downto 0);
           add_ten_deci : in STD_LOGIC_VECTOR (3 downto 0);
           
           start : out STD_LOGIC;
           led1 : out STD_LOGIC
           );
end start_clock_divider;

architecture Behavioral of start_clock_divider is
-- Signals:
signal hundredhertz : STD_LOGIC;
signal onehertz, tensseconds, onesminutes, singlesec : STD_LOGIC;
signal singleSeconds, singleMinutes : STD_LOGIC_VECTOR(3 downto 0);
signal tenSeconds, tensMinutes : STD_LOGIC_VECTOR(3 downto 0);

signal miliSec, tensMiliSec, deciSec, tensDeciSec : STD_LOGIC_VECTOR(3 downto 0);

signal falseEnable : STD_LOGIC;
signal start_o : STD_LOGIC;
signal led1_o : STD_LOGIC;

-- Components declarations
component downcounter is
   Generic ( period : integer:= 4;
             WIDTH  : integer:= 3
           );
      PORT ( clk : in  STD_LOGIC;
             reset : in  STD_LOGIC;
             enable : in  STD_LOGIC;
             
             zero : out  STD_LOGIC;
             value: out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
             
             add_en :in STD_LOGIC;
             amount : in STD_LOGIC_VECTOR(3 downto 0)
           );
end component;

component upcounter is
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
   
   oneKHzClock: upcounter
   generic map(
               --period => (100000),   -- divide by 100_000_000 to divide 100 MHz down to 1 Hz 
                 period => (80000),
--               period => (10),   -- divide by 100_000_000 to divide 100 MHz down to 1 Hz    
               WIDTH  => 17             -- 28 bits are required to hold the binary value of 101111101011110000100000000
              )
   PORT MAP (
               clk    => clk,
               reset  => reset,
               enable => falseEnable,
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
               value  => singleSeconds, -- binary value of seconds we decode to drive the 7-segment display        
               
               add_en => add_en,
               amount => add_mili
            );
   
-- Students fill in the VHDL code between these two lines
-- The missing code is instantiations of upcounter (like above) as needed.
-- Take a hint from the clock_divider entity description's port map.
--==============================================
    tensSecondsClock: downcounter
       generic map(
                  -- period => (6),   -- Counts numbers between 0 and 9 -> that's 10 values!
                   period => (9),
                   WIDTH  => 4
                  )
       PORT MAP (
                   clk    => clk,
                   reset  => reset,
                   enable => singlesec,
                   zero   => tensseconds,
                   value  => tenSeconds, -- binary value of seconds we decode to drive the 7-segment display        
                   
                   add_en => add_en,
                   amount => add_ten_mili
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
                       value  => singleMinutes, -- binary value of seconds we decode to drive the 7-segment display        
                       
                       add_en => add_en,
                       amount => add_deci
           );
                        
                        
        tensMinClock: downcounter
           generic map(
                       --period => (6),   -- Counts numbers between 0 and 9 -> that's 10 values!
                       period => (9),
                       WIDTH  => 4
                      )
           PORT MAP (
                       clk    => clk,
                       reset  => reset,
                       enable => onesminutes,
                       zero   => open,
                       value  => tensMinutes, -- binary value of seconds we decode to drive the 7-segment display        
                       
                       add_en => add_en,
                       amount => add_ten_deci
            );
                   
--============================================== 
   
   -- Connect internal signals to outputs
   start_process: process
   begin
        falseEnable <= enable;
        if (singleSeconds="0000" and tenSeconds ="0000" and singleMinutes = "0000" and tensMinutes= "0000") then
            falseEnable <= '0';
            start_o <= '1';
            led1_o <= '1';
        else 
            start_o <= '0';
            led1_o <= '0';
        end if;
   end process;
--============================================== 
   start <= start_o;
   led1 <= led1_o;
   
END Behavioral;
