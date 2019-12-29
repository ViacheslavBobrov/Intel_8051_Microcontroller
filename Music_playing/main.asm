; The program plays a simple 26 notes duration tune after any keyboard
; button is pressed. The tune: https://www.youtube.com/watch?v=GFSRQ_U65TU


; =====================Initialization=========================

        ORG     0000h                ; Start program address
        LJMP    INIT                 ; Go to the beginning of the initialization procedure
; ___Table of interrupt vectors___
        ORG     001Bh                ; T/C1 interrupt vector address
        LJMP    IT100                ; Transition to T/C1 interrupt processing
        ORG     000Bh                ; T/C0 interrupt vector address
        LJMP    IT000                ; Transition to T/C0 interrupt processing

; __ Tune __
        ORG     0100H
        
; 1 - Note A (Do)  3822   1911   63625   F889
; 2 - Note B (Re)  3405   1703   63833   F959
; 3 - Note C (Mi)  3034   1517   64019   FA13
; 4 - Note D (Fa)  2863   1432   64104   FA68
; 5 - Note E (Sol) 2551   1276   64260   FB04
; 6 - Note F (La)  2273   1136   64400   FB90
; 7 - Note G (Si)  2025   1012   64524   FC0C

        ;  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        DB 04,03,02,01,05,05,04,03,02,01,05,05,04,04,06,04  ; 0
        DB 03,03,05,03,02,03,04,02,01,01,00,00,00,00,00,00  ; 1

; __ TH0 values for the notes
        ORG     0200H
        ;   0    1      2      3      4      5      6      7
        DB  00,  0F8h,  0F9h,  0FAh,  0FAh,  0FBh,  0FBh,  0FCh
; __ TH1 values for the notes
        ORG     0210H
        ;   0      1    2      3      4      5      6      7
        DB  00,  089h,  059h,  013h,  068h,  004h,  090h,  00Ch
; __ Notes duration
       ; Working with 1/32 duration
       ; 1/8 = 1/32 * 4
       ; 1/4 = 1/32 * 8
        ORG     0300H
        ; 0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        DB 04,04,04,04,08,08,04,04,04,04,08,08,04,04,04,04   ; 0
        DB 04,04,04,04,04,04,04,04,08,08,00,00,00,00,00,00   ; 1

; _____Initialization of the microcontroller _____
        ORG     0030h                ; Initialization start address
INIT:   CLR     EA                   ; Disable All Interrupts
        MOV     SP,     #070h        ; Stack bottom
; __ Timers initializaion _____
        MOV     TMOD,   #00010001b   ; Setting 1st mode for timers T/C0 and T/C1
        
        ;65536 - 31250      = 34286  =85EE
        MOV     TH1,    #085h        ; Setting the initial value of the T/C1 timer for working with (1/32) notes
        MOV     TL1,    #0EEh        ; Setting the initial value of the T/C1 timer for working with (1/32) notes
        MOV     TH0,    #0CFh        ; Setting the initial value of the timer T/C0
        MOV     TL0,    #08Ah        ; Setting the initial value of the timer T/C0
    
        MOV     TCON,   #01010000b   ; Enabling the T/C0 and T/C1 timers
; __ Interrupts Initialization ___
        MOV     IP,     #00000000b   ; Setting Interrupt Priorities
        MOV     IE,     #00001010b   ; Enable timer interrupts for T/C0 and Ò/C1
; __ Set up register inint values __
        TH_0    EQU        030h      ; The value of the high byte of the timer counter T/C0
        TL_0    EQU        031h      ; The value of the lower byte of the timer counter T/C0
        
        MOV     TH_0,    #0FAh       ; TH_0 Init value
        MOV     TL_0,    #068h       ; TL_0 Init value
        

        SND     EQU      000h        ; Sound enabling flag ( 1 = enabled)         

        CNTLEN  EQU      032h        ; Note duration counter

        NOTA    EQU      033h        ; Note sequential counter        

        MELLEN  EQU      01Ah        ; 26 notes in the tune
        FNOTA   EQU      001h        ; Flag sounding note
        INDEX   EQU      034h        ; Note Index (1-7)
        T_NOTE  EQU      0100H       ; Tune table address
        T_TH0   EQU      0200H       ; Tune table address for TH0    
        T_TL0   EQU      0210H       ; Tune table address for TL0    
        T_LEN   EQU      0300H       ; Tune duration table address

        SETB    EA                   ; Enable interrupts
        LJMP    M11                  ; Transition to program start

;=====================Interrupts=========================//

; __ T/C0 __         
IT000:  MOV     TH0,     TH_0        ; Regeneration of register TH0 of counter T/C0
        MOV     TL0,     TL_0        ; Regeneration of register TH0 of counter T/C0
    
        JNB     SND,     TC0END      ; If sound is muted, exit interrupt
        CPL     P3.5                 ; Sound vibrations
             
TC0END: RETI


; __ T/C1 __    
IT100:  MOV     TH1,     #085h       ; Setting the initial value of the T/C1 timer for working with (1/32) notes
        MOV     TL1,     #0EEh       ; Setting the initial value of the T/C1 timer for working with (1/32) notes
        
        DJNZ    CNTLEN,  TC1END      ; If the notes still sound, exit the interrupt
        CLR     FNOTA                ; Reset the note playing flag

TC1END: RETI

;=====================Main program =========================//
        

M11:    CLR     SND                  ; Sound is turned off

; __ Check if button pressed __    
ASK_BUT:
        MOV     P1,      #00001111b    
        MOV     A,       P1            
        MOV     P1,      #11110000b    
        ORL     A,       P1            
        
        CJNE    A,       #11111111b, BUT_IS_PUSH
        LJMP    ASK_BUT                

BUT_IS_PUSH:
        MOV     NOTA,    #000h      ; Reset next note counter
        SETB    SND

; __ Loading tune data __
PLAY:
        MOV     DPTR,    #0100H     ; Set pointer to the tune array
        MOV     A,       NOTA       ; Register A receives index of the next note
        MOVC    A,       @A+DPTR    ; Get note index in register A 
        MOV     INDEX,   A          ; Save note index to INDEX variable

        MOV     DPTR,    #0200H     ; Set pointer to the tune array for TH0
        MOVC    A,       @A+DPTR        
        MOV     TH_0,    A            
        MOV     A,       INDEX
        
        MOV     DPTR,    #0210H     ; Set pointer to the tune array for TL0
        MOVC    A,       @A+DPTR        
        MOV     TL_0,    A            
        
        
        MOV     DPTR,    #0300H     ; Set pointer to the tune duration array
        MOV     A,       NOTA
        MOVC    A,       @A+DPTR    ; Get note duration into A
        
        
        MOV     CNTLEN,  A          ; Set note duration flag
        
        SETB    FNOTA               ; Set note sounding flag
             
PNOTA:  JB      FNOTA,   PNOTA      ; Play the tune while PNOTA is set
        INC     NOTA                ; Go to the next note
        MOV     A,       NOTA
        CJNE    A,       #MELLEN,   PLAY   ; If the next note = 26, stop the tune playing
        LJMP    M11
        END            