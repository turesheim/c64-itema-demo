/*
	Sprite data library
	Copyright (c) 2020 Itema AS

	Written by:
	- Øystein Steimler, ofs@itema.no
	- Torkild U. Resheim, tur@itema.no
	- Morten Moen, mmo@itema.no
	- Arve Moen, amo@itema.no
	- Bjørn Leithe Karlsen, bka@itema.no
*/

spriteindex:
	 .byte $00

spritemem:
/*
          +------------------------------------ X-location least significant bits
          |    +------------------------------- X-location most significant bits
          |    |    +-------------------------- Y-location least significant bits
          |    |    |    +--------------------- Y-location most significant bits
          |    |    |    |    +---------------- X-velocity (signed integer)
          |    |    |    |    |    +----------- Y-velocity (signed integer)
          |    |    |    |    |    |    +------ X-acceleration (signed integer)
          |    |    |    |    |    |    |    +- Y-acceleration (signed integer)
          |    |    |    |    |    |    |    |
          xl   xm   yl   ym   xv   yv	xa	 ya
*/
	.byte $18, $00, $32, $00, $01, $00, $01, $00
	.byte $18, $00, $42, $00, $02, $00, $01, $00
	.byte $18, $00, $52, $00, $03, $00, $01, $00
	.byte $18, $00, $62, $00, $01, $00, $01, $00
	.byte $18, $00, $72, $00, $02, $00, $01, $00
	.byte $18, $00, $82, $00, $02, $00, $01, $00
	.byte $18, $00, $92, $00, $03, $00, $01, $00
	.byte $18, $00, $a2, $00, $03, $00, $01, $00

.var xl = 0
.var xm = 1
.var yl = 2
.var ym = 3
.var xv = 4
.var yv = 5
.var xa = 6
.var ya = 7
.var spritelen = 8

ldx #0
stx spriteindex
jsr get_xm					// xm for 0 in a

get_xm:
	php
	jsr getspritebase		// Get spritebase in .A
	clc						// Clear the carry flag
	adc #xm					// Add index to get fieldaddr
	jmp get_val

get_xl:
	php
	jsr getspritebase		// Get spritebase in .A
	clc						// Clear the carry flag
	adc #xl					// Add index to get fieldaddr
	jmp get_val

get_ym:
	php
	jsr getspritebase		// Get spritebase in .A
	clc						// Clear the carry flag
	adc #ym					// Add index to get fieldaddr
	jmp get_val

get_yl:
	php
	jsr getspritebase		// Get spritebase in .A
	clc						// Clear the carry flag
	adc #yl					// Add index to get fieldaddr
	jmp get_val

get_ya:
	php
	jsr getspritebase		// Get spritebase in .A
	clc						// Clear the carry flag
	adc #ya					// Add index to get fieldaddr
	jmp get_val

get_xa:
	php
	jsr getspritebase		// Get spritebase in .A
	clc						// Clear the carry flag
	adc #xa					// Add index to get fieldaddr
	jmp get_val

get_xv:
	php
	jsr getspritebase		// Get spritebase in .A
	clc						// Clear the carry flag
	adc #xv					// Add index to get fieldaddr
	jmp get_val

get_yv:
	php
	jsr getspritebase		// Get spritebase in .A
	clc						// Clear the carry flag
	adc #yv					// Add index to get fieldaddr

	// jmp get_val // next instr

get_val:
	tax						// .A -> .X
	lda spritemem,x			// load fieldaddr -> .A
	plp
	rts

store_xm:
	php
	pha
	jsr getspritebase		// Get spritebase in .A
	clc						// Clear the carry flag
	adc #xm					// Add index to get fieldaddr
	jmp store_val

store_xl:
	php
	pha
	jsr getspritebase		// Get spritebase in .A
	clc
	adc #xl					// Add index to get fieldaddr
	jmp store_val

store_ym:
	php
	pha
	jsr getspritebase		// Get spritebase in .A
	clc
	adc #ym					// Add index to get fieldaddr
	jmp store_val

store_yl:
	php
	pha
	jsr getspritebase		// Get spritebase in .A
	clc
	adc #yl					// Add index to get fieldaddr
	jmp store_val

store_xa:
	php
	pha
	jsr getspritebase		// Get spritebase in .A
	clc
	adc #xa					// Add index to get fieldaddr
	jmp store_val

store_ya:
	php
	pha
	jsr getspritebase		// Get spritebase in .A
	clc
	adc #ya					// Add index to get fieldaddr
	jmp store_val

store_xv:
	php
	pha
	jsr getspritebase		// Get spritebase in .A
	clc
	adc #xv					// Add index to get fieldaddr
	jmp store_val

store_yv:
	php
	pha
	jsr getspritebase		// Get spritebase in .A
	clc
	adc #yv					// Add index to get fieldaddr
	// jmp store_val		// -> next instr

store_val:
	tax						// .A -> .X
	pla
	plp
	sta spritemem,x			// load fieldaddr -> .A
	rts

// getspritebase -> .A  -- uses .X
getspritebase:
	ldx spriteindex
	lda #$00

	getspritebase_loop:
		cpx #$00
		beq gotspritebase
		clc
		adc #spritelen
		dex
		jmp getspritebase_loop

	gotspritebase:
		rts

