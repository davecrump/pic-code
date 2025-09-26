
    #include p16f883.inc
    __config H'2007', 0x23F4
    __config H'2008', 0X3FFF

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


; FT290 Display Module by G8GKQ
; Uses 16F883 and internal oscillator
; Only needs 7 transistors and a 7 digit common cathode display
; Sequence spends 1.4ms listening to data and then
; 1 ms displaying each digit in turn and then repeats.

; Hardware Config:

; Sig Pin Mode                        RD Usage
; === === ==========================  ==========
; RA0 (2) Output Active Hi            LSB Digit Select
; RA1 (3) Output Active Hi            NSB Digit Select
; RA2 (4) Output Active Hi            NSB Digit Select
; RA3 (5) Output Active Hi            NSB Digit Select
; RA4 (6) Output Active Hi            NSB Digit Select
; RA5 (7) Output Active Hi            NSB Digit Select
; RA6 (10) Output Active Hi           MSB Digit Select
; RA7 (9 ) Spare		      Note Rev pins!

; RB0 (21) Input 		      R40 Data LSB
; RB1 (22) Input 		      R41 Data NSB
; RB2 (23) Input 		      R42 Data NSB
; RB3 (24) Input 		      R43 Data MSB
; RB4 (25) Input           	      STD
; RB5 (26) Input	              CE
; RB6 (27) Input 		      Spare
; RB7 (28) Input 		      Spare

; RC0 (11) Output Active Hi		Segment Select a
; RC1 (12) Output Active Hi		Segment Select b
; RC2 (13) Output Active Hi		Segment Select c
; RC3 (14) Output Active Hi		Segment Select d
; RC4 (15) Output Active Hi		Segment Select e
; RC5 (16) Output Active Hi		Segment Select f
; RC6 (17) Output Active Hi		Segment Select g
; RC7 (18) Output Active Hi           	Spare


; Memory Map:
;
; 0x0010 - 0x01FF used for program
; 0x0200 - 0x02FF used for look up tables and delay

; Definitions

;-------PIC Registers---------------------------------------------

INDR		EQU	0x00	; the indirect data register
PCL		EQU	0x02	; program counter low bits
STATUS		EQU	0x03	; Used for Zero bit
FSR		EQU	0x04	; the indirect address register
PORTA		EQU	0x05	; 
PORTB		EQU	0x06	; 
PORTC		EQU	0x07	; 
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
EECON1  	EQU     0x018C
EECON2  	EQU     0x018D

;-------PIC Bits--------------------------------------------------

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

;-------Project Registers-----------------------------------------

D0	EQU	0x20   	; Numeric value of LSD (100s of Hz)
D1	EQU	0x21	; Numeric value of NSD (KHz)
D2	EQU	0x22	; Numeric value of NSD (10s of KHz)
D3	EQU	0x23	; Numeric value of NSD (100s of KHz)
D4	EQU	0x24	; Numeric value of NSD (MHz)
D5	EQU	0x25	; Numeric value of NSD (10s of MHz)
D6	EQU	0x26	; Numeric value of MSD (100s of MHz)
;	EQU	0x27	; 
DATA0	EQU	0x28	; 4 bits of data (1)
DATA1	EQU	0x29	; 4 bits of data (1A)
DATA2   EQU     0x2A    ; 4 bits of data (2)
DATA3	EQU	0x2B	; 4 bits of data (2A)
DATA4	EQU	0x2C	; 4 bits of data (3)
DATA5	EQU	0x2D	; 4 bits of data (3A)
DATA6	EQU	0x2E	; 4 bits of data (4)
DATA7	EQU	0x2F	; 4 bits of data (4A)
DATA8	EQU	0x30	; 4 bits of data (5)
DATA9	EQU	0x31	; 4 bits of data (5A)
DATA10	EQU	0x32	; 4 bits of data (6)
DATA11	EQU	0x33	; 4 bits of data (6A)
;	EQU	0x34	; 
DELAY	EQU	0x35	; delay counter
;	EQU	0x36	; 
;	EQU	0x37	; 
;	EQU	0x38	; 
;	EQU	0x39	; 
;	EQU	0x3A	; 
;	EQU	0x3B	;  
;	EQU	0x3C	; 
;	EQU	0x3D	; 
;	EQU	0x3E	; 
;	EQU	0x3F	; 
;	EQU	0x40	; 
;	EQU	0x41	; 
;	EQU	0x42	; 
;	EQU	0x43	; 
;	EQU	0x44	; 
;	EQU	0x45	; 
;	EQU	0x46	; 
;	EQU	0x47	; 
;	EQU	0x48	; 
;	EQU     0x49    ; 
;	EQU	0x4A	; 
;	EQU	0x4B	; 
;	EQU	0x4C	; 
;	EQU	0x4D	; 
;	EQU	0x4E	; 
;	EQU	0x4F	; 
;	EQU	0x50	; 
;	EQU	0x51	; 
;	EQU	0x52	; 
;	EQU	0x53	; 
;	EQU	0x54	; 
;	EQU	0x55	; 
;	EQU	0x56	; 
;	EQU	0x57	; 
;	EQU	0x58	; 
;	EQU	0x59	; 
;	EQU	0x5A	; 
;	EQU	0x5B	; 
;	EQU	0x5C	;  
;	EQU	0x5D	; 
;	EQU	0x5E	; 
;	EQU	0x5F	;
;	EQU	0x60	;
;	EQU	0x61	; 
SSEG0 	EQU	0x62	; The segments illuminated in D0 (LSD)
SSEG1 	EQU	0x63	; The segments illuminated in D1 (NSD)
SSEG2 	EQU	0x64	; The segments illuminated in D2 (NSD)
SSEG3 	EQU	0x65	; The segments illuminated in D3 (NSD)
SSEG4 	EQU     0x66	; The segments illuminated in D4 (NSD)
SSEG5	EQU	0x67	; The segments illuminated in D5 (NSD)
SSEG6	EQU	0x68	; The segments illuminated in D6 (MSD)

;-------Project Bits----------------------------------------------

;	None

;-------START of Program------------------------------------------

        ORG	0x00		; Load from Program Memory 00 onwards
	GOTO	INIT

;-------Interrupt Vector------------------------------------------

; Not used
	
;------ Set up Internal Oscillator -------------------------------

        ORG	0x10		; Load from Program Memory 10 onwards
INIT	BSF 	3, 5		; Bank x1
	BCF	3, 6		; Bank 01 (1)

	MOVLW	0x61		; 4 MHz, 
	MOVWF	OSCCON		; and set it

	BCF	3, 5		; Go back to Register Bank x0

;------ Set up IO Ports ------------------------------------------
	
	CLRF	PORTA		; Clear output latches
	CLRF	PORTB		; Clear output latches
	CLRF	PORTC		; Clear output latches

	BSF 	3, 5		; Bank x1
	BCF	3, 6		; Bank 01 (1).  Now set Port directions

	MOVLW 	0x00 		; Initialize data direction
	MOVWF 	TRISA     	; Set RA0-7 as outputs

	MOVLW	0xFF 		; Initialize data direction
	MOVWF	TRISB   	; Set RB0-7 as inputs

	MOVLW	0x00	     	; Initialize data direction
	MOVWF	TRISC		; Set RC0-7 as outputs

	MOVLW	0x7F		; Initialize weak pull up enable
	MOVWF	OPTION_REG	; in the Option Register

	MOVLW	0x00		; No Weak Pull ups
	MOVWF	WPUB		; on Port B
	
	BSF	3, 6		; Bank 11 (3)

	MOVLW	0x00
	MOVWF	ANSEL		; Disable analog inputs on PORT A
	
	MOVLW	0x00
	MOVWF	ANSELH		; Disable analog inputs on PORT B
	
	BCF	3, 5		; Go back to Register Bank x0
	BCF	3, 6		; Bank 00 (0).

;------ Set Initial Values ---------------------------------------

	CLRF	PCLATH
	
;------ Start Main Code Here -------------------------------------


;------ Read data and then display each digit --------------------

BLOOP	NOP

; Wait for CE to be low before going to get data

WCELO0	BTFSC	PORTB, 5	; Skip next if CE Low
	GOTO	WCELO0		; Not low, so go back and test again

; CE is low, so go and get data

	CALL	GETDTA		; Get Data and return when all 12 nibbles have beeen read

; Now we have the data
; Calculate D0 and display

	MOVF	DATA1, W	; Move 100s of Hz into W
	MOVWF	D0		; and into D0

	MOVLW	0x02		; Load High byte of PC
	MOVWF	PCLATH		; set high byte of PC for lookup

	MOVF	D0, W           ; Load 100s of Hz
	CALL	LU7SEG		; Get the 7 Seg representation
	MOVWF	SSEG0		; and put it in the seg variable

	MOVLW	0x01		; Load the enable for D0
	MOVWF	PORTA		; Enable D0
	
	MOVF	SSEG0, W	; Load the segments for D0
	MOVWF	PORTC		; Turn on D0

	CALL	DEL1MS		; Delay 1044 uS

; Calculate D1 and display

	MOVF	DATA3, W	; Move KHz into W
	MOVWF	D1		; and into D1

	MOVLW	0x02		; Load High byte of PC
	MOVWF	PCLATH		; set high byte of PC for lookup

	MOVF	D1, W           ; Load KHz
	CALL	LU7SEG		; Get the 7 Seg representation
	MOVWF	SSEG1		; and put it in the seg variable

	MOVLW	0x02		; Load the enable for D1
	MOVWF	PORTA		; Enable D1
	
	MOVF	SSEG1, W	; Load the segments for D1
	MOVWF	PORTC		; Turn on D1

	CALL	DEL1MS		; Delay 1044 uS

; Calculate D2 and display

	MOVF	DATA5, W	; Move 10s of KHz into W
	MOVWF	D2		; and into D2

	MOVLW	0x02		; Load High byte of PC
	MOVWF	PCLATH		; set high byte of PC for lookup

	MOVF	D2, W           ; Load 10s of KHz
	CALL	LU7SEG		; Get the 7 Seg representation
	MOVWF	SSEG2		; and put it in the seg variable

	MOVLW	0x04		; Load the enable for D2
	MOVWF	PORTA		; Enable D2
	
	MOVF	SSEG2, W	; Load the segments for D2
	MOVWF	PORTC		; Turn on D2

	CALL	DEL1MS		; Delay 1044 uS

; Calculate D3 and display

	MOVF	DATA7, W	; Move 100s of KHz into W
	MOVWF	D3		; and into D3

	MOVLW	0x02		; Load High byte of PC
	MOVWF	PCLATH		; set high byte of PC for lookup

	MOVF	D3, W           ; Load 100s of KHz
	CALL	LU7SEG		; Get the 7 Seg representation
	MOVWF	SSEG3		; and put it in the seg variable

	MOVLW	0x08		; Load the enable for D3
	MOVWF	PORTA		; Enable D3
	
	MOVF	SSEG3, W	; Load the segments for D3
	MOVWF	PORTC		; Turn on D3

	CALL	DEL1MS		; Delay 1044 uS

; Calculate D4 and display

	MOVF	DATA9, W	; Move MHz into W
	MOVWF	D4		; and into D4

	MOVLW	0x02		; Load High byte of PC
	MOVWF	PCLATH		; set high byte of PC for lookup

	MOVF	D4, W           ; Load MHz
	CALL	LU7SEG		; Get the 7 Seg representation
	MOVWF	SSEG4		; and put it in the seg variable

	MOVLW	0x10		; Load the enable for D4
	MOVWF	PORTA		; Enable D4
	
	MOVF	SSEG4, W	; Load the segments for D4
	MOVWF	PORTC		; Turn on D4

	CALL	DEL1MS		; Delay 1044 uS

; Calculate D5 and display

	MOVLW	0x04	; Move 10s of MHz into W
	MOVWF	D5		; and into D5

	MOVLW	0x02		; Load High byte of PC
	MOVWF	PCLATH		; set high byte of PC for lookup

	MOVF	D5, W           ; Load 10s of MHz
	CALL	LU7SEG		; Get the 7 Seg representation
	MOVWF	SSEG5		; and put it in the seg variable

	MOVLW	0x20		; Load the enable for D5
	MOVWF	PORTA		; Enable D5
	
	MOVF	SSEG5, W	; Load the segments for D5
	MOVWF	PORTC		; Turn on D5

	CALL	DEL1MS		; Delay 1044 uS

; Calculate D6 and display

	MOVF	DATA11, W	; Move Control Indication into W
	MOVWF	D6		; and into D4

	MOVLW	0x02		; Load High byte of PC
	MOVWF	PCLATH		; set high byte of PC for lookup

	MOVF	D6, W           ; Load Control Indication
	CALL	LU7F		; Get the 7 Seg representation
	MOVWF	SSEG6		; and put it in the seg variable

	MOVLW	0x40		; Load the enable for D6
	MOVWF	PORTA		; Enable D6
	
	MOVF	SSEG6, W	; Load the segments for D6
	MOVWF	PORTC		; Turn on D6

	CALL	DEL1MS		; Delay 1044 uS	

; Blank the display while waiting for new data

	CLRF	PORTC

	GOTO	BLOOP		; Go and do it again forever

;------ End of code flow -----------------------------------------

;------ GETDTA ---------------------------------------------------

; Called when CE is low to read all the data from the FT290
; Waits for rising edge of CE and then records data on each 
; falling edge of STD

GETDTA	NOP

; Wait for CE to go high

WCEHI1	BTFSS	PORTB, 5	; Skip next if CE High
	GOTO	WCEHI1		; Not high, so go back and test again

; CE High, so wait for STD to go high

WSTDHI1	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHI1		; Not high, so go back and test again

; CE and STD Hi, so wait for STD to go low (data valid)

WSTDLO1	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLO1		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA0		; and load into DATA0

; Now wait for STD to go high again

WSTDHI2	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHI2		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLO2	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLO2		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA1		; and load into DATA1

; Now wait for STD to go high again

WSTDHI3	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHI3		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLO3	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLO3		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA2		; and load into DATA2

; Now wait for STD to go high again

WSTDHI4	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHI4		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLO4	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLO4		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA3		; and load into DATA3

; Now wait for STD to go high again

WSTDHI5	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHI5		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLO5	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLO5		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA4		; and load into DATA4

; Now wait for STD to go high again

WSTDHI6	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHI6		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLO6	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLO6		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA5		; and load into DATA5

; Now wait for STD to go high again

WSTDHI7	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHI7		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLO7	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLO7		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA6		; and load into DATA6

; Now wait for STD to go high again

WSTDHI8	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHI8		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLO8	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLO8		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA7		; and load into DATA7

; Now wait for STD to go high again

WSTDHI9	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHI9		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLO9	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLO9		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA8		; and load into DATA8

; Now wait for STD to go high again

WSTDHIA	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHIA		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLOA	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLOA		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA9		; and load into DATA9

; Now wait for STD to go high again

WSTDHIB	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHIB		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLOB	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLOB		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA10		; and load into DATA10

; Now wait for STD to go high again

WSTDHIC	BTFSS	PORTB, 4	; Skip next if STD High
	GOTO	WSTDHIC		; Not high, so go back and test again

; STD Hi, so wait for STD to go low (data valid)

WSTDLOC	BTFSC	PORTB, 4	; Skip next if STD Low
	GOTO	WSTDLOC		; Not low, so go back and test again

; Data is valid so load

	MOVF	PORTB, W	; Move data into W
	ANDLW	0x0F		; mask bottom 4 bits
	MOVWF	DATA11		; and load into DATA11

	RETURN	

;------ End of GETDTA --------------------------------------------

;------ Look-up tables and delay sub-routines here ---------------

	ORG	0x0200		; Place program segment at 0x0200

;------ LU7SEG ---------------------------------------------------

; Uses 6 cycles from call to next instruction
; Called with value to display in W
; Returns segments a-f in W active high 
	
LU7SEG	ADDWF	PCL,F
	RETLW	0x3F	;Zero	
	RETLW	0x06	;One
	RETLW	0x5B	;Two
	RETLW	0x4F	;Three
	RETLW	0x66	;Four
	RETLW	0x6D	;Five
	RETLW	0x7C	;Six
	RETLW	0x07	;Seven
	RETLW	0x7F	;Eight
	RETLW	0x67	;Nine
	RETLW	0x58	;10 A
	RETLW	0x4C	;11 B 
	RETLW	0x62	;12 C
	RETLW	0x69	;13 D
	RETLW	0x78	;14 E
	RETLW	0x00	;15 F

;------ End of LU7SEG --------------------------------------------

;------ LU7F -----------------------------------------------------

; Uses 6 cycles from call to next instruction
; Called with FT290 control data in W
; Returns segments a-f in W active high 
; If no control data, displays a 1
	
LU7F	ADDWF	PCL,F
	RETLW	0x06	;One	
	RETLW	0x54	;Memory
	RETLW	0x40	;Function
	RETLW	0x55	;Memory and Function
	RETLW	0x61	;Clarifier
	RETLW	0x75	;Carifier and memory
	RETLW	0x59	;Clarifier and function
	RETLW	0x7F	;Clarifier and memory and function
	RETLW	0x06	;One
	RETLW	0x06	;One
	RETLW	0x06	;One
	RETLW	0x06	;One 
	RETLW	0x06	;One
	RETLW	0x06	;One
	RETLW	0x06	;One
	RETLW	0x06	;One

;------ End of LU7F ----------------------------------------------


;------ DEL1MS ---------------------------------------------------

; Time delay 1044 cycles
; Best value to reduce flicker while waiting for next lot of data

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

;------ End of DEL1MS --------------------------------------------

        END
