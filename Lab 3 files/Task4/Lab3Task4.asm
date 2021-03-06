;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2015-09-03
; Author:
; John Charo 
; Matus Maruna
;
; Lab number: 3
; Title: Turning lights and breaks with interrupts 
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Building on top of task3, adding special break turn signals 
;
; Input ports: PORTD for switches to trigger the interrupts
;
; Output ports: PORTB for LEDs 
;
; Subroutines: "breakleft" handles the special break turn when left signals are on and the break is on. "breakright: handles the special break turn when right signals are on
;              and the break is on. "direction" checks the directional flags to decide which subroutine to branch to, if at all. "breaking" handles the sw3 interrupt. 
; Included files: m2560def.inc
;
; Other information:
;
; Changes in program: (Description and date)
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"
.org 0x00
rjmp start

.org INT2addr
rjmp left

.org INT1addr
rjmp right 

.org INT3addr 
rjmp breaking

.org 0x72
start:
ldi r16, 0x00
out DDRD, r16
ldi r16, 0xFF ; setting portB as output 
out DDRB, r16
ldi r16, 0xFF
out PORTB, r16
; initilizing the stack, copy pasted from the assignment question
ldi r24, HIGH(RAMEND) ; R20 = high part of RAMEND address
out SPH,R24 ; SPH = high part of RAMEND address
ldi R24, low(RAMEND) ; R20 = low part of RAMEND address
out SPL,R24 ; SPL = low part of RAMEND address
ldi r16,0b00001110
out EIMSK, r16
ldi r16,0b10101000
sts EICRA, r16
.def breakflag = r23
ldi r23, 0
.def directionflag = r24
ldi r24, 0
sei



main: 
ldi directionflag, 0
ldi r22,0b00111100
out PORTB, r22
call delay 
rjmp main 




delay: 
; Generated by delay loop calculator
; at http://www.bretmulvey.com/avrdelay.html
;
; Delay 500 000 cycles
; 500ms at 1.0 MHz
	push r18
    ldi  r18, 3
    ldi  r19, 138
    ldi  r20, 86
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    rjmp PC+1
	pop r18
ret
;subroutine that outputs to portB
display: 
out portB, r16
in r22,PIND
cpi r22,0b11110111 ;if break is being pressed than branch 
breq direction
call delay
ret
; subroutine to handle turning left 
left: 
ldi directionflag, 1
ldi r16, 0b11101100
call display
ldi r16, 0b11011100
call display
ldi r16, 0b10111100
call display
ldi r16, 0b01111100
call display
ldi directionflag, 0
reti
; subroutine that checks the state and branches to subroutines that handle breaking and turning
direction: 
cpi directionflag, 1
breq breakleft
cpi directionflag, 2
breq breakright
ret
;Subroutine to handle turning right 
right: 
ldi directionflag, 2 ; direction flag set to 2 
ldi r16, 0b00110111
call display
ldi r16, 0b00111011
out portB, r16
call display
ldi r16, 0b00111101
call display
ldi r16, 0b00111110
call display
ldi directionflag, 0 ; clear direction flag
reti
;subroutine to handle the breaking interrupt
breaking: 
ldi r16,0b00000000
out portB, r16
call delay
in r16, PIND
cpi r16, 0b11111111
brne breaking
reti
; subroutine handling turning right and breaking
breakright: 
ldi r16, 0b00000111
out portB, r16
call delay
ldi r16, 0b00001011
out portB, r16
call delay
ldi r16, 0b00001101
out portB, r16
call delay
ldi r16, 0b00001110
out portB, r16
call delay
ldi directionflag, 0 ; clearning direction flag 
ret

; subroutine handling turning left and breaking
breakleft: 
ldi r16, 0b11100000
out portB, r16
call delay
ldi r16, 0b11010000
out portB, r16
call delay
ldi r16, 0b10110000
out portB, r16
call delay
ldi r16, 0b01110000
out portB, r16
call delay
ret
