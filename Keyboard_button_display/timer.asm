IT100:  MOV		TH1,	#08Ah		; TH1 register regeneration Ò/C1 30 ms
		MOV		TL1,	#0D0h		; TL1 register regeneration Ò/C1 30 ms

		MOV 	P1,		#00001111b
		MOV 	A,		P1			; Record result of interaction of P1 with the keyboard
		MOV 	P1,		#11110000b	 
		ORL 	A,		P1			 
		CJNE 	A,		#255,	BUT_IS_PUSH	 ; Check if button is pushed
		LJMP	FIN
BUT_IS_PUSH:
		MOVC 	A,		@A+DPTR		; Transfer bytes from program memory to accumulator
		MOV  	P3,		A
	
FIN:	RETI						; Exit interrupt