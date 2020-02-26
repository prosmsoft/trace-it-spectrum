; =============================================================================
; === WIN ROUTINE
; =============================================================================

c_win:
	ld bc,d_win_music
	call c_musicplayer				; Play 'CHARGE!'

	call c_clear_player				; Remove player graphics
	call c_remove_enemies				; Remove enemy graphics

; Now we blank out the playfield column-by-column
	ld hl,22528+128					; Offset to playfield
	ld a,(v_blank_attr)

	ex af,af'
	ld a,$20					; Load column counter

c_win_l1:
	ex af,af'
	ld bc,$0113					; 1x19
	push hl						; Save attribute pointer
	call c_attrfill					; Fill attribute block
	pop hl						; Restore attribute pointer
	inc l						; Move to next column

; (NOTE: The following two lines of PUSH instructions are completely
; unneccesary and quite dangerous in fact. This would eventually crash the
; game if it weren't for the fact that the stack gets reset on each level.)

	push bc
	push de

	ex af,af'
	push af						; Save counter temporarily
	add a,a
	call c_sound_noset				; Play small click sound
	pop af						; Restore counter

	halt
	halt						; Wait for 2 frames (0.04 secs)
	dec a
	jr nz,c_win_l1

; Now print the score bonus
	ld ix,d_bonus
	ld bc,$020b
	call c_printstring				; Print 'BONUS' string

	ld hl,22528+64+19
	ld (hl),$3f					; Cover last digit of time

	ld b,100
	halt
	djnz $-1					; Wait two seconds

; Now, add the bonus to the score
	ld hl,v_score+5					; Units digit of score
	ld de,v_time+1					; Tens digit of time

	ld a,(de)
	dec a						; Adjust for character set offset
	ld b,a
	jr z,c_win_score_l1				; Don't do adding loop if digit is zero

; We just add the points one-by-one so that any
; extra lives aren't missed.
	ld hl,v_score+5					; Units digit of score
	call c_score_inc
	djnz $-6

c_win_score_l1:
	ld de,v_time+0					; Hundreds digit of time

	ld a,(de)
	dec a
	ld b,a
	jr z,c_win_score_l2				; Don't add if zero

	ld hl,v_score+4					; Tens digit of score
	call c_score_inc
	djnz $-6

c_win_score_l2:
; Now we increment the level number and handle any looping
	ld a,(v_levelno)
	inc a						; Go to next level
	ld (v_levelno),a
	cp 15						; Have we finished the last level
	jr nz,c_win_score_exit				; Jump if not

	ld a,e_round_secondtime
	ld (v_levelno),a				; Move to our looping point if we've finished the game

	ld a,2
	ld (v_deltax),a					; Floaters now go double speed horizontally

c_win_score_exit:
	jp c_initialise_level				; Go back to initialise the new level


; =============================================================================
; === REMOVE ENEMY GRAPHICS
; =============================================================================

c_remove_enemies:
	ld a,(v_enemyno)
	ld (v_enemytemp),a				; Make copy of enemy number (used as loop counter)
	ld ix,v_enemy_struct_start

c_remove_enemies_l1:
	ld (ix+o_enemy_oldframe),0
	ld (ix+o_enemy_oldframe+1),$40			; Prevents traces from old frame being drawn on screen
	ld a,(ix+o_enemy_type)

	push ix						; Preserve enemy structure pointer
	call c_remove_enemies_switch
	pop ix						; Retrieve structure pointer

	ld de,13
	add ix,de					; Next enemy structure
	ld hl,v_enemytemp
	dec (hl)					; Decrement temporary counter
	jr nz,c_remove_enemies_l1			; Jump back if there's still more enemies to process

	ret

c_remove_enemies_switch:
	cp 1
	jp z,c_draw_flyer
	cp 2
	jp z,c_draw_crawler
	cp 3
	jp z,c_draw_pacer

	ret

; =============================================================================
; === WIN DATA
; =============================================================================

d_bonus:
	db 18,31,30,37,35,0

e_round_secondtime: equ 5
