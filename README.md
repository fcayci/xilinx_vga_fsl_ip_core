## VGA IP Core for Xilinx
* 640x480 Resolution
* Connects to microblaze processor using FSL
* Tested with 14.6 ISE Design Suite
* Supports hard-coded 4 x 10-byte objects. Check `vga_fsl.vhd` to change it.

### Using the VGA fsl ip core in the EDK project
* Checkout the project and add it to project repository so that it shows up under peripherals tab in EDK
* Hit `Hardware -> Configure Coprocessor`
* `vga_fsl` should show up under `Available Coprocessors`. Hit it and hit `<< Add` then hit Ok
* Go to `Ports` tab and expand `vga_fsl_0` choose `hsync`, `vsync`, and `rgb`, right click and hit `Make External`
* Generate a 25 MHz clock from `clock_generator`, and hook it up to `vga_clk` port
* If it doesn't automatically, connect `FSL_Clk` to the bus clock, and `SYS_Rst` to the bus reset under `microblaze_to_vga_fsl_0`
* Add the external pins to the `ucf` file. Following is for `Digilent Nexys3 board`:

```
## VGA Pins for Digilent Nexys3 Board
NET vga_fsl_0_rgb_pin<7> LOC = "N7"  |  IOSTANDARD = "LVCMOS33"; # RED 2
NET vga_fsl_0_rgb_pin<6> LOC = "V7"  |  IOSTANDARD = "LVCMOS33"; # RED 1
NET vga_fsl_0_rgb_pin<5> LOC = "U7"  |  IOSTANDARD = "LVCMOS33"; # RED 0
NET vga_fsl_0_rgb_pin<4> LOC = "V6"  |  IOSTANDARD = "LVCMOS33"; # GREEN 2
NET vga_fsl_0_rgb_pin<3> LOC = "T6"  |  IOSTANDARD = "LVCMOS33"; # GREEN 1
NET vga_fsl_0_rgb_pin<2> LOC = "P8"  |  IOSTANDARD = "LVCMOS33"; # GREEN 0
NET vga_fsl_0_rgb_pin<1> LOC = "T7"  |  IOSTANDARD = "LVCMOS33"; # BLUE 1
NET vga_fsl_0_rgb_pin<0> LOC = "R7"  |  IOSTANDARD = "LVCMOS33"; # BLUE 0
NET vga_fsl_0_hsync_pin  LOC = "N6"  |  IOSTANDARD = "LVCMOS33"; # HSYNC
NET vga_fsl_0_vsync_pin  LOC = "P7"  |  IOSTANDARD = "LVCMOS33"; # VSYNC
```

* Generate bitstream and you should see the stuff in `vga_buffer.vhd` on your monitor

### Examples
* Check out `examples/gamedemo.c` to control the objects with buttons from SDK
* Check out `examples/system.mhs` to see an example design
* Download `examples/nexys3_vga_fsl_demo.bit` to your Nexys3 board for the demo that uses bottons to move an object on the monitor connected through VGA

