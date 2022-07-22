# Project Description

I implemented a classical game, Tetris, on the FPGA as a System-on-chip using systemVerilog (hardware) and C (software) as my final project in ECE385 (Digital System Laboratory). In this game, blocks of different shapes, which are generated randomly, fall from the top-center of the screen one at a time. Player can 
  1) adjust the position of the blocks by pressing LEFT and RIGHT button on the keyboard, 
  2) adjust the orientation of the blocks by pressing UP button and 
  3) accelerate the falling speed of the block by pressing DOWN button.

When blocks touch the bottom or fall on other blocks, they will stop falling, change into white color and become part of the game background (so that any later operations are invalid). Points are rewarded to the player when one or more rows are filled with blocks (i.e. no spaces or holes) and these rows will be eliminated. The uneliminated blocks pile up, and once they reach the top of the screen, the player will lose, and the game is over. They player will win if he successfully eliminates 50 rows. 

To realize the above functionality, I used SystemVerilog essential components such as the System Bus, RAM, Keyboard, LED, etc. The design also includes a NIOS II CPU for the purposes of interfacing with the USB keyboard to make judgements about the operations of the player.

# Features
## Basic Features
1. Able to display blocks, scores and other graphical elements on the screen and blocks of different shapes can continuously fall down.

2. Able to use the keyboard to control the block (position, orientation, falling speed)

3. Able to eliminate a complete line or lines at the bottom of the screen
## Additional Features
1. Able to display the current score and the highest score on the screen.

2. Display the number of rows eliminated on the hex driver.

3. Randomly generate the next block according to the output of a random number generator.

4. Play complicated music (canon) on FPGA.
