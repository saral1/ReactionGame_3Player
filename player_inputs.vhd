----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/29/2018 08:57:34 PM
-- Design Name: 
-- Module Name: player_inputs - Behavioral
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

entity player_inputs is
   port(
            clk  : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            p1 : in  STD_LOGIC;
            p2 : in  STD_LOGIC;
            p3 : in  STD_LOGIC;
            start_round : in  STD_LOGIC;
            
            p1_out : out STD_LOGIC;
            p2_out : out STD_LOGIC;
            p3_out : out STD_LOGIC;
            start_round_out : out STD_LOGIC
          );
end player_inputs;

architecture Behavioral of player_inputs is

signal QS1        : STD_LOGIC;  
signal loadS1        : STD_LOGIC;    

signal QS10        : STD_LOGIC;  
signal loadS10        : STD_LOGIC;   

signal QM1        : STD_LOGIC;  
signal loadM1        : STD_LOGIC;   

signal QM10        : STD_LOGIC;  
signal loadM10        : STD_LOGIC;  



BEGIN
p1_process: process(clk,loadS1) begin
    if (rising_edge(clk)) then 
        QS1 <= p1; 
    end if;
    loadS1 <= p1 and (not QS1);
end process;

p2_process: process(clk,loadS10) begin
    if (rising_edge(clk)) then 
        QS10 <= p2; 
    end if;
    loadS10 <= p2 and (not QS10);
end process;
    
p3_process: process(clk,loadM1) begin
    if (rising_edge(clk)) then 
        QM1 <= p3; 
    end if;
    loadM1 <= p3 and (not QM1);
end process;

new_round_process: process(clk,loadM10) begin
    if (rising_edge(clk)) then 
        QM10 <= start_round; 
    end if;
    loadM10 <= start_round and (not QM10);
end process;

p1_out <= loadS1;
p2_out <= loadS10;
p3_out <= loadM1;
start_round_out <= loadM10;    
    
END BEHAVIORAL;
