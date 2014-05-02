-- Created by Dr. K
-- Modified by F.Cayci
-- Top level for game with two objects.
-- Convention: (x,y) object coordinates track lower-left corner of the object

library ieee;
use ieee.std_logic_1164.all;
entity vga_top is
    generic (OBJECT_SIZE : natural := 10);
    port (
      clk, reset: in std_logic;
      object1x : in std_logic_vector(0 to OBJECT_SIZE-1);
      object1y : in std_logic_vector(0 to OBJECT_SIZE-1);
      object2x : in std_logic_vector(0 to OBJECT_SIZE-1);
      object2y : in std_logic_vector(0 to OBJECT_SIZE-1);
      hsync, vsync: out  std_logic;
      rgb: out std_logic_vector(7 downto 0)
   );
end vga_top;

architecture arch of vga_top is
   signal pixel_x, pixel_y: std_logic_vector (0 to OBJECT_SIZE-1);
   signal video_on, pixel_tick: std_logic;
   signal rgb_reg, rgb_next: std_logic_vector(7 downto 0);
   signal vsync_reg, vsync_next: std_logic;
   signal hsync_reg, hsync_next: std_logic;
   
begin
  -- instantiate VGA sync
  vga_sync_unit: entity work.vga_sync
    port map(
      clk=>clk, reset=>reset,
      video_on=>video_on,
      hsync=>hsync_next, vsync=>vsync_next,
      pixel_x=>pixel_x, pixel_y=>pixel_y);
  -- instantiate graphic generator
  vga_buffer_unit: entity work.vga_buffer
    generic map (OBJECT_SIZE=>OBJECT_SIZE)
    port map (video_on=>video_on,
      pixel_x=>pixel_x, pixel_y=>pixel_y,
      object1x=>object1x, object1y=>object1y,
      object2x=>object2x, object2y=>object2y,                
      graph_rgb=>rgb_next);
  -- rgb buffer
  process (clk)
  begin
    if (clk'event and clk='1') then
      rgb_reg <= rgb_next;
      hsync_reg <= hsync_next;
      vsync_reg <= vsync_next;
    end if;
  end process;
  rgb <= rgb_reg;
  hsync <= hsync_reg;
  vsync <= vsync_reg;
end arch;
