; #########################################################################
;
;   trig.asm - Assembly file for CompEng205 Assignment 3
;	;; RAR0632 Rhea Ramaiya
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE

FixedSin PROC USES edi esi ebx ecx edx angle:FXPT
	LOCAL negative_angle ;; local variable for dealing with negative angles
	mov negative_angle, 0 ;;initialize local variable negative_angle with 0 (for starters its not negative)

	;;mov angle, PI*3/2
	mov edi, angle ;; edi <-- angle

greater_than_2pi: ;;if angle is greater than 2pi, keep subtracting 2pi from it til it's not
	cmp edi, TWO_PI
	jl less_than_zero ;; fall thru if not greater than or equal to 2pi (break out)
	sub edi, TWO_PI ;; fell thru so is greater than 2pi. need to subtract 2pi
	jmp greater_than_2pi ;;check again if greater than 2pi

less_than_zero: ;; if angle is less than 0 (aka it's negative), keep adding 2pi til it's not
	cmp edi, 0 
	jge less_than_pi_over_2 ;;if eax/angle>=0, jump to that one (break out) if negative, fall thru
	add edi, TWO_PI ;; add 2pi to angle if it's negative, keep doing until positive
	jmp less_than_zero ;; check again if negative

;; at this point angle should be between 0 and 2pi (inclusive)

less_than_pi_over_2: ;;quad 1: between 0 and pi/2
	cmp edi, PI_HALF
	jg less_than_pi ;;if greater than pi/2, move to check if in quad 2
	jmp calculate_sin ;; ***************need to calculate sin**********************
	
less_than_pi: ;; quad 2: between pi/2 and pi
	cmp edi, PI
	jg less_than_3pi_over_2 ;;if greater than pi, move to check if in quad 3
	;; if pi/2 < angle < pi, need to do sin(x) = sin(pi-x), so move pi-x into edi
	mov ebx, PI ;; ebx <-- PI
	sub ebx, edi ;; ebx <-- PI - ebx aka PI - angle
	mov edi, ebx ;; move PI - angle back to edi 
	jmp calculate_sin ;; ******************need to calculate sin**************

less_than_3pi_over_2: ;; quad 3: between pi and 3pi/2
	mov negative_angle, 1 ;; at this point, need negative angle
	cmp edi, PI + PI_HALF ;; pi+pi/2 = 3pi/2
	jg less_than_2pi ;; if greater than 3pi/2, move to quad 4
	;; if pi < angle < 3pi/2, need to do sin(x+pi)=-sin(x) ;; need to put x+pi into edi, and also make it negative (did that)
	add edi, PI ;; edi = edi + pi 
	jmp calculate_sin ;; ********need to calculate sin********, negative_angle is set

less_than_2pi: ;; quad 4: between 3pi/2 and 2pi
	mov ebx, TWO_PI ;; ebx <-- 2pi
	sub ebx, edi ;; ebx <-- ebx - edi aka ebx <-- TWO_PI - angle ;; doing sin(2pi-x) = -sin(x)
	mov edi, ebx ;; move TWO_PI - angle back to edi
	jmp calculate_sin ;; ***********need to calculate sin *************, negative angle is set (from before)

calculate_sin:
	;; rememeber angle stored in edi
	;; i from the instruction is angle, in edi
	mov eax, edi ;; move angle to eax bc that's where result will be stored
	mov edx, PI_INC_RECIP ;; edx <-- 256/pi
	imul edx ;; {edx:eax} <-- eax * edx
	mov eax, 0 ;; clear upper part of eax because putting byte val into eax (at ax)
	mov ax, WORD PTR[SINTAB + edx*2] ;; get value from SINTAB TAB -- word pointer and zero extend into eax

	;; BUT gotta check if negative!! 
	cmp negative_angle, 1
	je negate ;; if negative_angle set, then negative and gotta negate it.
	;; else
	jmp finished ;; if negative_angle WASNT set, then not negative, and just return
negate:
	neg eax ;; then finish
finished:
	ret			; Don't delete this line!!!
FixedSin ENDP 

	
FixedCos PROC USES esi edi ebx ecx edx angle:FXPT
	mov edi, angle ;; edi <-- angle
	;; gotta do identity cos(x) = sin(x+pi/2)
	add edi, PI_HALF ;; edi <-- angle+pi/2
	INVOKE FixedSin, edi ;; should put in eax because that's what FixedSin does. 
	

	ret			; Don't delete this line!!!	
FixedCos ENDP	
END
