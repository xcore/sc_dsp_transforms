.. _lcd_demo_Quickstart:

Simple FFt Demo Quickstart Guide
================================

This simple demonstration runs all the provided FFT functions and measures their performance.

Hardware Setup
--------------


The instructions given here are for sliceKIT but this demo uses no I/O and will run on any XMOS L, U or A-series device on any board. 

To setup up a sliceKIT system:

   #. Connect the XTAG Adapter to sliceKIT Core board, and connect XTAG-2 to the Adapter. 
   #. Connect the XTAG-2 to host PC. Note that the USB cable is not provided with the sliceKIT starter kit.
   #. Set the ``XMOS LINK`` to ``OFF`` on the XTAG Adapter.
   #. Switch on the power supply to the sliceKIT Core board.
	
Import and Build the Application
--------------------------------

   #. Open xTIMEcomposer and check that it is operating in online mode. Open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``Simple FFT Function Library Test`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTIMEcomposer. 
   #. Click on the ``app_fft_test`` item in the Project Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorial, which you can find by selecting Help->Tutorials from the xTIMEcomposer menu.

Run the Application
-------------------

Now that the application has been compiled, the next step is to run it on the sliceKIT Core Board using the tools to load the application over JTAG (via the XTAG2 and Xtag Adapter card) into the xCORE multicore microcontroller.

   #. Select the file ``app_fft_demo.xc`` in the ``app_lcd_demo`` project from the Project Explorer.
   #. Click on the ``Run`` icon (the white arrow in the green circle). 
   #. At the ``Select Device`` dialog select ``XMOS XTAG-2 connect to L1[0..1]`` and click ``OK``.

The output in the xTIMEcomposer console window should look begin like this::

  FORWARDING
  Ticks: 1214
  ....
  ....
  1024 Point FFT: Sum Sig^2: 183169703 * 10^9 Sum Err^2: 2660352
       
    
Next Steps
----------

  #. Take a look at the module documentation which can be accessed from the front page for the item in the xTIMEcomposer developer column
  #. Take a look at a more complex application example called ``Spectrum/Level Meter Display Demo`` that makes use of this module. 

