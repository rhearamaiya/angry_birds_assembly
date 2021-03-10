; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2 
;   RHEA RAMAIYA ---- RAR0632 
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here

.CODE
	
;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax1 and eax registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD

DrawLine PROC USES eax ebx ecx edx edi esi x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD

        LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD, curr_x: DWORD, curr_y: DWORD
		;; actually ended up using registers for error, curr_x, curr_y, and prev_error
	mov eax, x1 ;; eax = x1
	mov ebx, y1 ;; ebx = y1
	sub eax, x0 ;;eax = x1 - x0
	cmp eax, 0
	jge next ;;if x1-x0 >=0, jump to next (don't negate anything)
	neg eax ;; else if x1-x0<0, need to negate it (for absolute value)

next:  
	mov delta_x, eax ;; delta_x = abs(x1-x0). at this point, don't need eax anymore. 
	sub ebx, y0 ;; ebx = y1 - y0
	jge next2 ;; if y1-y0 >= 0, jump to next2 (don't negate anything)
	neg ebx ;; else if y1-y0<0, need to negate it (for absolute value)

next2:  
	mov delta_y, ebx ;; delta_y = abs(y1-y0). at this point, don't need ebx anymore. 
	mov eax, x0 ;; eax = x0
	mov ebx, y0 ;; ebx = y0
	cmp eax, x1 ;; don't need eax after this
	jge FALSEBLOCK ;; if false, jump
	mov inc_x, 1 ;; eax<x1 -- x0<x1 -- if true, get to here
	jmp continue ;; skip the falseblock

FALSEBLOCK:
	mov inc_x, -1

continue:
	cmp ebx, y1 ;; don't need ebx after this
	jge FALSEBLOCK2 ;; if false, jump
	mov inc_y, 1 ;; y0<y1 -- if true, get to here
	jmp continue2 ;; skip the falseblock

FALSEBLOCK2:
	mov inc_y, -1

continue2: 
	;error is stored in edi
	mov eax, delta_x
	cmp eax, delta_y ;; compare delta_x and delta_y
	jle FALSEBLOCK3 ;; if delta_x<=delta_y, need to do error = -delta_y/2 -- in falseblock
	mov edi, delta_x ;; else if delta_x>delta_y, need to do error = delta_x/2
	sar edi, 1 ;; error = delta_x/2
	jmp continue3 ;; skip the falseblock

FALSEBLOCK3:
	mov edi, delta_y
	sar edi, 1
	neg edi ;; error = -delta_y/2

continue3:
	invoke DrawPixel, x0, y0, color
	mov eax, x0
	mov ecx, eax ;; curr_x, aka x0, is stored in ecx so can do operations with it 
	mov eax, y0
	mov edx, eax ;; curr_y, aka y0, is stored in edx so can do operations with it
	mov curr_x, ecx
	mov curr_y, edx
	jmp cond ;; check condition if we need to go into while loop initially

body:   
	invoke DrawPixel, ecx, edx, color
	mov esi, edi ;; move error to prev_error -- prev_error = error (remember prev_error is stored in esi)
	neg delta_x ;; comparing -delta_x to prev error for first if statement
	cmp esi, delta_x 
	jle continue4 ;; if prev_error <= -delta x, don't go into if (bc not true). go to next if statement
	mov eax, delta_y
	sub edi, eax ;; error = error - delta_y ;; if if statement is true, do this
	add ecx, inc_x ;; curr_x = curr_x + inc_x

continue4:
	neg delta_x ;; make -delta_x into delta_x again for second if statement
	mov eax, delta_y
	cmp esi, eax
	jge cond ;; if prev_error>= delta_y, don't go into if (bc not true). check while loop again bc body is done
	mov eax, delta_x
	add edi, eax ;; error = error + delta_x ;; if if statement is true, do this
	mov eax, inc_y
	add edx, eax ;; curr_y = curr_y + inc_y

cond:   
	mov eax, x1
	cmp ecx, eax 
	jne body ;; first if is true: jump right away. 
	mov eax, y1
	cmp edx, eax
	jne body ;; first wasn't true, but second if is true: jump
	jmp continue5 ;;  if neither of these are true, exit while loop and return. 

continue5:
	ret        	;;  Don't delete this line...you need it
DrawLine ENDP

END