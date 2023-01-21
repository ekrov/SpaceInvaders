-- Listing 13.7
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY pong_graph IS
    PORT (
        clk, reset : STD_LOGIC;
        btn : STD_LOGIC_VECTOR(1 DOWNTO 0);
        pixel_x, pixel_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        gra_still : IN STD_LOGIC;
        timer_up, attack_1_on, fight_on : IN STD_LOGIC;
        keyboard_code : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        graph_on, hit, miss : OUT STD_LOGIC;
        rgb : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

    );
END pong_graph;

ARCHITECTURE arch OF pong_graph IS
    SIGNAL pix_x, pix_y : unsigned(9 DOWNTO 0);
    CONSTANT MAX_X : INTEGER := 640;
    CONSTANT MAX_Y : INTEGER := 480;
    CONSTANT MIN_Y : INTEGER := 30;
    CONSTANT WALL_X_L : INTEGER := 32;
    CONSTANT WALL_X_R : INTEGER := 35;
    --constant BAR_X_L: integer:=600;
    --constant BAR_X_R: integer:=603;
    CONSTANT BAR_X_L : INTEGER := 300;
    CONSTANT BAR_X_R : INTEGER := 400;
    SIGNAL bar_y_t, bar_y_b : unsigned(9 DOWNTO 0);
    --constant BAR_Y_SIZE: integer:=72;
    CONSTANT BAR_Y_SIZE : INTEGER := 3;
    SIGNAL bar_y_reg, bar_y_next : unsigned(9 DOWNTO 0);
    CONSTANT BAR_V : INTEGER := 8;
    CONSTANT BALL_SIZE : INTEGER := 8; -- 8
    SIGNAL ball_x_l, ball_x_r : unsigned(9 DOWNTO 0);
    SIGNAL ball_y_t, ball_y_b : unsigned(9 DOWNTO 0);
    SIGNAL ball_x_reg, ball_x_next : unsigned(9 DOWNTO 0);
    SIGNAL ball_y_reg, ball_y_next : unsigned(9 DOWNTO 0);
    SIGNAL ball_vx_reg, ball_vx_next : unsigned(9 DOWNTO 0);
    SIGNAL ball_vy_reg, ball_vy_next : unsigned(9 DOWNTO 0);
    SIGNAL keycode_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL keycode_next : STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT BALL_V_P : unsigned(9 DOWNTO 0)
    := to_unsigned(2, 10);
    CONSTANT BALL_V_N : unsigned(9 DOWNTO 0)
    := unsigned(to_signed(-2, 10));
    TYPE rom_type IS ARRAY (0 TO 7) OF
    STD_LOGIC_VECTOR (7 DOWNTO 0);
    CONSTANT BALL_ROM : rom_type :=
    (
    "00111100", --   ****
    "01111110", --  ******
    "11111111", -- ********
    "11111111", -- ********
    "11111111", -- ********
    "11111111", -- ********
    "01111110", --  ******
    "00111100" --   ****
    );
    TYPE rom_type_2 IS ARRAY (0 TO 7) OF
    STD_LOGIC_VECTOR (7 DOWNTO 0);
    CONSTANT SHIP_ROM : rom_type_2 :=
    (
    "11111111", -- ********
    "01111110", --  ******
    "11111111", -- ********
    "11111111", -- ********
    "11111111", -- ********
    "11111111", -- ********
    "01111110", --  ******
    "11111111" -- ********
    );

    ---------------------------------  
    -- Heart  
    ---------------------------------
    CONSTANT HEART_SIZE : INTEGER := 8; -- 8
    SIGNAL heart_x_l, heart_x_r : unsigned(9 DOWNTO 0);
    SIGNAL heart_y_t, heart_y_b : unsigned(9 DOWNTO 0);
    SIGNAL heart_x_reg, heart_x_next : unsigned(9 DOWNTO 0);
    SIGNAL heart_y_reg, heart_y_next : unsigned(9 DOWNTO 0);
    CONSTANT HEART_V : INTEGER := 4;

    TYPE rom_type_heart IS ARRAY (0 TO 7) OF
    STD_LOGIC_VECTOR (7 DOWNTO 0);
    CONSTANT HEART_ROM : rom_type :=
    (
    "00011000", --    **
    "00011000", --    **    
    "00011000", --    **   
    "00111100", --   ****   
    "01111110", --  ****** 
    "11111111", -- ********
    "11111111", -- ********
    "11111111" -- ********
    );

    SIGNAL rom_addr_heart, rom_col_heart : unsigned(2 DOWNTO 0);
    SIGNAL rom_data_heart : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rom_bit_heart : STD_LOGIC;

    ---------------------------------
    -- Constant Keys
    ---------------------------------
    CONSTANT a : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01101011";
    CONSTANT d : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01110100";
    CONSTANT s : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01110010";
    CONSTANT w : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01110101";

    ---------------------------------
    -- Random Generator
    ---------------------------------
    SIGNAL rand_reg : unsigned(9 DOWNTO 0) := "0010110101";
    SIGNAL rand_next, rand_number : unsigned(9 DOWNTO 0);
    ---------------------------------
    -- Projectiles - Bars
    ---------------------------------

    -------------------------------
    --BOx
    -------------------------------
    CONSTANT WIDTH : INTEGER := 4;
    CONSTANT WALL_SIZE : INTEGER := 400;
    CONSTANT WALL1_X_R : INTEGER := (MAX_X - WALL_SIZE)/2;
    CONSTANT WALL1_X_L : INTEGER := WALL1_X_R - WIDTH;
    CONSTANT WALL2_X_L : INTEGER := (MAX_X + WALL_SIZE)/2;
    CONSTANT WALL2_X_R : INTEGER := WALL2_X_L + WIDTH;
    CONSTANT WALL_Y_T : INTEGER := 50;
    CONSTANT WALL_Y_T2 : INTEGER := WALL_Y_T + WIDTH;
    CONSTANT WALL_Y_B : INTEGER := WALL_Y_T2 + WALL_SIZE;
    CONSTANT WALL_Y_B2 : INTEGER := WALL_Y_B + WIDTH;

    CONSTANT SHIP_SIZE : INTEGER := 8; -- 8
    SIGNAL SHIP_x_l, SHIP_x_r : unsigned(9 DOWNTO 0);
    SIGNAL SHIP_y_t, SHIP_y_b : unsigned(9 DOWNTO 0);
    SIGNAL SHIP_x_reg, SHIP_x_next : unsigned(9 DOWNTO 0);
    SIGNAL SHIP_y_reg, SHIP_y_next : unsigned(9 DOWNTO 0);
    SIGNAL SHIP_vx_reg, SHIP_vx_next : unsigned(9 DOWNTO 0);
    SIGNAL SHIP_vy_reg, SHIP_vy_next : unsigned(9 DOWNTO 0);
    CONSTANT SHIP_V_P : unsigned(9 DOWNTO 0)
    := to_unsigned(2, 10);
    CONSTANT SHIP_V_N : unsigned(9 DOWNTO 0)
    := unsigned(to_signed(-2, 10));

    SIGNAL rom_addr, rom_col : unsigned(2 DOWNTO 0);
    SIGNAL rom_data : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rom_bit : STD_LOGIC;
    SIGNAL wall_on, bar_on, sq_ball_on, proj1_on, rd_ball_on, sq_ship_on, rd_ship_on, sq_heart_on, rd_heart_on : STD_LOGIC;
    SIGNAL wall_rgb, bar_rgb, proj1_rgb, ball_rgb, ship_rgb, heart_rgb :
    STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL refr_tick : STD_LOGIC;
    SIGNAL rom_ship_addr, rom_ship_col : unsigned(2 DOWNTO 0);
    SIGNAL rom_ship_data : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rom_ship_bit : STD_LOGIC;
BEGIN
    -- registers
    PROCESS (clk, reset, keyboard_code)
    BEGIN
        IF reset = '1' THEN
            bar_y_reg <= (OTHERS => '0');
            ball_x_reg <= (OTHERS => '0');
            ball_y_reg <= (OTHERS => '0');
            ball_vx_reg <= ("0000000100");
            ball_vy_reg <= ("0000000100");
            keycode_reg <= (OTHERS => '0');
            SHIP_x_reg <= (OTHERS => '0');
            SHIP_y_reg <= (OTHERS => '0');
            SHIP_vx_reg <= ("0000000100");
            SHIP_vy_reg <= ("0000000100");
            heart_x_reg <= (OTHERS => '0');
            heart_y_reg <= (OTHERS => '0');

        ELSIF (clk'event AND clk = '1') THEN
            bar_y_reg <= bar_y_next;
            ball_x_reg <= ball_x_next;
            ball_y_reg <= ball_y_next;
            ball_vx_reg <= ball_vx_next;
            ball_vy_reg <= ball_vy_next;
            keycode_reg <= keycode_next;

            SHIP_x_reg <= ball_x_next;
            SHIP_y_reg <= ball_y_next;
            SHIP_vx_reg <= ball_vx_next;
            SHIP_vy_reg <= ball_vy_next;

            heart_x_reg <= heart_x_next;
            heart_y_reg <= heart_y_next;
        END IF;
    END PROCESS;
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    refr_tick <= '1' WHEN (pix_y = 481) AND (pix_x = 0) ELSE
        '0';

    --KEYBOARD
    keycode_next <= keyboard_code WHEN keycode_reg /= keyboard_code ELSE
        "00000000";

    --previous_key_code<=keyboard_code when timer_up='1';
    --current_keycode<="00000000" when previous_key_code=keyboard_code and timer_up='0' else keyboard_code;
    --

    -- square heart
    heart_x_l <= heart_x_reg;
    heart_y_t <= heart_y_reg;
    heart_x_r <= heart_x_l + heart_SIZE - 1;
    heart_y_b <= heart_y_t + heart_SIZE - 1;
    sq_heart_on <=
        '1' WHEN (heart_x_l <= pix_x) AND (pix_x <= heart_x_r) AND
        (heart_y_t <= pix_y) AND (pix_y <= heart_y_b) ELSE
        '0';
    -- round heart
    rom_addr_heart <= pix_y(2 DOWNTO 0) - heart_y_t(2 DOWNTO 0);
    rom_col_heart <= pix_x(2 DOWNTO 0) - heart_x_l(2 DOWNTO 0);
    rom_data_heart <= HEART_ROM(to_integer(rom_addr_heart));
    rom_bit_heart <= rom_data_heart(to_integer(NOT rom_col_heart));
    rd_heart_on <=
        '1' WHEN (sq_heart_on = '1') AND (rom_bit_heart = '1') ELSE
        '0';
    heart_rgb <= "100"; -- red
    -- new heart position
    PROCESS (refr_tick, gra_still, heart_y_reg, heart_x_reg, heart_y_b, heart_y_t, heart_x_l, heart_x_r,
        keyboard_code)
    BEGIN
        heart_y_next <= heart_y_reg;
        heart_x_next <= heart_x_reg;
        IF gra_still = '1' THEN --initial position of heart
            heart_x_next <= to_unsigned((WALL2_X_L + WALL1_X_R)/2, 10);
            heart_y_next <= to_unsigned((WALL_Y_B + WALL_Y_T2)/2, 10);
        ELSIF refr_tick = '1' THEN
            IF (keyboard_code = s) AND heart_y_b < (WALL_Y_B - 1) THEN
                heart_y_next <= heart_y_reg + HEART_V; -- move down
            ELSIF (keyboard_code = w) AND heart_y_t > WALL_Y_T2 + 1 THEN
                heart_y_next <= heart_y_reg - HEART_V; -- move up
            ELSIF (keyboard_code = a) AND heart_x_l > (WALL1_X_R + 1) THEN
                heart_x_next <= heart_x_reg - HEART_V;
            ELSIF (keyboard_code = d) AND heart_x_r < (WALL2_X_L - 1) THEN
                heart_x_next <= heart_x_reg + HEART_V;
            END IF;
        END IF;
    END PROCESS;
    ----------------------------------
    --PROJECTIL
    ----------------------------------

    -- wall
    wall_on <=
        '1' WHEN (WALL_X_L <= pix_x) AND (pix_x <= WALL_X_R) ELSE
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
        '1' WHEN (ball_x_l <= pix_x) AND (pix_x <= ball_x_r) AND
        (ball_y_t <= pix_y) AND (pix_y <= ball_y_b) ELSE
        '0';
    -- round ball
    rom_addr <= pix_y(2 DOWNTO 0) - ball_y_t(2 DOWNTO 0);
    rom_col <= pix_x(2 DOWNTO 0) - ball_x_l(2 DOWNTO 0);
    rom_data <= BALL_ROM(to_integer(rom_addr));
    rom_bit <= rom_data(to_integer(NOT rom_col));
    rd_ball_on <=
        '1' WHEN (sq_ball_on = '1') AND (rom_bit = '1') ELSE
        '0';
    ball_rgb <= "100"; -- red
    -- new ball position
    ball_x_next <=
        to_unsigned((MAX_X)/2, 10) WHEN gra_still = '1' ELSE
        ball_x_reg + ball_vx_reg WHEN refr_tick = '1' ELSE
        ball_x_reg;
    ball_y_next <=
        to_unsigned((MAX_Y)/2, 10) WHEN gra_still = '1' ELSE
        ball_y_reg + ball_vy_reg WHEN refr_tick = '1' ELSE
        ball_y_reg;
    -- new ball velocity
    -- wuth new hit, miss signals
    PROCESS (ball_vx_reg, ball_vy_reg, ball_y_t, ball_x_l, ball_x_r,
        ball_y_t, ball_y_b, bar_y_t, bar_y_b, gra_still)
    BEGIN
        hit <= '0';
        miss <= '0';
        ball_vx_next <= ball_vx_reg;
        ball_vy_next <= ball_vy_reg;
        IF gra_still = '1' THEN --initial velocity
            ball_vx_next <= BALL_V_N;
            ball_vy_next <= BALL_V_P;
        ELSIF ball_y_t < 1 THEN -- reach top
            ball_vy_next <= BALL_V_P;
        ELSIF ball_y_b > (MAX_Y - 1) THEN -- reach bottom
            ball_vy_next <= BALL_V_N;
        ELSIF ball_x_l <= WALL_X_R THEN -- reach wall
            ball_vx_next <= BALL_V_P; -- bounce back
        ELSIF (BAR_X_L <= ball_x_r) AND (ball_x_r <= BAR_X_R) AND
            (bar_y_t <= ball_y_b) AND (ball_y_t <= bar_y_b) THEN
            -- reach x of right bar, a hit
            ball_vx_next <= BALL_V_N; -- bounce back
            hit <= '1';
        ELSIF (ball_x_r > MAX_X) THEN -- reach right border
            miss <= '1'; -- a miss
        END IF;
    END PROCESS;
    -- rgb multiplexing circuit
    PROCESS (wall_on, bar_on, rd_ball_on, wall_rgb, bar_rgb, ball_rgb, proj1_rgb, proj1_on)
    BEGIN
        IF wall_on = '1' THEN
            rgb <= wall_rgb;
            --elsif bar_on='1' then
            --      rgb <= bar_rgb;
        ELSIF rd_ball_on = '1' THEN
            rgb <= ball_rgb;
        ELSIF rd_heart_on = '1' THEN
            rgb <= heart_rgb;
        ELSIF proj1_on = '1' THEN
            rgb <= proj1_rgb;
        ELSE
            rgb <= "111"; -- black background
        END IF;
    END PROCESS;

    --SHIP copied of ball
    -- square ball
    SHIP_x_l <= SHIP_x_reg;
    SHIP_y_t <= SHIP_y_reg;
    SHIP_x_r <= SHIP_x_l + SHIP_SIZE - 1;
    SHIP_y_b <= SHIP_y_t + SHIP_SIZE - 1;
    sq_SHIP_on <=
        '1' WHEN (SHIP_x_l <= pix_x) AND (pix_x <= SHIP_x_r) AND
        (SHIP_y_t <= pix_y) AND (pix_y <= SHIP_y_b) ELSE
        '0';
    -- round ball
    rom_ship_addr <= pix_y(2 DOWNTO 0) - SHIP_y_t(2 DOWNTO 0);
    rom_ship_col <= pix_x(2 DOWNTO 0) - SHIP_x_l(2 DOWNTO 0);
    rom_ship_data <= SHIP_ROM(to_integer(rom_ship_addr));
    rom_ship_bit <= rom_ship_data(to_integer(NOT rom_ship_col));
    rd_ship_on <=
        '1' WHEN (sq_ship_on = '1') AND (rom_ship_bit = '1') ELSE
        '0';
    ship_rgb <= "111"; -- red
    -- new ball position
    ship_x_next <=
        to_unsigned((MAX_X)/2, 10) WHEN gra_still = '1' ELSE
        SHIP_x_reg + SHIP_vx_reg WHEN refr_tick = '1' ELSE
        SHIP_x_reg;
    SHIP_y_next <=
        to_unsigned((MAX_Y)/2, 10) WHEN gra_still = '1' ELSE
        SHIP_y_reg + SHIP_vy_reg WHEN refr_tick = '1' ELSE
        SHIP_y_reg;

    -- new graphic_on signal
    graph_on <= wall_on OR rd_ball_on OR rd_ship_on OR rd_heart_on OR proj1_on;
END arch;