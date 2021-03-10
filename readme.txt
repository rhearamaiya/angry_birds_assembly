Rhea Ramaiya

HOW TO PLAY: 

Try to get as high of a score as possible by killing as many pigs as possible. To do this, click the left/right mouseclicks to shoot the 
angrybird from the slingshot towards the pig. For better aim, you can move the angrybird and slingshot by pressing the left and 
right keys on your keyboard-- the left key makes the angrybird and slingshot move to the left, and the right key makes the angrybird 
and slingshot move to the right. 

Be careful! Over time, the pigs will realize what's happening and will start moving faster. 

If you are able to successfully kill even 1 pig before the time runs out, then you are considered a winner. But if not, you lost and the pigs win.

Mandatory Features: 
- 4 Bitmap Sprites (angrybird and pig are the main ones, slingshot and explosion are additional)
- Respond to player input:
	- angrybird moves across the screen with player input from mouse and keyboard:
		- right or left mouse click to "shoot" angrybird from slingshot towards pig
		- right keyboard arrow to move angrybird and slingshot to the right
		- left keyboard arrow to move angrybird and slingshot to the left
		(there are boundaries set so bird cannot go off screen)

	- pig moves back and forth across the screen continuously, gets faster over time

- When angrybird collides with pig, "Boom!" is displayed on the screen right above, and an explosion is shown (showing the pig explode).
Your score also goes up, depending on how direct the attack was: if the pig is hit directly in the middle (head on), you will get more points
than if you just hit a little piece of it.

- Reward and punishment: 
	-if the player is able to successfully destroy at least 1 pig by the time the timer runs out, they are considered a 
  	 winner and this is shown on the "game over" screen: ""You won! You defeated the pigs! You're final score is: " and the score
	-if the player is not able to successfully destroy any pigs by the time the timer runs out, they are considered to have 
	 lost to the pigs, and this is shown on the "game over" screen: "You got 0 points so you lost! The pigs won. Better luck next time"
- Pause feature is implemented-- when spacebar is pressed, if the game is unpaused it will pause, and if it is paused it will pause

Advanced Features: 
- Scrolling background (used 2 cloud background sprites and a loop to continously switch off as sprite scrolls upwards and off the screen)
- Music: angry birds theme song plays continously throughout the game
- "Gravity or Other Forces": pig sprite moves with non-constant velocity, speeding up as the game goes on/the time goes on to make gameplay
   more challenging
