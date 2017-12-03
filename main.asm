; Updated: 11/27/2017
; Author: Prangon Ghose

; create two variables for ticks and secs
.def ticks = r16
.def secs = r17
.def mins = r18
.def hrs = r19

// clears values
clr ticks
clr secs
clr mins
clr hrs

// setup ports
setup:
	ldi r20,0b00000011 ; 1 for output pins, 0 for inputs
	out ddrc, r20 ; program pc0 and pc1 as outputs

	ldi r20,0xff ; load 11111111 in r20
	out ddrd, r20 ; program all of portd as outputs

	ldi r16,0xfe ;turn pnp transistors off, pullups on
	out portb,r16

	ldi r16,0b11000111
	out ddrb,r16


// Loop
tick:
	sbis pinc, 7 ; check the value of pinc, bit 7; if zero, jump back
    rjmp tick
	
add_ticks:
	inc ticks ; increment ticks
	
	cpi ticks, 60 ; check to see if the value of ticks is 60
	breq add_secs ; if ticks equal to 60, go to add_secs
	rjmp display ; go to display

add_secs:
	clr ticks ; if ticks and 60 are equal, clear value of ticks
	inc secs ; increment of secs

	cpi secs, 60 ; check to see if the value of secs is 60
	breq add_mins ; if secs equal to 60, go to add_mins
	rjmp display ; go to display

add_mins: 
	clr secs ; if ticks and 60 are equal, clear value of secs
	inc mins ; increment mins

	cpi mins, 60 ; check to see if the value of mins is 60
	breq add_hrs ; if mins equal to 60, go to add_hrs
	rjmp display ; go to display

add_hrs:
	clr mins ; if mins equal to 60, clr mins
	inc hrs ; increment hrs
	
	cpi hrs, 24 ; check to see if the value of hrs is 24 
	brne display ; if not, display
	clr hrs ; if hrs equal to 24, clear hrs and then move on to display

// display output as LEDs
display:
// display seconds
	com secs
	out portd, secs
	com secs

// turn on the LEDs for the colon
// reverse logic: clearing the ports turns the LEDs on, setting the ports turns the LEDs off
	cbi portd, 6
	cbi portd, 7

// turn on the LEDS for the seconds counter
	cbi portb, 0 ; turn on the LEDs for the seconds counter
	rcall delay_1K ; delaying once dims the seconds counter LEDs
	sbi portb, 0 ; turns off the LEDs

// move the value of hrs to register 20 to get the segment values that need to light up
	mov r20, hrs ; sets the value of r20 as the value of hrs
	rcall get_segs ; calls get_segs 
	out portd, r21 ; sends tens digit segment values to portd
	
	cbi portb, 1 ; turns on the LEDs for the tens digit of hrs
	rcall delay_21k ; delay
	sbi portb, 1 ; turns off the LEDs
	out portd, r22 ; sends ones digit segment values to portd for output
	
	cbi portb, 2 ; turns on the LEDs for the ones digit of hrs
	rcall delay_21k ; delay
	sbi portb, 2 ; turns off the LEDs

// move the value of mins to register 20 to get the segment values that need to light up
	mov r20, mins ; sets the value of r20 as the value of hrs
	rcall get_segs ; calls get_segs
	out portd, r21 ; sends tens digit segment values to portd for output

	cbi portb, 6 ; turns on the LEDs for the tens digit of hrs
	rcall delay_21k ; delay
	sbi portb, 6 ; turns off the LEDs

	out portd, r22 ; sends ones digit segment values to portd for output
	cbi portb, 7 ; delay
	rcall delay_21k ; delay
	sbi portb, 7; turns off the LEDs
	
	rjmp tick ; jump to tick


/* get_segs is provided courtesy of Professor David Westerfeld */
/*get_segs_m takes an argument in scr and returns the most significant LED
  segments (segs_h) and least significant LED segment (segs_l). The scr 
  register is 0 to 59 for minutes 
  
  writes: clr, tens,zl, zh, segs_l, segs_h	*/
get_segs:
	clr r0				;clear tens register
div_m:
	cpi r20,10			;bigger than ten?		
	brlo done_div_m		;	no, done
	inc r0				;increment tens count
	subi r20,10			;subtract 10 from scr 
	rjmp div_m          ;repeat until r20 is less than 10
done_div_m:
	ldi zh,high(seg_table<<1)	;load z register for indirect read
	ldi zl,low(seg_table<<1)
	add zl,r0			;compute offset into the table
	brcc nc1_m			;carry required?
	inc zh				;carry
nc1_m:
	lpm r21,z			;read segments from data table
	ldi zh,high(seg_table<<1)	;load z register for indirect read
	ldi zl,low(seg_table<<1)
	add zl,r20			;compute offset into the table
	brcc nc2_m			;carry required?
	inc zh				;carry
nc2_m:
	lpm r22,z			;read segments from data table
	ret	                ;return


// delay_21k simply calls delay 21 times
delay_21k:
	rcall delay_counter ; delay counter does the delays without having to copy and paste rcall delay a bunch of times
	ret


// delay_counter goes through 21k clock cycles (21 delay loops)
delay_counter:          ; the label that identifies the subroutine to the assembler
	clr r30	; delay counter
delay:					; delays for days
	clr r31             ; initialize register 31 (this can be any unused register)
delay_loop:				; a label for the brne instruction
	inc r31             ; increment r31
    cpi r31,0xf9        ; compare r31 to the final value
    brne delay_loop     ; jump to delay_loop if the count has not reached the final value

	inc r30	; if the count (r31) has reached the final value, increment # of delays
	cpi r30, 21	; compare r30 to the amount of delays needed
	brne delay ; jump to delay if the amount of delays is below the # of delays needed

    ret                 ;return. The microcontroller 'remembers' where it came from

// Singular delay loop for the dimming of the seconds counter LEDs
delay_1k:
	clr r29             ; initialize register 31 (this can be any unused register)

	inc r29             ; increment r31
    cpi r29,0xf9        ; compare r31 to the final value
    brne delay_1k     ; jump to delay_loop if the count has not reached the final value


// initialize LED segment table
seg_table:		
	.dw 0xeb09				;1,0
	.dw 0xc185				;3,2
	.dw	0x5163				;5,4
	.dw 0xcb11				;7,6
	.dw 0x4101				;9,8
	.dw 0x00ff				;on,off
