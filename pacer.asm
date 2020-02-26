; =============================================================================
; === PROCESS PACER
; =============================================================================

c_process_pacer:
	ld a,(ix+o_enemy_x)
	ld (ix+o_enemy_oldx),a

	ld a,(ix+o_enemy_x)
	ld b,(ix+o_enemy_deltax)
	add a,b						; Add delta

	cp (ix+o_enemy_oldy)				; Left value

	call c,c_pacer_invert				; Change direction if left edge of path hit
	ld (ix+o_enemy_x),a
	ld (ix+o_enemy_deltax),b

	cp (ix+o_enemy_deltay)				; Right value
	call nc,c_pacer_invert				; Change direction if right edge of path hit
	ld (ix+o_enemy_x),a
	ld (ix+o_enemy_deltax),b

	ret

c_pacer_invert:
	ld c,a						; Save coord
	ld a,b						; Get delta
	neg						; Flip sign
	ld b,a						; Save delta
	add a,c						; Add to coord

	push bc
	push hl
	push af
	ld bc,e_crawler_bounce
	call c_set_sound				; Set up bounce sound
	pop af
	pop hl
	pop bc
	ret


; =============================================================================
; === PREPARE PACER GRAPHICS
; =============================================================================

c_prepare_pacer:
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

	and %00000110					; Keep bits 1 and 2
	ld l,a
	ld h,0

; Calculate offset into pacer graphics data
	add hl,hl					; x2
	add hl,hl					; x4
	add hl,hl					; x8

	push hl
	pop de

	add hl,hl					; x16
	add hl,de					; x24

	ld de,g_pacer_0
	add hl,de					; Add base address for pacer graphics

	ld (ix+o_enemy_frame),l
	ld (ix+(o_enemy_frame+1)),h

; Now find the screen X position
	ld a,(ix+o_enemy_x)
	and %11111000					; Keep column only
	rrca
	rrca
	rrca

	ld (ix+o_enemy_screenx),a

	ret

; =============================================================================
; === COLLISION CHECK WITH PACER
; =============================================================================

c_collide_pacer:
; B - Left edge of player
; C - Right edge of player
; D - Top edge of player
; E - Bottom edge of player
	ld a,(ix+o_enemy_x)
	inc a

	cp c						; Compare F's left edge with P's right edge
	ret nc

	add a,13
	cp b						; Compare F's right edge with P's left edge
	ret c

	ld a,(ix+o_enemy_y)
	inc a

	cp e						; Compare F's bottom edge with P's top edge
	ret nc

	add a,13
	cp d						; Compare F's top edge with P's bottom edge
	ret c

	ld ix,d_ouch
	jp c_ouch

; =============================================================================
; === DRAW PACER
; =============================================================================

c_draw_pacer:
	push ix

	ld c,(ix+o_enemy_oldscreenx)
	ld b,(ix+o_enemy_y)

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
