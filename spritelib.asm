/*
	Sprite handling library
	Copyright (c) 2020 Itema AS

	This will simply bounce sprites between the four walls of the screen. Load
	the current sprite number in to the A register and call the following
	functions:

	horizontal to
		move horizontally

	vertical to
		move vertically

	draw_sprite to
		draw the sprite on it's new location

	Written by:
	- Øystein Steimler, ofs@itema.no
	- Torkild U. Resheim, tur@itema.no
	- Morten Moen, mmo@itema.no
	- Arve Moen, amo@itema.no
	- Bjørn Leithe Karlsen, bka@itema.no
*/

set_table:
	.byte %00000001
	.byte %00000010
	.byte %00000100
	.byte %00001000
	.byte %00010000
	.byte %00100000
	.byte %01000000
	.byte %10000000

clear_table:
	.byte %11111110
	.byte %11111101
	.byte %11111011
	.byte %11110111
	.byte %11101111
	.byte %11011111
	.byte %10111111
	.byte %01111111

/*
	A helper "variable" we will need on occasion
*/
temp:
	.byte %00000000
temp2:
	.byte %00000000

/*
	Determine the offset of the sprite x-position address
*/
get_sprite_offset:
	ldx spriteindex
	lda #$00

	get_sprite_offset_loop:
		cpx #$00
		beq got_sprite_offset
		clc
		adc #$2
		dex
		jmp get_sprite_offset_loop

	got_sprite_offset:
		rts

draw_sprite:

	// set vertical position
	jsr get_sprite_offset
	tay
	jsr get_yl
	sta $d001,y	

	// set horizontal position
	jsr get_sprite_offset
	tay
	jsr get_xl
	sta $d000,y

	// set horizontal position msb
	jsr get_xm
	cmp #$01
	beq set_msb
	
	jsr get_xm
	cmp #$00
	beq clear_msb
rts

set_msb:
	ldx spriteindex
	lda $d010
	ora set_table,x
	sta $d010
rts

clear_msb:
	ldx spriteindex
	lda $d010
	and clear_table,x
	sta $d010
rts

////////////////////////////////////////////////////////////////////////////////

/*
 	Apply the acceleration to the velocity, moving up. Once passing $FF (-1) the
	direction will change to moving downwards. This transition causes some
	velocity to be lost.
*/
bounce_up:
	jsr get_ya
	sta temp
	jsr get_yv
	clc	
	adc #$04				// simulate gravity
	jsr store_yv
rts

/*
	Apply the acceleration to the velocity, moving down. Make sure that the
	maximum value of #$7f is not exceeded because that would mean moving up.
*/
fall_down:
	jsr get_ya
	sta temp
	jsr get_yv
	clc
	adc #$04				// simulate gravity
	cmp #$80				// Do not go negative
	bpl f_acc
	jsr store_yv
	f_acc:
rts

/*
	Perform horizontal movement
*/
horizontal:
	jsr get_xv
	cmp #$00				// Compare with signed integer
	bmi left				// Move left if value is negative
	bpl right				// Move right if value is positive
rts

/*
	Perform vertical movement
*/
vertical:
	jsr v_acceleration		// Apply vertical accelleration
	jsr get_yv
	cmp #$00				// Compare with signed integer
	bmi up					// Move up if value is negative
	bpl down				// Move down if value is positive
rts

v_acceleration:
	jsr get_yv
	cmp #$00				// Compare with signed integer
	bpl fall_down			// Move down if value is positive
	bmi bounce_up			// Move up if value is negative
rts

/*
	Move current sprite left
*/
left:
	jsr get_xv				// Get the X-velocity (which is negative)
	eor #$ff				// Flip the sign so that we get a positive number
	clc
	adc #$01
	sta temp				// Store the new value in a variable
	jsr get_xl
	sec
	sbc temp				// Move left by the amount of velocity 
	jsr store_xl
	jsr get_xm
	sbc #$00				// Subtract zero and borrow from lsb subtraction
	jsr store_xm
	jsr left_edge
rts
/*
	Move current sprite right
*/
right:
	jsr get_xv				// Get the X-velocity (a positive number)
	sta temp				// Store the value in a temporary variable
	jsr get_xl
	clc
	adc temp				// Move right by the amount of velocity
	jsr store_xl
	jsr get_xm
	adc #$00				// Add zero and carry from lsb addition
	jsr store_xm
	jsr right_edge
rts	

/*
	Move current sprite upwards
*/
up:
	jsr get_yv				// Get the Y-velocity (a negative number)
	eor #$ff				// Flip the sign so that we get a positive number
	clc
	jsr shift_right			// Apply the 3 MSB of velocity
	sta temp				// Store the new value in a variable
	jsr get_yl
	sec
	sbc temp				// Move up by the amount of velocity
	jsr store_yl
	cmp #$31				// Is top of screen hit?
	bcc change_vertical		// Jump if less than $31
rts

/*
	Move current sprite downwards
*/
down:
	jsr get_yv				// Get the Y-velocity (a positive number)
	jsr shift_right			// Apply only the 3 MSB of velocity
	sta temp				// Store the value in a temporary variable
	jsr get_yl
	clc
	adc temp				// Move down by the amount of velocity
	jsr store_yl
	cmp #$e6				// Is bottom of screen hit?
	bcs change_vertical		// If so change direction
rts

/*
	Flip the sign on the vertical velocity and acceleration
*/
change_vertical:
	jsr get_yv				// Change the direction of the velocity
	eor #$ff
	clc
// doing this properly moves the sprite below the border
//	adc #$01
	jsr store_yv
rts

/*
	Flip the sign on the horizontal velocity and acceleration
*/
change_horizontal:
	jsr get_xv				// Change the direction of the velocity
	eor #$ff
	clc
	adc #$01
	jsr store_xv
rts


/*
	Determine whether or not the current sprite is at the right edge
*/
right_edge:
	jsr get_xm
	cmp #$01				// Compare with #01 (over fold)
	beq at_right_edge
rts

/*
	Change direction and start moving leftwards
*/
at_right_edge:
	jsr get_xl
	cmp #$40
	bcs change_horizontal
rts

/*
	Determine whether or not the current sprite is at the left edge
*/
left_edge:
	jsr get_xm
	cmp #$01				// Compare with #01 (at fold)
	bne at_left_edge
rts

/*
	Change direction and start moving rightwards
*/
at_left_edge:
	jsr get_xl
	cmp #$17
	bcc change_horizontal
rts

shift_right:
	clc
	ror
	clc
	ror
	clc
rts
