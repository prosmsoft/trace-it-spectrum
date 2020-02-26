; +-----------------------------+
; |  T  R  A  C  E     I  T  !  |
; |     For 16K ZX Spectrum     |
; |  (C) PROSM Software, 2020   |
; +-----------------------------+

org $5e00

; =============================================================================
; === EQUATES
; =============================================================================

debug: equ 0						; Set to 1 for border timing & skip level cheat
e_stack_top: equ $5dff

; =============================================================================
; === INITIALISATION
; =============================================================================

c_start:
; Title
	ld sp,e_stack_top				; Reset stack
	
	call c_clearscreen
	ld ix,d_title
	ld bc,$0408
	call c_printtitle				; Draw title graphic to screen

	ld ix,d_titlestrings
	ld bc,$0b09
	call c_printstring				; 1 - KEYBOARD
	
	inc ix
	ld bc,$0c09
	call c_printstring				; 2 - INTERFACE 2
	
	inc ix
	ld bc,$0d09
	call c_printstring				; 3 - KEMPSTON
	
	inc ix
	ld bc,$0f09
	call c_printstring				; 4 - START GAME
	
	inc ix
	ld bc,$1009
	call c_printstring				; 5 - FREE DRAW
	
	inc ix
	ld bc,$1504
	call c_printstring				; WRITTEN BY JOHN CONNOLLY
	
	inc ix
	ld bc,$1607
	call c_printstring				; PROSM SOFTWARE, 2020
	
	ld de,d_copyright_symbol
	ld bc,$1605
	call c_print8char				; Print (C) symbol on bottom line

; Now apply screen attributes	
	ld hl,22528+7+(22*32)
	ld bc,$0501
	ld a,$56
	call c_attrfill					; Make PROSM text yellow on red
	
	ld a,(v_type)					; 00000xxx
	rrca						; x00000xx
	rrca						; xx00000x
	rrca						; xxx00000
	
	ld l,a
	ld h,0
	ld de,22528+9+(11*32)
	add hl,de
	ld (hl),$87					; Flash the active control scheme
	
	ld b,25
	halt
	djnz $-1					; Halt for .5 seconds, crude form of key debouncing

c_title_key1:
; Now, we check the key input for the 1-5 row
	ld bc,$f7fe
	in a,(c)
	
	rrca						; Key 1
	jr c,c_title_key2				; Next key if 1 not pressed

	ld hl,d_qaop
	ld de,v_key_struct
	ld bc,4
	ldir						; Set keyboard control scheme
	
	xor a
	ld (v_type),a					; Type 0
	
	jp c_start

c_title_key2:
	rrca						; Key 2
	jr c,c_title_key3				; Next key if 2 not pressed
	
	ld hl,d_sinclair
	ld de,v_key_struct
	ld bc,4
	ldir						; Set Interface II control scheme
	
	ld a,1
	ld (v_type),a					; Type 1
	
	jp c_start

c_title_key3:
	rrca						; Key 3
	jr c,c_title_key4				; Next key if 3 not pressed
	
	ld a,2						; Type 2
	ld (v_type),a
	
	jp c_start

c_title_key4:
	rrca
	jr c,c_title_key5

	jp c_initialise_game				; Start game

c_title_key5:
	rrca
	jr c,c_title_key1
	
	jp c_initialise_freedraw			; Start freedraw

; =============================================================================
; === CODE INCLUDES
; =============================================================================

include 'game.asm'
include 'freedraw.asm'
include 'ui.asm'
include 'gfx.asm'
include 'player.asm'
include 'death.asm'
include 'input.asm'
include 'sfx.asm'
include 'collision.asm'
include 'win.asm'
include 'time.asm'
include 'score.asm'
include 'level.asm'
include 'enemies.asm'
include 'title.asm'

; =============================================================================
; === DATA INCLUDES
; =============================================================================

include 'gfxdata.asm'
include 'leveldata.asm'

; =============================================================================
; === PROGRAM VARIABLES
; =============================================================================

v_level:
	ds 40

v_hiscore:
	db 1,1,1,3,6,1,0,1


v_score:
	db 1,1,1,1,1,1,0
v_lives:
	db 3,0
v_levelno:
	db 0
v_deltax:
	db 1

; =============================================================================
; === PROGRAM DATA
; =============================================================================

d_sessiontemplate:
	db 1,1,1,1,1,1,0,6,0,0,1


d_playertemplate:
	db 0
	db 0
	db 0
	db 0
	dw $0800
	dw $b200
	db 0
	db 0
	db 0
	db 0
	dw 0
	db 3

d_topbar:
	db 35,19,31,34,21,43,44,44,44,44,44,44,44,44,24,25,43,44,44,44,44,44,44,44,44,28,25,38,21,35,43,0
d_timename:
	db 36,25,29,21,0
d_trace_it:
	db 36,34,17,19,21,13,0
d_titlestrings:
	db 2,44,44,27,21,41,18,31,17,34,20,0
	db 3,44,44,25,30,36,21,34,22,17,19,21,44,3,0
	db 4,44,44,27,21,29,32,35,36,31,30,0
	db 5,44,44,35,36,17,34,36,44,23,17,29,21,0
	db 6,44,44,22,34,21,21,44,20,34,17,39,0
	db 39,34,25,36,36,21,30,44,18,41,44,26,31,24,30,44,19,31,30,30,31,28,28,41,0
	db 32,34,31,35,29,44,35,31,22,36,39,17,34,21,15,44,3,1,3,1,0
d_copyright_symbol:
	db %00111100
	db %01000010
	db %10011001
	db %10100001
	db %10100001
	db %10011001
	db %01000010
	db %00111100


	db "started on 17/02/2020, finished on 20/02/2020, didn't take long did it?"

end c_start
