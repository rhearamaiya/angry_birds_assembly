# Angry Birds in Assembly
Angry Birds game written in x86 assembly language


## Installation/Setup

Requires MASM32 assembler on either Windows PC or Windows VM on Mac or Linux machine

Download the MASM32 installation file from [https://www.masm32.com/](https://www.masm32.com/)

Download [this archive](https://canvas.northwestern.edu/courses/130434/files/10370975?wrap=1), expand it, and copy the files in the lib directory (default location would be c:\masm\lib).

## Usage

In terminal, navigate to where repository is saved. Call ```make``` and then ```game``` or double click ```game.exe```.

## How to Play
Try to get as high of a score as possible by killing as many pigs as possible. To do this, click the left/right mouseclicks to shoot the 
angrybird from the slingshot towards the pig. For better aim, you can move the angrybird and slingshot by pressing the left and 
right keys on your keyboard-- the left key makes the angrybird and slingshot move to the left, and the right key makes the angrybird 
and slingshot move to the right. 

Be careful! Over time, the pigs will realize what's happening and will start moving faster. 

If you are able to successfully kill even 1 pig before the time runs out, then you are considered a winner. But if not, you lost and the pigs win.

## Features
- Respond to player input:
	- Angrybird moves across the screen with player input from mouse and keyboard:
		- right or left mouse click to "shoot" angrybird from slingshot towards pig
		- right keyboard arrow to move angrybird and slingshot to the right
		- left keyboard arrow to move angrybird and slingshot to the left
- Pig moves back and forth across the screen continuously, gains velocity over time

- When angrybird collides with pig, an explosion is shown. 
Your score also goes up, depending on how direct the attack was: if the pig is hit directly in the middle (head on), you will get more points than if it were an indirect hit
- Pause feature: when spacebar is pressed, the game will pause/unpause (depending on current state)
- Scrolling background
- Music
