; =============================================================================
; === MAIN GAME
; =============================================================================

c_initialise_game:
; Initialises the game and sets up session variables
	ld sp,e_stack_top

	ld hl,d_sessiontemplate
	ld de,v_score
	ld bc,11
	ldir						; Reset score and lives

c_initialise_level:
; First, set up variables
	ld sp,e_stack_top
	ld hl,d_spr8_backup
	ld de,d_spr8_backup+1
	ld bc,15
	ld (hl),0
	ldir						; Clear out the sprite backup

	ld hl,v_enemyno
	ld de,v_enemyno+1
	ld bc,40
	ld (hl),0
	ldir						; Clear out enemy buffer

	ld hl,d_playertemplate
	ld de,v_player_struct
	ld bc,15
	ldir						; Set up player data

	ld hl,d_timetemplate
	ld de,v_time
	ld bc,5
	ldir						; Set up time counter

	call c_compare_scores				; In case bonus from previous round pushed score over hi

; Now, set up the level-specific details
; First, set up the palette for this level
	ld a,(v_levelno)
	and 3
	ld l,a
	add a,a
	add a,l						; x3

	ld l,a
	ld h,0
	ld de,d_pal1
	add hl,de					; Add offset into palette table

	ld de,v_ground_attr
	ld bc,3
	ldir						; Copy palette

; We can now decompress the level from its packed form
	ld a,(v_levelno)

	ld l,a
	ld h,0
	add hl,hl					; x2
	add hl,hl					; x4
	ld e,l
	ld d,h

	add hl,hl					; x8
	add hl,hl					; x16
	add hl,de					; x20

	ld de,d_levels
	add hl,de					; Form address to level

	call c_expand_level

; Now, we draw the text elements
	call c_draw_ui					; Draw the score and lives

	ld a,(v_levelno)
	ld l,a
	ld h,0
	add hl,hl
	ld de,d_levelnames
	add hl,de					; Add offset into level name pointer table

	ld e,(hl)
	inc hl
	ld d,(hl)					; Load string address
	push de
	pop ix						; Move string address into IX

	ld c,(ix+0)					; Get X position of string
	inc ix
	ld b,23
	call c_printstring				; Print level name

	call c_render_level				; Draw the level geometry

	ld hl,v_level+32				; Address to starting cell
	set 7,(hl)					; Mark as visited, so that we don't score for this cell

	ld b,25
	halt
	djnz $-1					; Wait for half a second

	ld a,$ff
	ld (v_input),a					; Stops any input from being taken

	call c_process_player
	call c_process_player_game
	call c_prepare_player
	call c_prepare_enemies
	call c_clear_player
	call c_draw_enemies
	call c_draw_player

	ld b,25
	halt
	djnz $-1					; Wait for half a second

; =============================================================================
; === GAME LOOP
; =============================================================================

c_game_loop:
	call c_get_input
	call c_process_player
	call c_process_player_game
	call c_process_enemies

	call c_prepare_player
	call c_prepare_enemies

	call c_collision

	call c_compare_scores
	call c_printscore
	call c_time_decrement

	call c_sound

if debug=1
	ld a,7
	out ($fe),a					; White border for remaining time

	ld bc,$bffe
	in a,(c)
	rrca
	jp nc,c_win					; End level if ENTER is pressed

endif

	halt

if debug=1
	xor a
	out ($fe),a					; Black border for graphics
endif

	call c_clear_player
	call c_draw_enemies
	call c_draw_player

if debug=1
	ld a,1
	out ($fe),a					; Blue border for processing
endif

	jr c_game_loop
