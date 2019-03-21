library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pulse_debounce is
    port(
            clk  : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            p_in_1 : in  STD_LOGIC;
            p_in_2 : in  STD_LOGIC;
            p_in_3 : in  STD_LOGIC;
            new_rnd_in : in  STD_LOGIC;
            p_out_1 : out STD_LOGIC;
            p_out_2 : out STD_LOGIC;
            p_out_3 : out STD_LOGIC;
            new_rnd_out : out STD_LOGIC
          );
end pulse_debounce;

architecture Behavioral of pulse_debounce is

signal QS1        : STD_LOGIC;  
signal loadS1        : STD_LOGIC;    

signal QS10        : STD_LOGIC;  
signal loadS10        : STD_LOGIC;   

signal QM1        : STD_LOGIC;  
signal loadM1        : STD_LOGIC;   

signal QM10        : STD_LOGIC;  
signal loadM10        : STD_LOGIC;  



BEGIN
p1: process(clk,loadS1) begin
    if (rising_edge(clk)) then 
        QS1 <= p_in_1; 
    end if;
    loadS1 <= p_in_1 and (not QS1);
end process;

p2: process(clk,loadS10) begin
    if (rising_edge(clk)) then 
        QS10 <= p_in_2; 
    end if;
    loadS10 <= p_in_2 and (not QS10);
end process;
    
p3: process(clk,loadM1) begin
    if (rising_edge(clk)) then 
        QM1 <= p_in_3; 
    end if;
    loadM1 <= p_in_3 and (not QM1);
end process;

new_round: process(clk,loadM10) begin
    if (rising_edge(clk)) then 
        QM10 <= new_rnd_in; 
    end if;
    loadM10 <= new_rnd_in and (not QM10);
end process;

p_out_1 <= loadS1;
p_out_2 <= loadS10;
p_out_3 <= loadM1;
new_rnd_out <= loadM10;    
    
END BEHAVIORAL;