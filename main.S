#include <xc.inc>

global	delay, myArray
extrn	GLCD_Setup, GLCD_Clear, GLCD_Main
extrn	Key_Setup, Key_Column, Key_Row
extrn	Int_Setup, B_Int

    
psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	0x00, 0x00, 0xB9, 0x45, 0x05, 0x00,0x3E,0x41,0x41,0x3E, 0x00, 0x00, 0xBB, 0x40, 0x05, 0x00,0x3E,0x41,0x41,0x3E, 0x00, 0x00, 0xBD, 0x50, 0x05, 0x00,0x3E,0x41,0x41,0x3E
	
					; message, plus carriage return
	myTable_l   EQU	30	; length of data
	align	2
    
;; initialise the array of characters that will float across screen
;; format: control byte, page byte, x-co, y-co, cha, l1, l2, l3, l4, l5
;; control byte is a byte that tells us if we are "mid screen" or not i.e. in between the 2 chips
;; page-byte tells us to either select chip 1 if on Left screen or chip 2 on right
;; x-co is the x-line number of the character
;; y-co is the y-column number that the character is at
;; cha is a another control variable for use when the character hits middle of the two chips
;;l1-l5 are just the information encoding the bit-pattern to write
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data
    

psect	udata_acs   ; named variables in access ram 
counter:	ds 1
counter2:	ds 1
delay_count1:	ds 1    
delay_count2:	ds 1    
delay_count3:	ds 1
    


psect	code, abs	
rst: 	org 0x0
 	goto	setup
	
int_hi:	org	0x0008	; high vector, no low vector
	btfss	INT0IF
	retfie	f
	call	B_Int
	call	GLCD_Clear
	retfie	f

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory 
	bcf	RBIF
	bsf	EEPGD 	; access Flash program memory
	call	GLCD_Setup
	call	Key_Setup
	;call	Int_Setup
	goto	start
	
	; ******* Main programme ****************************************
start: 	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
	
	;; reads out the message from program memory to data memory, 
	;; the FSR2L initially points at 0x00
	call	GLCD_Clear	;; clear the GLCD screen
	
	lfsr	2, myArray
Loop2:	call	GLCD_Main	;; GLCD_Main runs the game, and we keep branching back to it
	call	delay		;;
	;decfsz	counter2
	bra	Loop2
	
	setf	PORTC		;; error handling to show visual sign that the game 
	goto	$		;; has broken out of the loop
	
	
	
    
    
    
	
	goto	$		; goto current line in code

delay:	movlw	0x55
	movwf	delay_count1, A
	movwf	delay_count2, A
	movwf	delay_count3, A
delay1: decfsz	delay_count1, A	; decrement until zero
	bra	delay1
	movwf	delay_count1, A
	decfsz	delay_count2, A
	bra	delay1
	movwf	delay_count1, A
	movwf	delay_count2, A
	decfsz	delay_count3, A
	bra	delay1
	return
	
	end	rst