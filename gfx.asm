; =============================================================================
; === CALCULATE CHARACTER ADDRESS
; =============================================================================

c_calccharaddress:
; Inputs:  B - Y coord
;          C - X coord
	ld a,b						; Make a copy of the Y coordinate
	and 7						; Get the inner segment row
	rrca
	rrca
	rrca						; Rotate to the correct position
	add a,c						; Add the X coordinate
	ld l,a
	ld a,b
	and 24						; Get the segment
	or 64						; Add offset of 16384 to address
	ld h,a
	ret

; =============================================================================
; === PRINT 8x8 CHARACTER
; =============================================================================

c_print8char:
; Inputs:
	call c_calccharaddress
	ld b,8
c_print8char_l1:
	ld a,(de)					; Load the next byte
	ld (hl),a					; Place it on the screen
	inc h						; Go to the next row
	inc de						; Go to the next byte
	djnz c_print8char_l1				; Jump back if there is more to copy
	ret

; =============================================================================
; === PRINT 8x6 CHARACTER
; =============================================================================

c_print6char:
	call c_calccharaddress				; Find character address
	ld b,6
	ld (hl),0					; Set top line as empty
	inc h
	call c_print8char_l1				; Copy 6 lines of graphics data
	ld (hl),0					; Set bottom as empty
	ret

; =============================================================================
; === PRINT STRING
; =============================================================================

c_printstring:
; Inputs:  B - Y coord
;          C - X coord
;         IX - Null-terminated strings
	ld a,(ix+0)					; Get the next byte
	or a						; Is it NULL?
	ret z						; Return if NULL

	ld l,a						; Put A into the low byte of HL
	ld h,0						; Zero the high byte of HL
	add hl,hl
	push hl
	pop de
	add hl,hl
	add hl,de					; Get the address of the character we want
	ld de,d_uifont-6
	add hl,de					; Add the offset to the custom font
	ex de,hl					; Get the address in the right pair

	push bc						; Preserve the coords
	call c_print6char				; Print the character
	pop bc						; Retrieve the coords

	inc ix						; Go to the next byte
	inc c						; Go to the next column
	ld a,224

	and c						; Have we gone out of the screen?
	jr z,c_printstring				; Jump back if not
	ld c,0						; Reset the X coord
	inc b						; Go to the next row
	jr c_printstring				; Jump back to the loo

; =============================================================================
; === CLEAR SCREEN
; =============================================================================

c_clearscreen:
	ld hl,16384
	ld de,16385
	ld bc,6143
	ld (hl),0
	ldir

	inc hl
	inc de
	ld bc,767
	ld (hl),$38
	ldir

	ld a,7
	out (254),a
	ret

; =============================================================================
; === FILL RECTANGLE WITH ATTRIBUTES
; =============================================================================

c_attrfill:
; Inputs:  A - Attribute
;          B - Rows to fill
;          C - Columns to fill
;         HL - Initial address
; Inputs: A = Attribute, C = Rows to fill, B = Columns to fill, HL = Intial address
	ld d,0						; Clear D to prevent wrong results later
	
c_attrfill_l1:	
	ld e,b						; Make a backup of the row length
	
c_attrfill_l2:	
	ld (hl),a					; Copy the attribute
	inc hl						; Go to the next attribute
	djnz c_attrfill_l2				; Jump back if the bounds have been reached
	
c_attrfill_l3:	
	ld b,e						; Copy back to the original location
	ld e,32						; Go to the next row
	add hl,de	
	ld e,b	
	
	sbc hl,de					; Take away the fill length to get the next row from the original X coord
	dec c	
	jr nz,c_attrfill_l2				; Decrement the height counter and jump back if there is more to fill
	ret						; Return to the main program


; =============================================================================
; === OR 16x8 SPRITE
; =============================================================================

c_or_spr8:
; ORs a 16x8 sprite onto the screen at the coords specified
; Inputs:  B - Y coord
;          C - X coord
;         DE - Sprite address

	di						; Disable interrupts as stack will be changed

	ld l,b						; Y co-ordinate
	ld h,0
	ld a,c
	add hl,hl
	ld bc,d_row_lookup
	add hl,bc
	ld c,a

	push hl
	pop ix

	ld (c_or_spr8_exit+1),sp			; Save stack pointer
	ex de,hl
	ld sp,hl					; Put the sprite address into the stack pointer

	ld b,2						; 2 loops of the routine

c_or_spr8_l1:
; ORing loop

; WORD 1
	ld a,(ix+0)
	ld h,(ix+1)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de						; Get data
	ld a,e						; Byte 1
	or (hl)
	ld (hl),a					; Blit to screen
	inc l

	ld a,d						; Byte 2
	or (hl)
	ld (hl),a					; Blit to screen


; WORD 2
	ld a,(ix+2)
	ld h,(ix+3)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de						; Get data
	ld a,e						; Byte 1
	or (hl)
	ld (hl),a					; Blit to screen
	inc l

	ld a,d						; Byte 2
	or (hl)
	ld (hl),a					; Blit to screen


; WORD 3
	ld a,(ix+4)
	ld h,(ix+5)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de						; Get data
	ld a,e						; Byte 1
	or (hl)
	ld (hl),a					; Blit to screen
	inc l

	ld a,d						; Byte 2
	or (hl)
	ld (hl),a					; Blit to screen


; WORD 4
	ld a,(ix+6)
	ld h,(ix+7)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de						; Get data
	ld a,e						; Byte 1
	or (hl)
	ld (hl),a					; Blit to screen
	inc l

	ld a,d						; Byte 2
	or (hl)
	ld (hl),a					; Blit to screen

	ld de,8
	add ix,de

	djnz c_or_spr8_l1

c_or_spr8_exit:
	ld sp,0						; Restore stack pointer (self-modifying code)
	ei
	ret

; =============================================================================
; === LD 16x8 SPRITE
; =============================================================================

c_ld_spr8:
; LDs a 16x8 sprite onto the screen at a Y co-ordinate
; Inputs:  B - Y coord
;          C - X coord
;         DE - Sprite address

	di

	ld l,b						; Y co-ordinate
	ld h,0
	ld a,c
	add hl,hl
	ld bc,d_row_lookup
	add hl,bc
	ld c,a

	push hl
	pop ix

	ld (c_ld_spr8_exit+1),sp
	ex de,hl
	ld sp,hl					; Put the image address into the stack pointer

	ld b,2

c_ld_spr8_l1:
; ORing loop

; WORD 1
	ld a,(ix+0)
	ld h,(ix+1)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de

	ld a,e						; Byte 1
	ld (hl),a
	inc l

	ld a,d						; Byte 2
	ld (hl),a

; WORD 2
	ld a,(ix+2)
	ld h,(ix+3)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de

	ld a,e
	ld (hl),a					; Byte 1
	inc l

	ld a,d
	ld (hl),a					; Byte 2

; WORD 3
	ld a,(ix+4)
	ld h,(ix+5)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de

	ld a,e
	ld (hl),a					; Byte 1
	inc l

	ld a,d
	ld (hl),a					; Byte 2

; WORD 4
	ld a,(ix+6)
	ld h,(ix+7)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de

	ld a,e
	ld (hl),a					; Byte 1
	inc l

	ld a,d
	ld (hl),a					; Byte 2

	ld de,8
	add ix,de

	djnz c_ld_spr8_l1

c_ld_spr8_exit:
	ld sp,0
	ei
	ret

; =============================================================================
; === BACKUP 16x8 SPRITE
; =============================================================================

c_back_spr8:
; ORs a 16x8 sprite onto the screen at a Y co-ordinate, backs up the old data
; Inputs:  B - Y coord
;          C - X coord
	ld l,b						; Y co-ordinate
	ld h,0
	ld a,c
	add hl,hl
	ld bc,d_row_lookup
	add hl,bc
	ld c,a

	push hl
	pop ix

	ld de,d_spr8_backup

	ld b,8

c_back_spr8_l1:
	ld a,(ix+0)
	ld h,(ix+1)					; Get row address

	add a,c
	ld l,a						; Add X offset

	ld a,(hl)
	ld (de),a
	inc l
	inc de						; Increment screen and sprite pointers

	ld a,(hl)
	ld (de),a
	inc de						; Increment screen and sprite pointers

	inc ix
	inc ix
	djnz c_back_spr8_l1

	ret

d_spr8_backup:
	ds 16						; Reserve space for screen backup

; =============================================================================
; === XOR 16x16 SPRITE
; =============================================================================

c_xor_spr16:
; XORs a 16x16 sprite onto the screen at a Y co-ordinate
; Inputs:  B - Y coord
;          C - X coord
;         DE - Sprite address
	di

	ld l,b						; Y co-ordinate
	ld h,0
	ld a,c
	add hl,hl
	ld bc,d_row_lookup
	add hl,bc
	ld c,a

	push hl
	pop ix

	ld (c_xor_spr16_exit+1),sp
	ex de,hl
	ld sp,hl				; Put the image address into the stack pointer

	ld b,4

c_xor_spr16_l1:
; XORing loop

; WORD 1
	ld a,(ix+0)
	ld h,(ix+1)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de

	ld a,e
	xor (hl)
	ld (hl),a					; Byte 1
	inc l

	ld a,d
	xor (hl)
	ld (hl),a					; Byte 2

; WORD 1
	ld a,(ix+2)
	ld h,(ix+3)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de

	ld a,e
	xor (hl)
	ld (hl),a					; Byte 1
	inc l

	ld a,d
	xor (hl)
	ld (hl),a					; Byte 2

; WORD 1
	ld a,(ix+4)
	ld h,(ix+5)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de

	ld a,e
	xor (hl)
	ld (hl),a					; Byte 1
	inc l

	ld a,d
	xor (hl)
	ld (hl),a					; Byte 2

; WORD 1
	ld a,(ix+6)
	ld h,(ix+7)					; Get row address

	add a,c
	ld l,a						; Add X offset

	pop de

	ld a,e
	xor (hl)
	ld (hl),a					; Byte 1
	inc l

	ld a,d
	xor (hl)
	ld (hl),a					; Byte 2

	ld de,8
	add ix,de

	djnz c_xor_spr16_l1

c_xor_spr16_exit:
	ld sp,0
	ei
	ret

; =============================================================================
; === XOR 24x16 SPRITE
; =============================================================================

c_xor_spr24:
; Inputs:  B - Y coord
;          C - X coord
;         DE - Sprite address
	di

	ld l,b
	ld h,0
	ld a,c
	add hl,hl
	ld bc,d_row_lookup
	add hl,bc
	ld c,a

	push hl
	pop ix

	ld (c_xor_spr24_exit+1),sp
	ex de,hl
	ld sp,hl				; Put the image address into the stack pointer

	ld b,4

c_xor_spr24_l1:
	ld a,(ix+0)
	ld h,(ix+1)

	add a,c
	ld l,a					; Row address formed

; WORD 1
	pop de

	ld a,e
	xor (hl)
	ld (hl),a
	inc l

	ld a,d
	xor (hl)
	ld (hl),a
	inc l

; WORD 2
	pop de

	ld a,e
	xor (hl)
	ld (hl),a				; End of pixel row

	ld a,(ix+2)
	ld h,(ix+3)

	add a,c
	ld l,a					; Row address formed

	ld a,d
	xor (hl)
	ld (hl),a
	inc l

; WORD 3
	pop de
	ld a,e
	xor (hl)
	ld (hl),a
	inc l

	ld a,d
	xor (hl)
	ld (hl),a

; WORD 4
	ld a,(ix+4)
	ld h,(ix+5)

	add a,c
	ld l,a					; Row address formed

	pop de

	ld a,e
	xor (hl)
	ld (hl),a
	inc l

	ld a,d
	xor (hl)
	ld (hl),a
	inc l

; WORD 5
	pop de

	ld a,e
	xor (hl)
	ld (hl),a				; End of pixel row

	ld a,(ix+6)
	ld h,(ix+7)

	add a,c
	ld l,a					; Row address formed

	ld a,d
	xor (hl)
	ld (hl),a
	inc l

; WORD 6
	pop de
	ld a,e
	xor (hl)
	ld (hl),a
	inc l

	ld a,d
	xor (hl)
	ld (hl),a

	ld de,8
	add ix,de

	djnz c_xor_spr24_l1

c_xor_spr24_exit:
	ld sp,0
	ei
	ret

; =============================================================================
; === PLOT
; =============================================================================

c_plot:
; Inputs:  B - Y coord
;          C - X coord
	ld l,b						; Y co-ordinate
	ld h,0

	add hl,hl
	ld de,d_row_lookup
	add hl,de					; Calculate lookup index

	ld e,(hl)
	inc hl
	ld d,(hl)					; Get row address
	ex de,hl

	ld a,c

	and %11111000					; Keep the lowest 3 bits only
	rrca
	rrca
	rrca
	add a,l						; Add X coord
	ld l,a						; Now we have our address

	ld a,c
	and %00000111
	add a,d_plot%256
	ld d,d_plot/256
	ld e,a
	
	ld a,(de)					; Get bit pattern
	or (hl)
	ld (hl),a

	ret

d_plot:
if ($%256) GE 249
	.ERROR Please alter the placement of d_plot in memory! It cannot be here!
endif
	db %10000000
	db %01000000
	db %00100000
	db %00010000
	db %00001000
	db %00000100
	db %00000010
	db %00000001

; =============================================================================
; === SCREEN ROW LOOKUP TABLE
; =============================================================================

d_row_lookup:
	incbin 'lookup.bin'
