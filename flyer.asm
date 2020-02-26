; =============================================================================
; === PROCESS FLYER
; =============================================================================

c_process_flyer:
; Handle movement in the X direction
	ld a,(ix+o_enemy_x)				; Get X coord
	ld (ix+o_enemy_oldx),a				; Save as old coord

	ld b,(ix+o_enemy_deltax)
	add a,b						; Add the X delta

	cp 240						; Edge of screen?
	call nc,c_flyer_invert				; Bounce if so
	ld (ix+o_enemy_x),a
	ld (ix+o_enemy_deltax),b			; Save variables back

; Handle movement in the Y direction
	ld a,(ix+o_enemy_y)				; Get Y coord
	ld (ix+o_enemy_oldy),a				; Save as old coord

	ld b,(ix+o_enemy_deltay)
	add a,b						; Add the Y delta

	cp 32						; Top edge of screen?

	call c,c_flyer_invert				; Bounce if so
	ld (ix+o_enemy_y),a
	ld (ix+o_enemy_deltay),b			; Save variables back

	cp 176						; Bottom edge of screen?
	call nc,c_flyer_invert				; Bounce if so
	ld (ix+o_enemy_y),a
	ld (ix+o_enemy_deltay),b			; Save variables back

	ret

c_flyer_invert:
; This routine inverts the direction of the delta (in the B register)
; and adds this new delta to the coordinate (in the A register)
	ld c,a						; Save coord
	ld a,b						; Get delta
	neg						; Flip the sign
	ld b,a						; Save delta
	add a,c						; Add coord

	push bc
	push hl
	push af
	ld bc,e_flyer_bounce
	call c_set_sound				; Set up the bounce sound
	pop af
	pop hl
	pop bc
	ret

; =============================================================================
; === PREPARE FLYER GRAPHICS
; =============================================================================

c_prepare_flyer:
; Backup the old data first
	ld a,(ix+o_enemy_screenx)
	ld l,(ix+o_enemy_frame)
	ld h,(ix+o_enemy_frame+1)
	
	ld (ix+o_enemy_oldscreenx),a
	ld (ix+o_enemy_oldframe),l
	ld (ix+o_enemy_oldframe+1),h

; Calculate the frame first
	ld c,(ix+o_enemy_x)
	ld a,c

	and %00000110					; Keep only inter-column bits
	ld l,a
	ld h,0

	add hl,hl					; x2
	add hl,hl					; x4
	add hl,hl					; x8

	push hl
	pop de

	add hl,hl					; x16
	add hl,de					; x24

	ld de,g_flyer_0
	add hl,de					; Add base address for flyer graphics

	ld (ix+o_enemy_frame),l
	ld (ix+(o_enemy_frame+1)),h

; Now find the screen X position
	ld a,c
	and %11111000
	rrca
	rrca
	rrca

	ld (ix+o_enemy_screenx),a

	ret

; =============================================================================
; === COLLISION CHECK WITH FLYER
; =============================================================================

c_collide_flyer:
; B - Left edge of player
; C - Right edge of player
; D - Top edge of player
; E - Bottom edge of player
	ld a,(ix+o_enemy_x)
	inc a
	inc a

	cp c						; Compare F's left edge with P's right edge
	ret nc

	add a,11
	cp b						; Compare F's right edge with P's left edge
	ret c

	ld a,(ix+o_enemy_y)
	inc a
	inc a

	cp e						; Compare F's bottom edge with P's top edge
	ret nc

	add a,11
	cp d						; Compare F's top edge with P's bottom edge
	ret c

	ld ix,d_ouch
	jp c_ouch

; =============================================================================
; === DRAW FLYER
; =============================================================================

c_draw_flyer:
	push ix						; Save enemy structure pointer

	ld c,(ix+o_enemy_oldscreenx)
	ld b,(ix+o_enemy_oldy)

	ld e,(ix+o_enemy_oldframe)
	ld d,(ix+(o_enemy_oldframe+1))

	call c_xor_spr24				; Remove old sprite

	pop ix

	ld c,(ix+o_enemy_screenx)
	ld b,(ix+o_enemy_y)

	ld e,(ix+o_enemy_frame)
	ld d,(ix+(o_enemy_frame+1))

	call c_xor_spr24				; Add new sprite

	ret
