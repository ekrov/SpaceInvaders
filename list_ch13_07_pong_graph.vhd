-- Listing 13.7
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY pong_graph IS
    PORT (
        clk, reset : STD_LOGIC;
        btn : STD_LOGIC_VECTOR(1 DOWNTO 0);
        pixel_x, pixel_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        gra_still, died : IN STD_LOGIC;
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
    -- --constant BAR_X_L: integer:=600;
    -- --constant BAR_X_R: integer:=603;
    -- CONSTANT BAR_X_L : INTEGER := 300;
    -- CONSTANT BAR_X_R : INTEGER := 400;
    -- SIGNAL bar_y_t, bar_y_b : unsigned(9 DOWNTO 0);
    -- --constant BAR_Y_SIZE: integer:=72;
    -- CONSTANT BAR_Y_SIZE : INTEGER := 3;
    -- SIGNAL bar_y_reg, bar_y_next : unsigned(9 DOWNTO 0);
    -- CONSTANT BAR_V : INTEGER := 8;
    -- CONSTANT BALL_SIZE : INTEGER := 8; -- 8

    -- SIGNAL ball_x_reg, ball_x_next : unsigned(9 DOWNTO 0);
    -- SIGNAL ball_y_reg, ball_y_next : unsigned(9 DOWNTO 0);
    -- SIGNAL ball_vx_reg, ball_vx_next : unsigned(9 DOWNTO 0);
    -- SIGNAL ball_vy_reg, ball_vy_next : unsigned(9 DOWNTO 0);
    -- SIGNAL keycode_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    -- SIGNAL keycode_next : STD_LOGIC_VECTOR(7 DOWNTO 0);
    -- CONSTANT BALL_V_P : unsigned(9 DOWNTO 0)
    -- := to_unsigned(2, 10);
    -- CONSTANT BALL_V_N : unsigned(9 DOWNTO 0)
    -- := unsigned(to_signed(-2, 10));
    -- TYPE rom_type IS ARRAY (0 TO 7) OF
    -- STD_LOGIC_VECTOR (7 DOWNTO 0);
    -- CONSTANT BALL_ROM : rom_type :=
    -- (
    -- "00111100", --   ****
    -- "01111110", --  ******
    -- "11111111", -- ********
    -- "11111111", -- ********
    -- "11111111", -- ********
    -- "11111111", -- ********
    -- "01111110", --  ******
    -- "00111100" --   ****
    -- );
    TYPE rom_type IS ARRAY (0 TO 7) OF
    STD_LOGIC_VECTOR (7 DOWNTO 0);
    ---------------------------------
    -- giga ship
    ---------------------------------
    CONSTANT ship_SIZE : INTEGER := 16;
    SIGNAL ship_x_l, ship_x_r : unsigned(9 DOWNTO 0);
    SIGNAL ship_y_t, ship_y_b : unsigned(9 DOWNTO 0);
    SIGNAL ship_x_reg, ship_x_next : unsigned(9 DOWNTO 0);
    SIGNAL ship_y_reg, ship_y_next : unsigned(9 DOWNTO 0);
    CONSTANT ship_V : INTEGER := 3;
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
    SIGNAL ship_got_hit : STD_LOGIC;

    ---------------------------------  
    -- Aliens  
    ---------------------------------
    CONSTANT ALIEN_SIZE : INTEGER := 8; -- 8
    CONSTANT ALIEN_BOSS_SIZE : INTEGER := 16; -- 16

    -- Alien 1
    SIGNAL alien_x_l, alien_x_r : unsigned(9 DOWNTO 0);
    SIGNAL alien_y_t, alien_y_b : unsigned(9 DOWNTO 0);
    SIGNAL alien_x_reg, alien_x_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_y_reg, alien_y_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_vx_reg, alien_vx_next : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_vy_reg, alien_vy_next : unsigned(9 DOWNTO 0);
    SIGNAL rom_addr_alien, rom_col_alien : unsigned(2 DOWNTO 0);
    SIGNAL rom_data_alien : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rom_bit_alien : STD_LOGIC;
    -- SIGNAL alien_alive, alien_alive_reg, alien_alive_next : STD_LOGIC;
    SIGNAL alien_alive_reg, alien_alive_next : STD_LOGIC;
    SIGNAL alien_hits_counter_reg, alien_hits_counter_next : unsigned(2 DOWNTO 0);
    SIGNAL sq_alien_1_on, rd_alien_1_on : STD_LOGIC;
    -- Alien 2
    SIGNAL alien_2_x_l, alien_2_x_r : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_y_t, alien_2_y_b : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_x_reg, alien_2_x_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_y_reg, alien_2_y_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_vx_reg, alien_2_vx_next : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_2_vy_reg, alien_2_vy_next : unsigned(9 DOWNTO 0);
    SIGNAL rom_addr_alien_2, rom_col_alien_2 : unsigned(2 DOWNTO 0);
    SIGNAL rom_data_alien_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rom_bit_alien_2 : STD_LOGIC;
    -- SIGNAL alien_2_alive, alien_2_alive_reg, alien_2_alive_next : STD_LOGIC;
    SIGNAL alien_2_alive_reg, alien_2_alive_next : STD_LOGIC;
    SIGNAL alien_2_hits_counter_reg, alien_2_hits_counter_next : unsigned(2 DOWNTO 0);
    SIGNAL sq_alien_2_on, rd_alien_2_on : STD_LOGIC;

    -- Playable Alien
    SIGNAL play_alien_x_l, play_alien_x_r : unsigned(9 DOWNTO 0);
    SIGNAL play_alien_y_t, play_alien_y_b : unsigned(9 DOWNTO 0);
    SIGNAL play_alien_x_reg, play_alien_x_next : unsigned(9 DOWNTO 0);
    SIGNAL play_alien_y_reg, play_alien_y_next : unsigned(9 DOWNTO 0);
    SIGNAL play_alien_vx_reg, play_alien_vx_next : unsigned(9 DOWNTO 0);
    SIGNAL play_alien_vy_reg, play_alien_vy_next : unsigned(9 DOWNTO 0);
    SIGNAL rom_addr_play_alien, rom_col_play_alien : unsigned(2 DOWNTO 0);
    SIGNAL rom_data_play_alien : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rom_bit_play_alien : STD_LOGIC;
    -- SIGNAL play_alien_alive, play_alien_alive_reg, play_alien_alive_next : STD_LOGIC;
    SIGNAL play_alien_alive_reg, play_alien_alive_next : STD_LOGIC;
    SIGNAL play_alien_hits_counter_reg, play_alien_hits_counter_next : unsigned(1 DOWNTO 0);
    SIGNAL sq_play_alien_on, rd_play_alien_on : STD_LOGIC;

    -- CONSTANT ALIEN_V : INTEGER := 4;
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
    --Alien boss
    SIGNAL alien_boss_x_l, alien_boss_x_r : unsigned(9 DOWNTO 0);
    SIGNAL alien_boss_y_t, alien_boss_y_b : unsigned(9 DOWNTO 0);
    SIGNAL alien_boss_x_reg, alien_boss_x_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_boss_y_reg, alien_boss_y_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_boss_vx_reg, alien_boss_vx_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_boss_vy_reg, alien_boss_vy_next : unsigned(9 DOWNTO 0);
    SIGNAL rom_addr_alien_boss, rom_col_alien_boss : unsigned(3 DOWNTO 0);
    SIGNAL rom_data_alien_boss : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rom_bit_alien_boss : STD_LOGIC;
    SIGNAL alien_boss_alive, alien_boss_alive_reg, alien_boss_alive_next : STD_LOGIC;
    SIGNAL alien_boss_hits_counter_reg, alien_boss_hits_counter_next : unsigned(2 DOWNTO 0);
    SIGNAL alien_boss_lives_reg, alien_boss_lives_next : unsigned(3 DOWNTO 0);

    TYPE rom_type_al_Boss IS ARRAY (0 TO 15) OF
    STD_LOGIC_VECTOR (15 DOWNTO 0);
    CONSTANT ALIEN_BOSS_ROM : rom_type_al_Boss :=
    (
    "0000000000000000",
    "0000000000000000",
    "0000001111000000",
    "0000011111100000",
    "0000111111110000",
    "0001110111011000",
    "0001110010011000",
    "0000111111110000",
    "0000001111100000",
    "0001001111100100",
    "0001011111110100",
    "0001110000111100",
    "0000011001100000",
    "0000001001000000",
    "0000000000000000",
    "0000000000000000"
    );

    CONSTANT ALIEN_BOSS_2_ROM : rom_type_al_Boss :=
    (
    "0000000000000000",
    "0000000000000000",
    "0000000111000000",
    "0000000111100000",
    "0000011111100000",
    "0001110111011000",
    "0001110010011000",
    "0000111111110000",
    "0000000111100000",
    "0001000011100100",
    "0001011110110100",
    "0000000000111100",
    "0000000001100000",
    "0000000001000000",
    "0000000000000000",
    "0000000000000000"
    );

    ---------------------------------  
    -- Aliens Projectiles  
    ---------------------------------
    CONSTANT ALIEN_PROJECTIL_SIZE : INTEGER := 12; -- 4
    CONSTANT ALIEN_PROJECTIL_WIDTH : INTEGER := 4; -- 2
    CONSTANT ALIEN_PROJ_V_MOVE : unsigned(9 DOWNTO 0) := to_unsigned(1, 10);
    -- CONSTANT ALIEN_PROJ_V_NO_MOVE : unsigned(9 DOWNTO 0) := to_unsigned(0, 10);
    -- SIGNAL projectil_timer_reg, projectil_timer_next : unsigned(4 DOWNTO 0);
    -- Alien 1
    SIGNAL alien_projectil_x_l, alien_projectil_x_r : unsigned(9 DOWNTO 0);
    SIGNAL alien_projectil_y_t, alien_projectil_y_b : unsigned(9 DOWNTO 0);
    SIGNAL alien_projectil_x_reg, alien_projectil_x_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_projectil_y_reg, alien_projectil_y_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_projectil_on, alien_projectil_hit_reg, alien_projectil_hit_next : STD_LOGIC;
    -- Projectil 2
    -- SIGNAL alien_projectil_2_x_l, alien_projectil_2_x_r : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_projectil_2_y_t, alien_projectil_2_y_b : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_projectil_2_x_reg, alien_projectil_2_x_next : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_projectil_2_y_reg, alien_projectil_2_y_next : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_projectil_2_on, alien_projectil_2_hit_reg, alien_projectil_2_hit_next : STD_LOGIC;
    -- -- Projectil 3
    -- SIGNAL alien_projectil_3_x_l, alien_projectil_3_x_r : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_projectil_3_y_t, alien_projectil_3_y_b : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_projectil_3_x_reg, alien_projectil_3_x_next : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_projectil_3_y_reg, alien_projectil_3_y_next : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_projectil_3_on, alien_projectil_3_hit_reg, alien_projectil_3_hit_next : STD_LOGIC;
    ---------------- Alien 2 ----------------
    -- Projectil 1
    SIGNAL alien_2_projectil_x_l, alien_2_projectil_x_r : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_projectil_y_t, alien_2_projectil_y_b : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_projectil_x_reg, alien_2_projectil_x_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_projectil_y_reg, alien_2_projectil_y_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_2_projectil_on, alien_2_projectil_hit_reg, alien_2_projectil_hit_next : STD_LOGIC;
    -- Projectil 2
    -- SIGNAL alien_2_projectil_2_x_l, alien_2_projectil_2_x_r : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_2_projectil_2_y_t, alien_2_projectil_2_y_b : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_2_projectil_2_x_reg, alien_2_projectil_2_x_next : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_2_projectil_2_y_reg, alien_2_projectil_2_y_next : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_2_projectil_2_on, alien_2_projectil_2_hit_reg, alien_2_projectil_2_hit_next : STD_LOGIC;
    -- -- Projectil 3
    -- SIGNAL alien_2_projectil_3_x_l, alien_2_projectil_3_x_r : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_2_projectil_3_y_t, alien_2_projectil_3_y_b : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_2_projectil_3_x_reg, alien_2_projectil_3_x_next : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_2_projectil_3_y_reg, alien_2_projectil_3_y_next : unsigned(9 DOWNTO 0);
    -- SIGNAL alien_2_projectil_3_on, alien_2_projectil_3_hit_reg, alien_2_projectil_3_hit_next : STD_LOGIC;
    -- Alien Boss
    SIGNAL alien_boss_projectil_x_l, alien_boss_projectil_x_r : unsigned(9 DOWNTO 0);
    SIGNAL alien_boss_projectil_y_t, alien_boss_projectil_y_b : unsigned(9 DOWNTO 0);
    SIGNAL alien_boss_projectil_x_reg, alien_boss_projectil_x_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_boss_projectil_y_reg, alien_boss_projectil_y_next : unsigned(9 DOWNTO 0);
    SIGNAL alien_boss_projectil_on, alien_boss_projectil_hit_reg, alien_boss_projectil_hit_next : STD_LOGIC;
    ---------------------------------  
    -- Playable Alien Projectiles  
    ---------------------------------
    -- Porjectile 1
    SIGNAL play_alien_projectil_1_x_l, play_alien_projectil_1_x_r : unsigned(9 DOWNTO 0);
    SIGNAL play_alien_projectil_1_y_t, play_alien_projectil_1_y_b : unsigned(9 DOWNTO 0);
    SIGNAL play_alien_projectil_1_x_reg, play_alien_projectil_1_x_next : unsigned(9 DOWNTO 0);
    SIGNAL play_alien_projectil_1_y_reg, play_alien_projectil_1_y_next : unsigned(9 DOWNTO 0);
    SIGNAL play_alien_projectil_1_on, play_alien_projectil_1_hit_reg, play_alien_projectil_1_hit_next : STD_LOGIC;
    ---------------------------------
    -- Ship Projectiles
    ---------------------------------
    CONSTANT PROJ_WIDTH : INTEGER := 3;
    CONSTANT PROJ_SIZE : INTEGER := 10;
    SIGNAL PROJ1_V : INTEGER := 2;
    SIGNAL shoot_counter_reg, shoot_counter_next : unsigned(6 DOWNTO 0);
    -- Porjectile 1
    SIGNAL ship_projectil_1_x_l, ship_projectil_1_x_r : unsigned(9 DOWNTO 0);
    SIGNAL ship_projectil_1_y_t, ship_projectil_1_y_b : unsigned(9 DOWNTO 0);
    SIGNAL ship_projectil_1_x_reg, ship_projectil_1_x_next : unsigned(9 DOWNTO 0);
    SIGNAL ship_projectil_1_y_reg, ship_projectil_1_y_next : unsigned(9 DOWNTO 0);
    SIGNAL ship_projectil_1_on, ship_projectil_1_hit_reg, ship_projectil_1_hit_next : STD_LOGIC;

    --teste
    -- SIGNAL proj1_y_t, proj1_y_b, proj1_x_r, proj1_x_l, proj1_x_l_reg, proj1_y_t_reg, proj1_y_t_next, proj1_x_l_next : unsigned(9 DOWNTO 0);
    -- SIGNAL proj1_hit_reg : STD_LOGIC;
    -- Porjectile 2
    -- SIGNAL ship_projectil_2_x_l, ship_projectil_2_x_r : unsigned(9 DOWNTO 0);
    -- SIGNAL ship_projectil_2_y_t, ship_projectil_2_y_b : unsigned(9 DOWNTO 0);
    -- SIGNAL ship_projectil_2_x_reg, ship_projectil_2_x_next : unsigned(9 DOWNTO 0);
    -- SIGNAL ship_projectil_2_y_reg, ship_projectil_2_y_next : unsigned(9 DOWNTO 0);
    -- SIGNAL ship_projectil_2_on, ship_projectil_2_hit_reg, ship_projectil_2_hit_next : STD_LOGIC;
    -- Porjectile 3
    SIGNAL ship_projectil_3_x_l, ship_projectil_3_x_r : unsigned(9 DOWNTO 0);
    SIGNAL ship_projectil_3_y_t, ship_projectil_3_y_b : unsigned(9 DOWNTO 0);
    SIGNAL ship_projectil_3_x_reg, ship_projectil_3_x_next : unsigned(9 DOWNTO 0);
    SIGNAL ship_projectil_3_y_reg, ship_projectil_3_y_next : unsigned(9 DOWNTO 0);
    SIGNAL ship_projectil_3_on, ship_projectil_3_hit_reg, ship_projectil_3_hit_next : STD_LOGIC;

    ---------------------------------
    -- Constant Keys 
    ---------------------------------
    CONSTANT left_arrow : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01101011";
    CONSTANT right_arrow : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01110100";
    CONSTANT down_arrow : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01110010";
    CONSTANT up_arrow : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01110101";
    CONSTANT d : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00100011";
    CONSTANT r : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00101101";
    CONSTANT j : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00101011";
    CONSTANT g : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00110100";
    CONSTANT f : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00111011";
    CONSTANT spacebar : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00101001";

    ---------------------------------
    -- Random Generator
    ---------------------------------
    -- SIGNAL rand_reg : unsigned(9 DOWNTO 0) := "0010110101";
    -- SIGNAL rand_next, rand_number : unsigned(9 DOWNTO 0);

    -- SIGNAL random1 : unsigned(9 DOWNTO 0);

    -------------------------------
    --BOx
    -------------------------------
    CONSTANT WIDTH : INTEGER := 4;
    CONSTANT WALL_SIZE : INTEGER := 400;
    CONSTANT WALL1_X_R : INTEGER := (MAX_X - WALL_SIZE)/2;
    -- CONSTANT WALL1_X_L : INTEGER := WALL1_X_R - WIDTH;
    CONSTANT WALL2_X_L : INTEGER := (MAX_X + WALL_SIZE)/2;
    -- CONSTANT WALL2_X_R : INTEGER := WALL2_X_L + WIDTH;
    CONSTANT WALL_Y_T : INTEGER := 50;
    CONSTANT WALL_Y_T2 : INTEGER := WALL_Y_T + WIDTH;
    CONSTANT WALL_Y_B : INTEGER := WALL_Y_T2 + WALL_SIZE;
    -- CONSTANT WALL_Y_B2 : INTEGER := WALL_Y_B + WIDTH;

    SIGNAL   sq_ship_on, rd_ship_on : STD_LOGIC;
    SIGNAL   proj1_rgb,  ship_rgb, ship_rgb_2, ship_rgb_1, alien_rgb, play_alien_rgb, alien_boss_rgb :
    STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- Alien Flags
    SIGNAL sq_alien_boss_on, rd_alien_boss_on : STD_LOGIC;

    SIGNAL refr_tick : STD_LOGIC;
    SIGNAL rom_ship_addr, rom_ship_col : unsigned(2 DOWNTO 0);
    SIGNAL rom_ship_data : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rom_ship_bit : STD_LOGIC;
BEGIN
    -- registers
    PROCESS (clk, reset, died)
    BEGIN
        IF reset = '1' OR died = '1' THEN
            -- bar_y_reg <= (OTHERS => '0');
            -- ball_x_reg <= (OTHERS => '0');
            -- ball_y_reg <= (OTHERS => '0');
            -- ball_vx_reg <= ("0000000100");
            -- ball_vy_reg <= ("0000000100");

            alien_x_reg <= (OTHERS => '0');
            alien_y_reg <= (OTHERS => '0');
            alien_vx_reg <= ("0000000100");
            -- alien_vy_reg <= ("0000000100");
            alien_alive_reg <= '1';
            alien_hits_counter_reg <= (OTHERS => '0');

            alien_2_x_reg <= (OTHERS => '0');
            alien_2_y_reg <= (OTHERS => '0');
            alien_2_vx_reg <= ("0000000100");
            -- alien_2_vy_reg <= ("0000000100");
            alien_2_alive_reg <= '1';
            alien_2_hits_counter_reg <= (OTHERS => '0');

            play_alien_x_reg <= (OTHERS => '0');
            play_alien_y_reg <= (OTHERS => '0');
            play_alien_vx_reg <= ("0000000100");
            play_alien_vy_reg <= ("0000000100");
            play_alien_alive_reg <= '1';
            play_alien_hits_counter_reg <= (OTHERS => '0');
            --Alien boss
            alien_boss_x_reg <= (OTHERS => '0');
            alien_boss_y_reg <= (OTHERS => '0');
            alien_boss_vx_reg <= ("0000000100");
            alien_boss_vy_reg <= ("0000000100");
            alien_boss_alive_reg <= '1';
            alien_boss_hits_counter_reg <= (OTHERS => '0');
            alien_boss_lives_reg <= "1010";
            -- Alien Projectil 1 Hit Flag Initialization
            alien_projectil_hit_reg <= '1';
            -- Alien 2 Projectil 1 Hit Flag Initialization
            alien_2_projectil_hit_reg <= '1';
            -- Alien Boss projectil hit flag initialization
            alien_boss_projectil_hit_reg <= '1';

            -- Playable Alien Projectil 1 Hit Flag Initialization
            play_alien_projectil_1_hit_reg <= '1';

            -- keycode_reg <= (OTHERS => '0');
            ship_x_reg <= (OTHERS => '0');
            ship_y_reg <= (OTHERS => '0');

            -- proj1_y_t_reg <= (OTHERS => '0');
            -- new_proj1_reg <= '0';
            -- rand_reg <= "0010110101"; -- seed

            -- proj1_hit_reg <= '0';
            -- proj1_x_l_reg <= (OTHERS => '0');
            -- proj1_y_t_reg <= (OTHERS => '0');

            -- Ship Projectil 1 Hit Flag Initialization
            ship_projectil_1_hit_reg <= '0';
            -- Ship Projectil 2 Hit Flag Initialization
            -- ship_projectil_2_hit_reg <= '0';
            -- Ship Projectil 3 Hit Flag Initialization
            ship_projectil_3_hit_reg <= '0';

            -- Shoots Counter Initialization
            shoot_counter_reg <= (OTHERS => '0');

            --lives
            ship_lives_reg <= "11";

        ELSIF (clk'event AND clk = '1') THEN
            -- bar_y_reg <= bar_y_next;
            -- ball_x_reg <= ball_x_next;
            -- ball_y_reg <= ball_y_next;
            -- ball_vx_reg <= ball_vx_next;
            -- ball_vy_reg <= ball_vy_next;
            -- keycode_reg <= keycode_next;

            alien_x_reg <= alien_x_next;
            alien_y_reg <= alien_y_next;
            alien_vx_reg <= alien_vx_next;
            -- alien_vy_reg <= alien_vy_next;
            alien_alive_reg <= alien_alive_next;
            alien_hits_counter_reg <= alien_hits_counter_next;

            alien_2_x_reg <= alien_2_x_next;
            alien_2_y_reg <= alien_2_y_next;
            alien_2_vx_reg <= alien_2_vx_next;
            -- alien_2_vy_reg <= alien_2_vy_next;
            alien_2_alive_reg <= alien_2_alive_next;
            alien_2_hits_counter_reg <= alien_2_hits_counter_next;

            play_alien_x_reg <= play_alien_x_next;
            play_alien_y_reg <= play_alien_y_next;
            play_alien_vx_reg <= play_alien_vx_next;
            play_alien_vy_reg <= play_alien_vy_next;
            play_alien_alive_reg <= play_alien_alive_next;
            play_alien_hits_counter_reg <= play_alien_hits_counter_next;
            --Alien boss
            alien_boss_x_reg <= alien_boss_x_next;
            alien_boss_y_reg <= alien_boss_y_next;
            alien_boss_vx_reg <= alien_boss_vx_next;
            alien_boss_vy_reg <= alien_boss_vy_next;
            alien_boss_alive_reg <= alien_boss_alive_next;
            alien_boss_hits_counter_reg <= alien_boss_hits_counter_next;
            alien_boss_lives_reg <= alien_boss_lives_next;

            -- projectil_timer_reg <= projectil_timer_next;
            alien_projectil_x_reg <= alien_projectil_x_next;
            alien_projectil_y_reg <= alien_projectil_y_next;
            alien_projectil_hit_reg <= alien_projectil_hit_next;
            -- Alien 1: Projectil 2 Position Update
            -- alien_projectil_2_x_reg <= alien_projectil_2_x_next;
            -- alien_projectil_2_y_reg <= alien_projectil_2_y_next;
            -- alien_projectil_2_hit_reg <= alien_projectil_2_hit_next;
            -- -- Alien 1: Projectil 3 Position Update
            -- alien_projectil_3_x_reg <= alien_projectil_3_x_next;
            -- alien_projectil_3_y_reg <= alien_projectil_3_y_next;
            -- alien_projectil_3_hit_reg <= alien_projectil_3_hit_next;

            -- Alien 2: Projectil 1 Position Update
            alien_2_projectil_x_reg <= alien_2_projectil_x_next;
            alien_2_projectil_y_reg <= alien_2_projectil_y_next;
            alien_2_projectil_hit_reg <= alien_2_projectil_hit_next;
            -- Alien 2: Projectil 2 Position Update
            -- alien_2_projectil_2_x_reg <= alien_2_projectil_2_x_next;
            -- alien_2_projectil_2_y_reg <= alien_2_projectil_2_y_next;
            -- alien_2_projectil_2_hit_reg <= alien_2_projectil_2_hit_next;
            -- -- Alien 2: Projectil 3 Position Update
            -- alien_2_projectil_3_x_reg <= alien_2_projectil_3_x_next;
            -- alien_2_projectil_3_y_reg <= alien_2_projectil_3_y_next;
            -- alien_2_projectil_3_hit_reg <= alien_2_projectil_3_hit_next;
            -- Playable Alien Projectil 1 Variables Update
            play_alien_projectil_1_x_reg <= play_alien_projectil_1_x_next;
            play_alien_projectil_1_y_reg <= play_alien_projectil_1_y_next;
            play_alien_projectil_1_hit_reg <= play_alien_projectil_1_hit_next;

            --Alien boss projectil
            alien_boss_projectil_x_reg <= alien_boss_projectil_x_next;
            alien_boss_projectil_y_reg <= alien_boss_projectil_y_next;
            alien_boss_projectil_hit_reg <= alien_boss_projectil_hit_next;
            ship_x_reg <= ship_x_next;
            ship_y_reg <= ship_y_next;

            -- proj1_y_t_reg <= proj1_y_t_next;
            -- rand_reg <= rand_next;
            -- new_proj1_reg <= new_proj1_next;

            -- proj1_hit_reg <= proj1_hit_next;
            -- proj1_x_l_reg <= proj1_x_l_next;
            -- proj1_y_t_reg <= proj1_y_t_next;

            -- Shihp Projectil 1 Variables Update
            ship_projectil_1_x_reg <= ship_projectil_1_x_next;
            ship_projectil_1_y_reg <= ship_projectil_1_y_next;
            ship_projectil_1_hit_reg <= ship_projectil_1_hit_next;
            -- Shihp Projectil 2 Variables Update
            -- ship_projectil_2_x_reg <= ship_projectil_2_x_next;
            -- ship_projectil_2_y_reg <= ship_projectil_2_y_next;
            -- ship_projectil_2_hit_reg <= ship_projectil_2_hit_next;
            -- Shihp Projectil 3 Variables Update
            ship_projectil_3_x_reg <= ship_projectil_3_x_next;
            ship_projectil_3_y_reg <= ship_projectil_3_y_next;
            ship_projectil_3_hit_reg <= ship_projectil_3_hit_next;

            -- Shoots Counter Variable Update
            shoot_counter_reg <= shoot_counter_next;

            --ship lives
            ship_lives_reg <= ship_lives_next;
        END IF;
    END PROCESS;
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    refr_tick <= '1' WHEN (pix_y = 481) AND (pix_x = 0) ELSE
        '0';

    --KEYBOARD
    -- keycode_next <= keyboard_code WHEN keycode_reg /= keyboard_code ELSE
    --     "00000000";
    ----------------------------------------------  
    -- SHIP PROJECTILES
    ----------------------------------------------
    ----------------------------------------------  
    --- Projectil 1
    ----------------------------------------------
    ship_projectil_1_x_l <= ship_projectil_1_x_reg;
    ship_projectil_1_y_t <= ship_projectil_1_y_reg;
    ship_projectil_1_x_r <= ship_projectil_1_x_l + PROJ_WIDTH - 1;
    ship_projectil_1_y_b <= ship_projectil_1_y_t + PROJ_SIZE - 1;
    ship_projectil_1_on <=
        '1' WHEN (ship_projectil_1_x_l <= pix_x) AND (pix_x <= ship_projectil_1_x_r) AND
        (ship_projectil_1_y_t <= pix_y) AND (pix_y <= ship_projectil_1_y_b) AND
        (ship_projectil_1_hit_reg = '0') ELSE
        '0';

    ship_projectil_1_x_next <=
        ship_x_reg WHEN (keyboard_code = spacebar AND ship_projectil_1_hit_reg = '1') ELSE
        ship_projectil_1_x_reg;
    ship_projectil_1_y_next <=
        ship_y_reg WHEN (keyboard_code = spacebar AND ship_projectil_1_hit_reg = '1') ELSE
        ship_projectil_1_y_reg - PROJ1_V WHEN refr_tick = '1' ELSE
        ship_projectil_1_y_reg;

    -- Ship Projectil Hit Flag Update
    ship_projectil_1_hit_next <= '1' WHEN (ship_projectil_1_y_t < 3 OR gra_still = '1') OR
        (ship_projectil_1_on = '1' AND (rd_alien_1_on = '1' OR rd_alien_2_on = '1' OR rd_alien_boss_on='1' OR rd_play_alien_on='1')) ELSE
        '0' WHEN (keyboard_code = spacebar) ELSE
        ship_projectil_1_hit_reg;

    -- -- Projectil Hit State
    -- PROCESS (ship_projectil_1_hit_reg, ship_projectil_1_on, ship_projectil_1_y_b, rd_alien_1_on, rd_alien_2_on)
    -- BEGIN
    --     ship_projectil_1_hit_next <= ship_projectil_1_hit_reg;
    --     IF ship_projectil_1_hit_reg = '1' THEN
    --         ship_projectil_1_hit_next <= '0';
    --     ELSIF (ship_projectil_1_on = '1') AND (rd_alien_1_on = '1' OR rd_alien_2_on = '1') THEN
    --         ship_projectil_1_hit_next <= '1';
    --     ELSIF (ship_projectil_1_y_b < 10) THEN
    --         ship_projectil_1_hit_next <= '1';
    --     END IF;
    -- END PROCESS;

    -- proj1_y_t <= proj1_y_t_reg;
    -- proj1_y_b <= proj1_y_t + PROJ_SIZE - 1;
    -- proj1_x_r <= proj1_x_l_reg + PROJ_WIDTH;
    -- proj1_x_l <= proj1_x_l_reg;

    -- proj1_on <=
    --     '1' WHEN (proj1_x_l_reg <= pix_x) AND (pix_x <= proj1_x_r) AND
    --     (proj1_y_t <= pix_y) AND (pix_y <= proj1_y_b) AND (proj1_hit_reg = '0')ELSE
    --     '0';
    proj1_rgb <= "101"; -- magenta  
    -- -- new projectile1 y-position 
    -- --Projectile y axis
    -- proj1_y_t_next <= ship_y_reg WHEN (proj1_hit_reg = '1') ELSE
    --     (proj1_y_t_reg - PROJ1_V) WHEN refr_tick = '1' ELSE
    --     proj1_y_t_reg;

    -- proj1_hit_next <= '1' WHEN (proj1_y_t < 3 OR gra_still = '1' OR (proj1_on = '1' AND rd_play_alien_on = '1') OR (rd_alien_boss_on = '1' AND proj1_on = '1')) ELSE
    --     '0' WHEN (keyboard_code = spacebar) ELSE
    --     proj1_hit_reg;

    -- --Projectile x axis
    -- proj1_x_l_next <= ship_x_reg WHEN (keyboard_code = spacebar AND proj1_hit_reg = '1') ELSE
    --     proj1_x_l_reg;

    ----------------------------------------------  
    -- Projectile 2
    ----------------------------------------------
    -- ship_projectil_2_x_l <= ship_projectil_2_x_reg;
    -- ship_projectil_2_y_t <= ship_projectil_2_y_reg;
    -- ship_projectil_2_x_r <= ship_projectil_2_x_l + PROJ_WIDTH - 1;
    -- ship_projectil_2_y_b <= ship_projectil_2_y_t + PROJ_SIZE - 1;
    -- ship_projectil_2_on <=
    --     '1' WHEN (ship_projectil_2_x_l <= pix_x) AND (pix_x <= ship_projectil_2_x_r) AND
    --     (ship_projectil_2_y_t <= pix_y) AND (pix_y <= ship_projectil_2_y_b) AND
    --     (ship_projectil_2_hit_reg = '0') ELSE
    --     '0';

    -- -- New Ship Projectil Position
    -- ship_projectil_2_x_next <=
    --     ship_x_reg + ship_SIZE WHEN (keyboard_code = spacebar AND ship_projectil_2_hit_reg = '1') ELSE
    --     ship_projectil_2_x_reg;
    -- ship_projectil_2_y_next <=
    --     ship_y_reg WHEN (keyboard_code = spacebar AND ship_projectil_2_hit_reg = '1') ELSE
    --     ship_projectil_2_y_reg - PROJ1_V WHEN refr_tick = '1' ELSE
    --     ship_projectil_2_y_reg;

    -- -- Ship Projectil Hit Flag Update
    -- ship_projectil_2_hit_next <= '1' WHEN (ship_projectil_2_y_t < 10 OR gra_still = '1') OR
    --     (ship_projectil_2_on = '1' AND (rd_alien_1_on = '1' OR rd_alien_2_on = '1')) ELSE
    --     '0' WHEN (keyboard_code = spacebar AND ship_projectil_2_hit_reg = '1' AND shoot_counter_reg > 50 AND shoot_counter_reg < 75) ELSE
    --     ship_projectil_2_hit_reg;

    ----------------------------------------------  
    -- Projectile 3
    ----------------------------------------------
    ship_projectil_3_x_l <= ship_projectil_3_x_reg;
    ship_projectil_3_y_t <= ship_projectil_3_y_reg;
    ship_projectil_3_x_r <= ship_projectil_3_x_l + PROJ_WIDTH - 1;
    ship_projectil_3_y_b <= ship_projectil_3_y_t + PROJ_SIZE - 1;
    ship_projectil_3_on <=
        '1' WHEN (ship_projectil_3_x_l <= pix_x) AND (pix_x <= ship_projectil_3_x_r) AND
        (ship_projectil_3_y_t <= pix_y) AND (pix_y <= ship_projectil_3_y_b) AND
        (ship_projectil_3_hit_reg = '0') ELSE
        '0';

    -- New Ship Projectil Position    
    ship_projectil_3_x_next <=
        ship_x_reg + ship_SIZE + ship_SIZE WHEN (ship_projectil_3_hit_reg = '1') ELSE
        ship_projectil_3_x_reg;
    ship_projectil_3_y_next <=
        ship_y_reg WHEN (ship_projectil_3_hit_reg = '1') ELSE
        ship_projectil_3_y_reg - PROJ1_V WHEN refr_tick = '1' ELSE
        ship_projectil_3_y_reg;

    -- Ship Projectil Hit Flag Update
    ship_projectil_3_hit_next <= '1' WHEN (ship_projectil_3_y_t < 3 OR gra_still = '1') OR
        (ship_projectil_3_on = '1' AND (rd_alien_1_on = '1' OR rd_alien_2_on = '1' OR rd_alien_boss_on='1' OR rd_play_alien_on='1')) ELSE
        '0' WHEN (keyboard_code = spacebar AND ship_projectil_3_hit_reg = '1' AND shoot_counter_reg > 100) ELSE
        ship_projectil_3_hit_reg;

    ----------------------------------------------
    -- Shoots Counter Incrementation Process
    ----------------------------------------------
    PROCESS (shoot_counter_reg, refr_tick, ship_projectil_1_hit_reg)
    BEGIN
        shoot_counter_next <= shoot_counter_reg;

        IF (ship_projectil_1_hit_reg = '0') THEN
            IF (refr_tick = '1') THEN
                shoot_counter_next <= shoot_counter_reg + 1;
                -- IF shoot_counter_reg = 101 THEN
                -- shoot_counter_next <= (OTHERS => '0');
                -- END IF;
            END IF;
        ELSE
            shoot_counter_next <= (OTHERS => '0');
        END IF;
    END PROCESS;


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
    rom_data_ship <= ship_ROM_2l(to_integer(rom_addr_ship)) WHEN ship_lives_reg = "10" ELSE
        ship_ROM_1l(to_integer(rom_addr_ship)) WHEN ship_lives_reg = "01" ELSE
        ship_ROM(to_integer(rom_addr_ship));

    rom_bit_ship <= rom_data_ship(to_integer(NOT rom_col_ship));
    rd_ship_on <=
        '1' WHEN (sq_ship_on = '1') AND (rom_bit_ship = '1') ELSE
        '0';
    ship_rgb <= "111"; --white
    ship_rgb_2 <= "110"; -- yellow
    ship_rgb_1 <= "100";-- red
    -- new ship position
    PROCESS (refr_tick, gra_still, ship_y_reg, ship_x_reg, keyboard_code, ship_got_hit)
    BEGIN
        ship_y_next <= ship_y_reg;
        ship_x_next <= ship_x_reg;

        IF gra_still = '1' OR ship_got_hit = '1' THEN --initial position of ship
            ship_x_next <= to_unsigned((WALL2_X_L + WALL1_X_R)/2, 10);
            ship_y_next <= to_unsigned((WALL_Y_B + WALL_Y_T2)/2, 10);
        ELSIF refr_tick = '1' THEN
            IF (keyboard_code = down_arrow) THEN
                IF (ship_y_reg > MAX_Y - 20) THEN
                    ship_y_next <= to_unsigned(20, 10);
                ELSE
                    ship_y_next <= ship_y_reg + ship_V; -- move down
                    --projectile new initial position
                    -- proj1_y_initial<= to_unsigned(to_integer(ship_y_reg + ship_V) - 16 - PROJ_SIZE, 10);
                END IF;
            ELSIF (keyboard_code = up_arrow) THEN

                --projectile new initial position
                -- proj1_y_initial<= to_unsigned(to_integer(ship_y_reg + ship_V) - 16 - PROJ_SIZE, 10);
                IF (ship_y_reg < 20) THEN
                    ship_y_next <= to_unsigned(MAX_Y - 20, 10);
                ELSE
                    ship_y_next <= ship_y_reg - ship_V; -- move up
                END IF;
            ELSIF (keyboard_code = right_arrow) THEN

                IF (ship_x_reg > MAX_X - 20) THEN
                    ship_x_next <= to_unsigned(20, 10);
                ELSE
                    ship_x_next <= ship_x_reg + ship_V; -- move right
                END IF;
            ELSIF (keyboard_code = left_arrow) THEN

                IF (ship_x_reg < 20) THEN
                    ship_x_next <= to_unsigned(MAX_X - 20, 10);
                ELSE
                    ship_x_next <= ship_x_reg - ship_V; -- move left
                END IF;
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
        '1' WHEN (sq_alien_1_on = '1') AND (rom_bit_alien = '1') AND (alien_alive_reg = '1') ELSE
        '0';
    alien_rgb <= "010"; -- green
    -- new alien position
    alien_x_next <=
        to_unsigned((MAX_X)/2 + 50, 10) WHEN (gra_still = '1' OR alien_alive_reg = '0') ELSE
        alien_x_reg + alien_vx_reg WHEN refr_tick = '1' ELSE
        alien_x_reg;
    alien_y_next <=
        to_unsigned((MAX_Y)/2 - 50, 10) WHEN (gra_still = '1' OR alien_alive_reg = '0') ELSE
        alien_y_reg WHEN refr_tick = '1' ELSE
        alien_y_reg;

    -- alien_alive <= alien_alive_reg;

    -- New alien velocity
    -- With new hit, miss signals

    PROCESS (alien_vx_reg, alien_x_l, alien_x_r
    , gra_still, alien_alive_reg, alien_hits_counter_reg)
    BEGIN
        alien_vx_next <= alien_vx_reg;
        -- alien_vy_next <= alien_vy_reg;
        IF gra_still = '1' THEN --initial velocity
            alien_vx_next <= ALIEN_V_N - alien_hits_counter_reg;
            -- alien_vy_next <= ALIEN_V_P;
            -- alien_vy_next <= to_unsigned(0, 10);
        ELSIF (alien_alive_reg = '1') THEN
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
        '1' WHEN (sq_alien_2_on = '1') AND (rom_bit_alien_2 = '1') AND (alien_2_alive_reg = '1') ELSE
        '0';
    alien_rgb <= "010"; -- green
    -- new alien position
    alien_2_x_next <=
        to_unsigned(((MAX_X)/2) + 100, 10) WHEN (gra_still = '1' OR alien_2_alive_reg = '0') ELSE
        alien_2_x_reg + alien_2_vx_reg WHEN refr_tick = '1' ELSE
        alien_2_x_reg;
    alien_2_y_next <=
        to_unsigned(((MAX_Y)/2) - 100, 10) WHEN (gra_still = '1' OR alien_2_alive_reg = '0') ELSE
        alien_2_y_reg WHEN refr_tick = '1' ELSE
        alien_2_y_reg;

    -- alien_2_alive <= alien_2_alive_reg;

    -- New alien 2 velocity

    PROCESS (alien_2_vx_reg, alien_2_x_l, alien_2_x_r, gra_still, alien_2_alive_reg, alien_2_hits_counter_reg)
    BEGIN
        alien_2_vx_next <= alien_2_vx_reg;
        -- alien_2_vy_next <= alien_2_vy_reg;

        IF gra_still = '1' THEN --initial velocity
            alien_2_vx_next <= ALIEN_V_N - alien_2_hits_counter_reg;
            -- alien_vy_next <= ALIEN_V_P;
            -- alien_2_vy_next <= to_unsigned(0, 10);
        ELSIF (alien_2_alive_reg = '1') THEN
            IF (alien_2_x_l < 1) THEN -- reach left border
                alien_2_vx_next <= ALIEN_V_P + alien_2_hits_counter_reg;
            ELSIF (alien_2_x_r > MAX_X) THEN -- reach right border
                -- miss <= '1'; -- a miss
                alien_2_vx_next <= ALIEN_V_N - alien_2_hits_counter_reg;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------  
    --- Playable Alien
    ----------------------------------------------
    -- Square Alien
    play_alien_x_l <= play_alien_x_reg;
    play_alien_y_t <= play_alien_y_reg;
    play_alien_x_r <= play_alien_x_l + ALIEN_SIZE + ALIEN_SIZE - 1;
    play_alien_y_b <= play_alien_y_t + ALIEN_SIZE + ALIEN_SIZE - 1;
    sq_play_alien_on <=
        '1' WHEN (play_alien_x_l <= pix_x) AND (pix_x <= play_alien_x_r) AND
        (play_alien_y_t <= pix_y) AND (pix_y <= play_alien_y_b) ELSE
        '0';
    -- Round Alien
    rom_addr_play_alien <= pix_y(3 DOWNTO 1) - play_alien_y_t(3 DOWNTO 1);
    rom_col_play_alien <= pix_x(3 DOWNTO 1) - play_alien_x_l(3 DOWNTO 1);
    rom_data_play_alien <= ALIEN_ROM(to_integer(rom_addr_play_alien) - 1) WHEN to_integer(rom_addr_play_alien) > 0
        ELSE
        ALIEN_ROM(7);
    rom_bit_play_alien <= rom_data_play_alien(to_integer(NOT rom_col_play_alien));
    rd_play_alien_on <=
        '1' WHEN (sq_play_alien_on = '1') AND (rom_bit_play_alien = '1') ELSE
        '0';
    --AND (play_alien_alive = '1') 
    play_alien_rgb <= "011"; -- cyan
    -- -- new alien position
    -- play_alien_x_next <=
    --     to_unsigned(((MAX_X)/2) + 50, 10) WHEN (gra_still = '1' OR play_alien_alive = '0') ELSE
    --     play_alien_x_reg + play_alien_vx_reg WHEN refr_tick = '1' ELSE
    --     play_alien_x_reg;
    -- play_alien_y_next <=
    --     to_unsigned(((MAX_Y)/2) - 50, 10) WHEN (gra_still = '1' OR play_alien_alive = '0') ELSE
    --     play_alien_y_reg + play_alien_vy_reg WHEN refr_tick = '1' ELSE
    --     play_alien_y_reg;

    -- play_alien_alive <= play_alien_alive_reg;

    -- New playable alien position

    PROCESS (refr_tick, gra_still, play_alien_y_reg, play_alien_x_reg, keyboard_code)
    BEGIN
        play_alien_x_next <= play_alien_x_reg;
        play_alien_y_next <= play_alien_y_reg;

        IF gra_still = '1' THEN --initial position of ship
            play_alien_x_next <= to_unsigned((MAX_X)/2, 10);
            play_alien_y_next <= to_unsigned(((MAX_Y)/2) - 50, 10);
        ELSIF refr_tick = '1' THEN
            IF (keyboard_code = j) THEN
                IF (play_alien_y_reg > MAX_Y - 20) THEN
                    play_alien_y_next <= to_unsigned(20, 10);
                ELSE
                    play_alien_y_next <= play_alien_y_reg + ship_v; -- move down
                END IF;
            ELSIF (keyboard_code = r) THEN
                IF (play_alien_y_reg < 20) THEN
                    play_alien_y_next <= to_unsigned(MAX_Y - 20, 10);
                ELSE
                    play_alien_y_next <= play_alien_y_reg - ship_v; -- move up
                END IF;
            ELSIF (keyboard_code = d) THEN
                IF (play_alien_x_reg < 20) THEN
                    play_alien_x_next <= to_unsigned(MAX_X - 20, 10);
                ELSE
                    play_alien_x_next <= play_alien_x_reg - ship_v; -- move left
                END IF;
            ELSIF (keyboard_code = g) THEN
                IF (play_alien_x_reg > MAX_X - 20) THEN
                    play_alien_x_next <= to_unsigned(20, 10);
                ELSE
                    play_alien_x_next <= play_alien_x_reg + ship_v; -- move right
                END IF;
            END IF;
        END IF;

    END PROCESS;
    ----------------------------------------------  
    --- Alien Boss
    ----------------------------------------------
    -- Square Alien
    alien_boss_x_l <= alien_boss_x_reg;
    alien_boss_y_t <= alien_boss_y_reg;
    alien_boss_x_r <= alien_boss_x_l + ALIEN_BOSS_SIZE + ALIEN_BOSS_SIZE + ALIEN_BOSS_SIZE + 4;
    alien_boss_y_b <= alien_boss_y_t + ALIEN_BOSS_SIZE + ALIEN_BOSS_SIZE + ALIEN_BOSS_SIZE + 4;
    sq_alien_boss_on <=
        '1' WHEN (alien_boss_x_l <= pix_x) AND (pix_x <= alien_boss_x_r) AND
        (alien_boss_y_t <= pix_y) AND (pix_y <= alien_boss_y_b) ELSE
        '0';
    -- Round Alien
    rom_addr_alien_boss <= pix_y(5 DOWNTO 2) - alien_boss_y_t(5 DOWNTO 2);
    rom_col_alien_boss <= pix_x(5 DOWNTO 2) - alien_boss_x_l(5 DOWNTO 2);
    rom_data_alien_boss <= ALIEN_BOSS_ROM(to_integer(rom_addr_alien_boss)) WHEN
        (alien_boss_lives_reg > 5) ELSE
        ALIEN_BOSS_2_ROM(to_integer(rom_addr_alien_boss));

    rom_bit_alien_boss <= rom_data_alien_boss(to_integer(NOT rom_col_alien_boss));
    rd_alien_boss_on <=
        '1' WHEN (sq_alien_boss_on = '1') AND (rom_bit_alien_boss = '1') AND (alien_boss_alive = '1') ELSE
        '0';
    alien_boss_rgb <= "100"; -- red
    -- new alien position
    alien_boss_x_next <=
        to_unsigned(((MAX_X)/2) + 200, 10) WHEN (gra_still = '1' OR alien_boss_alive = '0') ELSE
        alien_boss_x_reg + alien_boss_vx_reg WHEN refr_tick = '1' ELSE
        alien_boss_x_reg;
    alien_boss_y_next <=
        to_unsigned(((MAX_Y)/2) - 200, 10) WHEN (gra_still = '1' OR alien_boss_alive = '0') ELSE
        alien_boss_y_reg + alien_boss_vy_reg WHEN refr_tick = '1' ELSE
        alien_boss_y_reg;

    alien_boss_alive <= alien_boss_alive_reg;

    -- New alien bosss velocity

    PROCESS (alien_boss_vx_reg, alien_boss_vy_reg, alien_boss_x_l, alien_boss_x_r, gra_still, alien_boss_alive, alien_boss_hits_counter_reg)
    BEGIN
        alien_boss_vx_next <= alien_boss_vx_reg;
        alien_boss_vy_next <= alien_boss_vy_reg;

        IF gra_still = '1' THEN --initial velocity
            alien_boss_vx_next <= ALIEN_V_N - alien_boss_hits_counter_reg;
            -- alien_vy_next <= ALIEN_V_P;
            alien_boss_vy_next <= to_unsigned(0, 10);
        ELSIF (alien_boss_alive = '1') THEN
            IF (alien_boss_x_l < 1) THEN -- reach left border
                alien_boss_vx_next <= ALIEN_V_P + alien_boss_hits_counter_reg;
            ELSIF (alien_boss_x_r > MAX_X) THEN -- reach right border
                -- miss <= '1'; -- a miss
                alien_boss_vx_next <= ALIEN_V_N - alien_boss_hits_counter_reg;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------  
    --- Aliens Elimination Process
    ----------------------------------------------
    PROCESS (alien_alive_reg, alien_2_alive_reg, alien_alive_next, alien_2_alive_next, rd_alien_1_on, rd_alien_2_on, 
        alien_hits_counter_reg, alien_2_hits_counter_reg, rd_play_alien_on, play_alien_hits_counter_reg,
        play_alien_alive_reg, alien_boss_alive_reg, rd_alien_boss_on, alien_boss_hits_counter_reg,
        alien_boss_alive_next, alien_boss_lives_reg,ship_projectil_1_on,ship_projectil_3_on)
                -- alien_boss_alive_next, alien_boss_lives_reg, alien_2_alive, alien_alive,ship_projectil_2_on,ship_projectil_1_on,ship_projectil_3_on)

    BEGIN
        hit <= '0';
        alien_alive_next <= alien_alive_reg;
        alien_2_alive_next <= alien_2_alive_reg;
        alien_boss_alive_next <= alien_boss_alive_reg;
        alien_hits_counter_next <= alien_hits_counter_reg;
        alien_2_hits_counter_next <= alien_2_hits_counter_reg;
        play_alien_alive_next <= play_alien_alive_reg;
        play_alien_hits_counter_next <= play_alien_hits_counter_reg;
        alien_boss_hits_counter_next <= alien_boss_hits_counter_reg;
        alien_boss_lives_next <= alien_boss_lives_reg;
        IF (alien_alive_next = '0' AND alien_2_alive_next = '0' AND alien_boss_alive_next = '0') THEN
            alien_alive_next <= '1';
            alien_2_alive_next <= '1';
            alien_boss_alive_next <= '1';
            alien_boss_lives_next <= "1010";

        END IF;
        IF (rd_alien_1_on = '1' AND (ship_projectil_1_on = '1' OR ship_projectil_3_on = '1')) THEN
                -- IF (rd_alien_1_on = '1' AND (ship_projectil_2_on = '1' OR ship_projectil_1_on = '1' OR ship_projectil_3_on = '1')) THEN

            alien_alive_next <= '0';
            hit <= '1';
            IF (alien_alive_reg = '1') THEN
                alien_hits_counter_next <= alien_hits_counter_reg + 1;
            END IF;
        END IF;

        IF (rd_alien_2_on = '1' AND (ship_projectil_1_on = '1' OR ship_projectil_3_on = '1')) THEN
                -- IF (rd_alien_2_on = '1' AND (ship_projectil_2_on = '1' OR ship_projectil_1_on = '1' OR ship_projectil_3_on = '1')) THEN

            alien_2_alive_next <= '0';
            hit <= '1';
            IF (alien_2_alive_reg = '1') THEN
                alien_2_hits_counter_next <= alien_2_hits_counter_reg + 1;
            END IF;
        END IF;
        IF (rd_play_alien_on = '1'  AND ( ship_projectil_1_on = '1' OR ship_projectil_3_on = '1')) THEN
                -- IF (rd_play_alien_on = '1'  AND (ship_projectil_2_on = '1' OR ship_projectil_1_on = '1' OR ship_projectil_3_on = '1')) THEN

            play_alien_alive_next <= '0';
            hit <= '1';
            -- IF (play_alien_alive = '1') THEN
            IF (play_alien_hits_counter_reg < 2) THEN
                play_alien_hits_counter_next <= play_alien_hits_counter_reg + 1;
            ELSE
                play_alien_hits_counter_next <= (OTHERS => '0');
            END IF;
        END IF;
        IF (rd_alien_boss_on = '1'  AND ( ship_projectil_1_on = '1' OR ship_projectil_3_on = '1')) THEN
                -- IF (rd_alien_boss_on = '1'  AND (ship_projectil_2_on = '1' OR ship_projectil_1_on = '1' OR ship_projectil_3_on = '1')) THEN

            alien_boss_hits_counter_next <= alien_boss_hits_counter_reg + 1;
            alien_boss_lives_next <= alien_boss_lives_reg - 1;
            IF (alien_boss_lives_reg = "0000") THEN
                alien_boss_alive_next <= '0';
            END IF;
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
        (alien_alive_reg = '1') ELSE
        '0';

    -- Projectil Hit State
    alien_projectil_x_next <=
        alien_x_reg WHEN (gra_still = '1' OR alien_projectil_hit_reg = '1') ELSE
        alien_projectil_x_reg;
    alien_projectil_y_next <=
        alien_y_reg WHEN (gra_still = '1' OR alien_projectil_hit_reg = '1') ELSE
        alien_projectil_y_reg + ALIEN_PROJ_V_MOVE + alien_hits_counter_reg WHEN refr_tick = '1' ELSE
        alien_projectil_y_reg;

    PROCESS (alien_alive_reg, alien_projectil_hit_reg, alien_projectil_on, rd_ship_on, alien_projectil_y_b)
    BEGIN
        alien_projectil_hit_next <= alien_projectil_hit_reg;
        -- ship_lives_next <= ship_lives_reg;
        IF (alien_alive_reg = '1') THEN
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
    --- Projectil 2
    -- ----------------------------------------------
    -- alien_projectil_2_x_l <= alien_projectil_2_x_reg;
    -- alien_projectil_2_y_t <= alien_projectil_2_y_reg;
    -- alien_projectil_2_x_r <= alien_projectil_2_x_l + ALIEN_PROJECTIL_WIDTH - 1;
    -- alien_projectil_2_y_b <= alien_projectil_2_y_t + ALIEN_PROJECTIL_SIZE - 1;
    -- alien_projectil_2_on <=
    --     '1' WHEN (alien_projectil_2_x_l <= pix_x) AND (pix_x <= alien_projectil_2_x_r) AND
    --     (alien_projectil_2_y_t <= pix_y) AND (pix_y <= alien_projectil_2_y_b)
    --     AND (alien_projectil_2_hit_reg = '0') AND (alien_alive = '1') AND (alien_hits_counter_reg > 2) ELSE
    --     '0';

    -- -- Projectil Hit State
    -- alien_projectil_2_x_next <=
    --     alien_x_reg + 8 WHEN (gra_still = '1' OR alien_projectil_2_hit_reg = '1') ELSE
    --     alien_projectil_2_x_reg;
    -- alien_projectil_2_y_next <=
    --     alien_y_reg WHEN (gra_still = '1' OR alien_projectil_2_hit_reg = '1') ELSE
    --     alien_projectil_2_y_reg + ALIEN_PROJ_V_MOVE WHEN refr_tick = '1' ELSE
    --     alien_projectil_2_y_reg;

    -- -- Projectil Hit State
    -- PROCESS (alien_alive, alien_projectil_2_hit_reg, alien_projectil_2_on, rd_ship_on, alien_projectil_2_y_b)
    -- BEGIN
    --     alien_projectil_2_hit_next <= alien_projectil_2_hit_reg;
    --     IF (alien_alive = '1') THEN
    --         IF alien_projectil_2_hit_reg = '1' THEN
    --             alien_projectil_2_hit_next <= '0';
    --         ELSIF (alien_projectil_2_on = '1' AND rd_ship_on = '1') THEN
    --             alien_projectil_2_hit_next <= '1';
    --         ELSIF (alien_projectil_2_y_b > MAX_Y) THEN
    --             alien_projectil_2_hit_next <= '1';
    --         END IF;
    --     END IF;
    -- END PROCESS;

    -- ----------------------------------------------  
    -- --- Projectil 3
    -- ----------------------------------------------
    -- alien_projectil_3_x_l <= alien_projectil_3_x_reg;
    -- alien_projectil_3_y_t <= alien_projectil_3_y_reg;
    -- alien_projectil_3_x_r <= alien_projectil_3_x_l + ALIEN_PROJECTIL_WIDTH - 1;
    -- alien_projectil_3_y_b <= alien_projectil_3_y_t + ALIEN_PROJECTIL_SIZE - 1;
    -- alien_projectil_3_on <=
    --     '1' WHEN (alien_projectil_3_x_l <= pix_x) AND (pix_x <= alien_projectil_3_x_r) AND
    --     (alien_projectil_3_y_t <= pix_y) AND (pix_y <= alien_projectil_3_y_b)
    --     AND (alien_projectil_3_hit_reg = '0') AND (alien_alive = '1') AND (alien_hits_counter_reg > 2) ELSE
    --     '0';

    -- -- New Projectil Position
    -- alien_projectil_3_x_next <=
    --     alien_x_reg + 16 WHEN (gra_still = '1' OR alien_projectil_3_hit_reg = '1') ELSE
    --     alien_projectil_3_x_reg;
    -- alien_projectil_3_y_next <=
    --     alien_y_reg WHEN (gra_still = '1' OR alien_projectil_3_hit_reg = '1') ELSE
    --     alien_projectil_3_y_reg + ALIEN_PROJ_V_MOVE WHEN refr_tick = '1' ELSE
    --     alien_projectil_3_y_reg;

    -- -- Projectil Hit State
    -- PROCESS (alien_alive, alien_projectil_3_hit_reg, alien_projectil_3_on, rd_ship_on, alien_projectil_3_y_b)
    -- BEGIN
    --     alien_projectil_3_hit_next <= alien_projectil_3_hit_reg;
    --     IF (alien_alive = '1') THEN
    --         IF alien_projectil_3_hit_reg = '1' THEN
    --             alien_projectil_3_hit_next <= '0';
    --         ELSIF (alien_projectil_3_on = '1' AND rd_ship_on = '1') THEN
    --             alien_projectil_3_hit_next <= '1';
    --         ELSIF (alien_projectil_3_y_b > MAX_Y) THEN
    --             alien_projectil_3_hit_next <= '1';
    --         END IF;
    --     END IF;
    -- END PROCESS;

    ----------------------------------------------  
    -------------- Alien 2 --------------
    ----------------------------------------------

    ----------------------------------------------  
    --- Projectil 1
    ----------------------------------------------
    alien_2_projectil_x_l <= alien_2_projectil_x_reg;
    alien_2_projectil_y_t <= alien_2_projectil_y_reg;
    alien_2_projectil_x_r <= alien_2_projectil_x_l + ALIEN_PROJECTIL_WIDTH - 1;
    alien_2_projectil_y_b <= alien_2_projectil_y_t + ALIEN_PROJECTIL_SIZE - 1;
    alien_2_projectil_on <=
        '1' WHEN (alien_2_projectil_x_l <= pix_x) AND (pix_x <= alien_2_projectil_x_r) AND
        (alien_2_projectil_y_t <= pix_y) AND (pix_y <= alien_2_projectil_y_b) AND (alien_2_projectil_hit_reg = '0') AND (alien_2_alive_reg = '1') ELSE
        '0';

    alien_2_projectil_x_next <=
        alien_2_x_reg WHEN (gra_still = '1' OR alien_2_projectil_hit_reg = '1') ELSE
        alien_2_projectil_x_reg;
    alien_2_projectil_y_next <=
        alien_2_y_reg WHEN (gra_still = '1' OR alien_2_projectil_hit_reg = '1') ELSE
        alien_2_projectil_y_reg + ALIEN_PROJ_V_MOVE + alien_2_hits_counter_reg WHEN refr_tick = '1' ELSE
        alien_2_projectil_y_reg;

    PROCESS (alien_2_alive_reg, alien_2_projectil_hit_reg, alien_2_projectil_on, rd_ship_on, alien_2_projectil_y_b)
    BEGIN
        alien_2_projectil_hit_next <= alien_2_projectil_hit_reg;
        -- ship_lives_next <= ship_lives_reg;
        IF (alien_2_alive_reg = '1') THEN
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

    ----------------------------------------------  
    --- Projectil 2
    ----------------------------------------------
    -- alien_2_projectil_2_x_l <= alien_2_projectil_2_x_reg;
    -- alien_2_projectil_2_y_t <= alien_2_projectil_2_y_reg;
    -- alien_2_projectil_2_x_r <= alien_2_projectil_2_x_l + ALIEN_PROJECTIL_WIDTH - 1;
    -- alien_2_projectil_2_y_b <= alien_2_projectil_2_y_t + ALIEN_PROJECTIL_SIZE - 1;
    -- alien_2_projectil_2_on <=
    --     '1' WHEN (alien_2_projectil_2_x_l <= pix_x) AND (pix_x <= alien_2_projectil_2_x_r) AND
    --     (alien_2_projectil_2_y_t <= pix_y) AND (pix_y <= alien_2_projectil_2_y_b)
    --     AND (alien_2_projectil_2_hit_reg = '0') AND (alien_2_alive = '1') AND (alien_2_hits_counter_reg > 2) ELSE
    --     '0';

    -- -- Projectil Hit State
    -- alien_2_projectil_2_x_next <=
    --     alien_2_x_reg + 8 WHEN (gra_still = '1' OR alien_2_projectil_2_hit_reg = '1') ELSE
    --     alien_2_projectil_2_x_reg;
    -- alien_2_projectil_2_y_next <=
    --     alien_2_y_reg WHEN (gra_still = '1' OR alien_2_projectil_2_hit_reg = '1') ELSE
    --     alien_2_projectil_2_y_reg + ALIEN_PROJ_V_MOVE WHEN refr_tick = '1' ELSE
    --     alien_2_projectil_2_y_reg;

    -- -- Projectil Hit State
    -- PROCESS (alien_2_alive, alien_2_projectil_2_hit_reg, alien_2_projectil_2_on, rd_ship_on, alien_2_projectil_2_y_b)
    -- BEGIN
    --     alien_2_projectil_2_hit_next <= alien_2_projectil_2_hit_reg;
    --     IF (alien_2_alive = '1') THEN
    --         IF alien_2_projectil_2_hit_reg = '1' THEN
    --             alien_2_projectil_2_hit_next <= '0';
    --         ELSIF (alien_2_projectil_2_on = '1' AND rd_ship_on = '1') THEN
    --             alien_2_projectil_2_hit_next <= '1';
    --         ELSIF (alien_2_projectil_2_y_b > MAX_Y) THEN
    --             alien_2_projectil_2_hit_next <= '1';
    --         END IF;
    --     END IF;
    -- END PROCESS;

    -- ----------------------------------------------  
    -- --- Projectil 3
    -- ----------------------------------------------
    -- alien_2_projectil_3_x_l <= alien_2_projectil_3_x_reg;
    -- alien_2_projectil_3_y_t <= alien_2_projectil_3_y_reg;
    -- alien_2_projectil_3_x_r <= alien_2_projectil_3_x_l + ALIEN_PROJECTIL_WIDTH - 1;
    -- alien_2_projectil_3_y_b <= alien_2_projectil_3_y_t + ALIEN_PROJECTIL_SIZE - 1;
    -- alien_2_projectil_3_on <=
    --     '1' WHEN (alien_2_projectil_3_x_l <= pix_x) AND (pix_x <= alien_2_projectil_3_x_r) AND
    --     (alien_2_projectil_3_y_t <= pix_y) AND (pix_y <= alien_2_projectil_3_y_b)
    --     AND (alien_2_projectil_3_hit_reg = '0') AND (alien_2_alive = '1') AND (alien_2_hits_counter_reg > 2) ELSE
    --     '0';

    -- -- New Projectil Position
    -- alien_2_projectil_3_x_next <=
    --     alien_2_x_reg + 16 WHEN (gra_still = '1' OR alien_2_projectil_3_hit_reg = '1') ELSE
    --     alien_2_projectil_3_x_reg;
    -- alien_2_projectil_3_y_next <=
    --     alien_2_y_reg WHEN (gra_still = '1' OR alien_2_projectil_3_hit_reg = '1') ELSE
    --     alien_2_projectil_3_y_reg + ALIEN_PROJ_V_MOVE WHEN refr_tick = '1' ELSE
    --     alien_2_projectil_3_y_reg;

    -- -- Projectil Hit State
    -- PROCESS (alien_2_alive, alien_2_projectil_3_hit_reg, alien_2_projectil_3_on, rd_ship_on, alien_2_projectil_3_y_b)
    -- BEGIN
    --     alien_2_projectil_3_hit_next <= alien_2_projectil_3_hit_reg;
    --     IF (alien_2_alive = '1') THEN
    --         IF alien_2_projectil_3_hit_reg = '1' THEN
    --             alien_2_projectil_3_hit_next <= '0';
    --         ELSIF (alien_2_projectil_3_on = '1' AND rd_ship_on = '1') THEN
    --             alien_2_projectil_3_hit_next <= '1';
    --         ELSIF (alien_2_projectil_3_y_b > MAX_Y) THEN
    --             alien_2_projectil_3_hit_next <= '1';
    --         END IF;
    --     END IF;
    -- END PROCESS;

    ----------------------------------------------  
    --- Alien Boss Projectil
    ----------------------------------------------
    alien_boss_projectil_x_l <= alien_boss_projectil_x_reg;
    alien_boss_projectil_y_t <= alien_boss_projectil_y_reg;
    alien_boss_projectil_x_r <= alien_boss_projectil_x_l + ALIEN_PROJECTIL_WIDTH - 1;
    alien_boss_projectil_y_b <= alien_boss_projectil_y_t + ALIEN_PROJECTIL_SIZE - 1;
    alien_boss_projectil_on <=
        '1' WHEN (alien_boss_projectil_x_l <= pix_x) AND (pix_x <= alien_boss_projectil_x_r) AND
        (alien_boss_projectil_y_t <= pix_y) AND (pix_y <= alien_boss_projectil_y_b) AND (alien_boss_projectil_hit_reg = '0') AND (alien_boss_alive = '1') ELSE
        '0';

    alien_boss_projectil_x_next <=
        (alien_boss_x_reg + ALIEN_BOSS_SIZE + ALIEN_BOSS_SIZE)WHEN (gra_still = '1' OR alien_boss_projectil_hit_reg = '1') ELSE
        alien_boss_projectil_x_reg;
    alien_boss_projectil_y_next <=
        (alien_boss_y_reg + ALIEN_BOSS_SIZE) WHEN (gra_still = '1' OR alien_boss_projectil_hit_reg = '1') ELSE
        alien_boss_projectil_y_reg + ALIEN_PROJ_V_MOVE + alien_boss_hits_counter_reg WHEN refr_tick = '1' ELSE
        alien_boss_projectil_y_reg;

    PROCESS (alien_boss_alive, alien_boss_projectil_hit_reg, alien_boss_projectil_on, rd_ship_on, alien_boss_projectil_y_b)
    BEGIN
        alien_boss_projectil_hit_next <= alien_boss_projectil_hit_reg;
        -- ship_lives_next <= ship_lives_reg;
        IF (alien_boss_alive = '1') THEN
            IF alien_boss_projectil_hit_reg = '1' THEN
                alien_boss_projectil_hit_next <= '0';
            ELSIF (alien_boss_projectil_on = '1' AND rd_ship_on = '1') THEN
                alien_boss_projectil_hit_next <= '1';
                --  ship_lives_next<=ship_lives_reg-1;
            ELSIF (alien_boss_projectil_y_b > MAX_Y) THEN
                alien_boss_projectil_hit_next <= '1';
            END IF;
        END IF;
    END PROCESS;

    --aliens hitting ship
    PROCESS (alien_alive_reg, alien_2_alive_reg, alien_projectil_on, alien_2_projectil_on,
        rd_ship_on, ship_lives_reg, alien_boss_alive, alien_boss_projectil_on, ship_got_hit)
    BEGIN
        miss <= '0';
        ship_lives_next <= ship_lives_reg;
        IF (alien_2_alive_reg = '1' AND alien_2_projectil_on = '1' AND rd_ship_on = '1') THEN
            ship_lives_next <= ship_lives_reg - 1;
            miss <= '1';
        ELSIF (alien_alive_reg = '1' AND alien_projectil_on = '1' AND rd_ship_on = '1') THEN
            ship_lives_next <= ship_lives_reg - 1;
            miss <= '1';
        ELSIF (alien_boss_alive = '1' AND alien_boss_projectil_on = '1' AND rd_ship_on = '1') THEN
            ship_lives_next <= ship_lives_reg - 1;
            miss <= '1';
        ELSIF (ship_got_hit = '1') THEN
            ship_lives_next <= ship_lives_reg - 1;
            miss <= '1';
        END IF;
    END PROCESS;

    --ship collision damage
    PROCESS (alien_alive_reg, alien_2_alive_reg, rd_alien_2_on, rd_alien_1_on, rd_alien_boss_on,
        rd_ship_on, alien_boss_alive)
    BEGIN
        ship_got_hit <= '0';
        IF (alien_2_alive_reg = '1' AND rd_alien_2_on = '1' AND rd_ship_on = '1') THEN
            ship_got_hit <= '1';
        ELSIF (alien_alive_reg = '1' AND rd_alien_1_on = '1' AND rd_ship_on = '1') THEN
            ship_got_hit <= '1';
        ELSIF (alien_boss_alive = '1' AND rd_alien_boss_on = '1' AND rd_ship_on = '1') THEN
            ship_got_hit <= '1';
        END IF;
    END PROCESS;
    ----------------------------------------------  
    -- Playable Alien Projectile 1
    ----------------------------------------------
    play_alien_projectil_1_x_l <= play_alien_projectil_1_x_reg;
    play_alien_projectil_1_y_t <= play_alien_projectil_1_y_reg;
    play_alien_projectil_1_x_r <= play_alien_projectil_1_x_l + PROJ_WIDTH - 1;
    play_alien_projectil_1_y_b <= play_alien_projectil_1_y_t + PROJ_SIZE - 1;
    play_alien_projectil_1_on <=
        '1' WHEN (play_alien_projectil_1_x_l <= pix_x) AND (pix_x <= play_alien_projectil_1_x_r) AND
        (play_alien_projectil_1_y_t <= pix_y) AND (pix_y <= play_alien_projectil_1_y_b) AND
        (play_alien_projectil_1_hit_reg = '0') ELSE
        '0';

    -- New Playable Alien Projectil Position
    play_alien_projectil_1_x_next <=
        play_alien_x_reg + 8 WHEN (keyboard_code = f AND play_alien_projectil_1_hit_reg = '1') ELSE
        play_alien_projectil_1_x_reg;
    play_alien_projectil_1_y_next <=
        play_alien_y_reg WHEN (keyboard_code = f AND play_alien_projectil_1_hit_reg = '1') ELSE
        play_alien_projectil_1_y_reg + PROJ1_V WHEN refr_tick = '1' ELSE
        play_alien_projectil_1_y_reg;

    -- Ship Projectil Hit Flag Update
    play_alien_projectil_1_hit_next <= '1' WHEN (play_alien_projectil_1_y_t > MAX_Y - 1 OR gra_still = '1') ELSE
        '0' WHEN (keyboard_code = f) ELSE
        play_alien_projectil_1_hit_reg;
    -- rgb multiplexing circuit
    PROCESS (proj1_rgb, rd_alien_1_on, rd_alien_2_on, alien_rgb,
        alien_projectil_on, alien_2_projectil_on, ship_lives_reg, ship_rgb, rd_ship_on, ship_rgb_2,
        ship_rgb_1, alien_boss_projectil_on, alien_boss_rgb, rd_alien_boss_on, rd_play_alien_on, play_alien_projectil_1_on,
        play_alien_hits_counter_reg, play_alien_rgb,ship_projectil_1_on,ship_projectil_3_on)
                -- play_alien_hits_counter_reg, play_alien_rgb,ship_projectil_1_on,ship_projectil_2_on,ship_projectil_3_on)

    BEGIN

        IF rd_ship_on = '1' AND ship_lives_reg = "11" THEN
            rgb <= ship_rgb;
        ELSIF rd_ship_on = '1' AND ship_lives_reg = "10" THEN
            rgb <= ship_rgb_2;
        ELSIF rd_ship_on = '1' AND ship_lives_reg = "01" THEN
            rgb <= ship_rgb_1;
        ELSIF (rd_alien_1_on = '1' OR rd_alien_2_on = '1') THEN
            rgb <= alien_rgb;
        ELSIF (alien_projectil_on = '1' OR
            --  alien_2_projectil_2_on = '1'OR alien_projectil_2_on = '1'  OR alien_2_projectil_on = '1' OR alien_2_projectil_2_on = '1' OR alien_2_projectil_3_on = '1' OR alien_projectil_3_on = '1') THEN
            alien_2_projectil_on = '1') THEN
            rgb <= alien_rgb;
        ELSIF (ship_projectil_1_on = '1' OR  ship_projectil_3_on = '1' ) THEN
                -- ELSIF (ship_projectil_1_on = '1' OR ship_projectil_2_on = '1' OR ship_projectil_3_on = '1' ) THEN

            rgb <= proj1_rgb;
        ELSIF (rd_play_alien_on = '1' OR play_alien_projectil_1_on = '1') THEN
            IF (play_alien_hits_counter_reg = 0) THEN
                rgb <= play_alien_rgb;
            ELSIF (play_alien_hits_counter_reg = 1) THEN
                rgb <= "110";
            ELSE
                rgb <= "101";
            END IF;
        ELSIF (rd_alien_boss_on = '1') THEN
            rgb <= alien_boss_rgb;
        ELSIF (alien_boss_projectil_on = '1') THEN
            rgb <= alien_boss_rgb;
        ELSE
            rgb <= "111"; -- black background
        END IF;
    END PROCESS;
    --OR rd_play_alien_on OR play_alien_projectil_1_on
    graph_on <= rd_ship_on OR rd_alien_1_on OR rd_alien_2_on  OR alien_projectil_on OR
        alien_2_projectil_on OR
        -- alien_2_projectil_3_on OR rd_play_alien_on OR play_alien_projectil_1_on OR alien_boss_projectil_on OR rd_alien_boss_on OR alien_projectil_3_on ;
        rd_play_alien_on OR play_alien_projectil_1_on OR alien_boss_projectil_on OR rd_alien_boss_on OR
        ship_projectil_1_on OR ship_projectil_3_on;
                -- ship_projectil_1_on OR ship_projectil_2_on OR ship_projectil_3_on;

END arch;