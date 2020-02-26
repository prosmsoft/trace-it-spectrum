; =============================================================================
; === PLAY SOUND
; =============================================================================

c_sound:
; Plays sound with the stored delay value
	ld a,(v_sound)				; Get delay value
	or a					; Is there silence?
	ld (v_sound_priority),a			; If there's silence, this resets the sound priority
						; (This allows for the ice to silence the rolling)
	ret z					; Don't play tone if there is none

c_sound_noset:
; Entry point for 'forced' sound (during end of level wiping effect)
; Inputs: A  - Delay value
	ld c,a					; Save frequency for later

	ld d,6					; 6 iterations of delay

	ld a,7					; Load accumulator with border colour

if debug=1
	ld a,3					; (This lets you check how long the sound takes
						; each frame if you are debugging the program)
endif

c_sound_l1:
	xor 16					; Toggle SPEAKER bit
	out (254),a				; Output to ULA
	ld b,c					; Get frequency

	djnz $					; Delay for set time
	dec d					; More iterations left?
	jr nz,c_sound_l1			; Jump back if so

; (Realised whilst writing extended comments for source release that this EI
; instruction is redundant, as we never disabled interrupts in the first place)
	ei

	xor a					; Zero out A
	ld (v_sound),a				; Disable sound
	ld (v_sound_priority),a			; Reset sound priority
	ret

; =============================================================================
; === SET SOUND
; =============================================================================

c_set_sound:
; Set a sound if the priority given is higher than that currently set
; Inputs: B  - Sound delay
;         C  - Sound priority
	ld hl,v_sound_priority
	ld a,(hl)				; Get current sound priority
	cp c					; Higher priority?
	ret nc					; Return if not

	ld (hl),c				; Load priority
	dec hl
	ld (hl),b				; Load sound delay
	ret

; =============================================================================
; === PLAY MUSIC
; =============================================================================

c_musicplayer:
; Inputs: BC - Start of music data
	ld a,56
	ld (v_bordcr),a					; Load border colour into BORDCR system variable

; Load the pitch (437500 / frequency - 30.125)
	ld a,(bc)					; Load in the value of L
	ld l,a
	inc bc
	ld a,(bc)					; Load in the value of H
	ld h,a
	inc bc

	or l						; Have we reached the end of the data?
	ret z						; Return if so

; Load the duration (frequency * seconds)
	ld a,(bc)
	ld e,a
	inc bc
	ld a,(bc)
	ld d,a
	inc bc

	push bc						; Preserve our data pointer
	call c_rombeep					; Play the note
	pop bc						; Retrieve our data pointer
	jr c_musicplayer				; Loop back to play next note

; =============================================================================
; === SOUND VARIABLES
; =============================================================================

v_sound:
	db 0
v_sound_priority:
	db 0
v_bordcr: equ 23624

; =============================================================================
; === MUSIC DATA
; =============================================================================

d_win_music:
	dw 1223, 35
	dw 908, 47
	dw 715, 59
	dw 596, 140
	dw 715, 59
	dw 596, 280
	dw 0

; =============================================================================
; === SOUND CONSTANTS
; =============================================================================

e_player_move:		equ $2004
e_crawler_bounce:	equ $3808
e_flyer_bounce:		equ $5008
e_player_ice:		equ $0005
c_rombeep:		equ 949
