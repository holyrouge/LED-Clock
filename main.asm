;
; ESE_ClockCode.asm
;
; Created: 11/2/2017 11:47:09 AM
; Author : Prangon Ghose0
;


; Replace with your application code
nop

ldi r18, 0 ;remainder
ldi r19, 0 ;quotient
ldi r20, 5 ;dividend
ldi r21, 0 ;divisor

division:
	cpi r21, 0 ; if the divisor is 0, go to error
	breq error 

	mov r17, r20 ;r17 is a register that is used for the branching
	
	sub r17, r21 ;if the divisor is greater than dividend, output the remainder and the quotient
	brmi output

	sub r20, r21 ;subtract r21 from r20, increment the quotient (r19)
	inc r19

	mov r17, r20

	sub r17, r21 ;if the divisor is greater than the dividend, output the remainder and the quotient
	brmi output
	brpl division ;if the divisor is lower than the dividend, continue with division

output:
	mov r18, r20 ;set the value of r20 as the value of r18, the remainder
	rjmp done ;go to done

error:
	rjmp error ;error time!

done:
	rjmp done ;we are so done :D