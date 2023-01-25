-- Listing 13.6
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY pong_text IS
   PORT (
      clk, reset : IN STD_LOGIC;
      pixel_x, pixel_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      dig0, dig1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      ball : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      text_on : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      text_rgb : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
   );
END pong_text;

ARCHITECTURE arch OF pong_text IS
   SIGNAL pix_x, pix_y : unsigned(9 DOWNTO 0);
   SIGNAL rom_addr : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL char_addr, char_addr_s, char_addr_s_2p, char_addr_r,
   char_addr_o : STD_LOGIC_VECTOR(6 DOWNTO 0);
   SIGNAL row_addr, row_addr_s, row_addr_s_2p, row_addr_r,
   row_addr_o : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL bit_addr, bit_addr_s, bit_addr_s_2p, bit_addr_r,
   bit_addr_o : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL font_word : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL font_bit : STD_LOGIC;
   SIGNAL score_on, score_2p_on, rule_on, over_on : STD_LOGIC;

   SIGNAL rule_rom_addr : unsigned(6 DOWNTO 0);
   TYPE rule_rom_type IS ARRAY (0 TO 95) OF
   STD_LOGIC_VECTOR (6 DOWNTO 0);
   -- rull text ROM definition
   CONSTANT RULE_ROM : rule_rom_type :=
   (
   -- row 1

   "0000000", -- 
   "1010011", -- S
   "1010000", -- P
   "1000001", -- A
   "1000011", -- C
   "1000101", -- E
   "0000000", --
   "1001001", -- I
   "1001110", -- N
   "1010110", -- V
   "1000001", -- A
   "1000100", -- D
   "1000101", -- E
   "1010010", -- R
   "1010011", -- S
   "0000000", --
   -- row 2
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   -- row 3
   "0000000", -- 
   "0000000", --
   "1010000", -- P
   "1001100", -- L
   "1000101", -- E
   "1000001", -- A
   "1010011", -- S
   "1000101", -- E
   "0000000", -- 
   "1010000", -- P
   "1010010", -- R
   "1000101", -- E
   "1010011", -- S
   "1010011", -- S
   "0000000", -- 
   "0000000", --   
   --row 4
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --
   "0000000", --    
   -- row 5
   "0000000", -- 
   "1000101", -- E
   "1001110", -- N
   "1010100", -- T
   "1000101", -- E
   "1010010", -- R
   "0000000", -- 
   "0101000", -- ( x28
   "1010110", -- V x56
   "1010011", -- S x53
   "0000000", --  
   "0000000", --        
   "1010000", -- P
   "1000011", -- C x43
   "0101001", -- ) x29
   "0000000", --        
   -- row 6
   "0000000", -- 
   "1010011", -- S
   "1010000", -- P
   "1000001", -- A
   "1000011", -- C
   "1000101", -- E
   "0000000", -- 
   "0101000", -- ( x28
   "1010110", -- V x56
   "1010011", -- S x53
   "0000000", --  
   "0000000", --        
   "1010000", -- P
   "0110010", -- 2 x32
   "0101001", -- ) x29
   "0000000" --
   );
BEGIN
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   -- instantiate font rom
   font_unit : ENTITY work.font_rom
      PORT MAP(clk => clk, reset => reset, addr => rom_addr, data => font_word);

   ---------------------------------------------
   -- score region
   --  - display two-digit score, ball on top left
   --  - scale to 16-by-32 font
   --  - line 1, 16 chars: "Score:DD Ball:D"
   ---------------------------------------------
   score_on <=
      '1' WHEN pix_y(9 DOWNTO 5) = 0 AND
      pix_x(9 DOWNTO 4) < 24 ELSE
      '0';
   row_addr_s <= STD_LOGIC_VECTOR(pix_y(4 DOWNTO 1));
   bit_addr_s <= STD_LOGIC_VECTOR(pix_x(3 DOWNTO 1));
   WITH pix_x(8 DOWNTO 4) SELECT
   char_addr_s <=
      "1010011" WHEN "00000", -- S x53
      "1100011" WHEN "00001", -- c x63
      "1101111" WHEN "00010", -- o x6f
      "1110010" WHEN "00011", -- r x72
      "1100101" WHEN "00100", -- e x65
      "0111010" WHEN "00101", -- : x3a
      "011" & dig1 WHEN "00110", -- digit 10
      "011" & dig0 WHEN "00111", -- digit 1
      "0000000" WHEN "01000",
      "1001100" WHEN "01001", -- L x4c
      "1101001" WHEN "01010", -- i x69
      "1110110" WHEN "01011", -- v x76
      "1100101" WHEN "01100", -- e x65
      "1110011" WHEN "01101", -- s x73
      "0111010" WHEN "01110", -- :
      "01100" & ball WHEN "01111",
      "1010011" WHEN "10000", -- S x53
      "1100011" WHEN "10001", -- c x63
      "1101111" WHEN "10010", -- o x6f
      "1110010" WHEN "10011", -- r x72
      "1100101" WHEN "10100", -- e x65
      "0111010" WHEN "10101", -- : x3a
      "011" & dig1 WHEN "10110", -- digit 10
      "011" & dig0 WHEN "10111", -- digit 1
      "0000000" WHEN OTHERS;
   ---------------------------------------------
   -- score region 2
   --  - display two-digit score, ball on top left
   --  - scale to 16-by-32 font
   --  - line 1, 16 chars: "Score:DD Ball:D"
   ---------------------------------------------
   -- score_2p_on <=
   --    '1' when pix_y(9 downto 5)=20 and
   --             pix_x(9 downto 4)<16 else
   --    '0';
   -- row_addr_s_2p <= std_logic_vector(pix_y(4 downto 1));
   -- bit_addr_s_2p <= std_logic_vector(pix_x(3 downto 1));
   -- with pix_x(7 downto 4) select
   --   char_addr_s_2p <=
   --      "1010011" when "0000", -- S x53
   --      "1100011" when "0001", -- c x63
   --      "1101111" when "0010", -- o x6f
   --      "1110010" when "0011", -- r x72
   --      "1100101" when "0100", -- e x65
   --      "0111010" when "0101", -- : x3a
   --      "011" & dig1 when "0110", -- digit 10
   --      "011" & dig0 when "0111", -- digit 1
   --      "0000000" when "1000",
   --      "1001100" when "1001", -- L x4c
   --      "1101001" when "1010", -- i x69
   --      "1110110" when "1011", -- v x76
   --      "1100101" when "1100", -- e x65
   --      "1110011" when "1101", -- s x73
   --      "0111010" when "1110", -- :
   --      "01100" & ball when others;
   ---------------------------------------------
   -- rule region
   --   - display rule (4-by-16 tiles)on center
   --   - rule text:
   --        SPACE INVADERS
   --
   --         PLEASE PRESS
   --        ENTER TO START
   ---------------------------------------------
   rule_on <= '1' WHEN pix_x(9 DOWNTO 7) = "010" AND
      pix_y(9 DOWNTO 7) = "001" ELSE
      '0';
   row_addr_r <= STD_LOGIC_VECTOR(pix_y(3 DOWNTO 0));
   bit_addr_r <= STD_LOGIC_VECTOR(pix_x(2 DOWNTO 0));
   rule_rom_addr <= pix_y(6 DOWNTO 4) & pix_x(6 DOWNTO 3);
   char_addr_r <= RULE_ROM(to_integer(rule_rom_addr));
   ---------------------------------------------
   -- game over region
   --  - display }Game Over" on center
   --  - scale to 32-by-64 fonts
   ---------------------------------------------
   over_on <=
      '1' WHEN pix_y(9 DOWNTO 6) = 3 AND
      5 <= pix_x(9 DOWNTO 5) AND pix_x(9 DOWNTO 5) <= 13 ELSE
      '0';
   row_addr_o <= STD_LOGIC_VECTOR(pix_y(5 DOWNTO 2));
   bit_addr_o <= STD_LOGIC_VECTOR(pix_x(4 DOWNTO 2));
   WITH pix_x(8 DOWNTO 5) SELECT
   char_addr_o <=
      "1000111" WHEN "0101", -- G x47
      "1100001" WHEN "0110", -- a x61
      "1101101" WHEN "0111", -- m x6d
      "1100101" WHEN "1000", -- e x65
      "0000000" WHEN "1001", --
      "1001111" WHEN "1010", -- O x4f
      "1110110" WHEN "1011", -- v x76
      "1100101" WHEN "1100", -- e x65
      "1110010" WHEN OTHERS; -- r x72
   ---------------------------------------------
   -- mux for font ROM addresses and rgb
   ---------------------------------------------
   PROCESS (score_on, score_2p_on, rule_on, pix_x, pix_y, font_bit,
      char_addr_s, char_addr_s_2p, char_addr_r, char_addr_o,
      row_addr_s, row_addr_s_2p, row_addr_r, row_addr_o,
      bit_addr_s, bit_addr_s_2p, bit_addr_r, bit_addr_o)
   BEGIN
      text_rgb <= "000"; -- background, black
      IF score_on = '1' THEN
         char_addr <= char_addr_s;
         row_addr <= row_addr_s;
         bit_addr <= bit_addr_s;
         IF font_bit = '1' THEN
            text_rgb <= "111";
         END IF;
      ELSIF score_2p_on = '1' THEN
         char_addr <= char_addr_s_2p;
         row_addr <= row_addr_s_2p;
         bit_addr <= bit_addr_s_2p;
         IF font_bit = '1' THEN
            text_rgb <= "111";
         END IF;
      ELSIF rule_on = '1' THEN
         char_addr <= char_addr_r;
         row_addr <= row_addr_r;
         bit_addr <= bit_addr_r;
         IF font_bit = '1' THEN
            text_rgb <= "111"; -- Green
         END IF;
      ELSE -- game over
         char_addr <= char_addr_o;
         row_addr <= row_addr_o;
         bit_addr <= bit_addr_o;
         IF font_bit = '1' THEN
            text_rgb <= "111";
         END IF;
      END IF;
   END PROCESS;
   text_on <= score_on & rule_on & over_on;
   ---------------------------------------------
   -- font rom interface
   ---------------------------------------------
   rom_addr <= char_addr & row_addr;
   font_bit <= font_word(to_integer(unsigned(NOT bit_addr)));
END arch;