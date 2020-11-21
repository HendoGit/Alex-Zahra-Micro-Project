#include <xc.inc>

global	myArray, delay
extrn	GLCD_Setup, GLCD_Clear, GLCD_Test
extrn	Key_Setup, Key_Column, Key_Row
extrn	Int_Setup, B_Int

psect	udata_acs   ; named variables in access ram
counter:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
delay_count1:	ds 1    
delay_count2:	ds 1    
delay_count3:	ds 1
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	0x3E,0x41,0x41,0x3E
					; message, plus carriage return
	myTable_l   EQU	4	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup
	
int_hi:	org	0x0008	; high vector, no low vector
	btfss	INT0IF
	retfie	f
	call	B_Int
	call	GLCD_Clear
	goto	GLCD_Test
	retfie	f

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory 
	bcf	RBIF
	bsf	EEPGD 	; access Flash program memory
	call	GLCD_Setup
	call	Key_Setup
	call	Int_Setup
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
    
	
	call	GLCD_Clear
Loop2:	goto	GLCD_Test
	goto	$
	
	
    
    
    
	
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