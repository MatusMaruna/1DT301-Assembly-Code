;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2016-09-05
; Author:
; Student Matus Maruna  
; Student John Charo 
;
; Lab number: 1
; Title: Infinite Ring counter
; Hardware: STK600, CPU ATmega2560
; Function: The function of this program is to execute the ring counter 
; Input ports: None. 
; Output ports: Port B is connected to the LEDs on the board 
;
; Subroutines: "johnson" is a subroutine loop that pushes in values of r16 and preforms a logic shift on them to reflect the way 
;               the values are going to be output. On completing the output, it branches to "backward" subroutine
;              "back_loop" is similar to "johnson and uses the values that were placed into stack in the "johnson" to output the LED flashes
;               backwards, when done it branches to "forward".
;              "forward" loads in the values needed for "johnson" and outputs the last value branching to "johnson" when done.                   
; Included files: m2560def.inc
; Other information: None. 
; Changes in program: None. 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 

.include "m2560def.inc"

ldi r16, 0xFF ; setting portB as output 
out 0x04, r16
ldi r16, 0xFF
out 0x05, r16
; initilizing the stack, copy pasted from the assignment question
ldi r24, HIGH(RAMEND) ; R20 = high part of RAMEND address
out SPH,R24 ; SPH = high part of RAMEND address
ldi R24, low(RAMEND) ; R20 = low part of RAMEND address
out SPL,R24 ; SPL = low part of RAMEND address
;Loading needed values into registers
ldi r16, 0b11111111
ldi r17, 0b00000000
ldi r20, 0b11111111

;Ring loop that lights LEDS from 0 to 7 
johnson:
push r16 ; push the value to stack, saving it for later
ldi r19, 0 ; load 0 to r19 to clear out superdelay counter
cp r16,r17 ; compare r16 to the last value being output which is in r17
BREQ backward ; branch if equal to backward subroutine 
lsl r16 ; pushing in 0 from the right shifting the bits 1 place to the left and removing leftmost bit. 
out portB,r16 ; outputting the value to portB 
call DELAY
rjmp johnson

forward: ; subroutine that switches and loads the values needed for the loop to go forward from 0 to 7 
out portB, r16
ldi r16,0b11111111
call DELAY
rjmp johnson

back_loop: ; same as the front loop with minor adjustments 
ldi r19, 0 ; loading a value to reset superdelay_back
cp r16,r20 ; compare r16 to last value to be output and branch if its the last value 
BREQ forward ; 
pop r16 ; pop a value from stack to r16, values previously saved in the front ring loop 
out portB,r16 ; output the value into portB 
call DELAY
rjmp back_loop

backward: ; subroutine that switches and loads the values needed for the loop to go backwards from 7 to 0 
out portB, r16
ldi r16,0b00000000
call DELAY
rjmp back_loop

; Generated by delay loop calculator
; at http://www.bretmulvey.com/avrdelay.html
;
; Delay 500 000 cycles
; 500ms at 1.0 MHz
DELAY:
    ldi  r18, 3
    ldi  r19, 138
    ldi  r21, 86
L1: dec  r21
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    rjmp PC+1
ret
