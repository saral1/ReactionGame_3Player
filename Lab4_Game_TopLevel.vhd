library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Lab4_Game_TopLevel is
    port(
          clk           : in  STD_LOGIC;
          reset         : in  STD_LOGIC;
          p1            : in  STD_LOGIC;
          p2            : in  STD_LOGIC;
          p3            : in  STD_LOGIC;
          start_game    : in STD_LOGIC;
          start_round   : in  STD_LOGIC;
          
          CA            : out STD_LOGIC;
          CB            : out STD_LOGIC;
          CC            : out STD_LOGIC;
          CD            : out STD_LOGIC;
          CE            : out STD_LOGIC;
          CF            : out STD_LOGIC;
          CG            : out STD_LOGIC;
          DP            : out STD_LOGIC;
          AN1           : out STD_LOGIC;
          AN2           : out STD_LOGIC;
          AN3           : out STD_LOGIC;
          AN4           : out STD_LOGIC;
          
          p1Led         : out STD_LOGIC;
          p2Led         : out STD_LOGIC;
          p3Led         : out STD_LOGIC;
          led1          : out STD_LOGIC;
          led2          : out STD_LOGIC;
          led3          : out STD_LOGIC;
          led4          : out STD_LOGIC;
          led5          : out STD_LOGIC;
          led6          : out STD_LOGIC;
          led7          : out STD_LOGIC;
          led8          : out STD_LOGIC;
          led9          : out STD_LOGIC;
          led10         : out STD_LOGIC;
          musicout      : out std_logic
          );
end Lab4_Game_TopLevel;

architecture Behavioral of Lab4_Game_TopLevel is

--state
type stateType is (
	s1,
	s2,
	s3,
	s4, 
	s5,
	s6,
	s7,
	s8
	);
signal currentState, nextState : stateType;

--game
signal p1_score, p2_score,p3_score : integer;
signal p1_o,p2_o,p3_o : STD_LOGIC;
signal start_round_out : STD_LOGIC;
signal p1_win,p2_win,p3_win: STD_LOGIC;
signal reset_t,enable_led, reset_timer : STD_LOGIC;
signal reset_random_start,reset_led: STD_LOGIC;
signal enable, start_r, winner,start_o : STD_LOGIC;
signal add_en, count_time, up_en : STD_LOGIC;
signal add_ten_deci,add_deci,add_ten_mili,add_mili: STD_LOGIC_VECTOR(3 downto 0);
signal winM,wintM,winD,wintD : STD_LOGIC_VECTOR (3 downto 0);
signal disp0,disp1,disp2,disp3 : STD_LOGIC_VECTOR (3 downto 0);
signal winning_player : STD_LOGIC_VECTOR (2 downto 0);

--display
signal in_DP, out_DP : STD_LOGIC;
signal an_i, digit_to_display, digit_select_i : STD_LOGIC_VECTOR(3 downto 0);
signal CA_i, CB_i, CC_i, CD_i, CE_i, CF_i, CG_i : STD_LOGIC;

--led and music
signal led1_o : STD_LOGIC;
signal speaker, speaker_o : STD_LOGIC;


component music is
    Port ( CLK : in STD_LOGIC;
           speaker : out std_logic
           );
end component;

component player_inputs is
    port( clk  : in  STD_LOGIC;       
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
end component;

component enable_clock_divider is
    port( clk      : in  STD_LOGIC;
          reset    : in  STD_LOGIC;
          enable   : in  STD_LOGIC;
          
          start_out  : out STD_LOGIC 
          );                       
end component;

component reactionTime_clock_divider is 
    PORT (  clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            enable   : in  STD_LOGIC;
       
            mili_seconds : out STD_LOGIC_VECTOR(3 downto 0);    
            ten_mili_seconds : out STD_LOGIC_VECTOR(3 downto 0);
            deci_seconds : out STD_LOGIC_VECTOR(3 downto 0);
            ten_deci_seconds : out STD_LOGIC_VECTOR(3 downto 0)      
         );
end component;

component start_clock_divider is
    PORT ( clk      : in  STD_LOGIC;
           reset    : in  STD_LOGIC;
           enable   : in  STD_LOGIC;
           add_en: in STD_LOGIC;                 
           add_mili : in STD_LOGIC_VECTOR (3 downto 0); 
           add_ten_mili : in STD_LOGIC_VECTOR (3 downto 0);
           add_deci : in STD_LOGIC_VECTOR (3 downto 0);
           add_ten_deci : in STD_LOGIC_VECTOR (3 downto 0);
           
           start : out STD_LOGIC;
           led1 : out STD_LOGIC
           );
    end component;
    
component seven_segment_digit_selector is   
    PORT ( clk          : in  STD_LOGIC;   
           digit_select : out  STD_LOGIC_VECTOR (3 downto 0);
           an_outputs : out  STD_LOGIC_VECTOR (3 downto 0);   
           reset        : in  STD_LOGIC   
          );   
end component;   
    
component digit_multiplexor is
    PORT(   sec_dig1 : in  STD_LOGIC_VECTOR(3 downto 0);   
            sec_dig2 : in  STD_LOGIC_VECTOR(3 downto 0);   
            min_dig1 : in  STD_LOGIC_VECTOR(3 downto 0);   
            min_dig2 : in  STD_LOGIC_VECTOR(3 downto 0);   
            selector   : in  STD_LOGIC_VECTOR(3 downto 0);   
       
            time_digit : out STD_LOGIC_VECTOR(3 downto 0)   
     );   
end component;   
    
component seven_segment_decoder is 
     PORT(  CA    : out STD_LOGIC;   
            CB    : out STD_LOGIC;   
            CC    : out STD_LOGIC;   
            CD    : out STD_LOGIC;   
            CE    : out STD_LOGIC;   
            CF    : out STD_LOGIC;   
            CG    : out STD_LOGIC;   
            DP    : out STD_LOGIC;   
            
            dp_in : in STD_LOGIC;   
            data  : in  STD_LOGIC_VECTOR (3 downto 0)   
          );   
end component;   
    
 
BEGIN

GAME_MUSIC: music 
    port map (
            CLK => clk,
            speaker => speaker
            );   

DISPLAY_WINNER: enable_clock_divider
    port map(clk => clk,
             reset => reset_timer,
             enable => enable_led,
             start_out => start_o
             );

RANDOM_COUNTDOWN_STARTROUND : start_clock_divider
    port map( clk => clk,
              reset => reset_random_start,
              enable => enable,
              add_en => add_en,   
              add_mili => add_mili,
              add_ten_mili => add_ten_mili,
              add_deci => add_deci,
              add_ten_deci => add_ten_deci,
              
              start => start_r,
              led1=> led1_o
              );

FIND_WINNER : reactionTime_clock_divider
    port map ( clk =>clk,
               reset => reset_t,
               enable=> up_en,
               
               mili_seconds => winM,
               ten_mili_seconds => wintM,
               deci_seconds => winD,
               ten_deci_seconds => wintD
               );


PLAYERS_INPUTS : player_inputs
    port map( clk=> clk,
              reset => reset,
              p1 => p1,
              p2 => p2,
              p3 => p3,
              start_round => start_round,
              
              p1_out  => p1_o,
              p2_out => p2_o,
              p3_out => p3_o,
              start_round_out => start_round_out
             );
         
DIGIT_MUX : digit_multiplexor                       
    PORT MAP(                                             
              sec_dig1 => disp0,                          
              sec_dig2 => disp1,                          
              min_dig1 => disp2,                          
              min_dig2 => disp3,                          
              selector   => digit_select_i,               
              time_digit => digit_to_display                                                              
            );  
                                                  
SELECTOR : seven_segment_digit_selector               
    PORT MAP( clk          => clk,                        
              digit_select => digit_select_i,             
              an_outputs   => an_i,                       
              reset        => reset                       
            );                                            
         
DECODER: seven_segment_decoder              
     PORT MAP( CA   => CA_i,                       
               CB   => CB_i,                      
               CC   => CC_i,                   
               CD   => CD_i,                   
               CE   => CE_i,                   
               CF   => CF_i,                       
               CG   => CG_i,                       
               DP   => out_DP,                     
               dp_in => in_DP,                     
               data => digit_to_display            
             );                                    
     
FSM_process : process(currentState,p1_o,p2_o, p3_o,start_round_out,start_r, start_game)
begin
    case currentState is
        when s5 =>
            if start_game = '1' then
                nextstate <= s1;
                up_en <='0';
                enable <= '0';
                count_time <= '1';
                p1_win <= '0';
                p2_win <= '0';
                p3_win <= '0';
                enable_led <='0';
                add_en <= '0';
                winning_player <= "000";
                reset_led <='1';
            else
                nextstate <= s5;
                up_en <= '0';
                enable <= '0';       
                count_time <= '1';        
                p1_win <= '0';    
                p2_win <= '0';    
                p3_win <= '0';  
                enable_led <='0';  
                add_en <= '0';   
                winning_player <= "000";
                reset_led <='1';
            end if;        
    
        when s1 => 
            if start_round_out='1' then
                nextstate <= s2;
                up_en <= '0';
                enable <= '1';
                count_time  <= '1';
                p1_win <= '0';
                p2_win <= '0';
                p3_win <= '0';
                enable_led <='0';
                add_en <= '0';
                winning_player <= "000";
                reset_led <='0';
            else
                nextstate <= s1;
                up_en <='0';
                enable <= '0';
                count_time  <= '0';
                p1_win <= '0';
                p2_win <= '0';
                p3_win <= '0';
                enable_led <='0';
                add_en <= '0';
                winning_player <= "000";
                reset_led <='0';
            end if;
            
        when s2 =>
            if start_r ='1' then
                nextstate <= s3;
                up_en <='1';
                enable <= '0';         
                count_time  <= '0';         
                p1_win <= '0';
                p2_win <= '0';
                p3_win <= '0';
                enable_led <='0';
                add_en <= '0';     
                winning_player <= "000";   
                reset_led <='0';      
            else
                nextstate <= s2;
                up_en <='0';
                enable <= '1';         
                count_time  <= '1';         
                p1_win <= '0';
                p2_win <= '0';
                p3_win <= '0';
                enable_led <='0';
                add_en <= '0';     
                winning_player <= "000";  
                reset_led <='0';              
            end if;
            
        when s3 =>
            if p1_o ='1' then
                nextstate <= s6;
                up_en <='0';           
                enable <= '0';         
                count_time  <= '0';         
                p1_win <= '1';  
                p2_win <= '0';
                p3_win <= '0';
                enable_led <='0';
                add_en <= '0';     
                winning_player <= "001"; 
                reset_led <='0';
            elsif p2_o = '1' then
                nextstate <= s7; 
                up_en <='0';                     
                enable <= '0';                   
                count_time  <= '0';                   
                p1_win <= '0';   
                p2_win <= '1';         
                p3_win <= '0';    
                enable_led <='0';  
                add_en <= '0';               
                winning_player <= "010";      
                reset_led <='0';          
            elsif  p3_o = '1' then
                nextstate <= s8; 
                up_en <='0';              
                enable <= '0';            
                count_time  <= '0';            
                p1_win <= '0';
                p2_win <= '0';
                p3_win <= '1'; 
                enable_led <='0';  
                add_en <= '0';        
                winning_player <= "100";  
                reset_led <='0';     
            else
                nextstate <= s3; 
                up_en <='1';              
                enable <= '0';            
                count_time  <= '0';            
                p1_win <= '0';
                p2_win <= '0';   
                p3_win <= '0';  
                enable_led <='0'; 
                add_en <= '0';        
                winning_player <= "000";  
                reset_led <='0';          
            end if;
            
        when s6=>
            if start_o ='1' then
                nextstate <= s4; 
                up_en <='0';           
                enable <= '0';         
                count_time  <= '0';         
                p1_win <= '0';          
                p2_win <= '0';          
                p3_win <= '0';          
                enable_led <='0';       
                add_en <= '0';     
                winning_player <= "000"; 
                reset_led <='0';          
             else 
                nextstate <= s6; 
                up_en <='0';           
                enable <= '0';         
                count_time  <= '0';         
                p1_win <= '0';          
                p2_win <= '0';          
                p3_win <= '0';          
                enable_led <='1';       
                add_en <= '0';     
                winning_player <= "001";  
                reset_led <='0';       
            end if;
                
        when s7=>                  
            if start_o ='1' then             
                nextstate <= s4; 
                up_en <='0';              
                enable <= '0';            
                count_time  <= '0';            
                p1_win <= '0';             
                p2_win <= '0';             
                p3_win <= '0';             
                enable_led <='0';          
                add_en <= '0';        
                winning_player <= "000"; 
                reset_led <='0';           
             else                         
                nextstate <= s7;   
                up_en <='0';              
                enable <= '0';            
                count_time  <= '0';            
                p1_win <= '0';             
                p2_win <= '0';             
                p3_win <= '0';             
                enable_led <='1';          
                add_en <= '0';        
                winning_player <= "010";
                reset_led <='0';            
            end if;                       
        
        when s8=>                  
            if start_o ='1' then             
                nextstate <= s4; 
                up_en <='0';              
                enable <= '0';            
                count_time  <= '0';            
                p1_win <= '0';             
                p2_win <= '0';             
                p3_win <= '0';             
                enable_led <='0';          
                add_en <= '0';        
                winning_player <= "000";  
                reset_led <='0';          
             else                         
                nextstate <= s8;   
                up_en <='0';              
                enable <= '0';            
                count_time  <= '0';            
                p1_win <= '0';             
                p2_win <= '0';             
                p3_win <= '0';             
                enable_led <='1';          
                add_en <= '0';        
                winning_player <= "100"; 
                reset_led <='0';           
            end if;                                    
            
        when s4 =>
            if winner ='1' then
                nextstate <= s5; 
                up_en <='0';              
                enable <= '0';            
                count_time  <= '0';            
                p1_win <= '0';
                p2_win <= '0';   
                p3_win <= '0';  
                enable_led <='0'; 
                add_en <= '0';        
                winning_player <= "000";
                reset_led <='0';
            else 
                nextstate <= s1; 
                up_en <='0';           
                enable <= '0';         
                count_time  <= '0';         
                p1_win <= '0';
                p2_win <= '0';
                p3_win <= '0';
                enable_led <='0';
                add_en <= '1';     
                winning_player <= "000";  
                reset_led <='0';       
            end if;
            
        when others =>
            nextstate <= s5; 
            up_en <='0';           
            enable <= '0';         
            count_time  <= '0';         
            p1_win <= '0';
            p2_win <= '0';
            p3_win <= '0';
            enable_led <='0';
            add_en <= '0';      
            winning_player <= "000"; 
            reset_led <='1';         
    end case;
end process;
                
FSM_state_update_process : process(RESET,CLK)
begin
    if rising_edge(clk) then
     if reset = '1' then
        currentstate <= s5;
     else
        currentState <= nextState;
     end if;
    end if;
end process;
  
score_process : process( p1_win,p2_win,p3_win,reset,start_game,clk)
begin
    if rising_edge(clk) then
      if (reset = '1' or start_game ='1')then
          p1_score <= 0;
          p2_score <= 0;
          p3_score <= 0;
      elsif p1_win ='1' then
          p1_score <= p1_score +1;
      elsif p2_win='1' then
          p2_score <= p2_score +1;
      elsif p3_win ='1' then
          p3_score <= p3_score +1;
      else
          p1_score <= p1_score;
          p2_score <= p2_score;
          p3_score <= p3_score;
      end if;
    end if;
end process;
  
check_winner_process : process(winner,p1_score,p2_score,p3_score,clk)
begin
    if rising_edge(clk) then
      if (p1_score =3 or p2_score=3 or p3_score=3)  then
         winner <='1';
      else 
         winner <='0';
      end if;
    end if;
end process;
  
display_winner_process: process(winner,clk)
begin 
    if rising_edge (clk) then
      if winner = '1' then
          in_dp <= '1';
          disp1 <= "0000";
          disp2 <= "1011";
          disp3 <= "1010";
          if p1_score = 3 then
              disp0 <= "0001";
          elsif p2_score = 3 then
              disp0 <= "0010";
          elsif p3_score <= 3 then
              disp0 <= "0011";
          end if;
      else
          in_dp <= an_i(3);
          disp0 <= winM;
          disp1 <= wintM;
          disp2 <= winD;
          disp3 <= wintD;
      end if;
    end if;
end process;
 
music_process: process(currentState)
begin
     if currentState = s3 then
         speaker_o <= '0';
     else
         speaker_o <= speaker;
     end if;
end process;
 
reset_random_start <= reset or reset_led;
reset_timer <= not enable_led;
reset_t <= reset or count_time;

add_mili <= winM;
add_ten_mili <= wintM;
add_deci <= winD;
add_ten_deci <= wintD;

DP <= out_dp;    
CA <= CA_i;       
CB <= CB_i;       
CC <= CC_i;       
CD <= CD_i;       
CE <= CE_i;       
CF <= CF_i;       
CG <= CG_i;       
                   
                  
AN1 <= an_i(0);
AN2 <= an_i(1);
AN3 <= an_i(2);
AN4 <= an_i(3);

led1 <= led1_o;
led2 <= led1_o;
led3 <= led1_o;
led4 <= led1_o;
led5 <= led1_o;
led6 <= led1_o;
led7 <= led1_o;
led8 <= led1_o;
led9 <= led1_o;
led10 <= led1_o;

p1Led <= winning_player(0);
p2Led <= winning_player(1);
p3Led <= winning_player(2);

musicout <= speaker_o;
 
 
END Behavioral;
 