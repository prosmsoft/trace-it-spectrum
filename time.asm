; =============================================================================
; === DECREMENT THE TIME REMAINING
; =========================================================================

c_time_decrement:
	ld hl,v_frameticker				; Time to decrement the ticker?
	dec (hl)
	ret nz						; Return if not

	ld (hl),10					; Reload frame ticker
	dec hl
	dec hl						; Two unnecessary DECs
	ld a,0+(v_time-1)%256
	ld ix,v_time
	ld bc,$0211
	ld hl,v_time+2					; Units digit

c_time_decrement_l1:
	dec (hl)					; Decrement the place
	jp nz,c_printstring				; Exit and print time if counter hasn't rolled over

c_time_decrement_l2:
	ld (hl),10					; Reload digit
	dec hl						; Up to next digit
	cp l						; Is this the last digit?
	jr nz,c_time_decrement_l1			; Loop round if not

; Now we're out of time, so trigger a player death
	ld ix,d_notime
	call c_printstring				; Print all zeroes for time

	ld hl,22528+12+64
	ld bc,$0801
	ld a,$0f
	call c_attrfill					; Flashing blue and white

	ld ix,d_timeout
	jp c_timeout					; Trigger 'time out' death

; =============================================================================
; === TIME DATA & VARIABLES
; =========================================================================

d_notime:
	db 1,1,1,0					; 000

v_time:
	db 4,6,1,0
v_frameticker:
	db 10

d_timetemplate:
	db 4,6,1,0,10
