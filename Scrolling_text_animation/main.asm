;
; Led scrolling text animation
;


;=====================Initialization=======================//
		ORG		0000h					
		LJMP	INIT					
		
		ORG		001Bh					
		LJMP	IT00					

;---------Character table-------------------		
		ORG 	0100H		
;			0   1   2   3   4   5   6   7	8	9	A	B	C  D	E	F
TABLE:	DB 3Fh,06h,5Bh,4Fh,66h,6Dh,7Dh,07h,7Fh,6Fh,77h,7Ch,39h,5Eh,79h,71h ;0-F		 

		ORG		0030h
INIT:	CLR		EA					
		MOV		SP,		#070h			
; __ Timers intialization _____
		MOV		TMOD,	#00010000b		
		MOV		TH1,	#00F6h			; 2.5 ms
		MOV		TL1,	#0036h			
		MOV		TCON,	#01000000b		
; __ Intrupts initialization ___
		MOV		IP,		#00000000b		
		MOV		IE,		#00001000b		

; __ Data initialization __

		DELAY	EQU		030h			; Counter for scrolling text speed
		MOV		DELAY,	#100			; Number of delays =  100 (2.5*100 = 250 ms)
		
		COUNT	EQU		031h			; Characters counter
		MOV		COUNT,	#0				
		
		POZ		EQU		032h			; Indicator position
		MOV		POZ,	01111111b		; Start from left side

		MOV		R0,		#60h			; Address in video memory
		
;-------- Video memory --------------------------------
		POS0	EQU		060h		 								   
		POS1	EQU		061h		 								   
		POS2	EQU		062h		 								   
		POS3	EQU		063h		 								   
		POS4	EQU		064h		 								   
		POS5	EQU		065h		 								   
		POS6	EQU		066h		 								   
		POS7	EQU		067h		
;-------- Video memory initialization------------------	
		MOV		POS0,	#3Fh  			; 00111111 
		MOV		POS1,	#0
		MOV		POS2,	#0
		MOV		POS3,	#0
		MOV		POS4,	#0
		MOV		POS5,	#0
		MOV		POS6,	#0
		MOV		POS7,	#0							


		SETB	EA						
		LJMP	M0						

 ; =====================Interrupts=========================//

IT00: 	MOV		TH1, 	#00F6h			
	   	MOV		TL1,	#0036h			

	    
		CJNE	R0,		#68h,	FILL	; If address != 68 (max = 67) go to FILL 

		; 250 ms delay	   	   	
		DJNZ	DELAY,	EXIT			; If 250 ms not passed, exit interrupt
		MOV 	DELAY,	#100			; else: restore counter 
		MOV		R0,		#60h			; go to the start address

	    ; Cyclic shift of values in video memory cells
		MOV		POS7,	POS6
		MOV		POS6,	POS5
		MOV		POS5,	POS4
		MOV		POS4,	POS3
		MOV		POS3,	POS2
		MOV		POS2,	POS1
		MOV		POS1,	POS0

		; Get next character
		INC		COUNT				 	; Next character in the table
		MOV		A,		COUNT
		CJNE	A,		#16,	SEG		
		MOV		COUNT,	#0				

	  ; Get segment code
SEG:	MOV		DPTR,	#TABLE			; Loading table address in DPTR
		MOV 	A,		COUNT			; Number oif the character
		MOVC	A,		@A+DPTR			
		MOV		POS0,	A				
		LJMP	EXIT

FILL:
	 ; Display chracter in on of the 1-8 cells
		MOV		P0,		POZ			 
		SETB	P2.3					
		MOV		P0,		@R0				
		CLR		P2.3					

	 ; Switch to the next cell
	 	MOV		A,		POZ				
		RR		A					   	; Shift to the right
		MOV		POZ,	A
		INC		R0						; Go to the next addres in video memory

EXIT:	RETI

;======================Main program =================//
M0:		LJMP	M0
END