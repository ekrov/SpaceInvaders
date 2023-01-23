-- Listing 13.7
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY pong_graph IS
    PORT (
        clk, reset : STD_LOGIC;
        btn : STD_LOGIC_VECTOR(1 DOWNTO 0);
        pixel_x, pixel_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        gra_still ,died: IN STD_LOGIC;
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

    ---------------------------------
    -- giga ship
    ---------------------------------
    CONSTANT ship_SIZE : INTEGER := 16; 
    SIGNAL ship_x_l, ship_x_r : unsigned(9 DOWNTO 0);
    SIGNAL ship_y_t, ship_y_b : unsigned(9 DOWNTO 0);
    SIGNAL ship_x_reg, ship_x_next : unsigned(9 DOWNTO 0);
    SIGNAL ship_y_reg, ship_y_next : unsigned(9 DOWNTO 0);
    CONSTANT ship_V : INTEGER := 4;
    TYPE rom_type_ship IS ARRAY (0 TO 15) OF
    STD_LOGIC_VECTOR (15 DOWNTO 0);
    CONSTANT ship_ROM : rom_type_ship :=
    (
    "0000000000000000", 
    "0000000011000000", 
    "0000000011000000", 
    "0000000011000000", 
    "0000000111100000", 
    "0000000111100000", 
    "0000011111111000", 
    "0000111111111100", 
    "0001111111111110", 
    "0011111111111111", 
    "0000001111110000", 
    "0000001111110000", 
    "0000011100111000", 
    "0000000100100000", 
    "0000000000000000", 
    "0000000000000000"
    );

    CONSTANT ship_ROM_2l : rom_type_ship :=
    (
    "0000000000000000", 
    "0000000001000000", 
    "0000000001000000", 
    "0000000011000000", 
    "0000000111100000", 
    "0000000111100000", 
    "0000000011100000", 
    "0000100011110100", 
    "0001111111111110", 
    "0011011111110111", 
    "0000001111110000", 
    "0000001111110000", 
    "0000011100111000", 
    "0000000100000000", 
    "0000000000000000", 
    "0000000000000000"
    );
	 
     
    CONSTANT ship_ROM_1l : rom_type_ship :=
    (
    "0000000000000000", 
    "0000000001000000", 
    "0000000001000000", 
    "0000000011000000", 
    "0000000011000000", 
    "0000000010100000", 
    "0000000011100000", 
    "0000100011110100", 
    "0001111100011110", 
    "0011010001110111", 
    "0000000001100000", 
    "0000000111100000", 
    "0000011100110000", 
    "0000000100000000", 
    "0000000000000000", 
    "0000000000000000"
    );

    SIGNAL rom_addr_ship, rom_col_ship : unsigned(3 DOWNTO 0);
    SIGNAL rom_data_ship : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rom_bit_ship : STD_LOGIC;
    SIGNAL ship_lives_reg, ship_lives_next : unsigned(1 DOWNTO 0);

    
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
    SIGNAL alien_hits_counter_reg, alien_hits_counter_next : unsigned(4 DOWNTO 0);
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
    SIGNAL alien_2_hits_counter_reg, alien_2_hits_counter_next : unsigned(4 DOWNTO 0);

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
    SIGNAL proj1_x_l,proj1_x_l_reg,proj1_x_l_next, proj1_x_r : unsigned(9 DOWNTO 0);
    SIGNAL proj1_y_t_reg, proj1_y_t_next ,proj1_y_initial: unsigned(9 DOWNTO 0);
    SIGNAL PROJ1_V : INTEGER :=2;
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

    SIGNAL wall_on, bar_on, sq_ball_on, proj1_on, rd_ball_on, sq_ship_on, rd_ship_on,proj1_hit_reg,proj1_hit_next : STD_LOGIC;
    SIGNAL wall_rgb, bar_rgb, proj1_rgb, ball_rgb, ship_rgb,ship_rgb_2,ship_rgb_1, alien_rgb :
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
    PROCESS (clk, reset,died, keyboard_code)
    BEGIN
        IF reset = '1' OR died = '1' THEN
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
            alien_hits_counter_reg <= (OTHERS => '0');

            alien_2_x_reg <= (OTHERS => '0');
            alien_2_y_reg <= (OTHERS => '0');
            alien_2_vx_reg <= ("0000000100");
            alien_2_vy_reg <= ("0000000100");
            alien_2_alive_reg <= '1';
            alien_2_hits_counter_reg <= (OTHERS => '0');

            -- projectil_timer_reg <= (OTHERS => '0');
            alien_projectil_hit_reg <= '1';
            alien_2_projectil_hit_reg <= '1';

            keycode_reg <= (OTHERS => '0');
            ship_x_reg <= (OTHERS => '0');
            ship_y_reg <= (OTHERS => '0');

            proj1_y_t_reg <= (OTHERS => '0');
            new_proj1_reg <= '0';
            rand_reg <= "0010110101"; -- seed
            
            proj1_hit_reg<='0';
            proj1_x_l_reg<=(OTHERS => '0');
            proj1_y_t_reg<=(OTHERS => '0');

            --lives
            ship_lives_reg<="11";
            
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
            alien_hits_counter_reg <= alien_hits_counter_next;

            alien_2_x_reg <= alien_2_x_next;
            alien_2_y_reg <= alien_2_y_next;
            alien_2_vx_reg <= alien_2_vx_next;
            alien_2_vy_reg <= alien_2_vy_next;
            alien_2_alive_reg <= alien_2_alive_next;
            alien_2_hits_counter_reg <= alien_2_hits_counter_next;

 -- projectil_timer_reg <= projectil_timer_next;
            alien_projectil_x_reg <= alien_projectil_x_next;
            alien_projectil_y_reg <= alien_projectil_y_next;
            alien_projectil_hit_reg <= alien_projectil_hit_next;

            alien_2_projectil_x_reg <= alien_2_projectil_x_next;
            alien_2_projectil_y_reg <= alien_2_projectil_y_next;
            alien_2_projectil_hit_reg <= alien_2_projectil_hit_next;
            ship_x_reg <= ship_x_next;
            ship_y_reg <= ship_y_next;

            proj1_y_t_reg <= proj1_y_t_next;
            rand_reg <= rand_next;
            new_proj1_reg <= new_proj1_next;

            proj1_hit_reg<=proj1_hit_next;
            proj1_x_l_reg<=proj1_x_l_next;
            proj1_y_t_reg<=proj1_y_t_next;

            --ship lives
            ship_lives_reg<=ship_lives_next;
        END IF;
    END PROCESS;
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    refr_tick <= '1' WHEN (pix_y = 481) AND (pix_x = 0) ELSE
        '0';

    --KEYBOARD
    keycode_next <= keyboard_code WHEN keycode_reg /= keyboard_code ELSE
        "00000000";
    ----------------------------------------------  
    -- PROJECTILES
    ----------------------------------------------
    ----------------------------------------------  
    ---Projectile - SHIP
    ----------------------------------------------
    proj1_y_t <= proj1_y_t_reg;
    proj1_y_b <= proj1_y_t + PROJ_SIZE - 1;
    proj1_x_r <= proj1_x_l_reg + PROJ_WIDTH;
    proj1_x_l <= proj1_x_l_reg;

    proj1_on <=
        '1' WHEN (proj1_x_l_reg <= pix_x) AND (pix_x <= proj1_x_r) AND
        (proj1_y_t <= pix_y) AND (pix_y <= proj1_y_b) AND (proj1_hit_reg = '0')ELSE
        '0';
    proj1_rgb <= "101"; -- magenta  
    -- new projectile1 y-position 


    --Projectile y axis
    proj1_y_t_next<= ship_y_reg when (proj1_hit_reg = '1') ELSE (proj1_y_t_reg-PROJ1_V) WHEN refr_tick='1' ELSE proj1_y_t_reg;
                
    proj1_hit_next <= '1' WHEN (proj1_y_t < 1 OR gra_still = '1') ELSE '0' WHEN (keyboard_code = spacebar) ELSE proj1_hit_reg;

    --Projectile x axis
    proj1_x_l_next <= ship_x_reg when (keyboard_code = spacebar and proj1_hit_reg = '1') else proj1_x_l_reg;

    -- PROCESS (proj1_y_t_reg, proj1_y_t, refr_tick, gra_still, PROJ1_V, proj1_y_initial, keyboard_code, proj1_hit_reg, ship_x_reg)
    -- BEGIN
    --     -- proj1_y_t_next <= proj1_y_t_reg; -- no move
    --     -- IF gra_still = '1' THEN --initial position of projectile 1
    --     --     proj1_hit <= '1';

    --     -- ELSIF refr_tick = '1' THEN

    --     --     IF proj1_y_t > 1 THEN
    --     --         -- proj1_y_t_next <= proj1_y_t_reg - PROJ1_V; -- move up
    --     --     ELSE
    --     --         proj1_hit <= '1';
    --     --     END IF;
    --     -- END IF;
    --     IF (keyboard_code = spacebar AND proj1_hit_reg = '1') THEN
    --             -- proj1_hit <= '0';
    --             proj1_x_initial <= ship_x_reg;
    --             -- PROJ1_V <= 2; -- Velocity will be 1
    --             -- proj1_y_t_next <= proj1_y_initial;
    --             -- proj1_y_initial <= to_unsigned(to_integer(ship_y_reg) - 16 - PROJ_SIZE, 10);
    --             -- proj1_x_l <= to_unsigned((to_integer(ship_x_reg)), 10);
    --     END IF;

    -- END PROCESS;

        
    ----------------------------------------------
    -- random number generator
    ----------------------------------------------

    rand_next <= (rand_reg(4)XOR rand_reg(3)XOR rand_reg(2) XOR rand_reg(0)) & rand_reg(9 DOWNTO 1);
    rand_number <= rand_reg;

    -- square ship
    ship_x_l <= ship_x_reg;
    ship_y_t <= ship_y_reg;
    ship_x_r <= ship_x_l + ship_SIZE + ship_SIZE - 1;
    ship_y_b <= ship_y_t + ship_SIZE + ship_SIZE - 1;
    sq_ship_on <=
        '1' WHEN (ship_x_l <= pix_x) AND (pix_x <= ship_x_r) AND
        (ship_y_t <= pix_y) AND (pix_y <= ship_y_b) ELSE
        '0';
    -- round ship
    rom_addr_ship <= pix_y(4 DOWNTO 1) - ship_y_t(4 DOWNTO 1);
    rom_col_ship <= pix_x(4 DOWNTO 1) - ship_x_l(4 DOWNTO 1);


    rom_data_ship <=ship_ROM_2l(to_integer(rom_addr_ship)) WHEN ship_lives_reg ="10" ELSE ship_ROM_1l(to_integer(rom_addr_ship)) WHEN  ship_lives_reg ="01"  ELSE ship_ROM(to_integer(rom_addr_ship));

    rom_bit_ship <= rom_data_ship(to_integer(NOT rom_col_ship));
    rd_ship_on <=
        '1' WHEN (sq_ship_on = '1') AND (rom_bit_ship = '1') ELSE
        '0';
    ship_rgb <= "111"; --white
    ship_rgb_2 <= "110"; -- yellow
    ship_rgb_1 <="100";-- red
    -- new ship position
    PROCESS (refr_tick, gra_still, ship_y_reg, ship_x_reg, ship_y_b, ship_y_t, ship_x_l, ship_x_r,keyboard_code)
    BEGIN
        ship_y_next <= ship_y_reg;
        ship_x_next <= ship_x_reg;

        IF gra_still = '1' THEN --initial position of ship
            ship_x_next <= to_unsigned((WALL2_X_L + WALL1_X_R)/2, 10);
            ship_y_next <= to_unsigned((WALL_Y_B + WALL_Y_T2)/2, 10);
        ELSIF refr_tick = '1' THEN
            IF (keyboard_code = s) AND ship_y_b < (WALL_Y_B - 1) THEN
                ship_y_next <= ship_y_reg + ship_V; -- move down
                --projectile new initial position
                -- proj1_y_initial<= to_unsigned(to_integer(ship_y_reg + ship_V) - 16 - PROJ_SIZE, 10);

            ELSIF (keyboard_code = w) AND ship_y_t > WALL_Y_T2 + 1 THEN
                ship_y_next <= ship_y_reg - ship_V; -- move up
                --projectile new initial position
                -- proj1_y_initial<= to_unsigned(to_integer(ship_y_reg + ship_V) - 16 - PROJ_SIZE, 10);

            ELSIF (keyboard_code = a) AND ship_x_l > (WALL1_X_R + 1) THEN
                ship_x_next <= ship_x_reg - ship_V;
            ELSIF (keyboard_code = d) AND ship_x_r < (WALL2_X_L - 1) THEN
                ship_x_next <= ship_x_reg + ship_V;
            END IF;
        END IF;

    END PROCESS;

    ----------------------------------------------  
    --- Alien 1
    ----------------------------------------------
    -- Square Alien
    alien_x_l <= alien_x_reg;
    alien_y_t <= alien_y_reg;

    alien_x_r <= alien_x_l + ALIEN_SIZE + ALIEN_SIZE - 1;
    alien_y_b <= alien_y_t + ALIEN_SIZE + ALIEN_SIZE - 1;
    sq_alien_1_on <=
        '1' WHEN (alien_x_l <= pix_x) AND (pix_x <= alien_x_r) AND
        (alien_y_t <= pix_y) AND (pix_y <= alien_y_b) ELSE
        '0';
    -- Round Alien
    
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
        to_unsigned((MAX_X)/2, 10) WHEN (gra_still = '1' OR alien_alive = '0') ELSE
        alien_x_reg + alien_vx_reg WHEN refr_tick = '1' ELSE
        alien_x_reg;
    alien_y_next <=
        to_unsigned((MAX_Y)/2, 10) WHEN (gra_still = '1' OR alien_alive = '0') ELSE
        alien_y_reg + alien_vy_reg WHEN refr_tick = '1' ELSE
        alien_y_reg;

    alien_alive <= alien_alive_reg;

    -- New alien velocity
    -- With new hit, miss signals

    PROCESS (alien_vx_reg, alien_vy_reg, alien_y_t, alien_x_l, alien_x_r,
        alien_y_b, gra_still,alien_alive, alien_hits_counter_reg)
    BEGIN
        alien_vx_next <= alien_vx_reg;
        alien_vy_next <= alien_vy_reg;
        IF gra_still = '1' THEN --initial velocity
            alien_vx_next <= ALIEN_V_N - alien_hits_counter_reg;
            -- alien_vy_next <= ALIEN_V_P;
            alien_vy_next <= to_unsigned(0, 10);
        ELSIF (alien_alive = '1') THEN
            IF (alien_x_l < 1) THEN -- reach left border
                alien_vx_next <= ALIEN_V_P + alien_hits_counter_reg;
        ELSIF (alien_x_r > MAX_X) THEN -- reach right border
            -- miss <= '1'; -- a miss
                alien_vx_next <= ALIEN_V_N - alien_hits_counter_reg;

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
        to_unsigned(((MAX_X)/2) + 50, 10) WHEN (gra_still = '1' OR alien_2_alive = '0') ELSE
        alien_2_x_reg + alien_2_vx_reg WHEN refr_tick = '1' ELSE
        alien_2_x_reg;
    alien_2_y_next <=
        to_unsigned(((MAX_Y)/2) - 50, 10) WHEN (gra_still = '1' OR alien_2_alive = '0') ELSE
        alien_2_y_reg + alien_2_vy_reg WHEN refr_tick = '1' ELSE
        alien_2_y_reg;

    alien_2_alive <= alien_2_alive_reg;

    -- New alien 2 velocity

    PROCESS (alien_2_vx_reg, alien_2_vy_reg, alien_2_x_l, alien_2_x_r, gra_still, alien_2_alive, alien_2_hits_counter_reg)
    BEGIN
        alien_2_vx_next <= alien_2_vx_reg;
        alien_2_vy_next <= alien_2_vy_reg;

        IF gra_still = '1' THEN --initial velocity
            alien_2_vx_next <= ALIEN_V_N - alien_2_hits_counter_reg;
            -- alien_vy_next <= ALIEN_V_P;
            alien_2_vy_next <= to_unsigned(0, 10);
        ELSIF (alien_2_alive = '1') THEN
            IF (alien_2_x_l < 1) THEN -- reach left border
                alien_2_vx_next <= ALIEN_V_P + alien_2_hits_counter_reg;
        ELSIF (alien_2_x_r > MAX_X) THEN -- reach right border
            -- miss <= '1'; -- a miss
                alien_2_vx_next <= ALIEN_V_N - alien_2_hits_counter_reg;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------  
    --- Aliens Elimination Process
    ----------------------------------------------
    PROCESS (alien_alive_reg, alien_2_alive_reg, alien_alive_next, alien_2_alive_next, rd_alien_1_on, rd_alien_2_on, proj1_on,
            alien_hits_counter_reg, alien_2_hits_counter_reg)
    BEGIN
    hit <='0';
        alien_alive_next <= alien_alive_reg;
        alien_2_alive_next <= alien_2_alive_reg;
        alien_hits_counter_next <= alien_hits_counter_reg;
        alien_2_hits_counter_next <= alien_2_hits_counter_reg;
        IF (alien_alive_next = '0' AND alien_2_alive_next = '0') THEN
            alien_alive_next <= '1';
            alien_2_alive_next <= '1';
        END IF;
        IF (rd_alien_1_on = '1' AND proj1_on = '1') THEN
            alien_alive_next <= '0';
            alien_hits_counter_next <= alien_hits_counter_reg + 1;
            hit <= '1';
        END IF;
        IF (rd_alien_2_on = '1' AND proj1_on = '1') THEN
            alien_2_alive_next <= '0';
            alien_2_hits_counter_next <= alien_2_hits_counter_reg + 1;
            hit <= '1';
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
        (alien_projectil_y_t <= pix_y) AND (pix_y <= alien_projectil_y_b) AND (alien_projectil_hit_reg = '0') AND 
		(alien_alive='1')		  ELSE
        '0';

    alien_projectil_x_next <=
        alien_x_reg WHEN (gra_still = '1' OR alien_projectil_hit_reg = '1') ELSE
        alien_projectil_x_reg;
    alien_projectil_y_next <=
        alien_y_reg WHEN (gra_still = '1' OR alien_projectil_hit_reg = '1') ELSE
        alien_projectil_y_reg + ALIEN_PROJ_V_MOVE + alien_hits_counter_reg WHEN refr_tick = '1' ELSE
        alien_projectil_y_reg;

    PROCESS (alien_alive, alien_projectil_hit_reg, alien_projectil_on,rd_ship_on, alien_projectil_y_b,ship_lives_reg)
    BEGIN
        alien_projectil_hit_next <= alien_projectil_hit_reg;
        -- ship_lives_next <= ship_lives_reg;
        IF (alien_alive = '1') THEN
            IF alien_projectil_hit_reg = '1' THEN
                alien_projectil_hit_next <= '0';
            ELSIF (alien_projectil_on = '1' AND rd_ship_on = '1') THEN
                alien_projectil_hit_next <= '1';
                -- ship_lives_next<=ship_lives_reg-1;
            ELSIF (alien_projectil_y_b > MAX_Y) THEN
                alien_projectil_hit_next <= '1';
            END IF;
        END IF;
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
        (alien_2_projectil_y_t <= pix_y) AND (pix_y <= alien_2_projectil_y_b) AND (alien_2_projectil_hit_reg = '0') AND (alien_2_alive='1') ELSE
        '0';

    alien_2_projectil_x_next <=
        alien_2_x_reg WHEN (gra_still = '1' OR alien_2_projectil_hit_reg = '1') ELSE
        alien_2_projectil_x_reg;
    alien_2_projectil_y_next <=
        alien_2_y_reg WHEN (gra_still = '1' OR alien_2_projectil_hit_reg = '1') ELSE
        alien_2_projectil_y_reg + ALIEN_PROJ_V_MOVE + alien_2_hits_counter_reg WHEN refr_tick = '1' ELSE
        alien_2_projectil_y_reg;

    PROCESS (alien_2_alive, alien_2_projectil_hit_reg, alien_2_projectil_on, rd_ship_on, alien_2_projectil_y_b,ship_lives_reg)
    BEGIN
        alien_2_projectil_hit_next <= alien_2_projectil_hit_reg;
        -- ship_lives_next <= ship_lives_reg;
        IF (alien_2_alive = '1') THEN
            IF alien_2_projectil_hit_reg = '1' THEN
                alien_2_projectil_hit_next <= '0';
            ELSIF (alien_2_projectil_on = '1' AND rd_ship_on = '1') THEN
                alien_2_projectil_hit_next <= '1';
                --  ship_lives_next<=ship_lives_reg-1;
            ELSIF (alien_2_projectil_y_b > MAX_Y) THEN
                alien_2_projectil_hit_next <= '1';
            END IF;
        END IF;
    END PROCESS;

    --aliens hitting ship
    Process (alien_alive,alien_2_alive,alien_projectil_on,alien_2_projectil_on,rd_ship_on,ship_lives_reg)
    begin
        miss<='0';
        ship_lives_next <= ship_lives_reg;
        IF (alien_2_alive = '1' and alien_2_projectil_on = '1' AND rd_ship_on = '1') THEN
            ship_lives_next<=ship_lives_reg-1;
            miss<='1';
        ELSIF (alien_alive = '1' and alien_projectil_on = '1' AND rd_ship_on = '1') THEN
            ship_lives_next<=ship_lives_reg-1;
            miss<='1';

        END IF;

    END process;
    -- rgb multiplexing circuit
    PROCESS (wall_on, bar_on, rd_ball_on, wall_rgb, bar_rgb, ball_rgb, proj1_rgb, proj1_on, rd_alien_1_on, rd_alien_2_on, alien_rgb,
            alien_projectil_on, alien_2_projectil_on)
    BEGIN
        
        IF rd_ship_on = '1' and ship_lives_reg ="11" THEN
            rgb <= ship_rgb;
        ELSIF rd_ship_on = '1' and ship_lives_reg ="10" THEN
            rgb <= ship_rgb_2;
        ELSIF rd_ship_on = '1' and ship_lives_reg ="01" THEN
            rgb <= ship_rgb_1;
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

    graph_on <= rd_ship_on OR rd_alien_1_on OR rd_alien_2_on OR proj1_on OR alien_projectil_on OR alien_2_projectil_on;
END arch;