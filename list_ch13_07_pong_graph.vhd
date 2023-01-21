-- Listing 13.7
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity pong_graph is
   port(
      clk, reset: std_logic;
      btn: std_logic_vector(1 downto 0);
      pixel_x,pixel_y: in std_logic_vector(9 downto 0);
      gra_still: in std_logic;
		timer_up,attack_1_on,fight_on: in std_logic;
		keyboard_code: in std_logic_vector(7 downto 0);
      graph_on, hit, miss: out std_logic;
      rgb: out std_logic_vector(2 downto 0)
		
   );
end pong_graph;

architecture arch of pong_graph is
   signal pix_x, pix_y: unsigned(9 downto 0);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
	constant MIN_Y: integer:=30;
   constant WALL_X_L: integer:=32;
   constant WALL_X_R: integer:=35;
   --constant BAR_X_L: integer:=600;
   --constant BAR_X_R: integer:=603;
	constant BAR_X_L: integer:=300;
   constant BAR_X_R: integer:=400;
   signal bar_y_t, bar_y_b: unsigned(9 downto 0);
   --constant BAR_Y_SIZE: integer:=72;
	constant BAR_Y_SIZE: integer:=3;
   signal bar_y_reg, bar_y_next: unsigned(9 downto 0);
   constant BAR_V: integer:=8;
   constant BALL_SIZE: integer:=8; -- 8
   signal ball_x_l, ball_x_r: unsigned(9 downto 0);
   signal ball_y_t, ball_y_b: unsigned(9 downto 0);
   signal ball_x_reg, ball_x_next: unsigned(9 downto 0);
   signal ball_y_reg, ball_y_next: unsigned(9 downto 0);
   signal ball_vx_reg, ball_vx_next: unsigned(9 downto 0);
   signal ball_vy_reg, ball_vy_next: unsigned(9 downto 0);
	signal keycode_reg: std_logic_vector(7 downto 0);
	signal keycode_next: std_logic_vector(7 downto 0);
   constant BALL_V_P: unsigned(9 downto 0)
            :=to_unsigned(2,10);
   constant BALL_V_N: unsigned(9 downto 0)
            :=unsigned(to_signed(-2,10));
   type rom_type is array (0 to 7) of
        std_logic_vector (7 downto 0);
   constant BALL_ROM: rom_type :=
   (
      "00111100", --   ****
      "01111110", --  ******
      "11111111", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "01111110", --  ******
      "00111100"  --   ****
   );
	type rom_type_2 is array (0 to 7) of
        std_logic_vector (7 downto 0);
	constant SHIP_ROM: rom_type_2 :=
   (
      "11111111", -- ********
      "01111110", --  ******
      "11111111", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "01111110", --  ******
      "11111111"  -- ********
   );
	
	---------------------------------  
-- Heart  
---------------------------------
   constant HEART_SIZE: integer:=8; -- 8
   signal heart_x_l, heart_x_r: unsigned(9 downto 0);  
   signal heart_y_t, heart_y_b: unsigned(9 downto 0);
   signal heart_x_reg, heart_x_next: unsigned(9 downto 0);
   signal heart_y_reg, heart_y_next: unsigned(9 downto 0);
constant HEART_V: integer:=4;


   type rom_type_heart is array (0 to 7) of
        std_logic_vector (7 downto 0);
   constant HEART_ROM: rom_type :=
   (
      "00011000", --    **
      "00011000", --    **    
      "00011000", --    **   
      "00111100", --   ****   
      "01111110", --  ****** 
      "11111111", -- ********
      "11111111", -- ********
      "11111111"  -- ********
   );

	signal rom_addr_heart, rom_col_heart: unsigned(2 downto 0);
   signal rom_data_heart: std_logic_vector(7 downto 0);
   signal rom_bit_heart: std_logic;
	
	---------------------------------
-- Constant Keys
---------------------------------
constant a: std_logic_vector (7 downto 0):="01101011";
constant d: std_logic_vector (7 downto 0):="01110100";
constant s: std_logic_vector (7 downto 0):="01110010";
constant w: std_logic_vector (7 downto 0):="01110101";

---------------------------------
-- Random Generator
---------------------------------
signal rand_reg: unsigned(9 downto 0) := "0010110101";
signal rand_next,rand_number: unsigned(9 downto 0);
---------------------------------
-- Projectiles - Bars
---------------------------------


-------------------------------
	--BOx
	-------------------------------
	constant WIDTH: integer:=4;
constant WALL_SIZE: integer:=400;
	  constant WALL1_X_R: integer:=(MAX_X-WALL_SIZE)/2;
constant WALL1_X_L: integer:=WALL1_X_R-WIDTH;
constant WALL2_X_L: integer:=(MAX_X+WALL_SIZE)/2;
   constant WALL2_X_R: integer:=WALL2_X_L+WIDTH;  
constant WALL_Y_T: integer:=50;
constant WALL_Y_T2: integer:=WALL_Y_T+WIDTH;
constant WALL_Y_B: integer:=WALL_Y_T2+WALL_SIZE;
constant WALL_Y_B2: integer:=WALL_Y_B+WIDTH;    
	
	constant SHIP_SIZE: integer:=8; -- 8
   signal SHIP_x_l, SHIP_x_r: unsigned(9 downto 0);
   signal SHIP_y_t, SHIP_y_b: unsigned(9 downto 0);
   signal SHIP_x_reg, SHIP_x_next: unsigned(9 downto 0);
   signal SHIP_y_reg, SHIP_y_next: unsigned(9 downto 0);
   signal SHIP_vx_reg, SHIP_vx_next: unsigned(9 downto 0);
   signal SHIP_vy_reg, SHIP_vy_next: unsigned(9 downto 0);
   constant SHIP_V_P: unsigned(9 downto 0)
            :=to_unsigned(2,10);
   constant SHIP_V_N: unsigned(9 downto 0)
            :=unsigned(to_signed(-2,10));
	
	
   signal rom_addr, rom_col: unsigned(2 downto 0);
   signal rom_data: std_logic_vector(7 downto 0);
   signal rom_bit: std_logic;
   signal wall_on, bar_on, sq_ball_on,proj1_on, rd_ball_on,sq_ship_on, rd_ship_on,sq_heart_on, rd_heart_on: std_logic;
   signal wall_rgb, bar_rgb,proj1_rgb, ball_rgb, ship_rgb,heart_rgb:
          std_logic_vector(2 downto 0);
   signal refr_tick: std_logic;
	signal rom_ship_addr, rom_ship_col: unsigned(2 downto 0);
   signal rom_ship_data: std_logic_vector(7 downto 0);
   signal rom_ship_bit: std_logic;
begin
   -- registers
   process (clk,reset,keyboard_code)
   begin
      if reset='1' then
         bar_y_reg <= (OTHERS=>'0');
         ball_x_reg <= (OTHERS=>'0');
         ball_y_reg <= (OTHERS=>'0');
         ball_vx_reg <= ("0000000100");
         ball_vy_reg <= ("0000000100");
			keycode_reg<= (OTHERS=>'0');
			SHIP_x_reg <= (OTHERS=>'0');
         SHIP_y_reg <= (OTHERS=>'0');
         SHIP_vx_reg <= ("0000000100");
         SHIP_vy_reg <= ("0000000100");
			heart_x_reg<= (OTHERS=>'0');
			heart_y_reg<= (OTHERS=>'0');
			
			
      elsif (clk'event and clk='1') then
         bar_y_reg <= bar_y_next;
         ball_x_reg <= ball_x_next;
         ball_y_reg <= ball_y_next;
         ball_vx_reg <= ball_vx_next;
         ball_vy_reg <= ball_vy_next;
			keycode_reg<= keycode_next;
			
			SHIP_x_reg <= ball_x_next;
         SHIP_y_reg <= ball_y_next;
         SHIP_vx_reg <= ball_vx_next;
         SHIP_vy_reg <= ball_vy_next;
			
			heart_x_reg <= heart_x_next;
			heart_y_reg <= heart_y_next;
      end if;
   end process;
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   refr_tick <= '1' when (pix_y=481) and (pix_x=0) else
                '0';
					 
	--KEYBOARD
			keycode_next<=keyboard_code when keycode_reg/=keyboard_code else "00000000"; 
			
		--previous_key_code<=keyboard_code when timer_up='1';
		--current_keycode<="00000000" when previous_key_code=keyboard_code and timer_up='0' else keyboard_code;
	--

-- square heart
   heart_x_l <= heart_x_reg;
   heart_y_t <= heart_y_reg;
   heart_x_r <= heart_x_l + heart_SIZE - 1;
   heart_y_b <= heart_y_t + heart_SIZE - 1;
   sq_heart_on <=
      '1' when (heart_x_l<=pix_x) and (pix_x<=heart_x_r) and
               (heart_y_t<=pix_y) and (pix_y<=heart_y_b) else
      '0';
   -- round heart
   rom_addr_heart <= pix_y(2 downto 0) - heart_y_t(2 downto 0);
   rom_col_heart <= pix_x(2 downto 0) - heart_x_l(2 downto 0);
   rom_data_heart <= HEART_ROM(to_integer(rom_addr_heart));
   rom_bit_heart <= rom_data_heart(to_integer(not rom_col_heart));
   rd_heart_on <=
      '1' when (sq_heart_on='1') and (rom_bit_heart='1') else
      '0';
   heart_rgb <= "100";   -- red
   -- new heart position
   process(refr_tick,gra_still,heart_y_reg,heart_x_reg,keycode_reg,rand_number,heart_y_b,heart_y_t,heart_x_l,heart_x_r)
   begin
heart_y_next <= heart_y_reg;
heart_x_next <= heart_x_reg;
      if gra_still='1' then  --initial position of heart
heart_x_next <= to_unsigned((WALL2_X_L+WALL1_X_R)/2,10);
heart_y_next <= to_unsigned((WALL_Y_B+WALL_Y_T2)/2,10);
      elsif refr_tick='1' then
         if (keyboard_code=s) and heart_y_b<(WALL_Y_B-1) then
            heart_y_next <= heart_y_reg + HEART_V; -- move down
         elsif (keyboard_code=w) and heart_y_t > WALL_Y_T2+1 then
            heart_y_next <= heart_y_reg - HEART_V; -- move up
elsif (keyboard_code=a) and heart_x_l >(WALL1_X_R+1) then
heart_x_next <= heart_x_reg - HEART_V;
elsif (keyboard_code=d) and heart_x_r < (WALL2_X_L-1) then
heart_x_next <= heart_x_reg +HEART_V;
         end if;
      end if;
   end process;
	----------------------------------
	--PROJECTIL
	----------------------------------
	 

   -- wall
   wall_on <=
      '1' when (WALL_X_L<=pix_x) and (pix_x<=WALL_X_R) else
      '0';
   wall_rgb <= "001"; -- blue
	
--	
--   -- paddle bar
--   bar_y_t <= bar_y_reg;
--   bar_y_b <= bar_y_t + BAR_Y_SIZE - 1;
--   bar_on <=
--      '1' when (BAR_X_L<=pix_x) and (pix_x<=BAR_X_R) and
--               (bar_y_t<=pix_y) and (pix_y<=bar_y_b) else
--      '0';
--   bar_rgb <= "010"; --green
--   -- new bar y-position
--   process(bar_y_reg,bar_y_b,bar_y_t,refr_tick,btn,gra_still)
--   begin
--      bar_y_next <= bar_y_reg; -- no move
--      if gra_still='1' then  --initial position of paddle
--         --bar_y_next <= to_unsigned((MAX_Y-BAR_Y_SIZE)/2,10);
--			bar_y_next <= to_unsigned(MAX_Y-50,10);
--      elsif refr_tick='1' then
--			if btn(1)='1' and bar_y_b<(MAX_Y-1-BAR_V) then
--            bar_y_next <= bar_y_reg + BAR_V; -- move down
--         elsif btn(0)='1' and bar_y_t > BAR_V then
--            bar_y_next <= bar_y_reg - BAR_V; -- move up
--         elsif keycode_reg="01110101" and bar_y_t > BAR_V then
--            bar_y_next <= bar_y_reg - BAR_V; -- move up
--			elsif keycode_reg="01110010" and bar_y_b<(MAX_Y-1-BAR_V) then
--            bar_y_next <= bar_y_reg + BAR_V; -- move down
--			--elsif keyboard_code="00010010" and bar_y_t > BAR_V then
--         --   bar_y_next <= bar_y_reg - BAR_V; -- move up 
--         end if;
--      end if;
--   end process;
--	
--	
   -- square ball
   ball_x_l <= ball_x_reg;
   ball_y_t <= ball_y_reg;
   ball_x_r <= ball_x_l + BALL_SIZE - 1;
   ball_y_b <= ball_y_t + BALL_SIZE - 1;
   sq_ball_on <=
      '1' when (ball_x_l<=pix_x) and (pix_x<=ball_x_r) and
               (ball_y_t<=pix_y) and (pix_y<=ball_y_b) else
      '0';
   -- round ball
   rom_addr <= pix_y(2 downto 0) - ball_y_t(2 downto 0);
   rom_col <= pix_x(2 downto 0) - ball_x_l(2 downto 0);
   rom_data <= BALL_ROM(to_integer(rom_addr));
   rom_bit <= rom_data(to_integer(not rom_col));
   rd_ball_on <=
      '1' when (sq_ball_on='1') and (rom_bit='1') else
      '0';
   ball_rgb <= "100";   -- red
   -- new ball position
   ball_x_next <=
      to_unsigned((MAX_X)/2,10) when gra_still='1' else
      ball_x_reg + ball_vx_reg when refr_tick='1' else
      ball_x_reg ;
   ball_y_next <=
      to_unsigned((MAX_Y)/2,10) when gra_still='1' else
      ball_y_reg + ball_vy_reg when refr_tick='1' else
      ball_y_reg ;
   -- new ball velocity
   -- wuth new hit, miss signals
   process(ball_vx_reg,ball_vy_reg,ball_y_t,ball_x_l,ball_x_r,
           ball_y_t,ball_y_b,bar_y_t,bar_y_b,gra_still)
   begin
      hit <='0';
      miss <='0';
      ball_vx_next <= ball_vx_reg;
      ball_vy_next <= ball_vy_reg;
      if gra_still='1' then            --initial velocity
         ball_vx_next <= BALL_V_N;
         ball_vy_next <= BALL_V_P;
      elsif ball_y_t < 1 then          -- reach top
         ball_vy_next <= BALL_V_P;
      elsif ball_y_b > (MAX_Y-1) then  -- reach bottom
         ball_vy_next <= BALL_V_N;
      elsif ball_x_l <= WALL_X_R  then -- reach wall
         ball_vx_next <= BALL_V_P;     -- bounce back
      elsif (BAR_X_L<=ball_x_r) and (ball_x_r<=BAR_X_R) and
            (bar_y_t<=ball_y_b) and (ball_y_t<=bar_y_b) then
            -- reach x of right bar, a hit
            ball_vx_next <= BALL_V_N; -- bounce back
            hit <= '1';
      elsif (ball_x_r>MAX_X) then     -- reach right border
         miss <= '1';                 -- a miss
      end if;
   end process;
   -- rgb multiplexing circuit
   process(wall_on,bar_on,rd_ball_on,wall_rgb,bar_rgb,ball_rgb,proj1_rgb,proj1_on)
   begin
      if wall_on='1' then
         rgb <= wall_rgb;
      --elsif bar_on='1' then
   --      rgb <= bar_rgb;
      elsif rd_ball_on='1' then
         rgb <= ball_rgb;
		elsif rd_heart_on='1' then
         rgb <= heart_rgb;
		elsif proj1_on='1' then
         rgb <= proj1_rgb;
      else
         rgb <= "111"; -- black background
      end if;
   end process;
	
	--SHIP copied of ball
	-- square ball
   SHIP_x_l <= SHIP_x_reg;
   SHIP_y_t <= SHIP_y_reg;
   SHIP_x_r <= SHIP_x_l + SHIP_SIZE - 1;
   SHIP_y_b <= SHIP_y_t + SHIP_SIZE - 1;
   sq_SHIP_on <=
      '1' when (SHIP_x_l<=pix_x) and (pix_x<=SHIP_x_r) and
               (SHIP_y_t<=pix_y) and (pix_y<=SHIP_y_b) else
      '0';
   -- round ball
   rom_ship_addr <= pix_y(2 downto 0) - SHIP_y_t(2 downto 0);
   rom_ship_col <= pix_x(2 downto 0) - SHIP_x_l(2 downto 0);
   rom_ship_data <= SHIP_ROM(to_integer(rom_ship_addr));
   rom_ship_bit <= rom_ship_data(to_integer(not rom_ship_col));
   rd_ship_on <=
      '1' when (sq_ship_on='1') and (rom_ship_bit='1') else
      '0';
   ship_rgb <= "111";   -- red
   -- new ball position
   ship_x_next <=
      to_unsigned((MAX_X)/2,10) when gra_still='1' else
      SHIP_x_reg + SHIP_vx_reg when refr_tick='1' else
      SHIP_x_reg ;
   SHIP_y_next <=
      to_unsigned((MAX_Y)/2,10) when gra_still='1' else
      SHIP_y_reg + SHIP_vy_reg when refr_tick='1' else
      SHIP_y_reg ;
	
	
   -- new graphic_on signal
   graph_on <= wall_on or rd_ball_on OR rd_ship_on or rd_heart_on or proj1_on;
end arch;
