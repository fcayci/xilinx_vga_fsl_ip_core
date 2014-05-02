-- Created by F.Cayci
-- clk input should be 25 MHz signal
-- VGA: Screen area 640x480 @60 Hz
--      Total area 800x525
--      FP+HS+BP+LB+VIDEO+RB x FP+VS+BP+TB+VIDEO+RB
--      8+96+40+8+640+8 x 2+2+25+8+480+8
-- HSYNC AND VSYNC NEGATIVE Polariy

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync is
  port(
    clk, reset    : in  std_logic;
    hsync, vsync  : out std_logic;
    video_on      : out std_logic;
    pixel_x       : out std_logic_vector(0 to 9);
    pixel_y       : out std_logic_vector(0 to 9)
  );
end vga_sync;

architecture arch of vga_sync is

  constant HMAX   : integer := 800; -- 800
  constant HS_S   : integer := 8;   -- 8
  constant HS_E   : integer := 104; -- HS_S+HS=104
  constant HBP_E  : integer := 152; -- HS_E+BP+LB=152
  constant HLINES : integer := 640; -- 640
  constant HFP_S  : integer := 792; -- TOTAL-RB=792

  constant VMAX   : integer := 525; -- 525
  constant VS_S   : integer := 2;   -- 2
  constant VS_E   : integer := 4;   -- VS_S+VS=4
  constant VBP_E  : integer := 37;  -- VS_E+BP+TB=37
  constant VLINES : integer := 480; -- 480
  constant VFP_S  : integer := 517; -- TOTAL-BB=517

  -- horizontal and vertical counters
  signal h_count : unsigned(9 downto 0) := (others => '0');
  signal v_count : unsigned(9 downto 0) := (others => '0');

begin

  count_process: process (clk, reset)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        v_count <= (others => '0');
        h_count <= (others => '0');
      else
        if (h_count = HMAX) then
          h_count <= (others => '0');
          if (v_count = VMAX) then
            v_count <= (others => '0');
          else
            v_count <= v_count + 1;
          end if;
        else
          h_count <= h_count + 1;
        end if;
      end if;
    end if;
  end process count_process;

  video_on <= 
    '1' when ((h_count >= HBP_E and h_count < HFP_S)      -- 152 =< h_count < 792 (640)
        and (v_count >= VBP_E and v_count < VFP_S)) else  --  37 =< v_count < 517 (480)
    '0';

  hsync <= 
    '0' when h_count >= HS_S      -- 8
        and h_count < HS_E else   -- 96
    '1';    
  vsync <= 
    '0' when v_count >= VS_S      -- 2
        and v_count < VS_E else   -- 4
    '1';
    
  pixel_x <= std_logic_vector(h_count-HBP_E) when h_count >= HBP_E else  -- -152
             (others => '0');
  pixel_y <= std_logic_vector(v_count-VBP_E) when v_count >= VBP_E else -- -37
             (others => '0');
    
end arch;
