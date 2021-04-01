/*
	Simple bouncing Itema logo
	Copyright (c) 2020 Itema AS

	Written by:
	- Øystein Steimler, ofs@itema.no
	- Torkild U. Resheim, tur@itema.no
	- Morten Moen, mmo@itema.no
	- Arve Moen, amo@itema.no
	- Bjørn Leithe Karlsen, bka@itema.no
*/

* = $c000 "Main Program"

// import our sprite library
#import "spritedata.asm"
#import "spritelib.asm"
#import "music/music.asm"
//
BasicUpstart2(initialize)
	
// Initialize
initialize:
	jsr $e544			// clear screen

	lda #%11111111		// enable all sprites
	sta $d015

	lda #$00			// disable xpand-y
	sta $d017

	lda #$00			// set sprite/background priority
	sta $d01b
	
	lda #$ff			// enable multicolor
	sta $d01c
	
	lda #$00			// disable xpand-x
	sta $d01d
	
	lda #$0f			// set sprite multicolor 1
	sta $d025
	lda #$0c			// set sprite multicolor 2
	sta $d026
	lda #$0a			// set sprite individual color
	sta $d027
	
	lda #spriteData/64	// set sprite data pointer
	sta $07f8			// sprite #1
	sta $07f9			// sprite #2
	sta $07fa			// sprite #3
	sta $07fb			// sprite #4
	sta $07fc			// sprite #5
	sta $07fd			// sprite #6
	sta $07fe			// sprite #7
	sta $07ff			// sprite #8
	
	//jsr startMusic

loop:
	lda #$00
	sta spriteindex
	animation_loop:
		jsr horizontal
		jsr vertical	
		jsr draw_sprite
		inc spriteindex
		lda spriteindex
		cmp #$08
		beq done
		jmp animation_loop
	done:
		// Spend a few cycles doing nothing in order to get a smooth motion
		ldy  #$10
		ldx  #$01
		delay:
			dex
			bne delay
			dey
			bne delay
jmp loop

// -- Sprite Data --------------------------------------------------------------
// Created using https://www.spritemate.com
* = $2140 "Sprite Data"
spriteData:
.byte %00000000,%00101000,%00000000
.byte %00000000,%10101010,%00000000
.byte %00000001,%10101010,%01000000
.byte %00000101,%10101010,%01010000
.byte %00110111,%00101000,%11011100
.byte %00010100,%00000000,%00010100
.byte %11010100,%01010100,%00010111
.byte %01011100,%01010100,%00110101
.byte %01011100,%00010100,%00110101
.byte %01011100,%00010100,%00110101
.byte %01011100,%00010100,%00110101
.byte %01011100,%00010100,%00110101
.byte %01011100,%00010100,%00010101
.byte %01011100,%00010100,%00010111
.byte %01011100,%00010111,%11010100
.byte %11010100,%00010101,%01011100
.byte %00010100,%00010101,%01110000
.byte %00110111,%00000000,%00000000
.byte %00000101,%01111101,%00000000
.byte %00001101,%01010101,%00000000
.byte %00000011,%11011100,%00000000
