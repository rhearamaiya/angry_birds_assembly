; #########################################################################
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

	;; Place your code here (code below)

	invoke DrawStar, 60, 160
	invoke DrawStar, 160, 60
	invoke DrawStar, 120, 320
	invoke DrawStar, 320, 60


	invoke DrawStar, 240, 160
	invoke DrawStar, 160, 240
	invoke DrawStar, 240, 320
	invoke DrawStar, 320, 240


	invoke DrawStar, 360, 160
	invoke DrawStar, 160, 420
	invoke DrawStar, 360, 320
	invoke DrawStar, 320, 420

	invoke DrawStar, 480, 360
	invoke DrawStar, 560, 270
	invoke DrawStar, 480, 180
	invoke DrawStar, 560, 60


	ret  			; Careful! Don't remove this line
DrawStarField endp



END

