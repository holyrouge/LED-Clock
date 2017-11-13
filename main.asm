; Created: 11/13/2017 9:04:04 AM
; Author: Prangon Ghose

; create two variables for ticks and secs
.def ticks = r16
.def secs = r17

// setup ports
ldi r20,0b00000011 ; 1 for output pins, 0 for inputs
out ddrc, r20 ; program pc0 and pc1 as outputs

ldi r20,0xff ; load 11111111 in r20
out ddrd, r20 ; program all of portd as outputs

// Loop
tick:
	sbis pinc, 7 ; check the value of pinc, bit 7; if zero, jump back
    rjmp tick
	
	inc ticks ; increment ticks
	
	cpi ticks, 60 ; check to see if the value of ticks is 60 (60 ticks in 1 sec)
	brne tock ; if ticks and 60 aren't equal, branch to tock

	clr ticks ; if ticks and 60 are equal, clear value of ticks
	inc secs ; increment of secs

	com secs ; turn secs into binary
	out portd, secs ; display secs
	com secs ; turn secs back into decimal numbers

tock:
	sbic pinc, 7 ; check the value of pinc, bit 7; if zero, skip the next command
	rjmp tock

	rjmp tick ; if zero, jump to tick
