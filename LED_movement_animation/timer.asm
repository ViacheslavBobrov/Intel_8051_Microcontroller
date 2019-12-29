IT100:  MOV     TH1,    #0B1h         ; Setting the initial value of the timer T / C1
        MOV     TL1,    #0E0h

        DJNZ    R0,     FINISH        ; Ignoring Handler Algorithm
        MOV     R0,     #4            ; Setting a handler ignore counter
        
        JB      STATE2, GO3           ; If bit 01h is set, then the processing of the state "Movement on port P3"
        JB      STATE3, TRAN          ; If bit 02h is set, then processing of the state "Transition from P3 to P1"
        JB      STATE4, GO1           ; If bit 03h is set, then the processing of the state "Movement on port P1"
        JB      STATE5, FIN           ; If bit 04h is set, then the processing of the state "End of motion"


; __State: Start of movement__
        MOV     A,      P3            ; Copy P3 to A for a cyclic shift
        RR      A                    
        MOV     P3,     A            
        SETB    P3.7                  ; Increase the set P3 bits by 1
        DJNZ    R1,     FINISH        ; Exit interrupt if the number of set bits of port P3 is less than 4

        MOV     CUR,    #00000010b    ; Setting the state "Movement on port P3"
        MOV     R1,     #4            ; P3 movement counter
        RETI

; __State: Movement on port P3__
GO3:    MOV     A,      P3            ; Copy P3 to A for a cyclic shift
        RR      A
        MOV     P3,     A
        DJNZ    R1,     FINISH        ; Exit interrupt if the number of set bits of port P3 is less than 4

    
        MOV     CUR,    #00000100b    ; Setting the state "Transition from P3 to P1"
        MOV     R1,     #4            ; Setting the transition counter from P3 to P1
        RETI

; __State: Transition from P3 to P1__
TRAN:   MOV     A,      P1            ; Copy P1 to A for a cyclic shift
        RR      A
        MOV     P1,     A

        CLR     C                     ; Decrease set P3 bits by reseting
                                      ; cyclic shift carry flag

        MOV     A,      P3            ; Copy P3 to A for a cyclic shift
        RRC     A
        MOV     P3,     A

        SETB    P1.7                  ; Increase the set bits of P1 by 1
        DJNZ    R1,     FINISH        ; Exit interrupt if the number of set bits of port P3 is less than 4

        
        MOV     CUR,    #00001000b    ; Setting the status of "Movement on port P1"
        MOV     R1,     #4            ; P1 movement counter
        RETI

; __State: Movement on port P1__            
GO1:    MOV     A,      P1            ; Copy P1 to A for a cyclic shift
        RR      A
        MOV     P1,     A

        DJNZ    R1,     FINISH        ; Exit interrupt if the number of set bits of port P3 is less than 4

        
        MOV     CUR,    #00010000b    ; Setting the state "End of motion"
        MOV     R1,     #4            ; Setting end of movement counter

; __State: End of movement__
FIN:    CLR     C                     ; Decrease set P3 bits by reseting
                                      ; cyclic shift carry flag
        
        MOV     A,      P1            ;  Copy P1 to A for a cyclic shift
        RRC     A
        MOV     P1,     A
        
        DJNZ    R1,     FINISH        ; Exit interrupt if the number of set bits on port P3 is less than 4
        
        MOV     CUR,    #00000001b    ; Setting the state "Start of movement"
        MOV     R1,     #4            ; Setting the start counter

FINISH: RETI
