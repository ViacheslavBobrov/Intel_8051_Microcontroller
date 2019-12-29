		ORG		0000h				; Program start address
		LJMP	INIT				; Jump to init procedure
; __Interrupt vector table_____
		ORG		001Bh				
		LJMP	IT100				
; __Initialization of the microcontroller_____
		ORG		0030h				; Initialization procedure start address
INIT:	CLR		EA					; Disable all interrupts
		MOV		SP,		#070h		; Stack bottom
; __Initialize Timers_____
		MOV		TMOD,	#00010000b	; Setting 1 T/C1 timer operation mode
		MOV		TH1,	#03Ch		; Setting the initial value of the timer T/C1
		MOV		TL1,	#0AFh		; Setting the initial value of the timer T/C1
		MOV		TCON,	#01000000b	; Turn on the T/C1 timer
; __Initialization of interrupts ___
		MOV		IP,		#00000000b	; Setting interrupt priorities
		MOV		IE,		#00001000b	; Enable timer Ò/C1 interrupt
; __Initialization of variables__
		STATE1	EQU		00h			; Start Movement State
		STATE2	EQU		01h			; State "Moving on port P3"
		STATE3	EQU		02h			; State "Transition from P3 to P1"
		STATE4	EQU		03h			; State "Moving on port P1"
		STATE5	EQU		04h			; End Movement State
		CUR		EQU 	20h			; Current State
; __Setting initial register values__
		MOV		P1,		#0			; Reset Port P1 to 0
		MOV		P3,		P1			; Reset Port P3 to 0
		MOV		R1,		#4			; Step counter
		MOV		R0,		#4			 
		MOV		CUR,	#00000001b	; Set Start Movement State
		
; ------------------------------------------------------------------------------------------
		SETB	EA					; Enable interruptions
		LJMP	M00					; Move to main.asm