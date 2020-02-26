; =============================================================================
; === LEVEL DATA
; =============================================================================

d_levels:

; LEVEL 01 - THE SNAKE (EASY)
	db $f4,$00,$08,$80
	db $f1,$ef,$ff,$ff
	db $f7,$00,$80,$5f
	db $ff,$ff,$fe,$1f
	db $00,$00,$00,$6f

; LEVEL 02 - CRAWLER'S DEBUT (EASY)
	db $5f,$ff,$ff,$ff
	db $14,$00,$80,$05
	db $11,$df,$df,$f1
	db $17,$00,$02,$59
	db $70,$20,$00,$67

; LEVEL 03 - TIGHTROPE (EASY)
	db $42,$22,$aa,$5f
	db $7a,$a2,$25,$75
	db $42,$22,$a6,$c1
	db $70,$22,$20,$51
	db $00,$02,$20,$67

; LEVEL 04 - SQUARE WAVE (EASY)
	db $40,$85,$48,$05
	db $14,$51,$1d,$f1
	db $11,$76,$14,$51
	db $11,$df,$76,$11
	db $67,$80,$08,$67

; LEVEL 05 - THE TRIO (EASY)
	db $cf,$ff,$ff,$ff
	db $ff,$40,$5f,$45
	db $ff,$1e,$1f,$bb
	db $ff,$1f,$1d,$bb
	db $00,$6f,$70,$67

; LEVEL 06 - SUBWAY (EASY)
	db $ff,$48,$5f,$cf
	db $ff,$1e,$3f,$ff
	db $40,$6f,$3f,$45
	db $70,$54,$6f,$91
	db $00,$67,$00,$67

; LEVEL 07 - PYRITE (MEDIUM)
	db $cf,$ff,$4a,$a5
	db $f4,$25,$7a,$51
	db $46,$46,$40,$61
	db $75,$1e,$1f,$f1
	db $06,$70,$6f,$f7

; LEVEL 08 - HAVE A HEART (MEDIUM)
	db $48,$5f,$f4,$85
	db $1e,$72,$26,$f1
	db $75,$fd,$df,$46
	db $f7,$05,$40,$6f
	db $00,$06,$70,$00

; LEVEL 09 - TELEVISION ROTS THE BRAIN (MEDIUM)
	db $40,$80,$08,$05
	db $1f,$ff,$fc,$f1
	db $1f,$cf,$ff,$f1
	db $78,$05,$40,$86
	db $00,$06,$70,$00

; LEVEL 10 - COATHANGER (MEDIUM)
	db $40,$08,$00,$05
	db $1f,$ff,$df,$f1
	db $1f,$40,$80,$06
	db $1e,$1d,$ff,$ff
	db $6f,$78,$80,$00

; LEVEL 11 - GENESIS (HARD)
	db $45,$c4,$54,$25
	db $93,$d9,$31,$eb
	db $97,$86,$11,$fb
	db $70,$54,$61,$46
	db $00,$67,$86,$70

; LEVEL 12 - ACRONYM FIASCO (HARD)
	db $48,$54,$54,$85
	db $9f,$93,$39,$c3
	db $9e,$13,$37,$53
	db $9f,$93,$3d,$93
	db $6f,$76,$78,$67

; LEVEL 13 - UP AND DOWN WE GO(HARD)
	db $42,$5f,$42,$5f
	db $bf,$3e,$bf,$3f
	db $3f,$bf,$3f,$bf
	db $be,$3f,$be,$3f
	db $6f,$72,$6f,$70

; LEVEL 14 - WINDING PATHS (V.HARD)
	db $40,$54,$08,$05
	db $1d,$91,$48,$06
	db $94,$69,$78,$5c
	db $19,$c1,$48,$6f
	db $67,$06,$7a,$aa

; LEVEL 15 - MINOR DRAG (V.HARD)
	db $4a,$aa,$aa,$5c
	db $78,$88,$85,$75
	db $48,$88,$86,$c1
	db $78,$88,$88,$51
	db $0a,$aa,$aa,$67

; =============================================================================
; === LEVEL NAMES
; =============================================================================

d_levelnames:
	dw s_level01
	dw s_level02
	dw s_level03
	dw s_level04
	dw s_level05
	dw s_level06
	dw s_level07
	dw s_level08
	dw s_level09
	dw s_level10
	dw s_level11
	dw s_level12
	dw s_level13
	dw s_level14
	dw s_level15

s_level01: db $0b,36,24,21,44,35,30,17,27,21,0
s_level02: db $08,19,34,17,39,28,21,34,11,35,44,20,21,18,37,36,0
s_level03: db $0b,36,25,23,24,36,34,31,32,21,0
s_level04: db $0b,35,33,37,17,34,21,44,39,17,38,21,0
s_level06: db $0d,35,37,18,39,17,41,0
s_level07: db $0d,32,41,34,25,36,21,0
s_level08: db $0a,24,17,38,21,44,17,44,24,21,17,34,36,0
s_level09: db $03,36,21,28,21,38,25,35,25,31,30,44,34,31,36,35,44,36,24,21,44,18,34,17,25,30,0
s_level10: db $0b,19,31,17,36,24,17,30,23,21,34,0
s_level11: db $0d,23,21,30,21,35,25,35,0
s_level12: db $09,17,19,34,31,30,41,29,44,22,25,17,35,19,31,0
s_level13: db $07,37,32,44,17,30,20,44,20,31,39,30,44,39,21,44,23,31,0
s_level14: db $08,39,25,30,20,25,30,23,44,32,17,36,24,39,17,41,0
s_level15: db $0b,29,25,30,31,34,44,20,34,17,23,0
s_level05: db $0c,36,24,21,44,36,34,25,31,0
