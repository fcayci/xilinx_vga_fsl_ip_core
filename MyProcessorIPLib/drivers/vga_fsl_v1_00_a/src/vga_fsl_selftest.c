/*****************************************************************************
* Filename:          /home/bee/xilinx/ips/MyProcessorIPLib/drivers/vga_fsl_v1_00_a/src/vga_fsl_selftest.c
* Version:           1.00.a
* Description:       
* Date:              Thu May  1 23:22:31 2014 (by Create and Import Peripheral Wizard)
*****************************************************************************/

#include "xparameters.h"
#include "vga_fsl.h"

/* IMPORTANT:
*  In order to run this self test, you need to modify the value of following
*  micros according to the slot ID defined in xparameters.h file. 
*/
#define input_slot_id   XPAR_FSL_VGA_FSL_0_INPUT_SLOT_ID
XStatus VGA_FSL_SelfTest()
{
	 unsigned int input_0[4];     

	 //Initialize your input data over here: 
	 input_0[0] = 12345;     
	 input_0[1] = 24690;     
	 input_0[2] = 37035;     
	 input_0[3] = 49380;     

	 //Call the macro with instance specific slot IDs
	 vga_fsl(
		 input_slot_id,
		 input_0    
		 );


	 return XST_SUCCESS;
}
