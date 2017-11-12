; Created: 11/6/2017
; Author: Prangon Ghose


bender_setup:
; Setup port c
; Program bit 1 of portc as output, all bits are configured as inputs
    ldi r16, 0b00000010
	out ddrc, r16

	rjmp bender_loop

bender_loop:
; Apply voltage to bender
	sbi portc, 1
	nop	nop	nop	nop
	in r17, pinc 

; wait time
	nop	nop	nop	nop nop	nop	nop	nop nop	nop	nop	nop nop	nop	nop	nop nop	nop	nop	nop nop	nop

; Remove voltage from bender
	cbi portc, 1
	in r18, pinc

; wait time
	nop	nop	nop	nop nop	nop	nop	nop nop	nop	nop	nop nop	nop	nop	nop nop	nop nop nop nop nop nop	nop	nop	nop nop	nop nop nop

; Recursion
	rjmp bender_loop
