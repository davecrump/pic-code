
    #include p16f883.inc
    __config H'2007', 0x23F4
    __config H'2008', 0X3EFF

   ERRORLEVEL -302

; CONFIG1

; 15 0 not used
; 14 0 not used
; 13 1 Debug not  implemented
; 12 0 LVP not implemented            2

; 11 0 Fail safe monitor disabled
; 10 0 IESO Disabled
;  9 1 Brown-out reset enabled
;  8 1 Brown-out reset enabled        3

; 7 1 Data code protection disabled 
; 6 1 Program code protection disabled 
; 5 1 MCLR enabled
; 4 1 Power-up timer disabled         F

; 3 0 Watchdog timer disabled
; 210 100 INTOSCIO Oscillator         4

; CONFIG2

; 15-12 not used                      3

; 11 not used
; 10 1 Flash write protection off
; 9  1 Flash write protection off
; 8  0 Brown-out Reset set to 2.1V    E

; 7 - 4 not used                      F

; 3 - 0 not used                      F
 
; Attenuator Controller uses 16F883 and internal oscillator
;
; Takes 12 lines from -11 to 0 rotary and 4 lines from 0, 10 ,20 , 30 rotary
; and converts them to 5 lines binary for Attenuator.
; 


; Hardware Config:

; Sig Pin  Mode                        Usage
; === ===  ==========================  ===================
; RA0 (2)  Output                      1s of dB Hi to attenuate
; RA1 (3)  Output                      2s of dB Hi to attenuate
; RA2 (4)  Output                      4s of dB Hi to attenuate
; RA3 (5)  Output                      8s of dB Hi to attenuate
; RA4 (6)  Output                      16s of dB Hi to attenuate
; RA5 (7)  Output                      not used
; RA6 (10) Output                      not used
; RA7 (9)  Output                      not used

; RB0 (21) Input with pull-up          -7 when low
; RB1 (22) Input with pull-up          -6 when low
; RB2 (23) Input with pull-up          -5 when low
; RB3 (24) Input with pull-up          -4 when low
; RB4 (25) Input with pull-up          -3 when low
; RB5 (26) Input with pull-up          -2 when low
; RB6 (27) Input with pull-up          -1 when low
; RB7 (28) Input with pull-up          0 when low

; RC0 (11) Input                       -30 when low
; RC1 (12) Input                       -20 when low
; RC2 (13) Input                       -10 when low
; RC3 (14) Input                       00 when low
; RC4 (15) Input                       -11 when low
; RC5 (16) Input                       -10 when low
; RC6 (17) Input                       -9 when low
; RC7 (18) Input                       -8 when low

; Definitions

;-------PIC Registers-------------------------

INDR		EQU	0x00	; the indirect data register
PCL	        EQU	0x02	; program counter low bits
STATUS		EQU	0x03	; Used for Zero bit
FSR	        EQU	0x04	; the indirect address register
PORTA		EQU	0x05	; 
PORTB		EQU	0x06	; 
PORTC		EQU	0x07	; 
PORTD		EQU	0x08	; 
PORTE		EQU	0x09	; 
PCLATH		EQU	0x0A	; Program Counter High Bits
INTCON		EQU	0x0B	; Interrupt Control
T1CON		EQU	0x10	; Counter Control
SSPBUF		EQU	0x13	; Sync Serial Port Buffer register
SSPCON		EQU	0x14	; Sync Serial Port Control register
ADRESH		EQU	0x1E	; A/D data register
ADCON0		EQU	0x1F	; A/D control register

OPTION_REG	EQU	0x81	; Option Register	
TRISA   	EQU     0x85
TRISB   	EQU     0x86
TRISC   	EQU     0x87
TRISD   	EQU     0x88
TRISE   	EQU     0x89
PINTCON		EQU	0x8B	; INTCON in Page 1
OSCCON		EQU	0x8F	; Internal oscillator control word
SSPCON2		EQU	0x91	; Sync Serial Port Control 2 register
SSPSTAT		EQU	0x94	; Sync Serial Port Status register
WPUB		EQU	0x95	; Weak pull up selects
IOCB		EQU	0x96	; Interupt on change Port B
ADCON1  	EQU     0x9F

EEDATA  	EQU     0x010C
EEADR   	EQU     0x010D
EEDATH  	EQU     0x010E
EEADRH  	EQU     0x010F

ANSEL		EQU	0x0188
ANSELH		EQU	0x0189
EECON1  	EQU 	0x018C
EECON2  	EQU	0x018D

;-------PIC Bits--------------------------------

W	EQU	0	; indicates result goes to working register
F	EQU	1	; indicates result goes to file (named register)
CARRY   EQU	0
ZERO	EQU	2

RP1     EQU     0x06
RP0     EQU     0x05
EEPGD   EQU     0x07
WREN    EQU     0x02
WR      EQU     0x01
RD      EQU     0x00
RBIF	EQU	0x00	; Interrupt Flag
RBIE	EQU	0x03	; Interrupt Enable Flag
GIE	EQU	0x07	; Global Interrupt Enable

;-------Project Registers------------------

CSW	EQU	0x20   	; Coarse Switch.  Should be 1, 2, 4 or 8.
CATT	EQU	0x21	; Coarse Attenuation: 0, 10, 20 or 30
FATT	EQU	0x22	; Fine Attenuation: 0 - 11
PB	EQU	0x23	; Value read from Port B (once for consistency)
CHI4	EQU	0x24	; Hi nibble of Port C
PATT	EQU	0x25	; Previously set attenuation to check for changes
DELAY	EQU	0x26	; Delay counter in DEL1MS
	
;-------Project Bits-------------------------



;-------START of Program--------------------

    	ORG	0x00		; Load from Program Memory 00 onwards
	GOTO	INIT

;-------Interrupt Vector--------------------

; Not used
	
;------ Set up Internal Oscillator -----------------

	ORG	0x10		; Load from Program Memory 10 onwards
INIT	NOP
	BSF 3, 5		; Bank x1
	BCF	3, 6		; Bank 01 (1)

	MOVLW	0x61		; 4 MHz, 
	MOVWF	OSCCON		; and set it

	BCF	3, 5		; Go back to Register Bank x0

;------ Set up IO Ports -----------------
	
	CLRF	PORTA		; Clear output latches
	CLRF	PORTB		; Clear output latches
	CLRF	PORTC		; Clear output latches

	BSF 	3, 5		; Bank x1
	BCF 	3, 6		; Bank 01 (1).  Now set Port directions

	MOVLW 	0x00 		; Initialize data direction
	MOVWF 	TRISA     	; Set RA0-7 as outputs

	MOVLW	0xFF 		; Initialize data direction
	MOVWF	TRISB   	; Set RB0-7 as inputs

	MOVLW	0xFF	   	; Initialize data direction
	MOVWF	TRISC		; Set RC0-7 as inputs

	MOVLW	0x7F		; Initialize weak pull up enable
	MOVWF	OPTION_REG	; in the Option Register

	MOVLW	0xFF		; Enable Weak Pull ups
	MOVWF	WPUB		; on Port B
	
	BSF	3, 6		; Bank 11 (3)

	MOVLW	0x00
	MOVWF	ANSEL		; Disable analog inputs on PORT A
	MOVLW	0x00
	MOVWF	ANSELH		; Disable analog inputs on PORT B
	
	BCF	3, 5		; Go back to Register Bank x0
	BCF	3, 6		; Bank 00 (0).

;------ Set Initial Values ----------------------------

	CLRF	PCLATH
        MOVLW	0x1F		; 31 dB
        MOVWF	PORTA		; Set max attenuation
	MOVWF	PATT		; Set previous attenuation to 31 as well	
;------ Start Here -----------------------------------------------

STLOOP	NOP

;------ Read data from Coarse Switch --------------------

	MOVF	PORTC, W	; Read Input From Coarse Switch
	ANDLW	0x0F		; Mask input bits
	CALL	LUCOSE		; Return with Coarse attenuation value
	MOVWF	CATT		; and save in Coarse attenuation

;------ Read data from Fine Switch --------------------

	MOVF	PORTB, W	; Read Input From Port B to check all High
	MOVWF	PB		; Keep a copy of what was read for later
	MOVF	PORTC, W	; Read Input From Port C
	ANDLW	0xF0		; Mask Fine Switch bits (top 4 =11, 10, 9, and 8)
	MOVWF	CHI4		; Save result in C Hi 4
	SUBLW	0xF0		; If port is 0xF0 will give zero result
	BTFSC	STATUS, ZERO	; and set zero status bit
	GOTO	CHKB		; Port C no data, so go and check port B

;------ Now decode fine data found in top 4 of Port C ---------------

	MOVF	PB, W		; Load Input From Port B to check all High
	ADDLW	0x01		; Result will be zero if port B all high
	BTFSS	STATUS, ZERO	; Test for error condition (not all high)
	GOTO	SWERR		; Error, so set max attenuation and try again

				; No error so retrieve switch setting
	SWAPF	CHI4, W		; Swap nibbles in CHI4 and put result in W
	CALL	LUAINC		; Look up and Return with attenuation in W
	MOVWF	FATT		; and save in fine attenuation
	GOTO	CALCOP		; Go and calculate the output value

;------ Read Data from Port B.  Handle as 2 separate nibbles

;------ Low Nibble -----
	
CHKB	MOVF	PB, W		; Move Port B value into W
	ANDLW	0x0F		; Mask Low Nibble
	SUBLW	0x0F		; Set zero bit if low nibble is all high
	BTFSC	STATUS, ZERO	; Skip next if low nibble was not all high
	GOTO	CHKBHI		; All high so go and test high nibble

	MOVF	PB, W		; Move Port B value into W
				; and error check high nibble which should be all high
	ANDLW	0xF0		; Mask high nibble
	SUBLW	0xF0		; Set zero bit if high nibble is all high
	BTFSS	STATUS, ZERO	; Skip next if high nibble was all high
	GOTO	SWERR		; Wasn't high so set max attenuation and try again

	MOVF	PB, W		; Move Port B value into W
	ANDLW	0x0F		; Mask in low nibble
	CALL	LULOINB		; Look up and Return with attenuation in W
	MOVWF	FATT		; and save in fine attenuation
	GOTO	CALCOP		; Go and calculate the output value

;------ High Nibble -----
	
CHKBHI	NOP			; Low nibble is all high
	SWAPF	PB, W		; Swap nibbles of PB and put into W
	ANDLW	0x0F		; Mask in low (was the high) nibble
	CALL	LUHIINB		; Look up and Return with attenuation in W
	MOVWF	FATT		; and save in fine attenuation
	GOTO	CALCOP		; Go and calculate the output value

;------ Now calculate CATT + FATT and limit to 31 -----------

CALCOP	NOP			; Total attenuation is in CATT + FATT, but needs capping at 31

	MOVF	FATT, W		; Move the fine value (0 - 11) into W
	ADDWF	CATT, F		; Total Attenuation now in CATT, but may be over 31

	MOVLW	0x1F		; Preload W with 31
	BTFSC	CATT, 5		; Skip next if 32 bit of CATT is not set
	MOVWF	CATT		; If 32 bit set, overwrite with 31
	GOTO	SETOP		; Go and set the output

;------ Handle anomalous switch selections by setting 31 -----

SWERR	MOVLW	0x1F		; Preload W with 31
	MOVWF	CATT		; If 32 bit set, overwrite with 31.

;----- Set output on Port A ------------------------

SETOP	MOVF	CATT, W		; Put Total attenuation in W
	ANDLW	0x1F		; Mask in bottom 5 bits
	SUBWF	PATT		; Set zero bit if same as previous
	BTFSC	STATUS, ZERO	; Skip next if there has been a change
	GOTO	WRTOP		; No change, simply write the output
	
;------ Set max attenuation for 1ms to avoid any spurious low attenuation
;------ during changes
	
	MOVLW	0x1F		; 31
	MOVWF	PORTA		; into Port A
	CALL	DEL1MS		; Delay 1 ms before allowing the new value to be written
	
WRTOP	MOVF	CATT, W		; Put Total attenuation in W
	MOVWF	PATT		; Copy to "Previous Attenuation" for next time
	MOVWF	PORTA		; and write to port A

;-----  End of loop.  Do it all again --------------------	

ENDLOOP	GOTO	STLOOP

; ********* End of code flow  **************
	
;------ DEL1MS -------------------------------------

	; Time delay 1044 cycles

DEL1MS	MOVLW	0xC9		; 201				2
	MOVWF	DELAY		;				3
LOOP3	DECFSZ	DELAY, F	;				4
	GOTO	LOOP3		;
	NOP	           	; 602uS in Loop3 =200*3+2	606	

	MOVLW	0x90		; 144				607				
	MOVWF	DELAY		;				608
LOOP4	DECFSZ	DELAY, F	;				609
	GOTO	LOOP4		;
	NOP	           	; 431uS in Loop4 =143*3+2	1040
	NOP			;				1041
	
	RETURN             	; return after 9+602+431	1042
				; next is 1044

; ********* Look-up table for Coarse Attenuation ************

LUCOSE	ADDWF	PCL, F		; calculate Program Counter jump based on W (0-15)

        RETLW   0x1E    	; 0000 error so 30
        RETLW   0x1E    	; 0001 error so 30
        RETLW   0x1E    	; 0010 error so 30
        RETLW   0x1E    	; 0011 error so 30
        RETLW   0x1E    	; 0100 error so 30
        RETLW   0x1E    	; 0101 error so 30
        RETLW   0x1E    	; 0110 error so 30
        RETLW   0x00    	; 0111 sets 0
        RETLW   0x1E    	; 1000 error so 30
        RETLW   0x1E    	; 1001 error so 30
        RETLW   0x1E    	; 1010 error so 30
        RETLW   0x0A    	; 1011 sets 10
        RETLW   0x1E    	; 1100 error so 30
        RETLW   0x14    	; 1101 sets 20
        RETLW   0x1E    	; 1110 sets 30
        RETLW   0x1E    	; 1111 error so 30

; ********* Look-up tables for Fine Attenuation ************

LUAINC	ADDWF	PCL, F		; calculate Program Counter jump based on W (0-15)

        RETLW   0x0B    	; 0000 error so 11
        RETLW   0x0B    	; 0001 error so 11
        RETLW   0x0B    	; 0010 error so 11
        RETLW   0x0B    	; 0011 error so 11
        RETLW   0x0B    	; 0100 error so 11
        RETLW   0x0B    	; 0101 error so 11
        RETLW   0x0B    	; 0110 error so 11
        RETLW   0x08    	; 0111 sets 8
        RETLW   0x0B    	; 1000 error so 11
        RETLW   0x0B    	; 1001 error so 11
        RETLW   0x0B    	; 1010 error so 11
        RETLW   0x09    	; 1011 sets 9
        RETLW   0x0B    	; 1100 error so 11
        RETLW   0x0A    	; 1101 sets 10
        RETLW   0x0B    	; 1110 sets 11
        RETLW   0x0B    	; 1111 should be trapped earlier so 11

LULOINB	ADDWF	PCL, F		; calculate Program Counter jump based on W (0-15)

        RETLW   0x0B    	; 0000 error so 11
        RETLW   0x0B    	; 0001 error so 11
        RETLW   0x0B    	; 0010 error so 11
        RETLW   0x0B    	; 0011 error so 11
        RETLW   0x0B    	; 0100 error so 11
        RETLW   0x0B    	; 0101 error so 11
        RETLW   0x0B    	; 0110 error so 11
        RETLW   0x04    	; 0111 sets 4
        RETLW   0x0B    	; 1000 error so 11
        RETLW   0x0B    	; 1001 error so 11
        RETLW   0x0B    	; 1010 error so 11
        RETLW   0x05    	; 1011 sets 5
        RETLW   0x0B    	; 1100 error so 11
        RETLW   0x06    	; 1101 sets 6
        RETLW   0x07    	; 1110 sets 7
        RETLW   0x0B    	; 1111 error so 11

LUHIINB	ADDWF	PCL, F		; calculate Program Counter jump based on W (0-15)

        RETLW   0x0B    	; 0000 error so 11
        RETLW   0x0B    	; 0001 error so 11
        RETLW   0x0B    	; 0010 error so 11
        RETLW   0x0B    	; 0011 error so 11
        RETLW   0x0B    	; 0100 error so 11
        RETLW   0x0B    	; 0101 error so 11
        RETLW   0x0B    	; 0110 error so 11
        RETLW   0x00    	; 0111 sets 0
        RETLW   0x0B    	; 1000 error so 11
        RETLW   0x0B    	; 1001 error so 11
        RETLW   0x0B    	; 1010 error so 11
        RETLW   0x01    	; 1011 sets 1
        RETLW   0x0B    	; 1100 error so 11
        RETLW   0x02    	; 1101 sets 2
        RETLW   0x03    	; 1110 sets 3
        RETLW   0x0B    	; 1111 error so 11

        END