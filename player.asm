; =============================================================================
; === PROCESS PLAYER MOVEMENT
; =============================================================================

c_process_player:
; This routine handles the basic player logic - inertia
; calculations and screen boundaries.
	call c_process_deltas_x				; Handle input in X-axis
	call c_process_deltas_y				; Handle input in Y-axid

; First, backup the old coordinates
	ld a,(v_player_currentx+1)
	ld (v_player_oldx),a				; Preserve only integer part

	ld a,(v_player_currenty+1)
	ld (v_player_oldy),a				; Preserve only integer part

; Now, add the deltas into the current X and Y values
; First, handle the Y coord.

	ld hl,(v_player_currenty)
	ld a,(v_player_deltay)
	ld d,0						; Set up DE for the addition
	bit 7,a
	jr z,c_process_player_l1			; Jump over if delta is positive

	dec d						; Flip sign

c_process_player_l1:
	ld e,a
	add hl,de
	ld (v_player_currenty),hl

; Now do the X coord.

	ld hl,(v_player_currentx)
	ld a,(v_player_deltax)
	ld d,0						; Set up DE for the addition
	bit 7,a
	jr z,c_process_player_l2			; Jump over if delta is positive

	dec d						; Flip sign

c_process_player_l2:
	ld e,a
	add hl,de
	ld (v_player_currentx),hl

; Handle screen boundaries
; Check left edge
	ld a,(v_player_currentx+1)
	cp 6
	jr nc,c_process_player_l3			; Jump if no collision
	ld a,6
	ld (v_player_currentx+1),a

c_process_player_l3:
; Check right edge
	cp 252
	jr c,c_process_player_l4			; Jump if no collision
	ld a,252
	ld (v_player_currentx+1),a

c_process_player_l4:
; Check bottom edge
	ld a,(v_player_currenty+1)
	cp 187
	jr c,c_process_player_l5			; Jump if no collision
	ld a,187
	ld (v_player_currenty+1),a

c_process_player_l5:
; Check top edge
	cp 38
	ret nc						; Return if no collision
	
	ld a,38
	ld (v_player_currenty+1),a
	ret


c_process_player_game:
; This routine handles the more advanced player logic which is not applicable
; to free-draw mode: checking for win condition, setting up sound and altering
; intertia according to surface.
	ld a,(v_player_currentx+1)
	cp 252						; Have we reached the right edge?
	jp nc,c_win					; We've won if so

; Handle sound
	ld hl,v_player_oldx
	ld a,(v_player_currentx+1)			; Get integer parts of old and new X coord
	xor (hl)					; Are they equal? (if no, moved since last frame)
	ld bc,e_player_move
	call nz,c_set_sound				; Set sound if not

	inc hl						; HL points to old Y coord now
	ld a,(v_player_currenty+1)			; Get integer part of new Y coord
	xor (hl)					; Are they equal? (if no, moved since last frame)
	ld bc,e_player_move				; (possible optimization, BC already set earlier and wasn't destroyed)
	call nz,c_set_sound				; Set sound if not

c_process_player_score:
; We are going to check the current block and see if it has been visited.
; If not, we will mark it as such and increment the score by 1 point.
	ld a,(v_player_currenty+1)			; Get Y coord
	and %11100000					; yyy00000
	rrca						; 0yyy0000
	rrca						; 00yyy000
	ld b,a

	ld a,(v_player_currentx+1)			; Get X coord
	and %11100000					; xxx00000
	rlca						; xx00000x
	rlca						; x00000xx
	rlca						; 00000xxx
	add a,b						; 00yyyxxx

	ld l,a
	ld h,0

	ld de,v_level-8					; -8 accounts for top of screen
	add hl,de					; Add base address for current level's data
	
	bit 7,(hl)					; Have we already visited this block?
	
	jr nz,c_process_player_floor			; Jump out if so
	
	set 7,(hl)					; Indicate the visit
	ld hl,v_score+5
	call c_score_inc				; Increment the score

c_process_player_floor:
; The next step is to check if the player has come away from the floor or not.
; If so, we will kill off the character.

; Find the attribute for the current pixel position.
	ld a,(v_player_currenty+1)
	and %11111000					; Keep row only
	ld l,a
	ld h,$16
	add hl,hl
	add hl,hl					; Perform multiply by 4

	ld a,(v_player_currentx+1)
	and %11111000					; Keep column only
	rrca
	rrca
	rrca

	or l						; Add the X coord
	ld l,a						; We now have our attribute address

	ld ix,d_fallout
	ld a,(hl)
	bit 6,a						; Are we on ground? (BRIGHT)
	jp z,c_fallout

; Now, we should adjust the inertia (probably should use the term
; friction for this part but I've written too many lines to change it now).
	and $38						; Keep only the PAPER colour

	cp $28						; On ice?
	jr z,c_process_player_ice			; Jump if so

c_process_player_ground:
	ld a,e_ground
	ld (v_inertia),a

	ret

c_process_player_ice:
; Elementary mistake - should've used XOR A to save a byte!!   :(
	ld a,e_ice
	ld (v_inertia),a
	
	ld bc,e_player_ice
	call c_set_sound				; Silence all rolling sounds

	ret

; =============================================================================
; === PROCESS DELTAS
; =============================================================================

c_process_deltas_x:
; Process any of the horizontal directional input
	ld a,(v_input)
	rrca
	rrca
	rrca						; Discard 3 bits

	rrca						; RIGHT
	ld hl,v_player_deltax
	jr nc,c_process_deltas_inc

	rrca						; LEFT
	jr nc,c_process_deltas_dec

	ret						; Nothing to process, return

c_process_deltas_y:
; Process any of the vertical directional input
	ld a,(v_input)
	rrca						; Discard 'fire' bit

	rrca						; UP
	ld hl,v_player_deltay
	jr nc,c_process_deltas_dec

	rrca						; DOWN
	jr nc,c_process_deltas_inc

	ret						; Nothing to process, return



c_process_deltas_dec:
	ld a,(v_inertia)
	ld d,a

	ld a,(hl)					; Get the delta value
	bit 7,a						; Is this negative?
	jr nz,c_process_deltas_dec_l1			; Jump forward if so

	sub d						; Subtract the delta constant
	ld (hl),a

	ret						; Return (no need for sign check)

c_process_deltas_dec_l1:
	sub d						; Subtract the delta constant
	ld (hl),a

	bit 7,a						; Check sign of number
	ret nz						; Return if still negative

	ld (hl),128					; Store maximum value if the delta overflowed
	ret



c_process_deltas_inc:
	ld a,(v_inertia)
	ld d,a

	ld a,(hl)					; Get the delta value
	bit 7,a						; Is this positive?
	jr z,c_process_deltas_inc_l1			; Jump forward if so

	add a,d						; Subtract the delta constant
	ld (hl),a

	ret						; Return (no need for sign check)

c_process_deltas_inc_l1:
	add a,d						; Subtract the delta constant
	ld (hl),a

	bit 7,a						; Check sign of number
	ret z						; Return if still positive

	ld (hl),127					; Store maximum value if the delta overflowed
	ret

; =============================================================================
; === PREPARE PLAYER
; =============================================================================

c_prepare_player:
; First, calculate the old X coordinate (for clearing)
	ld a,(v_player_oldx)
	sub 4						; Calculate old smiley position
	and %11111000
	rrca
	rrca
	rrca						; Keep only the byte-wise part of the X coordinate
	ld (v_player_oldscreenx),a

; Now calculate the coordinates for plotting the smiley

	ld a,(v_player_currenty+1)
	sub 4						; Drawing point will be at centre of smiley
	ld (v_player_smiley),a

	ld a,(v_player_currentx+1)
	sub 4
	ld (v_player_smilex),a

	ret

c_clear_player:
; This routine will return the small backup taken from under the smiley sprite
; to the screen so that the sprites under it can be cleared properly.
	ld a,(v_player_oldy)
	sub 4
	ld b,a						; Calculate old smiley Y position

	ld a,(v_player_oldscreenx)
	ld c,a						; Get left column of old X position

	ld de,d_spr8_backup
	call c_ld_spr8					; Copy the backup to the screen

	ret

; =============================================================================
; === DRAW PLAYER
; =============================================================================

c_draw_player:
; Now get the current coordinates
	ld a,(v_player_currentx+1)
	ld c,a
	ld a,(v_player_currenty+1)
	ld b,a

	call c_plot					; Plot the new point

; Calculate the coordinates for the smiling face

	ld a,(v_player_smiley)
	ld b,a						; Get Y coord
	ld a,(v_player_smilex)
	ld c,a						; Get X coord

	push bc						; Save coords

	and %11111000					; Keep the column only
	rrca
	rrca
	rrca
	ld c,a						; We now have the position of the sprite backup

	call c_back_spr8				; Back up the region
	pop bc						; Restore coords

	ld a,c
	and %00000111					; Keep the inter-column portion only
	add a,a
	add a,a
	add a,a
	add a,a						; Calculate offset to appropriate preshifted graphic

	ld l,a
	ld h,0
	ld de,g_player_0
	add hl,de					; Add base address of player graphics table
	ex de,hl

	ld a,c
	and %11111000					; Keep the column only
	rrca
	rrca
	rrca
	ld c,a						; We now have the column position of the graphic

	call c_or_spr8					; Place the player graphic onto the screen

	ret

; =============================================================================
; === PLAYER DATA
; =============================================================================

v_player_struct:
v_player_deltax:
	db 0
v_player_deltay:
	db 0
v_player_oldx:
	db 0
v_player_oldy:
	db 0
v_player_currentx:
	dw $0600
v_player_currenty:
	dw $a200
v_player_smilex:
	db 0
v_player_smiley:
	db 0
v_player_screenx:
	db 0
v_player_oldscreenx:
	db 0
v_player_frame:
	dw 0
v_inertia:
	db 3

; =============================================================================
; === PLAYER INERTIA CONSTANTS
; =============================================================================

e_ground: equ 3
e_ice: equ 0
