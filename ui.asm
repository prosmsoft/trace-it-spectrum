; =============================================================================
; === DRAW THE USER INTERFACE
; =============================================================================

c_draw_ui:
	call c_clearscreen

; Now we set the playfield colours
	ld hl,22528+128
	ld de,22528+129
	ld bc,639
	ld a,(v_blank_attr)
	ld (hl),a
	ldir

; Set up the score colours
	ld hl,22528
	ld bc,$2003
	ld a,$39
	call c_attrfill

; Now print the UI
	ld ix,d_topbar

	ld bc,$0000
	call c_printstring				; Print top bar of information
	inc ix
	ld bc,$020c
	call c_printstring				; Print TIME header

	call c_printscore				; Print scores

	ld ix,v_lives
	ld bc,$001f
	call c_printstring				; Show lives counter

	ld ix,v_time
	ld bc,$0211
	call c_printstring				; Show time counter

	ret

; =============================================================================
; === DRAW THE SCORES
; =========================================================================

c_printscore:
	ld ix,v_score
	ld bc,$0006
	call c_printstring				; Print score

	ld ix,v_hiscore
	ld bc,$0011
	call c_printstring				; Print hi-score
	ret
