library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity upcounter is
   Generic (  period : integer:= 4;
              WIDTH  : integer:= 3
           );
      PORT ( clk    : in  STD_LOGIC;
             reset  : in  STD_LOGIC;
             enable : in  STD_LOGIC;
             zero   : out STD_LOGIC;
             value  : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
           );
end upcounter;

architecture Behavioral of upcounter is
   signal current_count : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
--   signal zero_i        : STD_LOGIC;   
   
   constant max_count : STD_LOGIC_VECTOR(WIDTH-1 downto 0) := STD_LOGIC_VECTOR(to_unsigned(period - 1, WIDTH));
   constant zeros     : STD_LOGIC_VECTOR(WIDTH-1 downto 0) := (others => '0');
   
BEGIN
   
   count: process(clk,reset) begin
      if (rising_edge(clk)) then 
         if (reset = '1') then  -- Synchronous active-high reset
            current_count <= zeros;
            zero          <= '0';
         elsif (enable = '1') then  -- if counter is enabled, then
            if (current_count = max_count) then -- if reached max_count defined by period is reached, then
               current_count <= zeros; -- reset counter to zero
               zero          <= '1';  -- toggle zero output to 1
            else 
               current_count <= current_count + '1'; -- continue counting up
               zero          <= '0'; -- keep zero output to value zero
            end if;
         else 
            zero <= '0';
         end if;
      end if;
   end process;
   
   -- Connect internal signals to output
   value <= current_count;   
   
END Behavioral;
