; =============================================================================
; === DEATH
; =============================================================================

c_death:
; Expects IX to be pointer to death strings
	ei						; Enable interrupts from sound routine
	ld sp,e_stack_top				; Reset stack, we don't know we've come from
	ld bc,$020c
	call c_printstring

	ld a,13						; 13 loops

c_death_loop:
	push af						; Save loop counter
	ld e,a
	call c_death_sound
	ld a,e
	or $38						; Set white paper colour

	ld hl,22528+(32*2)+12
	ld bc,$0801					; 8x1 block
	call c_attrfill					; Fill attributes

	pop af						; Restore loop counter
	dec a
	jr nz,c_death_loop

	ld a,(v_lives)
	dec a
	ld (v_lives),a					; Decrement lives counter
	jr z,c_gameover

	jp c_initialise_level

c_gameover:
	ld bc,$020b
	ld ix,d_gameover
	call c_printstring				; Print game over string

	ld a,13

c_gameover_loop:
	push af						; Save loop counter
	ld e,a
	call c_death_sound
	ld a,e
	or $38						; Set white paper colour

	ld hl,22528+(32*2)+11
	ld bc,$0a01					; 10x1 block
	call c_attrfill					; Fill attributes

	pop af						; Restore loop counter
	dec a
	jr nz,c_gameover_loop

	jp c_start

c_death_sound:
	di
	ld a,7
	ld c,0

c_death_sound_l1:
	ld b,c
	xor 16
	out (254),a
	nop
	nop
	djnz $-2

	dec c
	jr nz,c_death_sound_l1

	ei
	ret

; =============================================================================
; === FALL OUT SOUND
; =============================================================================

c_fallout:
; Plays sound of decreasing frequency
	di
	ld d,4
	ld a,7

c_fallout_l1:
	ld c,96						; 96 iterations per pitch

c_fallout_l2:
	xor 16
	ld b,d
	out ($fe),a
	djnz $

	dec c
	jr nz,c_fallout_l2

	ex af,af'
	inc d
	inc d						; Decrease frequency
	ld a,120
	cp d
	jp c,c_death

	ex af,af'
	jr c_fallout_l1

; =============================================================================
; === OUCH SOUND
; =============================================================================

c_ouch:
; Plays random noise
	di
	ld hl,0
	ld c,38

c_ouch_l1:
	ld a,(hl)					; Pull some data from the ROM
	and %00010000					; Keep only bit for SPEAKER
	or 7						; Set white border colour

	out ($fe),a					; Output to ULA
	ld b,23
	djnz $						; Small delay loop

	inc l
	jr nz,c_ouch_l1

	inc h
	dec c
	jr nz,c_ouch_l1

	jp c_death

; =============================================================================
; === TIME OUT SOUND
; =============================================================================

c_timeout:
; Plays buzzer sound
	ld d,%011100100					; Sharp, annoying bit pattern
	ld c,0						; 256 loops of the above
c_timeout_l1:
	ld e,8
c_timeout_l2:
	rlc d
	ld a,$10
	and d
	or 7						; Set white border colour
	out (254),a					; Output to ULA
	ld b,143
c_timeout_l4:
	djnz c_timeout_l4				; Small delay loop
	dec e
	jr nz,c_timeout_l2
	dec c
	jr nz,c_timeout_l1
	jp c_death

d_ouch:
	db 44,31,37,19,24,13,13,44,0
d_fallout:
	db 22,17,28,28,44,31,37,36,0
d_timeout:
	db 36,25,29,21,44,31,37,36,0
d_gameover:
	db 23,17,29,21,44,31,38,21,34,13,0
