-- Display buffer for VGA screen for 2 object game

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_buffer is
   generic (OBJECT_SIZE : natural := 10);
   port(
        video_on: in std_logic;
        pixel_x, pixel_y : in std_logic_vector(0 to OBJECT_SIZE-1);
        object1x, object1y : in std_logic_vector(0 to OBJECT_SIZE-1);
        object2x, object2y : in std_logic_vector(0 to OBJECT_SIZE-1);
        graph_rgb: out std_logic_vector(7 downto 0)
   );
end vga_buffer;

architecture arch of vga_buffer is
   ----------------------------------------------
   -- stationary object - vertical strip as a wall
   ----------------------------------------------
   -- wall left, right boundary
   constant WALL_X_L: integer:=32;
   constant WALL_X_R: integer:=35;
  ----------------------------------------------
   -- 1st game object - a square bar
   ----------------------------------------------
   -- bar left, right boundary
   constant BAR_SIZE: integer:=16;
   ----------------------------------------------
   -- 2nd game object - round ball image ROM
   ----------------------------------------------
   constant BALL_SIZE: integer:=8;
   type rom_type is array (0 to 7)
        of std_logic_vector(0 to 7);
   -- ROM definition
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
   signal rom_addr, rom_col: unsigned(0 to 2);
   signal rom_data: std_logic_vector(0 to 7);
   signal rom_bit: std_logic;
   ----------------------------------------------

   -- x, y coordinates of the ball
   signal ball_x_l : unsigned (0 to OBJECT_SIZE-1);
   signal ball_y_t : unsigned (0 to OBJECT_SIZE-1);
   signal ball_x_r : unsigned (0 to OBJECT_SIZE-1);
   signal ball_y_b : unsigned (0 to OBJECT_SIZE-1);

   -- x, y coordinates of the bar
   signal bar_x_l : unsigned (0 to OBJECT_SIZE-1);
   signal bar_y_t : unsigned (0 to OBJECT_SIZE-1);
   signal bar_x_r : unsigned (0 to OBJECT_SIZE-1);
   signal bar_y_b : unsigned (0 to OBJECT_SIZE-1);

   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(0 to OBJECT_SIZE-1);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;

   ----------------------------------------------
   -- object output signals
   ----------------------------------------------
   signal wall_on, bar_on, sq_ball_on, rd_ball_on: std_logic;
   signal wall_rgb, bar_rgb, ball_rgb:
          std_logic_vector(7 downto 0);

begin
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   ----------------------------------------------
   -- Constant object - (wall) left vertical strip
   ----------------------------------------------
   -- pixel within wall
   wall_on <=
      '1' when (WALL_X_L<=pix_x) and (pix_x<=WALL_X_R) else
      '0';
   -- wall rgb output
   wall_rgb <= "00000011"; -- blue
   ----------------------------------------------
   -- 1st game object - a red ball
   ----------------------------------------------
   -- boundary
   ball_x_l <= unsigned(object1x);
   ball_y_t <= unsigned(object1y);
   ball_x_r <= ball_x_l + BALL_SIZE - 1;
   ball_y_b <= ball_y_t + BALL_SIZE - 1;
   -- pixel within ball
   sq_ball_on <=
      '1' when (ball_x_l<=pix_x) and (pix_x<=ball_x_r) and
               (ball_y_t<=pix_y) and (pix_y<=ball_y_b) else
      '0';
   -- map current pixel location to ROM addr/col
   rom_addr <= pix_y(7 to 9) - ball_y_t(7 to 9);
   rom_col <= pix_x(7 to 9) - ball_x_l(7 to 9);
   rom_data <= BALL_ROM(to_integer(rom_addr));
   rom_bit <= rom_data(to_integer(rom_col));
   -- pixel within ball
   rd_ball_on <=
      '1' when (sq_ball_on='1') and (rom_bit='1') else
      '0';
   -- ball rgb output
   ball_rgb <= "11100000";   -- red
   ----------------------------------------------
   -- 2nd game object - a square bar
   ----------------------------------------------
   -- pixel within bar
   bar_x_l <= unsigned(object2x);
   bar_y_t <= unsigned(object2y);
   bar_x_r <= bar_x_l + BAR_SIZE - 1;
   bar_y_b <= bar_y_t + BAR_SIZE - 1;
   bar_on <=
      '1' when (BAR_X_L<=pix_x) and (pix_x<=BAR_X_R) and
               (bar_y_t<=pix_y) and (pix_y<=bar_y_b) else
      '0';
   -- bar rgb output
   bar_rgb <= "00011100"; --green
   ----------------------------------------------
   -- rgb multiplexing circuit
   ----------------------------------------------
   process(video_on,wall_on,bar_on,sq_ball_on,
           wall_rgb, bar_rgb, ball_rgb, rd_ball_on)
   begin
      if video_on='0' then
          graph_rgb <= "00000000"; --blank
      else
         if wall_on='1' then
            graph_rgb <= wall_rgb;
         elsif bar_on='1' then
            graph_rgb <= bar_rgb;
         elsif rd_ball_on='1' then
            graph_rgb <= ball_rgb;
         else
            graph_rgb <= "11111100"; -- yellow background
         end if;
      end if;
   end process;
end arch;
