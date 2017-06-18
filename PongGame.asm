;Author: Omar Shaalan 11417338 - Mohamed Hazem 1145022 - Abdelrahman Nasser 11417388 - Youssef El-Maraghy 1142140
;Instructions:
;If you will play with keyboard, Left player will use Q and A and the right player will use up and down to move the Pad
;If you will use the gaming joysticks, every player will use his joystick to move up and down and 'X' to play the serve 
;Random angles are generated when you move up and down by a simple equation, not by time :) 
;Press Enter to go to main screen 
;Exit by ESC 
;You can go up and down before playing the first point and this helps in deciding which angle the ball will go with


.model small
	
	
.stack 512

.data 

	Line db '--------------------------------------------------------------------------------$'
	PosC db 3
	PosR db 0Ch 
	Vc db 1
	Vr db 0
	Pad1s dw 0B02h
	Pad2s dw 0B4Dh
	Score1 db 0
	Score2 db 0
	WinFor1 db 0
	WinFor2 db 0
	Random db 0
	Last db 0
	won db 'Won$'
	Anykey db 'Press any key to continue$'
	get_Player1 db 'Enter 1st Player Name:$'
	get_Player2 db 'Enter 2nd Player Name:$'
    option_1 db 'Press F1 to start chatting $'
	option_2 db 'Press F2 to start Pong Game ;) $'
	option_3 db 'Press ESC to end the program $'
	wrong_char db 'Invalid Char. PRESS ENTER TO RETRY$'
	
	First1 db ?
	First2 db ?
	Player1 db 10,?,10 dup('$')
	endName db '$'
	Player2 db 10,?,10 dup('$')
	endPlayer2 db '$'
	WhereToGo db 0
	;Main
	
.code

Main_Prog proc far
	mov ax,@data
	mov ds,ax
	mov bx,0
	mov ah,0
    mov al,3
    int 10h
	call ClearScreen
	call DrawPong
	call WaitForClick
	call ClearScreen
	call Menu
	mov WhereToGo,bl
	cmp bl,0
	JE ExitGame
	call ClearScreen
	call DrawLine
	call DrawInitialPad1
	call DrawInitialPad2
	call song	
		call printball
		call MovingStaticPad
		call RandomAngle
	Label2:
		;call GameLogic
		call clearball
		call Moveball
		call GameLogic
		
		call printball
		call MovingPad
		mov cx,0AFFFh
		Labels:
			mov bx,1
			LOL:
			dec bx
			JNZ LOL
		loop Labels
		
		call PrintPlayer1
		call PrintPlayer2
		;Checking if game ended
		mov al,WinFor1
		cmp al,1
		JE ExitGame
		mov al,WinFor2
		cmp al,1
		JE ExitGame
		;call MoveBall
	JMP Label2
	
	ExitGame:
		call EndScreen
		mov ax,4c00h
		int 21h
Main_Prog endp
	
	
	
printball proc near

		push ax
		push bx
		push cx
		push dx
		
		
		;set new cursor
		MOV BX,0
		mov dh,PosR
        mov dl,PosC
        mov ah,2
        int 10h
		
		;Print new ball
		mov ah,2
		mov dl,2
		int 21h

		pop dx
		pop cx
		pop bx
		pop ax
		ret
	printball endp

	clearball proc near
		
		push ax
		push bx
		push cx
		push dx

					;Set old cursor 
					; mov dh,PosR
					; mov dl,PosC
					; mov ah,2
					; int 10h
					
					;Print a black tab
					; mov ah,9
					; mov bh,0
					; mov al,9
					; mov cx,1
					; mov bl,0
					; int 10h
					
					
					mov ax,0600h
					mov bh,7
					mov cx,0003h
					mov dh,19
					mov dl,76
					int 10h
		pop dx
		pop cx
		pop bx
		pop ax
		ret		
	clearball endp

	; MoveBall proc near
		; push ax
		; push bx
		; push cx
		; push dx
		
			;inc the cursor 
			; mov ah,Vr
			; mov al,Vc
			; add PosC,al
			; add PosR,ah
		
		; pop dx
		; pop cx
		; pop bx
		; pop ax
		; ret	
	; MoveBall endp    
	
	MoveBall proc near
		push ax
		push bx
		push cx
		push dx
		
			;inc the cursor 
			;;;;;;;;;;;;; hazem beyl3ab f eelcode hena
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			mov ah,Vr
			mov al,Vc
			mov bl,al
			add bl,PosC
			cmp bl,76
			JG setposition
			cmp bl,3
			JL setposition2
			add PosC,al
			add PosR,ah
			;cmp PosC,77 
			;JG setposition
			jmp completenormal
			;;;;;;;;;;;;;;;;;;;;;;;;;;
			setposition:
			inc PosC
			add PosR,ah
			jmp completenormal
			setposition2:
			dec PosC
			add PosR,ah
			jmp completenormal
			completenormal:
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret	
	MoveBall endp    
	
	
	DrawLine proc near
		push ax
		push bx
		push cx
		push dx
		
			XOR BX,BX
			MOV AH,2
			MOV DH,20D ;DH is the row
			MOV DL,00D ;DL is the column
			INT 10H
			
			LEA DX,LINE
			MOV AH,09H
			INT 21H

		pop dx
		pop cx
		pop bx
		pop ax
		ret
	DrawLine endp
	
	
	
	GameLogic proc near
		push ax
		push bx
		push cx
		push dx
			CMP PosC,3
			JE LeftWall
			CMP PosC,76
			JE temp
			Cmp PosR,0
			JE FloorAndCeil
			Cmp PosR,19
			JE FloorAndCeil
			
	
	;Call MoveBall
	
	
	;If we get to this point, no change in the velocity will occur
	JMP Exit
	
	FloorAndCeil:
		Push ax
		mov al,Vr
		Neg al
		mov Vr,al
		call HitSound
		Pop ax
		JMP Exit
	LeftWall:
		call HitSound
		mov ax,Pad1s
		UpperPad:
			Cmp PosR,ah
			JNE MiddlePad
			;Knowing the angle
				Angle0:
					cmp Vr,0
					JNE Angle30
					inc Vc
					inc Vc
					inc Vr
					Exit: JMP Exit1
				Angle30:
					cmp Vc,0FEh
					JNE Angle45
					Push bx
					mov bl,0
					mov Vr,bl
					inc bl
					mov Vc,bl
					Pop bx
					Exit1: JMP Exit2
				
				Angle45:
					inc Vc
					inc Vc
					inc Vc
					JMP Exit		
		MiddlePad:
			inc ah
			CMP ah,PosR
			JNE LowerPad
				Push ax
				mov al,Vc
				neg al
				mov Vc,al
				Pop ax
				JMP Exit2
								temp: JMP RightWall
		LowerPad:
			inc ah
			CMP ah,PosR
			JNE EndPointFor2
				AngleL0:
						cmp Vr,0
						JNE AngleL30
						inc Vc
						inc Vc
						dec Vr
						JMP Exit2
									
				AngleL30:
						cmp Vc,0FEh
						JNE AngleL45
						Push bx
						mov bl,0
						mov Vr,bl
						inc bl
						mov Vc,bl
						Pop bx
						Exit2: JMP Exit3
				AngleL45:
						inc Vc
						inc Vc
						inc Vc
						JMP Exit3
			EndPointFor2:
				call EndPointFor2P
				
				
				JMP Exit3
	RightWall:
		call HitSound
		mov ax,Pad2s
		
		UpperPad_1:
			Cmp PosR,ah
			JNE MiddlePad_1
			;Knowing the angle
				Angle0_1:
					cmp Vr,0
					JNE Angle30_1
					dec Vc
					dec Vc
					inc Vr
					JMP Exit3
				Angle30_1:
					cmp Vc,0FEh
					JNE Angle45_1
					Push bx
					mov bl,0
					mov Vr,bl
					dec bl
					mov Vc,bl
					Pop bx
					Exit3: JMP Exit4
				
				Angle45_1:
					dec Vc
					dec Vc
					dec Vc
					JMP Exit4		
		MiddlePad_1:
			inc ah
			CMP ah,PosR
			JNE LowerPad_1
				Push ax
				mov al,Vc
				neg al
				mov Vc,al
				Pop ax
				JMP Exit4
		LowerPad_1:
			inc ah
			CMP ah,PosR
			JNE EndPointFor1
				AngleL0_1:
						cmp Vr,0
						JNE AngleL30_1
						dec Vc
						dec Vc
						dec Vr
						JMP Exit4
				AngleL30_1:
						cmp Vc,0FEh
						JNE AngleL45_1
						Push bx
						mov bl,0
						mov Vr,bl
						dec bl
						mov Vc,bl
						Pop bx
						Exit4: JMP Exit5
				AngleL45_1:
						dec Vc
						dec Vc
						dec Vc
						JMP Exit5
			EndPointFor1:
				call EndPointFor1P
				
				JMP Exit5
	
	Exit5: ;we succesfully change Velocity 
	
	
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	GameLogic endp
	
	
	MovingPad proc near
		push ax
		push bx
		push cx
		push dx
		
			mov ah,1
			int 16h
			JZ EnDD
			mov ah,0
			int 16h
		UpR:	
			cmp ah,72
			JNE DownR
			call MovePadUp2
			
		DownR:	
			cmp ah,80
			JNE DownL
			call MovePadDown2
			
		DownL:	
			cmp al,97
			JNE UpL
			call MovePadDown1
			
		UpL:	
			cmp al,113
			JNE Exit23
			call MovePadUp1
		Exit23:
			cmp al,27
			JNE EnDD
			mov ax,4c00h
			int 21h
			
		EnDD:
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	MovingPad endp
	
	DrawInitialPad1 proc near
	
		mov ax, 0600h         
		mov bh, 00010001b   
		
		mov cx,Pad1s
		mov dx,cx
		inc dh
		inc dh
		int 10h
		ret
	DrawInitialPad1 endp
	
	DrawInitialPad2 proc near
		mov ax, 0600h         
		mov bh, 01000100b   
		
		mov cx,Pad2s
		mov dx,cx
		inc dh
		inc dh
		int 10h
		ret
	DrawInitialPad2 endp
	

	MovePadUp1 proc 
		;Macro to move the pad up
		push ax
		push bx
		push cx
		push dx
			mov ah,6  ;ah=6 is used in the scroll up 
			mov al,1  ;Number of lines 
			mov bh,7
			mov cx,Pad1s ;Loc is the variable containg the upper bound of my pad, i need to locate it in the cx (top lef corner )
			cmp ch,0
			JE GoOut
			mov dx,Pad1s ;Put the value of Loc in dx
			add dh,2   ; by adding 2, i will make sure that the lower right edge of my rectangle is covering the whole pad
			dec ch  ; we let the ch (Row value of the Cx) be dec so that we add a free space in our rectangle that will have the pad after scrolling 
			int 10h
			mov Pad1s,cx   ;saving the new value of the pad in the Loc 	
			GoOut:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	 MovePadUp1 endp
	 
	 
	 
	 
	MovePadUp2 proc 
		;Macro to move the pad up
		push ax
		push bx
		push cx
		push dx
			mov ah,6  ;ah=6 is used in the scroll up 
			mov al,1  ;Number of lines 
			mov bh,7
			mov cx,Pad2s ;Loc is the variable containg the upper bound of my pad, i need to locate it in the cx (top lef corner )
			cmp ch,0
			JE GoOut1
			mov dx,Pad2s ;Put the value of Loc in dx
			add dh,2   ; by adding 2, i will make sure that the lower right edge of my rectangle is covering the whole pad
			dec ch  ; we let the ch (Row value of the Cx) be dec so that we add a free space in our rectangle that will have the pad after scrolling 
			int 10h
			mov Pad2s,cx   ;saving the new value of the pad in the Loc 	
			GoOut1:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	 MovePadUp2 endp
	 
	 
	 
	MovePadDown1 proc 
		
		push ax
		push bx
		push cx
		push dx
			mov ah,7   ;ah=7 is used in the scroll down
			mov al,1	;Number of lines 
			mov bh,7
			mov cx,Pad1s    ;Loc is the variable containg the upper bound of my pad, i need to locate it in the cx (top lef corner )
			cmp ch,17
			JE GoOut2
			mov dx,Pad1s    ;Put the value of Loc in dx
			add dh,3	;by adding 3 to dx, i will ensure that my rectangle is covering my pad and the space i will take to go down
			int 10h
			inc ch		;increasing ch so that cx will now have the new value of the offset of my pad
			mov Pad1s,cx	;saving the loc of my pad in its variable 
			GoOut2:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	 MovePadDown1 endp
	 
	 
	 
	MovePadDown2 proc 
		
		push ax
		push bx
		push cx
		push dx
			mov ah,7   ;ah=7 is used in the scroll down
			mov al,1	;Number of lines 
			mov bh,7
			mov cx,Pad2s    ;Loc is the variable containg the upper bound of my pad, i need to locate it in the cx (top lef corner )
			cmp ch,17
			JE GoOut22
			mov dx,Pad2s    ;Put the value of Loc in dx
			add dh,3	;by adding 3 to dx, i will ensure that my rectangle is covering my pad and the space i will take to go down
			int 10h
			inc ch		;increasing ch so that cx will now have the new value of the offset of my pad
			mov Pad2s,cx	;saving the loc of my pad in its variable 
			GoOut22:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	 MovePadDown2 endp


	EndpointFor1P proc near
		Push ax
		Push bx
		Push cx
		Push dx
		;Left Player won the point
		
		inc Score1
		
		;Clearing screem
				mov ax,0600h
				mov bh,7
				mov cx,0000h
				mov dh,19
				mov dl,80
				int 10h
		
		;Printing large numbers later
		
		mov al,Score1
		cmp al,5
		JNE still1
		Mov al,1
		mov WinFor1,al
		JMP EnDDD
		still1:
		mov dx,0B02h
		mov Pad1s,dx
		mov dx,0B4Dh
		mov Pad2s,dx
		call DrawInitialPad1
		call DrawInitialPad2
		mov dh,0ch
		mov PosR,dh
		mov dh,76
		mov PosC,dh
		mov dh,0
		mov Vr,dh
		dec dh
		mov Vc,dh
		;Print Pads and ball
		call printball
		call LambaBlue
		
		call PrintPlayer1
		call PrintPlayer2
		; mov cx,0FFFFh
		; label99:
		; loop label99
		call ClearingUnwanted
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; hazem beygrab hena 
		call MovingStaticPad
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		mov ah,Random
		mov al,last
		cmp ah,0
			JNE NextAngle
				mov dl,0
				mov Vr,dl
				dec dl
				mov Vc,dl
			NextAngle:
			cmp ah,1
			JNE NextAngle1
				mov dl,1
				neg dl
				mov Vr,dl
				mov Vc,dl
				cmp al,0
				JNE NextAngle1
				neg dl
				mov Vr,dl
			NextAngle1:
			cmp ah,2
			JNE Lastaya
				mov dl,2
				neg dl
				mov Vc,dl
				inc dl
				mov Vr,dl
				cmp al,0
				JNE Lastaya
				neg dl
				mov Vr,dl
			Lastaya:
		
		
		call ClearingUnwanted
		EnDDD:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	EndpointFor1P endp



	EndpointFor2P proc near
		Push ax
		Push bx
		Push cx
		Push dx
		;Left Player won the point
		
		inc Score2
		
		;Clearing screem
				mov ax,0600h
				mov bh,7
				mov cx,0000h
				mov dh,19
				mov dl,80
				int 10h
		
		;Printing large numbers later
		
		mov al,Score2
		cmp al,5
		JNE still2
		Mov al,1
		mov WinFor2,al
		JMP EnDDDD
		still2:
		mov dx,0B02h
		mov Pad1s,dx
		mov dx,0B4Dh
		mov Pad2s,dx
		call DrawInitialPad1
		call DrawInitialPad2
		mov dh,0ch
		mov PosR,dh
		mov dh,3
		mov PosC,dh
		mov dh,0
		mov Vr,dh
		inc dh
		mov Vc,dh
		;Print Pads and ball
		call printball
		call LambaRed
		
		call PrintPlayer1
		call PrintPlayer2
		; mov cx,0FFFFh
		; label993:
		; loop label993
		call ClearingUnwanted
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; hazem beygarab hena 
		call MovingStaticPad
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				mov ah,Random
				mov al,last
				cmp ah,0
				JNE NextAngle2
					mov dl,0
					mov Vr,dl
					inc dl
					mov Vc,dl
				NextAngle2:
				cmp ah,1
				JNE NextAngle12
					mov dl,1
					mov Vr,dl
					mov Vc,dl
					cmp al,1
					JNE NextAngle12
					neg dl
					mov Vr,dl
				NextAngle12:
				cmp ah,2
				JNE Lastaya2
					mov dl,2
					mov Vc,dl
					dec dl
					mov Vr,dl
					cmp al,1
					JNE Lastaya2
					neg dl
					mov Vr,dl
				Lastaya2:
		
		
		call ClearingUnwanted
		EnDDDD:
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	EndpointFor2P endp

	
	PrintPlayer1 proc 
			push ax
			push bx
			push cx
			push dx
				;setting cursor
				mov bx,0
				mov ah,2
				mov dh,21
				mov dl,00
				int 10h
				;Print Charter
				mov dl,First1
				mov ah,2
				int 21h
				;SetCursor
				mov bx,0
				mov ah,2
				mov dh,21
				mov dl,01
				int 10h
				;Printing name
				Lea dx,Player1+2
				mov ah,9h
				int 21h
				;Setting cursor again
				mov bx,0
				mov ah,2
				mov dh,21
				mov dl,11
				int 10h
				;Printing :
				mov dl,':'
				int 21h
				;Setting cursor again
				mov bx,0
				mov ah,2
				mov dh,21
				mov dl,11
				int 10h
				;Printing score
				mov dl,Score1
				add dl,30h
				int 21h
				
			pop dx
			pop cx
			pop bx
			pop ax
			ret		
	PrintPlayer1 endp

	PrintPlayer2 proc
			push ax
			push bx
			push cx
			push dx
				
				;setting cursor
				mov bx,0
				mov ah,2
				mov dh,21
				mov dl,60
				int 10h
				;Print Charter
				mov dl,First2
				mov ah,2
				int 21h
				;SetCursor
				mov bx,0
				mov ah,2
				mov dh,21
				mov dl,61
				int 10h
				;Printing name
				Lea dx,Player2+2
				mov ah,9h
				int 21h
				;Setting cursor again
				mov bx,0
				mov ah,2
				mov dh,21
				mov dl,71
				int 10h
				;Printing :
				mov dl,':'
				int 21h
				;Setting cursor again
				mov bx,0
				mov ah,2
				mov dh,21
				mov dl,71
				int 10h
				;Printing score
				mov dl,Score2
				add dl,30h
				int 21h
				
			pop dx
			pop cx
			pop bx
			pop ax
			ret
	PrintPlayer2 endp


	HitSound proc
		push ax
		push bx
		push cx
		push dx
			mov al,182
			out 43h,al
			mov ax,2711
			
			out 42h,al
			mov al,ah
			out 42h,al
			in al,61h
			
			or al,00000011b
			out 61h,al
			mov bx,25
		.pause1:
			mov cx,935
		.pause2:
			dec cx
			jne .pause2
			dec bx
			jne .pause1
			in al,61h
			
			and al,11111100b
			out 61h,al 
			
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	HitSound endp

	
	HitSoundE proc
		push ax
		push bx
		push cx
		push dx
			mov al,182
			out 43h,al
			mov ax,3619
			
			out 42h,al
			mov al,ah
			out 42h,al
			in al,61h
			
			or al,00000011b
			out 61h,al
			mov bx,25
		.pause12:
			mov cx,2935
		.pause22:
			dec cx
			jne .pause22
			dec bx
			jne .pause12
			in al,61h
			
			and al,11111100b
			out 61h,al 
			
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	HitSoundE endp
	
	
	HitSoundC proc
		push ax
		push bx
		push cx
		push dx
			mov al,182
			out 43h,al
			mov ax,4560
			
			out 42h,al
			mov al,ah
			out 42h,al
			in al,61h
			
			or al,00000011b
			out 61h,al
			mov bx,25
		.pause13:
			mov cx,2935
		.pause23:
			dec cx
			jne .pause23
			dec bx
			jne .pause13
			in al,61h
			
			and al,11111100b
			out 61h,al 
			
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	HitSoundC endp
	
	
	
	HitSoundLowG proc
		push ax
		push bx
		push cx
		push dx
			mov al,182
			out 43h,al
			mov ax,1521
			
			out 42h,al
			mov al,ah
			out 42h,al
			in al,61h
			
			or al,00000011b
			out 61h,al
			mov bx,25
		.pause14:
			mov cx,2905
		.pause24:
			dec cx
			jne .pause24
			dec bx
			jne .pause14
			in al,61h
			
			and al,11111100b
			out 61h,al 
			
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	HitSoundLowG endp
	
	
	
	HitSoundG proc
		push ax
		push bx
		push cx
		push dx
			mov al,182
			out 43h,al
			mov ax,3043
			
			out 42h,al
			mov al,ah
			out 42h,al
			in al,61h
			
			or al,00000011b
			out 61h,al
			mov bx,25
		.pause15:
			mov cx,2935
		.pause25:
			dec cx
			jne .pause25
			dec bx
			jne .pause15
			in al,61h
			
			and al,11111100b
			out 61h,al 
			
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	HitSoundG endp
	
	HitSoundA proc
		push ax
		push bx
		push cx
		push dx
			mov al,182
			out 43h,al
			mov ax,2711
			
			out 42h,al
			mov al,ah
			out 42h,al
			in al,61h
			
			or al,00000011b
			out 61h,al
			mov bx,35
		.pause16:
			mov cx,2335
		.pause26:
			dec cx
			jne .pause26
			dec bx
			jne .pause16
			in al,61h
			
			and al,11111100b
			out 61h,al 
			
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	HitSoundA endp
	
	
	HitSoundB proc
		push ax
		push bx
		push cx
		push dx
			mov al,182
			out 43h,al
			mov ax,2415
			
			out 42h,al
			mov al,ah
			out 42h,al
			in al,61h
			
			or al,00000011b
			out 61h,al
			mov bx,25
		.pause11:
			mov cx,2935
		.pause21:
			dec cx
			jne .pause21
			dec bx
			jne .pause11
			in al,61h
			
			and al,11111100b
			out 61h,al 
			
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	HitSoundB endp
	
	
	HitSoundAcharp proc
		push ax
		push bx
		push cx
		push dx
			mov al,182
			out 43h,al
			mov ax,2559
			
			out 42h,al
			mov al,ah
			out 42h,al
			in al,61h
			
			or al,00000011b
			out 61h,al
			mov bx,25
		.pause17:
			mov cx,2935
		.pause27:
			dec cx
			jne .pause27
			dec bx
			jne .pause17
			in al,61h
			
			and al,11111100b
			out 61h,al 
			
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	HitSoundAcharp endp
	
	
	
	
	
	song proc
			call HitSoundE
			call HitSoundE
			call HitSoundE
			call HitSoundC
			call HitSoundE
			call HitSoundG
			call HitSoundLowG
			call HitSoundC
			call HitSoundG
			call HitSoundE
			call HitSoundA
			call HitSoundB
			call HitSoundAcharp
			; call HitSoundA
			; call HitSoundG
			; call HitSoundE
			; call HitSoundG
			; call HitSoundE
			; call HitSoundC
			; call HitSoundE
			call HitSoundG
			call HitSoundLowG
			call HitSoundC
			call HitSoundG
			call HitSoundE
			call HitSoundA
			call HitSoundB
			call HitSoundAcharp
			call HitSoundA
			call HitSoundA
			call HitSoundG
			call HitSoundE
			call HitSoundG
			call HitSoundE
			call HitSoundC
			call HitSoundE
			call HitSoundG
			call HitSoundLowG
			call HitSoundC
			call HitSoundG
			call HitSoundE
			call HitSoundA
			call HitSoundB
			call HitSoundAcharp
			call HitSoundLowG
			call HitSoundC
			call HitSoundG
			call HitSoundE
			call HitSoundA
			call HitSoundB
			ret
	song endp
	
	MovingStaticPad proc near
		push ax
		push bx
		push cx
		push dx
		
		
		mov cx,0
		Starting:
			mov ah,1
			int 16h
			JZ Starting
			mov ah,0
			int 16h
		UpR1:	
			cmp ah,72
			JNE DownR1
			call MovePadUp2
			mov dh,PosC
			cmp dh,76
			JNE DownR1
			mov dl,PosR
			; cmp dl,18
			; JE DownR1
			cmp dl,1
			JE DownR1
			dec PosR
			inc cx
			mov ch,1
			call clearball
			call printball
		DownR1:	
			cmp ah,80
			JNE DownL1
			call MovePadDown2
			mov dh,PosC
			cmp dh,76
			JNE DownL1
			mov dl,PosR
			cmp dl,18
			JE DownL1
			; cmp dl,1
			; JE DownL1
			inc PosR
			inc cx
			mov ch,0
			call clearball
			call printball
		DownL1:	
			cmp al,97
			JNE UpL1
			call MovePadDown1
			mov dh,PosC
			cmp dh,3
			JNE UpL1
			mov dl,PosR
			cmp dl,18
			JE UpL1
			; cmp dl,1
			; JE UpL1
			inc PosR
			inc cx
			mov ch,0
			call clearball
			call printball
			JMP UpL1
			Hamada: JMP Starting
		UpL1:	
			cmp al,113
			JNE Exit231
			call MovePadUp1
			mov dh,PosC
			cmp dh,3
			JNE Exit231
			mov dl,PosR
			; cmp dl,18
			; JE Exit231
			cmp dl,1
			JE Exit231
			dec PosR
			inc cx
			mov ch,1
			call clearball
			call printball
		Exit231:
			cmp al,27
			JNE ContinuePoint
			mov ax,4c00h
			int 21h
		ContinuePoint:
			cmp al,32 
			JNE Hamada
			;Generate a random angle
			mov last,ch
			mov ah,0
			mov al,cl
			mov bh,3
			
			div bh
			mov random,ah
			
			
			
		EnDDDDD:
		
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	MovingStaticPad endp
	
	
	LambaRed proc
		push ax
		push bx
		push cx
		push dx
			
			mov ax, 0600h         
			mov bh, 01001000b      ; this uses the first four bits for background and the next four bits are for font
			mov cx, 0000           ; first eight bits are used for row of top left corner of rectangle
			mov dh,19		; this sets the row and column of right bottom corner in which the background and font colors are set
			mov dl,0
			int 10h
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	LambaRed endp
	
	LambaBlue proc 
		push ax
		push bx
		push cx
		push dx
			
			mov ax, 0600h         
			mov bh, 00010001b      ; this uses the first four bits for background and the next four bits are for font
			mov ch,00			; first eight bits are used for row of top left corner of rectangle
			mov cl,79
			mov dh,19		; this sets the row and column of right bottom corner in which the background and font colors are set
			mov dl,79
			int 10h
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	LambaBlue endp
	
	
	EndScreen proc
		push ax
		push bx
		push cx
		push dx
			call SongEnd
			mov ax, 0600h         
			mov bh, 00011110b      ; this uses the first four bits for background and the next four bits are for font
			mov cx, 0000           ; first eight bits are used for row of top left corner of rectangle
			mov dx, 8025           ; this sets the row and column of right bottom corner in which the background and font colors are set
			mov dh,19
			mov dl,79
			int 10h
			call SongEnd
			;Set Cursor in the middle of screen 
			mov bx,0
			mov ah,2 
			mov dl,22 
			mov dh,06 
			int 10h
			
			;Print the winner 
			mov al,Score1
			cmp al,5
			JNE player2Won
			;print player1 won
				mov dl,First1
				mov ah,2
				int 21h
				;set cursor again
				;Set Cursor in the middle of screen 
			mov bx,0
			mov ah,2 
			mov dl,23 
			mov dh,06 
			int 10h
			
				Lea dx,Player1+2
				mov ah,9h
				int 21h
				JMP ENDDDDDDD
			Player2Won:
			mov dl,First2
				mov ah,2
				int 21h
				;set cursor again
				;Set Cursor in the middle of screen 
			mov bx,0
			mov ah,2 
			mov dl,23 
			mov dh,06 
			int 10h
				Lea dx,Player2+2
				mov ah,9h
				int 21h
			;print player2 won
			ENDDDDDDD:
			;Set Cursor in the middle of screen 
			mov bx,0
			mov ah,2 
			mov dl,33 
			mov dh,06 
			int 10h
			Lea dx,won
			mov ah,9h
			int 21h
			
			;Wait Key press and exit 
			
			mov bx,0
			mov ah,2 
			mov dl,22 
			mov dh,09 
			int 10h
			Lea dx,Anykey
			mov ah,9h
			int 21h
			
			mov ah,0
			int 16h
			
			mov ax,4c00h
			int 21h
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	EndScreen endp
	
	
	RandomAngle proc
			mov ah,Random
				mov al,last
				cmp ah,0
				JNE NextAngle25
					mov dl,0
					mov Vr,dl
					inc dl
					mov Vc,dl
				NextAngle25:
				cmp ah,1
				JNE NextAngle125
					mov dl,1
					mov Vr,dl
					mov Vc,dl
					cmp al,1
					JNE NextAngle125
					neg dl
					mov Vr,dl
				NextAngle125:
				cmp ah,2
				JNE Lastaya25
					mov dl,2
					mov Vc,dl
					dec dl
					mov Vr,dl
					cmp al,1
					JNE Lastaya25
					neg dl
					mov Vr,dl
				Lastaya25:
		ret
	RandomAngle endp
	
	
	DrawPong proc
	Push ax
	Push bx
	Push cx
	Push dx
		
		mov ax, 0600h         
		mov bh, 00010001b      ; this uses the first four bits for background and the next four bits are for font
		mov cx, 0000           ; first eight bits are used for row of top left corner of rectangle
		mov dx, 8025           ; this sets the row and column of right bottom corner in which the background and font colors are set
		int 10h
		
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,7
		mov cl,20
		mov dh,8
		mov dl,27
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,7
		mov cl,20
		mov dh,17
		mov dl,21
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,8
		mov cl,26
		mov dh,12
		mov dl,27
		int 10h
		
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,7
		mov cl,20
		mov dh,8
		mov dl,27
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,11
		mov cl,20
		mov dh,12
		mov dl,27
		int 10h
		
		;Printing O
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,12
		mov cl,30
		mov dh,13
		mov dl,37
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,16
		mov cl,30
		mov dh,17
		mov dl,37
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,12
		mov cl,30
		mov dh,17
		mov dl,31
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,12
		mov cl,36
		mov dh,17
		mov dl,37
		int 10h
		
		
		;Printing N
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,12
		mov cl,40
		mov dh,13
		mov dl,47
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,12
		mov cl,40
		mov dh,17
		mov dl,41
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,12
		mov cl,46
		mov dh,17
		mov dl,47
		int 10h
		
		;Printing G
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,12
		mov cl,50
		mov dh,13
		mov dl,57
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,12
		mov cl,50
		mov dh,17
		mov dl,51
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,16
		mov cl,50
		mov dh,17
		mov dl,57
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,12
		mov cl,56
		mov dh,22
		mov dl,57
		int 10h
		
		mov ax, 0600h         
		mov bh, 11111111b      
		mov ch,21
		mov cl,53
		mov dh,22
		mov dl,57
		int 10h
		
		
		
	pop dx
	pop cx
	pop bx
	pop ax
	ret
		
	DrawPong endp
	
	
	ClearScreen proc
	Push ax
	Push bx
	Push cx
	Push dx
		mov bx,0
		mov ah,0
        mov al,3
        int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	ClearScreen endp
	
	
	WaitForClick proc
	Push ax
	Push bx
	Push cx
	Push dx
			mov ah,9h
			int 21h
			
			mov ah,0
			int 16h
	pop dx
	pop cx
	pop bx
	pop ax
	ret		
	WaitForClick endp
	
	ClearingUnwanted proc
	Push ax
	Push bx
	Push cx
	Push dx
		call MovePadDown1
		call MovePadDown2
		call MovePadUp1
		call MovePadUp2
		call clearball
		call printball
	mov ah,PosC
	cmp ah,3
	JNE AnotherPoint
		mov ax, 0600h         
		mov bh, 0    
		mov ch,0
		mov cl,78
		mov dh,19
		mov dl,79
		int 10h
		
		mov ax, 0600h         
		mov bh, 0      
		mov ch,0
		mov cl,1
		mov dh,19
		mov dl,1
		int 10h
		JMP Cleared
	AnotherPoint:	
		mov ax, 0600h         
		mov bh, 0      
		mov ch,0
		mov cl,0
		mov dh,19
		mov dl,1
		int 10h
		
		mov ax, 0600h         
		mov bh, 0      
		mov ch,0
		mov cl,78
		mov dh,19
		mov dl,78
		int 10h
	
	Cleared:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	ClearingUnwanted endp
	
	
	SongEnd proc
	
		Call HitSoundA
		Call HitSound
		Call HitSoundG
		Call HitSoundE
		Call HitSoundB
		Call HitSoundC
		ret
	SongEnd endp 
	
	
Menu proc  near
	  ContinueAfterWrongEntry:   
		;set the background and font color!!
		
		mov ax, 0600h   
		mov bl,0
		mov bh, 00011110b      ; this uses the first four bits for background and the next four bits are for font
		mov cx, 0000           ; first eight bits are used for row of top left corner of rectangle
		mov dx, 8025           ; this sets the row and column of right bottom corner in which the background and font colors are set
		int 10h
	 
		;set the cursor to the mid of the screen
		mov bx,0
		mov ah,2 
		mov dl,22 
		mov dh,00 
		int 10h
	  
	  ;message to get player-1 name
	  lea dx, get_Player1
	  mov ah, 9
	  int 21h 
	  ;wait the 1st user to enter his/her name 
		  ;to set the color of what is typed
		  mov ah,6
		  mov bh,00011010b
		  mov cx,0044
		  mov dx,0065
		  int 10h
	  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	  ;;;;;;;;;;;;;;;;;;;;;;;;; Ignore the Special Characters ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	 
	THEEND1:
	 		mov ah,1
			int 16h
			JZ THEEND1
			mov ah,0
			int 16h
		
	  
	  cmp al,65
	  jge A
	  jmp wrong
	  A:
	  cmp al,90
	  jle print
	  jmp check2
	  check2:
	  cmp al,97
	  jge aa
	  jmp wrong
	  aa:
	  cmp al,122
	  jle print
	  jmp wrong
	  print:
	  mov First1,al
	  
	  mov ah,9 ;Display
	  int 10h
	  
	  jmp string
	  wrong: 
		  ; mov ah,6
		  ; mov bh,00011100b
		  ; mov cx,0044
		  ; mov dx,0080
		  ; int 10h
	  ; lea dx,wrong_char
	  ; mov ah,9
	  ; int 21h
	  ;JMP EnterToContinue
		;Click Enter to continue
	  ; mov ah,07
	   ; int 21h
				;mov ah,9h
				;int 21h
				
				;mov ah,0
				;int 16h
		; cmp al,10
	  ; jz EnterToContinue
	  ; EnterToContinue:
		;scroll up to remove the invalid entry
	  ; mov ax,0600h 
	  ; mov bh,07
	  ; mov cx,0
	  ; mov dx,184FH
	  ; int 10h
	  
	  jmp ContinueAfterWrongEntry

	  
	  string:
	  mov ah,2
	  mov dl,First1
	  int 21h
	  
	  mov ah,0Ah
	  lea dx,Player1
	  int 21h 
	;;;;;;;;;;;;;;;;;;;;;;;End of Entering 1st Player name;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      
	  ;Click Enter to enter 2nd player's name
	  ; mov ah,07
	  ; int 21h
	  ; cmp al,10
	  ; jz Enter000
	  
	  
	  ;set the cursor to the next line
	  Enter000: 
	  mov bx,0
	  mov ah,2 
	  mov dl,22 
	  mov dh,03 
	  int 10h
	 
	   
	  ;message to get player-2 name
	  lea dx, get_Player2
	  mov ah, 9
	  int 21h

	ContinueAfterWrongEntry2:
	  ;wait the 2nd user to enter his/her name!
		  ;to set the color of what is typed
			 
		  mov ah,6
		  mov al,0
		  mov bl,0
		  mov bh,00011010b
		  mov ch,04
		  mov cl,60
		  mov dh,04
		  mov dl,80
		  int 10h
		  
	  
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;; Ignore the Special Characters ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		THEEND:
	 		mov ah,1
			int 16h
			JZ THEEND
			mov ah,0
			int 16h
		
	  
			; Starting:
				; mov ah,1
				; int 16h
				; JZ Starting
				; mov ah,0
				; int 16h
				
				
	  ; call HitSoundB
	  ; call HitSoundB
	  ; call HitSoundB
	  ; call HitSoundB 
	  
	  cmp al,65
	  jge A2
	  jmp wrong2
	  A2:
	  cmp al,90
	  jle print2
	  jmp check22
	  check22:
	  cmp al,97
	  jge aa2
	  jmp wrong2
	  aa2:
	  cmp al,122
	  jle print2
	  jmp wrong2
	  print2:
	  mov First2,al
	  mov ah,9 ;Display
	  int 10h
	  
	  jmp string2
	  
	  
	  wrong2:
		  ;setting the color of the message appear when invalid char is entered 
		  ; mov ah,6
		  ; mov bh,00011100b
		  ; mov bl,0
		  ; mov al,0
		  ; mov cx,0460
		  ; mov dx,0495
		  ; int 10h
	  ; lea dx,wrong_char
	  ; mov ah,9
	  ; int 21h
	  
		;Click Enter to continue
	  ; mov ah,07
	  ; int 21h
	  ; cmp al,10
	  ; jz EnterToContinue2
	  EnterToContinue2:
	  ;delete the area where the invalid entry occured 
	  ; mov ax,0600h
	  ; mov bh,00011010b
	  ; mov bl,0
	  ; mov cx,0460
	  ; mov dx,0495
	  ; int 10h
	  jmp set
	  set:
	  mov ah,2
	  mov bx,0
	  mov dl,44
	  mov dh,03
	  int 10h

			; mov ah,9
			; mov bh,0
			; mov al,9
			; mov cx,1
			; mov bl,0
			; int 10h
			
	  jmp ContinueAfterWrongEntry2
	  
	  string2:
	 mov ah,2
	  mov dl,First2
	  int 21h
	  
	  mov ah,0Ah
	  lea dx,Player2
	  int 21h
	  
	  mov bx,0
	  mov ah,2 
	  mov dl,00 
	  mov dh,05 
	  int 10h
	  
		lea dx, option_1
		mov ah, 9
		int 21h
	  ;set cursor2  
	  mov bx,0
	  mov ah,2 
	  mov dl,00 
	  mov dh,06 
	  int 10h
			   
		lea dx, option_2
		mov ah, 9
		int 21h
	  ;set cursor3         
	  mov bx,0
	  mov ah,2 
	  mov dl,00 
	  mov dh,07 
	  int 10h
			  
		lea dx, option_3
		mov ah, 9
		int 21h
		
		;Check the options 
			YALLLA:
				mov ah,1
				int 16h
				JZ YALLLA
				mov ah,0
				int 16h
				
				cmp al,27
				JNE Game
				mov ax,4c00h
				int 21h
				Game:
				cmp al,103
				JNE Chatting
				mov bl,1
				mov WhereToGo,bl
				JMP etla3bara
				Chatting:
				cmp al,99
				JNE YALLLA
				mov ax,4c00h
				int 21h
				
		etla3bara:
		
	ret  

Menu endp

End Main_prog 




	