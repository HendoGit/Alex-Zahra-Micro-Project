#include <xc.inc>
    
global  GLCD_Setup, GLCD_Clear, GLCD_Test, LCD_delay_x4us, LCD_delay_ms
extrn	myArray, delay
extrn	Int_Setup

psect	udata_acs   ; named variables in access ram
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
LCD_tmp:	ds 1   ; reserve 1 byte for temporary use
LCD_counter:	ds 1   ; reserve 1 byte for counting through nessage
YCount:		ds 1
Y_Count_Max:	ds 1
XCount:		ds 1
X_Count_Max:	ds 1
location:	ds 1
location2:	ds 1    
max_pos:	ds 1
counter5:	ds 1
three:		ds 1
counter6:	ds 1
counter7:	ds 1
LCD_counter2:	ds 1
    
	
LCD_CS1	EQU 0	; LCD register select bit
LCD_CS2	EQU 1	; LCD register select bit
LCD_RS	EQU 2	; LCD register select bit
LCD_RW	EQU 3
LCD_E	EQU 4	; LCD enable bit
LCD_RT	EQU 5
	

psect	glcd_code,class=CODE
    
GLCD_Setup:
	banksel ANCON0
	clrf    ANCON0, A	; set all pins to digital output, not analogue
	clrf    ANCON1, A
	clrf    ANCON2, A
	movlb	0x00
	clrf    TRISH, A
	clrf	TRISD, A
	clrf    PORTH, A
	clrf	PORTD, A
	bsf	LATH, LCD_RT
	bsf	LATH, LCD_E
	movlw   10
	call	LCD_delay_x4us	; wait 40ms for LCD to start up properly
	movlw   0x3F	    ; RB0:5 all outputs
	movwf	PORTD, A
	movlw	10
	call	LCD_delay_x4us
	call	LCD_Enable
	
	
	
	call	LCD_delay_x4us
	
	return


LCD_Enable:	    ; pulse enable bit LCD_E for 500ns
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	LATH, LCD_E, A	    ; Take enable high
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	LATH, LCD_E, A	    ; Writes data to LCD
	return
    
GLCD_Y_address:
	movwf	PORTD, A
	movlw	20
	call	LCD_delay_x4us
	call	LCD_Enable
	;call	LCD_delay_x4us
	return
	
GLCD_CS1:
	bsf	LATH, LCD_CS2
	bcf	LATH, LCD_CS1
	;movlw	10
	;call	LCD_delay_x4us
	return
GLCD_CS2:
	bsf	LATH, LCD_CS1
	bcf	LATH, LCD_CS2
	;movlw	10
	;call	LCD_delay_x4us
	return
	
GLCD_X_address:
	movwf	PORTD, A
	movlw	20
	call	LCD_delay_x4us
	call	LCD_Enable
	;call	LCD_delay_x4us
	return
GLCD_Write:
	bsf	LATH, LCD_RS
	movwf	PORTD, A
	movlw	20
	call	LCD_delay_x4us
	call	LCD_Enable
	call	LCD_delay_x4us
	bcf	LATH, LCD_RS	
	clrf	PORTD
	return
	
GLCD_Clear:
	call	GLCD_CS1
	call	GLCD_Clear_Page
	call	GLCD_CS2
	call	GLCD_Clear_Page	
	return
	
GLCD_Clear_Page:
	movlw	10111111B
	movwf	X_Count_Max
	movlw	0xF0
	movwf	Y_Count_Max
	movlw	10111000B
	movwf	XCount
GLCD_Clear_X:
	movf	XCount, W
	call	GLCD_X_address
	call	GLCD_Clear_Row
	incf	XCount, F
	movf	XCount, W
	CPFSLT	X_Count_Max, A
	bra	GLCD_Clear_X
	return	
GLCD_Clear_Row:
	movlw	01000000B
	call	GLCD_Y_address
	movlw	0x00
	movwf	YCount
LoopY:	
	movlw	0x00
	call	GLCD_Write
	incf	YCount, 1, 0
	movf	YCount,W, A
	CPFSLT	Y_Count_Max
	bra	LoopY
	return
	
GLCD_Test:
	call	Int_Setup
	call	GLCD_Clear
	movlw	0
	movwf	counter7
	movlw	3
	movwf	counter6
	movlw	4
	movwf	counter5
	movlw	4
	movwf	three
	movlw	01000001B
	movwf	location
	movlw	01111101B
	movwf	max_pos
	call	GLCD_CS1
	movlw	10111000B
	call	GLCD_X_address
Loop3:	
	movlw	4
	movwf   LCD_counter, A
	lfsr	2, myArray
	movf	location, W
	addlw	0xFF
	call	GLCD_Y_address
	call	delay
	movlw	0x00
	call	GLCD_Write
	call	GLCD_Loop_message
	incf	location
	incf	location, W
	CPFSLT	max_pos
	bra	Loop3

	bra	GLCD_Tran
GLCD_Loop_message:
	movf    POSTINC2, W, A
	call    GLCD_Write
	decfsz  LCD_counter, A
	bra	GLCD_Loop_message
	return
GLCD_Tran:
	call	GLCD_CS1
	lfsr	2, myArray
	movf	location, W
	addlw	0xFF
	call	GLCD_Y_address
	call	delay
	movlw	0x00
	call	GLCD_Write
	decfsz	counter5
	bra	cont
	bra	run4
cont:	movff	counter5, LCD_counter
	call	GLCD_Loop_message
	
	incf	location
	
	call	GLCD_CS2
	movlw	10111000B
	call	GLCD_X_address
	
run1:	movlw	1
	CPFSLT	counter7
	bra	run2
	lfsr	2, myArray
	;ADDFSR	2, 3
	movf	POSTINC2, W, A
	movf	POSTINC2, W, A
	movf	POSTINC2, W, A
	movlw	1
	movwf	counter6
	call	GLCD_Tran2
	incf	counter7
	bra	GLCD_Tran
	
run2:	movlw	2
	CPFSLT	counter7
	bra	run3
	lfsr	2, myArray
	;ADDFSR	2, 2
	movf	POSTINC2, W, A
	movf	POSTINC2, W, A
	movlw	2
	movwf	counter6
	call	GLCD_Tran2
	incf	counter7
	bra	GLCD_Tran
	
run3:	;goto	$
	movlw	3
	CPFSLT	counter7
	bra	run4
	lfsr	2, myArray
	;ADDFSR	2, 1
	movf	POSTINC2, W, A
	movlw	3
	movwf	counter6
	call	GLCD_Tran2
	incf	counter7
	bra	GLCD_Tran
	

	
GLCD_Tran2:
	movlw	01000000B
	call	GLCD_Y_address
Loop4:	movf    POSTINC2, W, A
	call    GLCD_Write
	decfsz  counter6, A
	bra	Loop4
	return

run4:	call	GLCD_CS2
	lfsr	2, myArray
	movlw	4
	movwf	counter6
	call	GLCD_Tran2

GLCD_Page2:
	movlw	01000001B
	movwf	location2
Loop6:
	movlw	4
	movwf   LCD_counter2, A
	lfsr	2, myArray
	movf	location2, W
	addlw	0xFF
	call	GLCD_Y_address
	call	delay
	movlw	0x00
	call	GLCD_Write
	

	call	GLCD_Loop_message2
	incf	location2
	incf	location2, W
	CPFSLT	max_pos
	bra	Loop6
	decf	location2
	movf	location2, W
	call	GLCD_Clear_4line
	goto	GLCD_Test
	goto	$
	
GLCD_Loop_message2:
	movf    POSTINC2, W, A
	call    GLCD_Write
	decfsz  LCD_counter2, A
	bra	GLCD_Loop_message2
	return
	
GLCD_Clear_4line:
	call	GLCD_Y_address
	movlw	0
	call	GLCD_Write
	call	GLCD_Write
	call	GLCD_Write
	call	GLCD_Write
	return
	
	
	
; ** a few delay routines below here as GLCD timing can be quite critical ****
LCD_delay_ms:		    ; delay given in ms in W
	movwf	LCD_cnt_ms, A
lcdlp2:	movlw	250	    ; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms, A
	bra	lcdlp2
	return
    
LCD_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l, A	; now need to multiply by 16
	swapf   LCD_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l, W, A ; move low nibble to W
	movwf	LCD_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1:	decf 	LCD_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return
	
	
