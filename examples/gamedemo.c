#include <stdio.h>
#include "xparameters.h"
#include "xil_cache.h"
#include "xbasic_types.h"
#include "xgpio.h"

#include <stdlib.h>

// Copied from drivers/vga_fsl_XXX/src/vga_fsl.h
#include "fsl.h"
#define write_into_fsl(val, id)  putfsl(val, id)
#define read_from_fsl(val, id)  getfsl(val, id)
#define vga_fsl(input_slot_id, input_0) {int i; for (i=0; i<4; i++){ write_into_fsl(input_0[i], input_slot_id); }}

#define vga_slot_id    0
#define GAME_DELAY     20000

int main()
{
  Xuint32 objects_array[4];	// obj_ball_x, obj_ball_y, obj_bar_x, obj_bar_y
  XGpio LedsOutput;
  XGpio ButtonInput;

  Xuint32 DataRead;
  Xuint32 Status;

  volatile int Delay;

  // Initialize buttons
  Status = XGpio_Initialize(&ButtonInput, XPAR_PUSH_BUTTONS_4BITS_DEVICE_ID);
  if (Status != XST_SUCCESS) print("PANIC! Gpio Initialize FAILED.\r\n");
  // Set the direction to be all inputs
  XGpio_SetDataDirection(&ButtonInput, 1, 0xFF);

  // Initialize Leds
  Status = XGpio_Initialize(&LedsOutput, XPAR_LEDS_8BITS_DEVICE_ID);
  if (Status != XST_SUCCESS) print("PANIC! Gpio Initialize FAILED.\r\n");
  // Set the direction to be all outputs
  XGpio_SetDataDirection(&ButtonInput, 1, 0x00);

  //Initialize input data
  objects_array[0] = 320; // x coordinate for ball
  objects_array[1] = 240; // y coordinate for ball
  objects_array[2] = 10; // x coordinate for bar
  objects_array[3] = 10; // y coordinate for bar

  while(1) {
    //Call the FSL peripheral to display game objects
    vga_fsl(vga_slot_id, objects_array);
    // Get new ball position based on user input
    DataRead = XGpio_DiscreteRead(&ButtonInput, 1);

    if (DataRead == 2) objects_array[1] = objects_array[1]+1; // Down button
    if (DataRead == 8) objects_array[1] = objects_array[1]-1; // Up button
    if (DataRead == 1) objects_array[0] = objects_array[0]+1; // Left button
    if (DataRead == 4) objects_array[0] = objects_array[0]-1; // Right button
    //xil_printf("Read data:0x%X\r\n", DataRead);

    // Bar moves around randomly
    objects_array[2] = objects_array[2] - 1 + (rand() % 3);
    objects_array[3] = objects_array[3] - 1 + (rand() % 3);

    // If the ball catches up to the randomly moving bar, game is WON!
    if ((objects_array[0]==objects_array[2]) && (objects_array[1]==objects_array[3])) {
      print("YOU WON!\r\n");
    }

    /* Wrap the ball object around the screen */
    if (objects_array[0] == 0) objects_array[0] = 639-8;
    if (objects_array[1] == 0) objects_array[1] = 479-8;
    objects_array[0] = objects_array[0] % 640;
    objects_array[1] = objects_array[1] % 480;

    /* Wrap the bar object around the screen */
    if (objects_array[2] == 0) objects_array[2] = 639-8;
    if (objects_array[3] == 0) objects_array[3] = 479-8;
    objects_array[2] = objects_array[2] % 640;
    objects_array[3] = objects_array[3] % 480;

    // Wait a small amount of time or the ball will move too fast!
    for (Delay = 0; Delay < GAME_DELAY; Delay++);
  }
  return 0;
}
