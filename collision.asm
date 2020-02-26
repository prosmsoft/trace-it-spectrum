; =============================================================================
; === COLLISION HANDLER
; =============================================================================

c_collision:
	ld hl,v_player_smilex				; Use X position of smile sprite
	ld b,(hl)
	inc b						; Player left row position
	inc hl
	ld d,(hl)					; Use Y position of smile sprite
	inc d						; Player top row position

	ld a,b
	add a,5
	ld c,a						; Player right row position

	ld a,d
	add a,5
	ld e,a						; Player bottom row position

	ld a,(v_enemyno)
	ld (v_enemytemp),a				; Make copy of enemy number (used as loop counter)
	ld ix,v_enemy_struct_start

c_collision_l1:
	ld a,(ix+o_enemy_type)				; Get the enemy type

	push bc
	push de						; Save the player's bounding box
	push ix						; Save the enemy structure pointer
	call c_collision_switch
	pop ix						; Restore enemy structure pointer

	ld de,13
	add ix,de					; Go to next enemy structure
	ld hl,v_enemytemp
	dec (hl)					; Decrement counter

	pop de
	pop bc						; Restore bounding box
	jr nz,c_collision_l1				; Jump back if there's still more enemies to process

	ret

c_collision_switch:
; Jumps into the appropriate collision routine.
	cp 1
	jp z,c_collide_flyer

	cp 2
	jp z,c_collide_crawler

	cp 3
	jp z,c_collide_pacer

	ret						; Fail-safe (don't do anything if type doesn't exist)
