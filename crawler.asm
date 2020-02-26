; =============================================================================
; === PROCESS CRAWLER
; =============================================================================

c_process_crawler:
; First, check if the player is in the crawler zone. If so,
; run the crawler logic twice.
	ld a,(ix+o_enemy_y)
	ld (ix+o_enemy_oldy),a

	ld a,(v_player_currentx+1)
	add a,6
	ld b,(ix+o_enemy_x)
	cp b						; Compare right edge of P with left edge of F
	jr c,c_process_crawler_l1
	
	sub 22
	cp b						; Compare left edge of P with right edge of F
	jr nc,c_process_crawler_l1
	
	bit 7,(ix+o_enemy_deltay)			; Is crawler moving down screen?
	call z,c_process_crawler_l1			; Run the process routine twice if so

c_process_crawler_l1:
	ld a,(ix+o_enemy_y)
	ld b,(ix+o_enemy_deltay)
	add a,b						; Add delta value

	cp (ix+o_enemy_oldscreenx)			; Top value

	call c,c_crawler_invert				; Change direction if top hit
	ld (ix+o_enemy_y),a
	ld (ix+o_enemy_deltay),b

	cp (ix+o_enemy_deltax)				; Bottom value
	call nc,c_crawler_invert			; Change direction if bottom hit
	ld (ix+o_enemy_y),a
	ld (ix+o_enemy_deltay),b
	
	ret

c_crawler_invert:
	ld c,a						; Save coord
	ld a,b						; Get delta
	neg						; Flip sign
	ld b,a						; Save delta
	add a,c						; Add coord

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
; === PREPARE CRAWLER GRAPHICS
; =============================================================================

c_prepare_crawler:
; Backup the old data first
	ld l,(ix+o_enemy_frame)
	ld h,(ix+o_enemy_frame+1)

	ld (ix+o_enemy_oldframe),l
	ld (ix+o_enemy_oldframe+1),h

; Calculate the frame first
	ld a,(ix+o_enemy_y)
	and %00000100					; Keep only bit 2
	add a,a
	add a,a
	add a,a						; Calculate offset into graphics data
	
	ld l,a
	ld h,0
	ld de,g_crawler_0
	add hl,de					; Add base address for crawler graphics

	ld (ix+o_enemy_frame),l
	ld (ix+(o_enemy_frame+1)),h

; Now find the screen X position
	ld a,(ix+o_enemy_x)
	and %11111000					; Get column
	rrca
	rrca
	rrca

	ld (ix+o_enemy_screenx),a

	ret

; =============================================================================
; === COLLISION CHECK WITH CRAWLER
; =============================================================================

c_collide_crawler:
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
; === DRAW CRAWLER
; =============================================================================

c_draw_crawler:
	push ix

	ld c,(ix+o_enemy_screenx)
	ld b,(ix+o_enemy_oldy)

	ld e,(ix+o_enemy_oldframe)
	ld d,(ix+(o_enemy_oldframe+1))

	call c_xor_spr16				; Remove old sprite

	pop ix

	ld c,(ix+o_enemy_screenx)
	ld b,(ix+o_enemy_y)

	ld e,(ix+o_enemy_frame)
	ld d,(ix+(o_enemy_frame+1))

	call c_xor_spr16				; Add new sprite

	ret
