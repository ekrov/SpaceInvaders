-- Listing 13.10
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity pong_top is
   port(
      clock, reset: in std_logic;
      btn: in std_logic_vector (1 downto 0);
      hsync, vsync: out std_logic;
      rgb: out   std_logic_vector (2 downto 0);
	  outred: out std_logic_vector(2 downto 0);
	  outgreen: out std_logic_vector(2 downto 0);
	  outblue: out std_logic_vector(1 downto 0);
	  PS2_CLK,PS2_DATA : in std_logic;
	  led: out std_logic_vector(7 downto 0)
   );
end pong_top;

architecture arch of pong_top is
   type state_type is (newgame, play,play_2p, newball, over);
   signal state_reg, state_next: state_type;	
   signal clk: std_logic;
	signal video_on, pixel_tick: std_logic;
   signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
   signal graph_on, gra_still, hit, miss: std_logic;
   signal text_on: std_logic_vector(3 downto 0);
   signal graph_rgb, text_rgb: std_logic_vector(2 downto 0);
   signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
   signal dig0, dig1: std_logic_vector(3 downto 0);
   signal d_inc, d_clr: std_logic;
   signal timer_tick, timer_start, timer_up: std_logic;
	signal timer_tick_2, timer_start_2, timer_up_2: std_logic;
   signal ball_reg, ball_next: unsigned(1 downto 0);
   signal ball: std_logic_vector(1 downto 0);
	signal CODEWORD: std_logic_vector(7 downto 0);
	signal debounce_out: std_logic; 
   signal died: std_logic;
   CONSTANT spacebar : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00101001";
   CONSTANT enter : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01011010";
   signal GameMode2: std_logic;


begin

   -- instantiate clock manager unit
	-- this unit converts the 25MHz input clock to the expected 50MHz clock
	ClockManager_unit: entity work.clockmanager 
	  port map(
		CLKIN_IN => clock,
		RST_IN => reset,
		CLK2X_OUT => clk,
		LOCKED_OUT => open);
	--ps2 keyboard
	timer_tick_2 <=  -- 60 Hz tick
      '1' when pixel_x="0000000000" and
               pixel_y="0000000000" else
      '0';
	timer_unit_2: entity work.timer_2
      port map(clk=>clk, reset=>reset,
               timer_tick=>timer_tick_2,
               timer_start=>timer_start_2,
               timer_up=>timer_up_2);
	
   keyboard_unit: entity work.ps2_keyboard
      port map(clk=>clk,reset=>reset, PS2_CLK=>ps2_clk,PS2_DATA=>ps2_data,ps2_code=>CODEWORD,debounce_out=>debounce_out);
	led<=CODEWORD;
	--led(7)<=debounce_out;
	
   -- instantiate video synchonization unit
   vga_sync_unit: entity work.vga_sync
      port map(clk=>clk, reset=>reset,
               hsync=>hsync, vsync=>vsync,
               pixel_x=>pixel_x, pixel_y=>pixel_y,
               video_on=>video_on, p_tick=>pixel_tick);
   -- instantiate text module
   ball <= std_logic_vector(ball_reg);  --type conversion
   text_unit: entity work.pong_text
      port map(clk=>clk, reset=>reset,
               pixel_x=>pixel_x, pixel_y=>pixel_y,
               dig0=>dig0, dig1=>dig1, ball=>ball,
               text_on=>text_on, text_rgb=>text_rgb);
   -- instantiate graph module
   graph_unit: entity work.pong_graph
      port map(clk=>clk, reset=>reset, btn=>btn,died=>died,
              pixel_x=>pixel_x, pixel_y=>pixel_y,
              gra_still=>gra_still,hit=>hit, miss=>miss,
              graph_on=>graph_on,rgb=>graph_rgb,keyboard_code=>CODEWORD,timer_up=>timer_up_2,attack_1_on=>'1',gamemode2=>GameMode2);
   -- instantiate 2 sec timer
   timer_tick <=  -- 60 Hz tick
      '1' when pixel_x="0000000000" and
               pixel_y="0000000000" else
      '0';
   timer_unit: entity work.timer
      port map(clk=>clk, reset=>reset,
               timer_tick=>timer_tick,
               timer_start=>timer_start,
               timer_up=>timer_up);
					
	
   
   -- instantiate 2-digit decade counter
   counter_unit: entity work.m100_counter
      port map(clk=>clk, reset=>reset,
               d_inc=>d_inc, d_clr=>d_clr,
               dig0=>dig0, dig1=>dig1);
   -- registers
   process (clk,reset)
   begin
      if reset='1' then
         state_reg <= newgame;
         ball_reg <= (others=>'0');
         rgb_reg <= (others=>'0');
      elsif (clk'event and clk='1') then
         state_reg <= state_next;
         ball_reg <= ball_next;
         if (pixel_tick='1') then
           rgb_reg <= rgb_next;
         end if;
      end if;
   end process;
   -- fsmd next-state logic
   process(btn,hit,miss,timer_up,state_reg,
           ball_reg,ball_next, CODEWORD)
   begin
      gra_still <= '1';
      timer_start <='0';
      d_inc <= '0';
      d_clr <= '0';
      died<='0';
      GameMode2<='0';

      state_next <= state_reg;
      ball_next <= ball_reg;
      case state_reg is
         when newgame =>
            ball_next <= "11";    -- three balls
            d_clr <= '1';         -- clear score
            died<='0';
            -- if (btn /= "00") then -- button pressed
            if (CODEWORD =enter) then -- button pressed
               state_next <= play;
            end if;
            if(CODEWORD=spacebar)then
               state_next <= play_2p;
            end if;
         when play =>
            gra_still <= '0';    -- animated screen
            if hit='1' then
               d_inc <= '1';     -- increment score
               
            elsif miss='1' then
               ball_next <= ball_reg - 1;
            elsif (ball_reg=0) then
               state_next <= over;

--                  state_next <= over;
--            elsif miss='1' then
--               if (ball_reg=0) then
--                  state_next <= over;
--               else
--                  state_next <= newball;
--               end if;
--               timer_start <= '1';  -- 2 sec timer
--               ball_next <= ball_reg - 1;
            end if;
         when play_2p=>
            GameMode2<='1';
            gra_still <= '0';    -- animated screen
            if hit='1' then
               d_inc <= '1';     -- increment score
            elsif miss='1' then
               ball_next <= ball_reg - 1;
            elsif (ball_reg=0) then
               state_next <= over;
            end if;
         when newball =>
            -- wait for 2 sec and until button pressed
            if  timer_up='1' and (btn /= "00") then
              state_next <= play;
            end if;
         when over =>
            died<='1';

            -- wait for 2 sec to display game over
            if timer_up='1' then
                state_next <= newgame;
            end if;
       end case;
   end process;
   -- rgb multiplexing circuit
   process(state_reg,video_on,graph_on,graph_rgb,
           text_on,text_rgb)
   begin
      if video_on='0' then
         rgb_next <= "000"; -- blank the edge/retrace
      else
         -- display score, rule or game over
         -- if (text_on(2)='1') or
         --    (state_reg=newgame and text_on(1)='1') or -- rule
         --    (state_reg=over and text_on(0)='1') or 
         --    (text_on(3)='1') then
         if (state_reg=newgame and text_on(1)='1') or -- rule
            (state_reg=over and text_on(0)='1') or --game over
            (text_on(3)='1') or (text_on(2)='1') then --scoreboards

               rgb_next <= text_rgb;
         elsif graph_on='1'  then -- display graph
           rgb_next <= graph_rgb;
         -- elsif text_on(2)='1'  then -- display logo
         --   rgb_next <= text_rgb;
         else
           rgb_next <= "000"; -- black background
         end if;
      end if;
   end process;
   
   outred <= rgb_reg(2) & rgb_reg(2) & rgb_reg(2);
   outgreen <= rgb_reg(1) & rgb_reg(1) & rgb_reg(1);
   outblue <= rgb_reg(0) & rgb_reg(0);
   rgb <= rgb_reg;
	
	
end arch;