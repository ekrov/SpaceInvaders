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
    -- Aliens  
    ---------------------------------
    CONSTANT ALIEN_SIZE : INTEGER := 8; -- 8
    -- Alien 1
    SIGNAL alien_x_l, alien_x_r : unsigned(9 DOWNTO 0);
    SIGNAL alien_y_t, alien_y_b : unsigned(9 DOWNTO 0);
    SIGNAL alien_x_reg, alien_x_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_y_reg, alien_y_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_vx_reg, alien_vx_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_vy_reg, alien_vy_next : unsigned(9 DOWNTO 0);
    SIGNAL rom_addr_alien, rom_col_alien : unsigned(2 DOWNTO 0);
    SIGNAL rom_data_alien : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rom_bit_alien : STD_LOGIC;
    SIGNAL alien_alive, alien_alive_reg, alien_alive_next : STD_LOGIC;
    -- Alien 2
    SIGNAL alien_2_x_l, alien_2_x_r : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_y_t, alien_2_y_b : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_x_reg, alien_2_x_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_y_reg, alien_2_y_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_vx_reg, alien_2_vx_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_vy_reg, alien_2_vy_next : unsigned(9 DOWNTO 0);
    SIGNAL rom_addr_alien_2, rom_col_alien_2 : unsigned(2 DOWNTO 0);
    SIGNAL rom_data_alien_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rom_bit_alien_2 : STD_LOGIC;
    SIGNAL alien_2_alive, alien_2_alive_reg, alien_2_alive_next : STD_LOGIC;

    CONSTANT ALIEN_V : INTEGER := 4;
    CONSTANT ALIEN_V_P : unsigned(9 DOWNTO 0) := to_unsigned(1, 10);
    CONSTANT ALIEN_V_N : unsigned(9 DOWNTO 0) := unsigned(to_signed(-1, 10));
    TYPE rom_type_alien IS ARRAY (0 TO 7) OF
    STD_LOGIC_VECTOR (7 DOWNTO 0);
    CONSTANT ALIEN_ROM : rom_type :=
    (
    "01111110", --  ****** 
    "11011011", -- ** ** ** 
    "01111110", --  ****** 
    "00111100", --   ****   
    "01100110", --  **  ** 
    "11111111", -- ********
    "10011001", -- *  **  *
    "10011001" -- *  **  *
    );

    ---------------------------------  
    -- Aliens Projectiles  
    ---------------------------------
    CONSTANT ALIEN_PROJECTIL_SIZE : INTEGER := 4; -- 4
    CONSTANT ALIEN_PROJECTIL_WIDTH : INTEGER := 2; -- 2
    CONSTANT ALIEN_PROJ_V_MOVE : unsigned(9 DOWNTO 0) := to_unsigned(1, 10);
    CONSTANT ALIEN_PROJ_V_NO_MOVE : unsigned(9 DOWNTO 0) := to_unsigned(0, 10);
    -- SIGNAL projectil_timer_reg, projectil_timer_next : unsigned(4 DOWNTO 0);
    -- Alien 1
    SIGNAL alien_projectil_x_l, alien_projectil_x_r : unsigned(9 DOWNTO 0);
    SIGNAL alien_projectil_y_t, alien_projectil_y_b : unsigned(9 DOWNTO 0);
    SIGNAL alien_projectil_x_reg, alien_projectil_x_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_projectil_y_reg, alien_projectil_y_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_projectil_on, alien_projectil_hit_reg, alien_projectil_hit_next : STD_LOGIC;
    -- Alien 2
    SIGNAL alien_2_projectil_x_l, alien_2_projectil_x_r : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_projectil_y_t, alien_2_projectil_y_b : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_projectil_x_reg, alien_2_projectil_x_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_projectil_y_reg, alien_2_projectil_y_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_projectil_on, alien_2_projectil_hit_reg, alien_2_projectil_hit_next : STD_LOGIC;
    ---------------------------------
    -- Constant Keys 
    ---------------------------------
    CONSTANT a : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01101011";
    CONSTANT d : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01110100";
    CONSTANT s : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01110010";
    CONSTANT w : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01110101";
    CONSTANT spacebar : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00101001";

    ---------------------------------
    -- Random Generator
    ---------------------------------
    SIGNAL rand_reg : unsigned(9 DOWNTO 0) := "0010110101";
    SIGNAL rand_next, rand_number : unsigned(9 DOWNTO 0);
    ---------------------------------
    -- Projectiles - Bars
    ---------------------------------
    CONSTANT PROJ_WIDTH : INTEGER := 3;
    CONSTANT PROJ_SIZE : INTEGER := 10;
    -- Porjectile 1
    SIGNAL proj1_y_t, proj1_y_b : unsigned(9 DOWNTO 0);
    SIGNAL proj1_x_l, proj1_x_r : unsigned(9 DOWNTO 0);
    SIGNAL proj1_y_reg, proj1_y_next : unsigned(9 DOWNTO 0);
    SIGNAL PROJ1_V : INTEGER;
    SIGNAL new_proj1_next, new_proj1_reg : STD_LOGIC;

    SIGNAL proj1_x_initial : unsigned(9 DOWNTO 0);
    SIGNAL random1 : unsigned(9 DOWNTO 0);

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
    SIGNAL wall_on, bar_on, sq_ball_on, proj1_on, rd_ball_on, sq_ship_on, rd_ship_on, sq_heart_on, rd_heart_on, proj1_hit : STD_LOGIC;
    SIGNAL wall_rgb, bar_rgb, proj1_rgb, ball_rgb, ship_rgb, heart_rgb, alien_rgb :
    STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- Alien Flags
    SIGNAL sq_alien_1_on, rd_alien_1_on : STD_LOGIC;
    SIGNAL sq_alien_2_on, rd_alien_2_on : STD_LOGIC;

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

            alien_x_reg <= (OTHERS => '0');
            alien_y_reg <= (OTHERS => '0');
            alien_vx_reg <= ("0000000100");
            alien_vy_reg <= ("0000000100");
            alien_alive_reg <= '1';

            alien_2_x_reg <= (OTHERS => '0');
            alien_2_y_reg <= (OTHERS => '0');
            alien_2_vx_reg <= ("0000000100");
            alien_2_vy_reg <= ("0000000100");
            alien_2_alive_reg <= '1';

            -- projectil_timer_reg <= (OTHERS => '0');
            alien_projectil_hit_reg <= '0';
            alien_2_projectil_hit_reg <= '0';

            keycode_reg <= (OTHERS => '0');
            SHIP_x_reg <= (OTHERS => '0');
            SHIP_y_reg <= (OTHERS => '0');
            SHIP_vx_reg <= ("0000000100");
            SHIP_vy_reg <= ("0000000100");
            heart_x_reg <= (OTHERS => '0');
            heart_y_reg <= (OTHERS => '0');

            proj1_y_reg <= (OTHERS => '0');
            new_proj1_reg <= '0';
            rand_reg <= "0010110101"; -- seed

        ELSIF (clk'event AND clk = '1') THEN
            bar_y_reg <= bar_y_next;
            ball_x_reg <= ball_x_next;
            ball_y_reg <= ball_y_next;
            ball_vx_reg <= ball_vx_next;
            ball_vy_reg <= ball_vy_next;
            keycode_reg <= keycode_next;

            alien_x_reg <= alien_x_next;
            alien_y_reg <= alien_y_next;
            alien_vx_reg <= alien_vx_next;
            alien_vy_reg <= alien_vy_next;
            alien_alive_reg <= alien_alive_next;

            alien_2_x_reg <= alien_2_x_next;
            alien_2_y_reg <= alien_2_y_next;
            alien_2_vx_reg <= alien_2_vx_next;
            alien_2_vy_reg <= alien_2_vy_next;
            alien_2_alive_reg <= alien_2_alive_next;

            -- projectil_timer_reg <= projectil_timer_next;
            alien_projectil_hit_reg <= alien_projectil_hit_next;
            alien_2_projectil_hit_reg <= alien_2_projectil_hit_next;

            SHIP_x_reg <= ball_x_next;
            SHIP_y_reg <= ball_y_next;
            SHIP_vx_reg <= ball_vx_next;
            SHIP_vy_reg <= ball_vy_next;

            heart_x_reg <= heart_x_next;
            heart_y_reg <= heart_y_next;

            proj1_y_reg <= proj1_y_next;
            rand_reg <= rand_next;
            new_proj1_reg <= new_proj1_next;
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

    ----------------------------------------------  
    -- PROJECTILES
    ----------------------------------------------
    ----------------------------------------------  
    ---Projectile - BAR1
    ----------------------------------------------
    proj1_y_t <= proj1_y_reg;
    proj1_y_b <= proj1_y_t + PROJ_SIZE - 1;
    --proj1_x_l <= to_unsigned((to_integer(heart_x_reg)), 10);
    proj1_x_r <= proj1_x_l + PROJ_WIDTH;

    proj1_on <=
        '1' WHEN (proj1_x_l <= pix_x) AND (pix_x <= proj1_x_r) AND
        (proj1_y_t <= pix_y) AND (pix_y <= proj1_y_b) AND (proj1_hit = '0')ELSE
        '0';
    proj1_rgb <= "111"; -- white  
    -- new projectile1 y-position  
    PROCESS (proj1_y_reg, proj1_y_b, proj1_y_t, refr_tick, gra_still, attack_1_on, new_proj1_reg, rand_number, PROJ1_V, proj1_on)
    BEGIN
        proj1_y_next <= proj1_y_reg; -- no move
        IF gra_still = '1' THEN --initial position of projectile 1
            proj1_hit <= '1';

        ELSIF refr_tick = '1' THEN

            -- IF proj1_y_b < (WALL_Y_B2 + 30 + PROJ_SIZE - 1) AND random1(5) = '1' THEN
            --     proj1_y_next <= proj1_y_reg + PROJ1_V; -- move down
            --     new_proj1_next <= '0';
            IF proj1_y_t > 1 THEN
                proj1_y_next <= proj1_y_reg - PROJ1_V; -- move up

                -- new_proj1_next <= '0';
            ELSE
                -- new_proj1_next <= '1';
                proj1_hit <= '1';
            END IF;
        END IF;
        IF (keyboard_code = spacebar AND proj1_hit = '1') THEN
            proj1_hit <= '0';
            proj1_x_initial <= heart_x_reg;
            PROJ1_V <= 2; -- Velocity will be 1
            proj1_y_next <= to_unsigned(to_integer(heart_y_reg) - 16 - PROJ_SIZE, 10);

            proj1_x_l <= to_unsigned((to_integer(heart_x_reg)), 10);
        END IF;

    END PROCESS;

    ----------------------------------------------
    -- random number generator
    ----------------------------------------------

    rand_next <= (rand_reg(4)XOR rand_reg(3)XOR rand_reg(2) XOR rand_reg(0)) & rand_reg(9 DOWNTO 1);
    rand_number <= rand_reg;

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
    PROCESS (refr_tick, gra_still, heart_y_reg, heart_x_reg, keycode_reg, rand_number, heart_y_b, heart_y_t, heart_x_l, heart_x_r)
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

    -- -- wall
    -- wall_on <=
    --     '1' WHEN (WALL_X_L <= pix_x) AND (pix_x <= WALL_X_R) ELSE
    --     '0';
    -- wall_rgb <= "001"; -- blue

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
    -- ball_x_l <= ball_x_reg;
    -- ball_y_t <= ball_y_reg;
    -- ball_x_r <= ball_x_l + BALL_SIZE - 1;
    -- ball_y_b <= ball_y_t + BALL_SIZE - 1;
    -- sq_ball_on <=
    --     '1' WHEN (ball_x_l <= pix_x) AND (pix_x <= ball_x_r) AND
    --     (ball_y_t <= pix_y) AND (pix_y <= ball_y_b) ELSE
    --     '0';
    -- -- round ball
    -- rom_addr <= pix_y(2 DOWNTO 0) - ball_y_t(2 DOWNTO 0);
    -- rom_col <= pix_x(2 DOWNTO 0) - ball_x_l(2 DOWNTO 0);
    -- rom_data <= BALL_ROM(to_integer(rom_addr));
    -- rom_bit <= rom_data(to_integer(NOT rom_col));
    -- rd_ball_on <=
    --     '1' WHEN (sq_ball_on = '1') AND (rom_bit = '1') ELSE
    --     '0';
    -- ball_rgb <= "100"; -- red
    -- -- new ball position
    -- ball_x_next <=
    --     to_unsigned((MAX_X)/2, 10) WHEN gra_still = '1' ELSE
    --     ball_x_reg + ball_vx_reg WHEN refr_tick = '1' ELSE
    --     ball_x_reg;
    -- ball_y_next <=
    --     to_unsigned((MAX_Y)/2, 10) WHEN gra_still = '1' ELSE
    --     ball_y_reg + ball_vy_reg WHEN refr_tick = '1' ELSE
    --     ball_y_reg;
    -- new ball velocity
    -- wuth new hit, miss signals

    -- PROCESS (ball_vx_reg, ball_vy_reg, ball_y_t, ball_x_l, ball_x_r,
    --     ball_y_t, ball_y_b, bar_y_t, bar_y_b, gra_still)
    -- BEGIN
    --     hit <= '0';
    --     miss <= '0';
    --     ball_vx_next <= ball_vx_reg;
    --     ball_vy_next <= ball_vy_reg;
    --     IF gra_still = '1' THEN --initial velocity
    --         ball_vx_next <= BALL_V_N;
    --         ball_vy_next <= BALL_V_P;
    --     ELSIF ball_y_t < 1 THEN -- reach top
    --         ball_vy_next <= BALL_V_P;
    --     ELSIF ball_y_b > (MAX_Y - 1) THEN -- reach bottom
    --         ball_vy_next <= BALL_V_N;
    --     ELSIF ball_x_l <= WALL_X_R THEN -- reach wall
    --         ball_vx_next <= BALL_V_P; -- bounce back
    --     ELSIF (BAR_X_L <= ball_x_r) AND (ball_x_r <= BAR_X_R) AND
    --         (bar_y_t <= ball_y_b) AND (ball_y_t <= bar_y_b) THEN
    --         -- reach x of right bar, a hit
    --         ball_vx_next <= BALL_V_N; -- bounce back
    --         hit <= '1';
    --     ELSIF (ball_x_r > MAX_X) THEN -- reach right border
    --         miss <= '1'; -- a miss

    --     END IF;
    -- END PROCESS;

    ----------------------------------------------  
    --- Alien 1
    ----------------------------------------------
    -- Square Alien
    alien_x_l <= alien_x_reg;
    alien_y_t <= alien_y_reg;
    -- alien_x_r <= alien_x_l + ALIEN_SIZE - 1;
    -- alien_y_b <= alien_y_t + ALIEN_SIZE - 1;
    alien_x_r <= alien_x_l + ALIEN_SIZE + ALIEN_SIZE - 1;
    alien_y_b <= alien_y_t + ALIEN_SIZE + ALIEN_SIZE - 1;
    sq_alien_1_on <=
        '1' WHEN (alien_x_l <= pix_x) AND (pix_x <= alien_x_r) AND
        (alien_y_t <= pix_y) AND (pix_y <= alien_y_b) ELSE
        '0';
    -- Round Alien
    -- rom_addr_alien <= pix_y(2 DOWNTO 0) - alien_y_t(2 DOWNTO 0);
    -- rom_col_alien <= pix_x(2 DOWNTO 0) - alien_x_l(2 DOWNTO 0);
    rom_addr_alien <= pix_y(3 DOWNTO 1) - alien_y_t(3 DOWNTO 1);
    rom_col_alien <= pix_x(3 DOWNTO 1) - alien_x_l(3 DOWNTO 1);
    rom_data_alien <= ALIEN_ROM(to_integer(rom_addr_alien));
    rom_bit_alien <= rom_data_alien(to_integer(NOT rom_col_alien));
    rd_alien_1_on <=
        '1' WHEN (sq_alien_1_on = '1') AND (rom_bit_alien = '1') AND (alien_alive = '1') ELSE
        '0';
    alien_rgb <= "010"; -- green
    -- new alien position
    alien_x_next <=
        to_unsigned((MAX_X)/2, 10) WHEN gra_still = '1' ELSE
        alien_x_reg + alien_vx_reg WHEN refr_tick = '1' ELSE
        alien_x_reg;
    alien_y_next <=
        to_unsigned((MAX_Y)/2, 10) WHEN gra_still = '1' ELSE
        alien_y_reg + alien_vy_reg WHEN refr_tick = '1' ELSE
        alien_y_reg;

    alien_alive <= alien_alive_reg;
    -- ball_y_next <= to_unsigned((MAX_Y)/2, 10);

    -- New alien velocity
    -- With new hit, miss signals

    PROCESS (alien_vx_reg, alien_vy_reg, alien_y_t, alien_x_l, alien_x_r,
        alien_y_b, gra_still)
    BEGIN
        alien_vx_next <= alien_vx_reg;
        alien_vy_next <= alien_vy_reg;
        alien_alive_next <= alien_alive_reg;
        IF gra_still = '1' THEN --initial velocity
            alien_vx_next <= ALIEN_V_N;
            -- alien_vy_next <= ALIEN_V_P;
            alien_vy_next <= to_unsigned(0, 10);
            -- ELSIF alien_y_t < 1 THEN -- reach top
            --     alien_vy_next <= ALIEN_V_P;
            -- ELSIF alien_y_b > (MAX_Y - 1) THEN -- reach bottom
            --     alien_vy_next <= ALIEN_V_N;
            -- ELSIF alien_x_l <= WALL_X_R THEN -- reach wall
            --     alien_vx_next <= ALIEN_V_P; -- bounce back
            -- ELSIF (BAR_X_L <= ball_x_r) AND (ball_x_r <= BAR_X_R) AND
            --     (bar_y_t <= ball_y_b) AND (ball_y_t <= bar_y_b) THEN
            --     -- reach x of right bar, a hit
            --     ball_vx_next <= ALIEN_V_N; -- bounce back
            --     hit <= '1';
        ELSIF (alien_alive = '1') THEN
            IF (rd_alien_1_on = '1' AND proj1_on = '1') THEN
                alien_alive_next <= '0';
            END IF;
            IF (alien_x_l < 1) THEN -- reach left border
                alien_vx_next <= ALIEN_V_P;
            ELSIF (alien_x_r > MAX_X) THEN -- reach right border
                -- miss <= '1'; -- a miss
                alien_vx_next <= ALIEN_V_N;

            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------  
    --- Alien 2
    ----------------------------------------------
    -- Square Alien
    alien_2_x_l <= alien_2_x_reg;
    alien_2_y_t <= alien_2_y_reg;
    alien_2_x_r <= alien_2_x_l + ALIEN_SIZE + ALIEN_SIZE - 1;
    alien_2_y_b <= alien_2_y_t + ALIEN_SIZE + ALIEN_SIZE - 1;
    sq_alien_2_on <=
        '1' WHEN (alien_2_x_l <= pix_x) AND (pix_x <= alien_2_x_r) AND
        (alien_2_y_t <= pix_y) AND (pix_y <= alien_2_y_b) ELSE
        '0';
    -- Round Alien
    rom_addr_alien_2 <= pix_y(3 DOWNTO 1) - alien_2_y_t(3 DOWNTO 1);
    rom_col_alien_2 <= pix_x(3 DOWNTO 1) - alien_2_x_l(3 DOWNTO 1);
    -- rom_data_alien_2 <= ALIEN_ROM(to_integer(rom_addr_alien_2));
    rom_data_alien_2 <= ALIEN_ROM(to_integer(rom_addr_alien_2) - 1) WHEN to_integer(rom_addr_alien_2) > 0
        ELSE
        ALIEN_ROM(7);
    rom_bit_alien_2 <= rom_data_alien_2(to_integer(NOT rom_col_alien_2));
    rd_alien_2_on <=
        '1' WHEN (sq_alien_2_on = '1') AND (rom_bit_alien_2 = '1') AND (alien_2_alive = '1') ELSE
        '0';
    alien_rgb <= "010"; -- green
    -- new alien position
    alien_2_x_next <=
        to_unsigned(((MAX_X)/2) + 50, 10) WHEN gra_still = '1' ELSE
        alien_2_x_reg + alien_2_vx_reg WHEN refr_tick = '1' ELSE
        alien_2_x_reg;
    alien_2_y_next <=
        to_unsigned(((MAX_Y)/2) - 50, 10) WHEN gra_still = '1' ELSE
        alien_2_y_reg + alien_2_vy_reg WHEN refr_tick = '1' ELSE
        alien_2_y_reg;

    alien_2_alive <= alien_2_alive_reg;

    -- New alien 2 velocity

    PROCESS (alien_2_vx_reg, alien_2_vy_reg, alien_2_y_t, alien_2_x_l, alien_2_x_r,
        alien_2_y_b, gra_still)
    BEGIN
        alien_2_vx_next <= alien_2_vx_reg;
        alien_2_vy_next <= alien_2_vy_reg;
        alien_2_alive_next <= alien_2_alive_reg;
        IF gra_still = '1' THEN --initial velocity
            alien_2_vx_next <= ALIEN_V_N;
            -- alien_vy_next <= ALIEN_V_P;
            alien_2_vy_next <= to_unsigned(0, 10);
        ELSIF (alien_2_alive = '1') THEN
            IF (rd_alien_2_on = '1' AND proj1_on = '1') THEN
                alien_2_alive_next <= '0';
            END IF;
            IF (alien_2_x_l < 1) THEN -- reach left border
                alien_2_vx_next <= ALIEN_V_P;
            ELSIF (alien_2_x_r > MAX_X) THEN -- reach right border
                -- miss <= '1'; -- a miss
                alien_2_vx_next <= ALIEN_V_N;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------  
    --- Alien 1 Projectil
    ----------------------------------------------
    alien_projectil_x_l <= alien_projectil_x_reg;
    alien_projectil_y_t <= alien_projectil_y_reg;
    alien_projectil_x_r <= alien_projectil_x_l + ALIEN_PROJECTIL_WIDTH - 1;
    alien_projectil_y_b <= alien_projectil_y_t + ALIEN_PROJECTIL_SIZE - 1;
    alien_projectil_on <=
        '1' WHEN (alien_projectil_x_l <= pix_x) AND (pix_x <= alien_projectil_x_r) AND
        (alien_projectil_y_t <= pix_y) AND (pix_y <= alien_projectil_y_b) AND (alien_projectil_hit_reg = '0') ELSE
        '0';

    -- new alien projectil position
    -- alien_projectil_x_next <=
    --     alien_x_reg WHEN projectil_timer_reg = "00000" ELSE
    --     alien_projectil_x_reg;
    -- alien_projectil_y_next <=
    --     alien_y_reg WHEN projectil_timer_reg = "00000" ELSE
    --     alien_projectil_y_reg + ALIEN_PROJ_V_MOVE WHEN refr_tick = '1' ELSE
    --     alien_projectil_y_reg;

    alien_projectil_x_next <=
        alien_x_reg WHEN alien_projectil_hit_reg = '1' ELSE
        alien_projectil_x_reg;
    alien_projectil_y_next <=
        alien_y_reg WHEN alien_projectil_hit_reg = '1' ELSE
        alien_projectil_y_reg + ALIEN_PROJ_V_MOVE WHEN refr_tick = '1' ELSE
        alien_projectil_y_reg;

    PROCESS (alien_alive, alien_projectil_hit_reg, alien_projectil_on, rd_heart_on, alien_projectil_y_b)
    BEGIN
        -- projectil_timer_next <= projectil_timer_reg;
        alien_projectil_hit_next <= alien_projectil_hit_reg;
        -- IF refr_tick = '1' THEN
        IF (alien_alive = '1') THEN
            -- projectil_timer_next <= projectil_timer_reg + 1;
            IF alien_projectil_hit_reg = '1' THEN
                alien_projectil_hit_next <= '0';
            ELSIF (alien_projectil_on = '1' AND rd_heart_on = '1') THEN
                alien_projectil_hit_next <= '1';
            ELSIF (alien_projectil_y_b > MAX_Y) THEN
                alien_projectil_hit_next <= '1';
            END IF;
        END IF;
        -- END IF;
    END PROCESS;

    ----------------------------------------------  
    --- Alien 2 Projectil
    ----------------------------------------------
    alien_2_projectil_x_l <= alien_2_projectil_x_reg;
    alien_2_projectil_y_t <= alien_2_projectil_y_reg;
    alien_2_projectil_x_r <= alien_2_projectil_x_l + ALIEN_PROJECTIL_WIDTH - 1;
    alien_2_projectil_y_b <= alien_2_projectil_y_t + ALIEN_PROJECTIL_SIZE - 1;
    alien_2_projectil_on <=
        '1' WHEN (alien_2_projectil_x_l <= pix_x) AND (pix_x <= alien_2_projectil_x_r) AND
        (alien_2_projectil_y_t <= pix_y) AND (pix_y <= alien_2_projectil_y_b) AND (alien_2_projectil_hit_reg = '0') ELSE
        '0';

    alien_2_projectil_x_next <=
        alien_2_x_reg WHEN alien_2_projectil_hit_reg = '1' ELSE
        alien_2_projectil_x_reg;
    alien_2_projectil_y_next <=
        alien_2_y_reg WHEN alien_2_projectil_hit_reg = '1' ELSE
        alien_2_projectil_y_reg + ALIEN_PROJ_V_MOVE WHEN refr_tick = '1' ELSE
        alien_2_projectil_y_reg;

    PROCESS (alien_2_alive, alien_2_projectil_hit_reg, alien_2_projectil_on, rd_heart_on, alien_2_projectil_y_b)
    BEGIN
        alien_2_projectil_hit_next <= alien_2_projectil_hit_reg;
        IF (alien_2_alive = '1') THEN
            IF alien_2_projectil_hit_reg = '1' THEN
                alien_2_projectil_hit_next <= '0';
            ELSIF (alien_2_projectil_on = '1' AND rd_heart_on = '1') THEN
                alien_2_projectil_hit_next <= '1';
            ELSIF (alien_2_projectil_y_b > MAX_Y) THEN
                alien_2_projectil_hit_next <= '1';
            END IF;
        END IF;
    END PROCESS;

    -- rgb multiplexing circuit
    PROCESS (wall_on, bar_on, rd_ball_on, wall_rgb, bar_rgb, ball_rgb, proj1_rgb, proj1_on, rd_alien_1_on, rd_alien_2_on, alien_rgb,
            alien_projectil_on, alien_2_projectil_on)
    BEGIN
        -- IF wall_on = '1' THEN
        --     rgb <= wall_rgb;
        --elsif bar_on='1' then
        --      rgb <= bar_rgb;
        -- ELSIF rd_ball_on = '1' THEN
        --     rgb <= ball_rgb;
        IF rd_heart_on = '1' THEN 
            rgb <= heart_rgb;
        ELSIF (rd_alien_1_on = '1' OR rd_alien_2_on = '1') THEN
            rgb <= alien_rgb;
        ELSIF (alien_projectil_on = '1' OR alien_2_projectil_on = '1') THEN
            rgb <= alien_rgb;
        ELSIF proj1_on = '1' THEN
            rgb <= proj1_rgb;
        ELSE
            rgb <= "111"; -- black background
        END IF;
    END PROCESS;

    -- --SHIP copied of ball
    -- -- square ball
    -- SHIP_x_l <= SHIP_x_reg;
    -- SHIP_y_t <= SHIP_y_reg;
    -- SHIP_x_r <= SHIP_x_l + SHIP_SIZE - 1;
    -- SHIP_y_b <= SHIP_y_t + SHIP_SIZE - 1;
    -- sq_SHIP_on <=
    --     '1' WHEN (SHIP_x_l <= pix_x) AND (pix_x <= SHIP_x_r) AND
    --     (SHIP_y_t <= pix_y) AND (pix_y <= SHIP_y_b) ELSE
    --     '0';
    -- -- round ball
    -- rom_ship_addr <= pix_y(2 DOWNTO 0) - SHIP_y_t(2 DOWNTO 0);
    -- rom_ship_col <= pix_x(2 DOWNTO 0) - SHIP_x_l(2 DOWNTO 0);
    -- rom_ship_data <= SHIP_ROM(to_integer(rom_ship_addr));
    -- rom_ship_bit <= rom_ship_data(to_integer(NOT rom_ship_col));
    -- rd_ship_on <=
    --     '1' WHEN (sq_ship_on = '1') AND (rom_ship_bit = '1') ELSE
    --     '0';
    -- ship_rgb <= "111"; -- red
    -- -- new ball position
    -- ship_x_next <=
    --     to_unsigned((MAX_X)/2, 10) WHEN gra_still = '1' ELSE
    --     SHIP_x_reg + SHIP_vx_reg WHEN refr_tick = '1' ELSE
    --     SHIP_x_reg;
    -- SHIP_y_next <=
    --     to_unsigned((MAX_Y)/2, 10) WHEN gra_still = '1' ELSE
    --     SHIP_y_reg + SHIP_vy_reg WHEN refr_tick = '1' ELSE
    --     SHIP_y_reg;
    -- -- new graphic_on signal

    graph_on <= rd_heart_on OR rd_alien_1_on OR rd_alien_2_on OR proj1_on;
END arch;