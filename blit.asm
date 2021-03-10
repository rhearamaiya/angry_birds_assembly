; #########################################################################
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc

.DATA
	;; If you need to, you can place global variables here
	
.CODE

DrawPixel PROC USES eax ebx ecx edx esi edi x:DWORD, y:DWORD, color:DWORD
	mov ebx, color ;; store color in ebx: ebx <-- color ;; need this later
	;; first check if out of bounds
	cmp x, 0
	jl finished ;; if x less than 0 --> out of bounds
	cmp y, 0
	jl finished ;; if y less than 0 --> out of bounds

	cmp x, 639
	jg finished ;; if x greater than 639 --> out of bounds
	cmp y, 479 
	jg finished ;; if y greater than 479 --> out of bounds

	;; need to do 640*y + x + ScreenBitsPtr (remember ScreenBitsPtr is initial address of first pixel)

	mov eax, y ;; for mul, multiplying y with 640
	mov ecx, 640 ;; ecx <-- 640
	imul ecx ;; {edx:eax} <-- 640*y
	add eax, x ;; eax = eax + x = 640*y + x
	add eax, ScreenBitsPtr ;; add the address of the first pixel (0,0)
	;; at this point, eax <-- 640*y+x+ScreenBitsPtr

	mov BYTE PTR[eax], bl ;; "each color is a byte" -- move the color into eax

finished:
	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES eax ebx ecx edx edi esi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
	LOCAL x1:DWORD, x2:DWORD, y1:DWORD, y2:DWORD

	mov esi, 0 ;; treat esi as a counter -- remember that!

	mov ebx, ptrBitmap  	; ebx <-- address of EECS205BITMAP
	mov al, (EECS205BITMAP PTR [ebx]).bTransparent ;; stores transparent color (from struct) in al **remember this**
	;; CAN'T USE EAX AT THIS POINT! 


	;; setting x1 and x2
	mov ecx, xcenter
	mov edx, xcenter
	mov x1, ecx	
	mov x2, edx		
	;; at this point, don't need ecx or edx anymore
	mov ecx, (EECS205BITMAP PTR[ebx]).dwWidth ;; getting width of bitmap (for x1)
	mov edx, (EECS205BITMAP PTR[ebx]).dwWidth ;; getting width of bitmap (for x2)
	sar ecx, 1  ;; divide width by 2, store in ecx
	sar edx, 1 ;; divide width by 2, store in edx
	add x1, ecx ;; x1 <-- x1 + width/2
	sub x2, edx ;; x2 <-- x2 - width/2

	;; at this point, don't need ecx anymore

	;; now do this same for setting y1 and y2
	mov ebx, ptrBitmap  	; ebx <-- address of EECS205BITMAP

	mov ecx, ycenter
	mov edx, ycenter
	mov y1, ecx
	mov y2, edx
	;;  at this point, don't need ecx or edx anymore
	mov ecx, (EECS205BITMAP PTR [ebx]).dwHeight ;; getting height of bitmap (for y1)
	mov edx, (EECS205BITMAP PTR [ebx]).dwHeight ;; getting height of bitmap (for y2)

	sar ecx, 1 ;; divide height by 2, store in ecx
	sar edx, 1 ;; divide width by 2, store in edx

	add y1, ecx ;; y1 <-- y1 + height/2
	sub y2, edx ;; y2 <-- y2 - height/2
	;; at this point, x1, x2, y1, and y2 are set. 
	;; at this point, don't need ecx or edx anymore. REMEMBER EAX IS STILL STORING THE TRANSPARENT COLOR-- STILL CANT USE. ALSO EBX IN USE. 

loop_through_x:
	mov ecx, x1 
	mov edi, x2
	cmp edi, ecx 
	je loop_through_y ;; loop through y with new y value if x1=x2 (reached end condition)
	;; else
	mov ecx, (EECS205BITMAP PTR [ebx]).lpBytes  ;; stores the bitmap's color values in ecx
	mov dl, BYTE PTR [ecx + esi] ;; current color is counter (remember in esi) plus the starting 

	sub dl, al ;; if 0, means they are equal (remember al was transparent color). want to skip that pixel if colors are equal.
	je next

	invoke DrawPixel, x2, y2, [ecx + esi] ;; else, draw the pixel with that color
	jmp next
	
;; basically same thing (first part) for looping thru y
loop_through_y:
	mov edi, y1
	add y2, 1 ;; go to next y-val
	mov ecx, y2
	cmp ecx, edi
	je finished	;; finished once ending condition is reached (y1 = y2)
	;; else
	mov ecx, (EECS205BITMAP PTR [ebx]).dwWidth ;; stores the bitmap's width in ecx
	mov edi, x2;; move x2 into register
	sub edi, ecx ;; edi = edi - ecx aka x2 = x2 - width 
	mov x2, edi ;; move edi back into x2
	jmp loop_through_x ;; go back to loop thru x with new y-value

next:
	add x2, 1 ;;increment x to skip it
	add esi, 1; incremement counter 
	jmp loop_through_x ;; go back to start over with new x value

finished:	 
	ret 			; Don't delete this line!!!	
BasicBlit ENDP

RotateBlit PROC USES eax ebx ecx edx edi esi  lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	LOCAL cosa: DWORD, sina: DWORD, shiftx: DWORD, shifty: DWORD, dstHeight: DWORD, dstWidth: DWORD, dstx: DWORD, dsty: DWORD,
	srcx: DWORD, srcy: DWORD

	invoke FixedCos, angle
	mov cosa, eax ;; cosa stores cos angle
	invoke FixedSin, angle	
	mov sina, eax ;; sina stores sin angle
	;; all registers free at this point 

	mov esi, lpBmp
	mov cl, (EECS205BITMAP PTR [esi]).bTransparent ;;stores transparent color (from struct) in cl **remember this**
	;; ECX, ESI IS NOT FREE AT THIS POINT

	;; calculating shiftx
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth ;; eax storing the width
	imul cosa ;; multiply cosa by width: {edx:eax} <-- eax * cosa = width * cosa
	mov shiftx, eax ;; put result into shiftx variable
	sar shiftx, 1 ;; divide by 2 : shiftx <-- shiftx / 2 = width*cosa/2
	;; don't need eax at this point
	;; now get height for subtracting purposes
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight ;; eax now stores the height
	imul sina ;; similar thing as above-- {edx:eax} <-- height * sina
	sar eax, 1 ;; divide by 2 : shifty <-- shifty/2 = height*sina/2
	mov ebx, shiftx
	sub ebx, eax ;; subtract to get final shiftx
	mov shiftx, ebx
	
	;now for calculating shifty except shift around height and width being added
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight ;; eax stores height
	imul cosa;; {edx:eax} <-- eax * cosa = height * cosa
	mov shifty, eax ;; put result into shifty variable
	sar shifty, 1 ;; divide by 2 so now shifty <-- height*cosa/2
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth ;; now for width, store that in eax
	imul sina ;; similar thing: {edx:eax} <-- width * sina
	sar eax, 1 ;; divide by 2 so now eax <-- width*sina/2
	mov ebx, shifty
	add ebx, eax ;; add two together to get final shifty
	mov shifty, ebx
	;; don't need eax at this point

	;; done with assigning shifty and shiftx
	;; need to convert them from fixed point to integer for later: 

	sar shifty, 16
	sar shiftx, 16

	;; now need to assign dstWidth
	mov ebx, (EECS205BITMAP PTR [esi]).dwWidth
	add ebx, (EECS205BITMAP PTR [esi]).dwHeight ;; ebx <-- (EECS205BITMAP PTR [esi]).dwWidth + (EECS205BITMAP PTR [esi]).dwHeight
	mov dstWidth, ebx ;; store in dstWidth

	;; now assign dstHeight
	mov ebx, dstWidth
	mov dstHeight, ebx  ;; because dstHeight = dstWidth

	;; initialize first for loop:
	neg ebx ;; stored -dstWidth for for loop  
	mov dstx, ebx		;dstx = -dstWidth
	
	;initialize second for loop:
	mov dsty, ebx		;dsty = -dstHeight = -dstWidth ;; gonna keep re-initializing thru outer x-loop
	

first_loop_cond: ;;for even entering 1st loop in the 1st place;; dstx<dstHeight
    mov ebx, dstHeight
	neg ebx
    mov dsty, ebx
	mov ebx, dstx
	mov dstx, ebx
	cmp ebx, dstWidth ;; for end condition
	je finished ;; if reached end condition (they are equal), then don't go into the for loop again. otherwise, fall thru and keep going

second_loop_cond: ;; dsty<dstHeight
	mov ebx, dsty
	cmp ebx, dstHeight
	jl body ;; if dsty<dstHeight, go into body of loop. 
	add dstx, 1 ;;gotta increment dstx (go to next dstx) since not going into body of inner loop
	jmp first_loop_cond ;; go to next iteration of x_loop

body:	
	mov eax, dstx ;; eax <-- dstx for imul
	imul cosa ;; {edx:eax} <-- dstx * cosa
	mov srcx, eax ;; store current srcx bc need eax for dsty
	mov eax, dsty ;; dsty for imul
	imul sina ;; {edx:eax} <-- dsty*sina
	add srcx, eax ;; add them together to get srcx = dstx*cosa + dsty*sina

	;; now do same thing for srcy except switch x and y and subtract
	mov eax, dsty ;; eax <-- dsty for imul
	imul cosa ;; {edx:eax} <-- dsty * cosa
	mov srcy, eax ;; store current srcx bc need eax for dstx
	mov eax, dstx ;; dstx for imul
	imul sina ;; {edx:eax} <-- dstx * sina
	sub srcy, eax ;; subtract them to get srcy = dsty*cosa - dsty*sina

	;; convert from fixed point to integer
	sar srcx, 16
	sar srcy, 16

	;; short-circuiting checks for all the if "ands" -- bc they all must be true for inner stuff to be executed. 
	;; if srcx<0, already exit. increment/go to next y
	cmp srcx, 0
	jl next2

	;; if dwWidth<srcx, already exit. increment/go to next y
	mov ebx, srcx
	cmp (EECS205BITMAP PTR [esi]).dwWidth, ebx
	jl next2

	;; if srcy<0, already exit. increment/go to next y
	cmp srcy, 0
	jl next2

	;; if dwHeight<srcy, already exit. increment/go to next y
	mov ebx, srcy
	cmp (EECS205BITMAP PTR [esi]).dwHeight, ebx
	jl next2

	;; if xcenter+dstx-shiftx<0, already exit. increment/go to next y
	mov ebx, xcenter
	add ebx, dstx
	sub ebx, shiftx
	;; at this point, ebx = xcenter+dstx-shiftx
	cmp ebx, 0
	jl next2

	;; if xcenter+dstx-shiftx>=639, already exit. increment/go to next y
	;; at this point, ebx = xcenter+dstx-shiftx
	cmp ebx, 639
	jge next2

	;; if ycenter+dsty-shifty<0, already exit. increment/go to next y
	mov ebx, ycenter
	add ebx, dsty
	sub ebx, shifty
	;; at this point, ebx = ycenter+dsty-shifty
	cmp ebx, 0
	jl next2

	;; if ycenter+dsty-shifty>=479, already exit. increment/go to next y
	;; at this point, ebx = ycenter+dsty-shifty
	cmp ebx, 479
	jge next2

	;; final and: check that bitmap pixel at (srcx, srcy) is not transparent
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	mov edx, srcy
	imul edx ;; {edx:eax} <-- eax * edx aka (EECS205BITMAP PTR [esi]).dwWidth * srcy

	add eax, srcx ;; (EECS205BITMAP PTR [esi]).dwWidth * srcy + srcx
	add eax, (EECS205BITMAP PTR [esi]).lpBytes ;; (EECS205BITMAP PTR [esi]).dwWidth * srcy + srcx + (EECS205BITMAP PTR [esi]).lpBytes
	mov bl, BYTE PTR [eax] ;; get the bitmap pixel (srcx, srcy) out
	cmp bl, cl ;; compare to initial transparent color
	je next2 ;; if they are equal, SKIP. Don't draw pixel with this 

	;; if made it here, then draw the pixel! finally!
	mov edi, xcenter ;; edi <-- xcenter
	add edi, dstx ;; edi <-- xcenter + dstx
	sub edi, shiftx ;; edi <-- xcenter + dstx - shiftx ;; 1 input into DrawPixel 
	mov ebx, ycenter ;; ebx <-- ycenter
	add ebx, dsty ;; ebx <-- ycenter + dsty
	sub ebx, shifty ;; ebx <-- ycenter + dsty - shifty ;; other input into DrawPixel
	invoke DrawPixel, edi, ebx, BYTE PTR [eax]
	jmp next2 ;; go to next y after has been drawn


next2: ;; go to next y after been drawn (next iteration of for loop for y) 
	add dsty, 1 ;; next y
	jmp second_loop_cond ;; check the inner loop condition again to see if we should keep going. if yes, go back in. if not (else), jump to finished.

finished:
	sal srcx, 16 ;; shift back at the end?? do I need to??
	sal srcy, 16 ;; ^^ 
	ret 			; Don't delete this line!!!		
RotateBlit ENDP


END
