; =============================================================================
; === PROCESS ENEMIES
; =============================================================================

c_process_enemies:
	ld a,(v_enemyno)
	ld (v_enemytemp),a				; Make copy of enemy number (used as loop counter)
	ld ix,v_enemy_struct_start

c_process_enemies_l1:
	ld a,(ix+o_enemy_type)				; Get enemy type
	
	push ix
	call c_process_enemies_switch			; Switch to appropriate routine
	pop ix
	
	ld de,13
	add ix,de					; Next enemy structure
	ld hl,v_enemytemp
	dec (hl)					; Decrement temporary counter
	jr nz,c_process_enemies_l1			; Jump back if there's still more enemies to process
	
	ret

c_process_enemies_switch:
	cp 1
	jp z,c_process_flyer
	cp 2
	jp z,c_process_crawler
	cp 3
	jp z,c_process_pacer
	
	ret

; =============================================================================
; === PREPARE ENEMIES
; =============================================================================

c_prepare_enemies:
	ld a,(v_enemyno)
	ld (v_enemytemp),a				; Make copy of enemy number (used as loop counter)
	ld ix,v_enemy_struct_start
	
c_prepare_enemies_l1:
	ld a,(ix+o_enemy_type)				; Get enemy type
	
	push ix
	call c_prepare_enemies_switch			; Switch to appropriate routine
	pop ix
	
	ld de,13
	add ix,de					; Next enemy structure
	ld hl,v_enemytemp
	dec (hl)					; Decrement temporary counter
	jr nz,c_prepare_enemies_l1			; Jump back if there's still more enemies to process
	
	ret

c_prepare_enemies_switch:
	cp 1
	jp z,c_prepare_flyer
	cp 2
	jp z,c_prepare_crawler
	cp 3
	jp z,c_prepare_pacer
	
	ret

; =============================================================================
; === DRAW ENEMIES
; =============================================================================

c_draw_enemies:
	ld a,(v_enemyno)
	ld (v_enemytemp),a				; Make copy of enemy number (used as loop counter)
	ld ix,v_enemy_struct_start
	
c_draw_enemies_l1:
	ld a,(ix+o_enemy_type)				; Get enemy type
	
	push ix
	call c_draw_enemies_switch			; Switch to appropriate routine
	pop ix
	
	ld de,13
	add ix,de					; Next enemy structure
	ld hl,v_enemytemp
	dec (hl)					; Decrement temporary counter
	jr nz,c_draw_enemies_l1				; Jump back if there's still more enemies to process
	
	ret

c_draw_enemies_switch:
	cp 1
	jp z,c_draw_flyer
	cp 2
	jp z,c_draw_crawler
	cp 3
	jp z,c_draw_pacer
	
	ret

; =============================================================================
; === ENEMY VARIABLES
; =============================================================================

v_enemyno:
	db 2
v_enemytemp:
	db 0

v_enemy_struct_start:
	ds 39

; =============================================================================
; === ENEMY OFFSETS
; =============================================================================

o_enemy_x:		equ 0
o_enemy_y:		equ 1
o_enemy_deltax:		equ 2
o_enemy_deltay:		equ 3
o_enemy_oldx:		equ 4
o_enemy_oldy:		equ 5
o_enemy_screenx:	equ 6
o_enemy_frame:		equ 7
o_enemy_oldscreenx:	equ 9
o_enemy_oldframe:	equ 10
o_enemy_type:		equ 12

include 'flyer.asm'
include 'crawler.asm'
include 'pacer.asm'
