; =============================================================================
; === INCREMENT SCORE
; =============================================================================

c_score_inc:
	ld a,11						; 1 character past top limit
	inc (hl)					; Increment the digit
	cp (hl)
	ret nz						; Return if no overflow has occurred
	
	ld (hl),1					; Reset digit
	dec hl						; Move up one digit
	ld a,0+(v_score+2)%256
	cp l						; Is this the thousands digit?
	jr z,c_extra_life_prepare			; Set up an extra life if so
	
	ld a,0+(v_score-1)%256
	cp l						; Have we pushed past the last digit?
	ret z						; Stop here if we've overflowed the score
	jr c_score_inc

c_extra_life_prepare:
	ld de,c_extra_life
	push de						; Return into 'extra life' routine after score has been handled
	jr c_score_inc					; Back to loop

; =============================================================================
; === ADD EXTRA LIFE
; =============================================================================

c_extra_life:
; Thinking about it now, I was a bit mean to add the extra life every 1000 points,
; as a full playthrough of all 15 levels will only net you around 600.
	ld a,(v_lives)
	inc a
	cp 11						; Overflowed?
	ret nc						; Jump out if so
	
	ld (v_lives),a
	ld bc,$001f
	ld ix,v_lives					; Update the lives counter
	jp c_printstring				; Show the updated lives counter

; =============================================================================
; === COMPARE HI-SCORE WITH SCORE
; =============================================================================

c_compare_scores:
	ld hl,v_score
	ld de,v_hiscore
	ld b,6						; 6 digits to compare

c_compare_scores_l1:
; First, check if score digit is greater than or equal to hi-score digit
	ld a,(de)					; Get hi-score digit
	dec a						; Ensures that carry is set by CP even if digits are equal
	cp (hl)						; Subs. score from hiscore
	ret nc						; Return if hi-score larger

; Now, check if score digit is greater than hi-score digit. If so, we can
; go straight to copying the score into the hi-score.
	inc a						; Ensures that carry is reset by CP if digits are equal
	cp (hl)						; Is score greater than hi-score?
	jr c,c_compare_scores_l2			; Copy score if so
	
	inc hl
	inc de						; Next digit of both scores
	djnz c_compare_scores_l1			; Loop back if digits are left.
	
c_compare_scores_l2:
; Score is larger than hiscore, so we copy it across.
	ld hl,v_score
	ld de,v_hiscore
	ld bc,6
	ldir
	
	ret
