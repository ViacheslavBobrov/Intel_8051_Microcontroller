		ORG		0000h				; Program Start Address
		LJMP	INIT				; Go to the beginning of the initialization procedure
; -- Table of interrupt vectors -----------------------------------------------------------
		ORG		001Bh				; T/C1 interrupt vector address
		LJMP	IT100				; Go to T/C1 interrupt processing
; --Initialization of the microcontroller --------------------------------------------------------
		ORG		0030h				; Initialization start address
INIT:	CLR		EA					; Disable all interrupts
		MOV		SP,		#070h		; Stack bottom
; __ Timers Initialation   _____
		MOV		TMOD,	#00010000b	; Setting 1st timer operation mode for T/C1
		MOV		TH1,	#08Ah		; Setting the initial value of the timer T/C1 = 30 ms
		MOV		TL1,	#0D0h		; Setting the initial value of the timer T/C1 
		MOV		TCON,	#01000000b	; Turn on the T/C1 timer
; __ Interrupts  Initialation ___
		MOV		IP,		#00000000b	; Setting Interrupt Priorities
		MOV		IE,		#00001000b	; Enabling T/C1 timer interrupt
; __ Initialization of program components __
	   	SLEEP  	EQU		 000H	  	; Shows whether the set delay time has passed.

	    MOV  	P3, 	#0			; P3 port reset
		MOV	 	DPTR,	#100H		
	   	SETB	EA					; Enabling Interrupts
		LJMP	M11					; Transition to the main.asm program 	
	
		ORG 	0170H				;	Creating a table of segmented keyboard codes
 TABL:
		 ;	 0	1  2  3	 4	5  6  7	 8	9  A  B	 C	D  E  F
 		 DB 00,00,00,00,00,00,00,B9,00,00,00,5E,00,79,71,00	 ; 7
		 DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00	 ; 8
		 DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00	 ; 9
		 DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00	 ; A
		 DB 00,00,00,00,00,00,00,7C,00,00,00,DF,00,FD,4F,00	 ; B
		 DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00	 ; C
		 DB 00,00,00,00,00,00,00,77,00,00,00,7F,00,6D,5B,00	 ; D
		 DB 00,00,00,00,00,00,00,3F,00,00,00,07,00,66,06,00	 ; E								