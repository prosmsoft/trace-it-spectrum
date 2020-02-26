; =============================================================================
; === PRINT TITLE
; =============================================================================

c_printtitle:
; This routine consists of two loops: the block loop and the
; empty loop. The title is compressed with a sort of RLE encoding,
; where runs of characters are interspersed with runs of empty
; characters.

; First, the character loop
	ld a,(ix+0)				; Get number of characters
	or a
	ret z					; Return if end-of-file
	
	inc ix					; Get to character data
	ld l,a					; L is our character counter

c_printtitle_l1:
	push ix
	pop de					; Move pointer into source character pointer

	push bc					; Preserve the coords
	push hl
	call c_print8char			; Print the character
	pop hl
	pop bc					; Retrieve the coords
	
	push de
	pop ix					; Restore pointer+8

	inc c					; Next column
	ld a,23
	cp c					; Have we reached the end of the row?
	jr nz,c_printtitle_l2

	ld c,8					; Reset column counter
	inc b					; Next row

c_printtitle_l2:
	dec l					; End of run?
	jr nz,c_printtitle_l1			; Jump back if not
	
	ld a,(ix+0)				; Get the next byte
	or a
	ret z					; Return if end-of-file

	add a,c					; Skip over empty bytes
	ld c,a					; Takes advantage of fact that empty runs never spill over row
						; so we don't need to check for overflow
	
	inc ix
	
	jr c_printtitle				; Jump back to character loop

; =============================================================================
; === TITLE GRAPHICS
; =============================================================================

d_title:
	incbin 'title.bin'			; Compressed title data
