; The program sequentially turns on the 4 LEDs that
; correspond to the high-order bits of P3, and then shift these 4 LEDs 
; from the high-order bits of P3 to the low-order bits of P1. 
; After the LEDs reach the lower bits of P1, 
; they are turned off sequentially. Total duration of the animation = 200 ms


$INCLUDE (init.asm)
$INCLUDE (timer.asm)

M00:	LJMP M00
END