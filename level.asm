; =============================================================================
; === RENDER LEVEL AND SET UP ENEMIES
; =============================================================================

c_render_level:
; Renders the currently loaded level onto the screen (and sets up the
; enemies as well)
	ld ix,v_level
	ld bc,0

c_render_level_l1:
	push bc						; Make a backup of the coords first
	ld a,(ix+0)					; Get block
	ld e,a

	cp 15						; Is this a blank space?
	jp z,c_render_level_eob				; Skip rendering if so

	cp 12						; Is this an enemy?
	jp nc,c_init_enemy				; Initialise its structure if so

; Calculate the screen address
; We must shift the Y coordinate left by seven places.
; (Y * 32 * 4)
	ld a,b						; -----xxx
	rrca						; x-----xx
	rrca						; xx-----x
	rrca						; xxx-----
	add a,%00100000					; Add offset from top of screen

	ld l,a
	ld h,$16

	add hl,hl
	add hl,hl					; Row address found

; Now add the X offset
	ld a,c
	add a,a
	add a,a						; Multiply X by 4
	add a,l						; Add to attribute offset
	ld l,a						; We have now formed the screen address

; Now we are able to plot the appropriate graphics
	ld a,(v_ground_attr)
	bit 3,e						; Is this ice?
	
	ld (c_render_level_plot+1),a			; Set ground colour
	jr z,c_render_level_l2				; Jump if not

	ld a,(v_ice_attr)
	ld (c_render_level_plot+1),a			; Set ice colour

c_render_level_l2:
; Now we need to retrieve the image data for this junction
; First, calculate the image's offset into the image data table
	ld a,e
	and %00000111					; Keep only the junction type
	add a,a
	
	add a,d_render_data%256
	ld e,a
	ld d,d_render_data/256
	
; Now we have the address, we can start the loop
	ld a,(de)
	call c_render_level_row

	ld bc,28
	add hl,bc					; Move to next row
	call c_render_level_row

	inc e
	ld a,(de)					; Get next byte
	ld bc,28
	add hl,bc					; Move to next row
	call c_render_level_row

	ld bc,28
	add hl,bc					; Move to next row
	call c_render_level_row
	
c_render_level_eob:
; Rendering is now complete for this block, so check our row counters
	inc ix						; Move to next block

	pop bc						; Restore coordinates
	inc c
	ld a,8
	cp c						; End of row?
	jp nz,c_render_level_l1
	
	ld c,0						; Reset row counters
	inc b
	ld a,5
	cp b						; Out of blocks?
	jp nz,c_render_level_l1
	
	ret						; Out of blocks, stop



c_render_level_row:
; Renders a row of the cell, using the 4 most significant bits of the accumulator
	ld b,4						; Four squares per row

c_render_level_row_l1:
	rlca						; Fetch next bit
	jr nc,c_render_level_row_l2			; Ignore if bit reset
	
c_render_level_plot:
	ld (hl),0					; Plot colour square (self-modifying code, sorry!)

c_render_level_row_l2:
	inc hl						; (Could've used INC L as doesn't cross page boundary)
	djnz c_render_level_row_l1			; Loop back if row is not finished
	
	ret



c_init_enemy:
; Initialises the enemy structure
; First step: calculate pixel-space coordinates
; B and C hold attribute cooridnates, so multiply them by 8
	ld a,c
	rrca
	rrca
	rrca						; x8
	add a,8						; Put enemy in middle of block
	ld c,a
	
	ld a,b
	rrca
	rrca
	rrca						; x8
	add a,40					; Add offset from middle of block and top of screen
	ld b,a

; Now find next empty slot for enemy
	ld a,(v_enemyno)				; Get number of enemies
	inc a
	ld (v_enemyno),a				; Increment number of enemies

	ld e,a
	add a,a						; x2
	ld d,a
	add a,a						; x4
	add a,d						; x6
	add a,a						; x12
	add a,e						; x13
	
	ld e,a
	ld d,0
	
	ld hl,v_enemy_struct_start-13			; Account for number being offset by 1
	add hl,de
	
	ld a,(ix+0)					; Get block data
	push ix						; Save pointer into level data
	sub 11						; Subtract 11 to obtain enemy type
	
	push hl
	pop ix						; Move enemy structure pointer into IX
	
	ld hl,$4000					; Pointer to empty run of bytes

; Save general enemy data into the structure
	ld (ix+o_enemy_type),a
	ld (ix+o_enemy_x),c
	ld (ix+o_enemy_y),b
	ld (ix+o_enemy_frame),l
	ld (ix+o_enemy_frame+1),h

; Now jump to specific initialisation for each enemy
	cp 1
	jr z,c_init_flyer
	
	cp 2
	jr z,c_init_crawler
	
	cp 3
	jr z,c_init_pacer
	
	jp c_render_level_eob				; Exit if enemy type not recognised
; (While adding these comments for the source release, I've realised that a POP IX
; is needed before the failsafe exit, otherwise the stack just gets messed up)

c_init_flyer:
; Initialise the flyer
	ld a,$01
	ld (ix+o_enemy_deltay),a
	ld a,(v_deltax)
	ld (ix+o_enemy_deltax),a
	pop ix						; Restore level data pointer
	jp c_render_level_eob

c_init_crawler:
	ld a,$01
	ld (ix+o_enemy_deltay),a
	ld a,b
	sub 32						; One square above centre for top limit
	ld (ix+o_enemy_oldscreenx),a
	add a,64					; One square below centre for bottom limit
	ld (ix+o_enemy_deltax),a
	pop ix						; Restore level data pointer
	jp c_render_level_eob

c_init_pacer:
	ld a,$01
	ld (ix+o_enemy_deltax),a
	ld a,c
	sub 32						; One square left of centre for left limit
	ld (ix+o_enemy_oldy),a
	add a,64					; One square right of centre for right limit
	ld (ix+o_enemy_deltay),a
	pop ix						; Restore level data pointer
	jp c_render_level_eob

; =============================================================================
; === EXPAND PACKED LEVEL DATA
; =============================================================================

c_expand_level:
; Expands level data from nibbles to full bytes
; Inputs: HL - Packed level data
	ld b,20						; Length of packed level data
	ld c,$0f					; Mask for right nibble
	ld de,v_level	

c_expand_level_l1:
; Left nibble
	ld a,(hl)					; Get packed byte
	and $f0						; Keep left nibble only
	
	rrca
	rrca
	rrca
	rrca						; Rotate into place
	
	ld (de),a					; Store expanded right nibble
	inc de

; Right nibble
	ld a,(hl)
	and c						; Keep right nibble only
	ld (de),a					; Store expanded left nibble
	inc de
	
	inc hl						; Onto next byte of packed data
	djnz c_expand_level_l1				; Loop back if there's more data
	ret

; =============================================================================
; === RENDERING VARIABLES
; =============================================================================
	
v_ground_attr:
	db $72
v_ice_attr:
	db $6a
v_blank_attr:
	db $3a

; =============================================================================
; === RENDERING PALETTES
; =============================================================================

d_pal1:
; Data for the screen palette
	db $72, $6a, $3a				; Levels 1, 5, 9 & 13
	db $59, $69, $39				; Levels 2, 6, 10 & 14
	db $4b, $6b, $3b                                ; Levels 3, 7, 11 & 15
	db $55, $69, $3d                                ; Levels 4, 8 & 12

; =============================================================================
; === IMAGE DATA
; =============================================================================

d_render_data:
if ($%256) GE 241
	.ERROR Please alter the placement of d_render_data in memory! It cannot be here!
endif

	db %00001111
	db %11110000					; $0 - Horizontal straight  (ice $8)

	db %01100110
	db %01100110					; $1 - Vertical straight    (ice $9)

	db %00001111
	db %00000000					; $2 - Horizontal tightrope (ice $A)

	db %00100010
	db %00100010					; $3 - Vertical tightrope   (ice $B)

	db %00000111
	db %01110110					; $4 - Corner (bottom + right)

	db %00001110
	db %11100110					; $5 - Corner (bottom + left)

	db %01101110
	db %11100000					; $6 - Corner (top + left)

	db %01100111
	db %01110000					; $7 - Corner (top + right)

