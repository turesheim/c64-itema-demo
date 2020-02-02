
initScroller:	ldx #40				// init color map
			lda #01
			sta $dbc0, x
			dex
			bpl initScroller+4

			// sei					// set up interrupt
			// lda #$7f
			// sta $dc0d			// turn off the CIA interrupts
			// sta $dd0d
			// and $d011			// clear high bit of raster line
			// sta $d011		

			// ldy #00				// trigger on first scan line
			// sty $d012

			// lda #<noscroll		// load interrupt address
			// ldx #>noscroll
			// sta $0314
			// stx $0315

			// lda #$01 			// enable raster interrupts
			// sta $d01a
			// cli
			rts					// back to BASIC

noscroll:	lda $d016			// default to no scroll on start of screen
			and #248			// mask register to maintain higher bits
			sta $d016
			ldy #242			// trigger scroll on last character row
			sty $d012
			lda #<scroll		// load interrupt address
			ldx #>scroll
			sta $0314
			stx $0315
			inc $d019			// acknowledge interrupt
			rts

scroll:		lda $d016			// grab scroll register
			and #248			// mask lower 3 bits
			adc offset			// apply scroll
			sta $d016

			dec smooth			// smooth scroll
			bne continue

			dec offset			// update scroll
			bpl resetsmooth
			lda #07				// reset scroll offset
			sta offset

shiftrow:	ldx #00 			// shift characters to the left
			lda $07c1, x
			sta $07c0, x
			inx
			cpx #39
			bne shiftrow+2

			ldx nextchar		// insert next character
			lda message, x
			sta $07e7			
			inx
			lda message, x
			cmp #$ff			// loop message
			bne resetsmooth-3
			ldx #00
			stx nextchar

resetsmooth:	ldx #01				// set smoothing
			stx smooth			

			ldx offset			// update colour map
			lda colors, x
			sta	$dbc0
			lda colors+8, x
			sta $dbc1
			lda colors+16, x
			sta	$dbe6
			lda colors+24, x
			sta $dbe7

continue:	ldy #00				// trigger on first scan line
			sty $d012
			lda #<noscroll		// load interrupt address
			ldx #>noscroll
			sta $0314
			stx $0315
			inc $d019			// acknowledge interrupt
			rts

offset:		.byte 07 			// start at 7 for left scroll
smooth:		.byte 01
nextchar:	.byte 00
//--= WORLDCLASS DEMO - BY ITEMA 1337 HAX0R CREW - FROYA 2020 =--
message:	.byte 045, 045, 061, 032, 023, 015, 018, 012 
			.byte 004, 003, 012, 001, 019, 019, 032, 004 
			.byte 005, 013, 015, 032, 045, 032, 002, 025 
			.byte 032, 009, 020, 005, 013, 001, 032, 049
			.byte 051, 051, 055, 032, 008, 001, 024, 048 
			.byte 018, 032, 003, 018, 005, 023, 032, 045
			.byte 032, 006, 018, 015, 025, 001, 032, 050 
			.byte 048, 050, 048, 032, 061, 045, 045, 255
colors: 	.byte 00, 00, 00, 00, 06, 06, 06, 06
			.byte 14, 14, 14, 14, 03, 03, 03, 03
			.byte 03, 03, 03, 03, 14, 14, 14, 14
			.byte 06, 06, 06, 06, 00, 00, 00, 00