; =============================================================================
; === GET INPUT
; =============================================================================

c_get_input:
; This routine gets the input and sets it up as the following: 111LRDUU
	ld a,(v_type)
	cp 2						; Is Kempston in use?
	jr z,c_get_input_kempston			; Jump if so

	ld d,$ff
	ld a,(v_left)
	call c_test_key					; Get value of left key
	rl d

	ld a,(v_right)
	call c_test_key					; Get value of right key
	rl d

	ld a,(v_down)
	call c_test_key					; Get value of down key
	rl d

	ld a,(v_up)
	call c_test_key					; Get value of up key
	rl d
	rl d

	ld a,d
	ld (v_input),a					; Store input

	ret


c_get_input_kempston:
	ld d,$ff
	ld a,2						; Check left bit
	call c_test_kempston
	rl d

	ld a,1						; Check right bit
	call c_test_kempston
	rl d

	ld a,4						; Check down bit
	call c_test_kempston
	rl d

	ld a,8						; Check up bit
	call c_test_kempston
	rl d
	rl d

	ld a,d
	ld (v_input),a					; Store input
	ret

; =============================================================================
; === TEST JOYSTICK
; =============================================================================

c_test_kempston:
; Inputs: A  - bit mask
	ld e,a						; Save mask in E
	ld bc,31					; Kempston joystick port
	in a,(c)					; Get input

	and e						; Keep only relevant direction
	add a,$ff					; Sets carry if direction is activated
	ccf						; Invert to match keyboard output
	ret

; =============================================================================
; === TEST KEY
; =============================================================================

c_test_key:
; Inputs: A  - rrrmmmmm
; where r is row and m is key mask
	ld e,a						; Save key
	and %11100000					; Keep row only

							; rrr-----
	rlca						; rr-----r
	rlca						; r-----rr
	rlca						; -----rrr

	add a,d_plot%256				; Add offset into bit table
	ld l,a
	ld h,d_plot/256
	ld a,(hl)
	cpl						; Invert to form high byte of port address

	ld b,a
	ld c,$fe

	ld a,e
	and %00011111					; Form bit mask
	ld e,a

	in a,(c)					; Read keyboard

	and e						; Keep only the relevant key
	add a,$ff					; Carry reset if key pressed
	ret

; =============================================================================
; === INPUT VARIABLES
; =============================================================================

v_input:
	db 0
v_type:
	db 0						; 0 - QAOP
							; 1 - Interface II
							; 2 - Kempston

v_key_struct:
v_left:
	db %01000010					; Q
v_right:
	db %01000001					; A
v_up:
	db %10100001					; O
v_down:
	db %11000001					; P

; =============================================================================
; === INPUT DATA
; =============================================================================

d_qaop:
	db %01000010					; Q
	db %01000001					; A
	db %10100001					; O
	db %11000001					; P

d_sinclair:
	db %01110000
	db %01101000
	db %01100010
	db %01100100
