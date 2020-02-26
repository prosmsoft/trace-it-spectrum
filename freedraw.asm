; =============================================================================
; === FREEDRAW
; =============================================================================

c_initialise_freedraw:
; Initialises the free-draw mode
	ld sp,e_stack_top
	ld hl,d_spr8_backup
	ld de,d_spr8_backup+1
	ld bc,15
	ld (hl),0
	ldir						; Clear out the sprite backup

	ld hl,d_playertemplate
	ld de,v_player_struct
	ld bc,15
	ldir						; Copy the player template in

	call c_clearscreen				; Clear the screen

	ld ix,d_freedraw_instructions
	ld bc,$0000
	call c_printstring				; Show free-draw instructions

c_freedraw_loop:
	call c_get_input

	ld bc,$bffe
	in a,(c)
	rrca						; Check enter bit
	jp nc,c_start					; Jump to menu if enter is pressed

	call c_process_player				; Do basic delta calculation and collision detection
	call c_prepare_player				; Prepare player graphics

	halt

	call c_clear_player				; Remove previous player frame
	call c_draw_player				; Draw new player frame

	jr c_freedraw_loop

; =============================================================================
; === FREEDRAW INSTRUCTIONS
; =============================================================================

d_freedraw_instructions:
	db 44,44,37,35,21,44,27,21,41,35,44,36,31,44,20,34,17,39,44,31,30,44,35,19,34,21,21,30,44,44,44,44,32,34,21,35,35,44,21,30,36,21,34,44,36,31,44,34,21,36,37,34,30,44,36,31,44,36,25,36,28,21,44,0
