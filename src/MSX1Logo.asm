;
; MSX1 logo
;
VDP.DW: equ 07H
ROMVER1: equ 2BH
DISSCR: equ 41H
ENASCR: equ 44H
WRTVRM: equ 4DH
FILVRM: equ 56H
LDIRVM: equ 5CH
CHGMOD: equ 5FH
GRPNAM: equ 0F3C7H
GRPCOL: equ 0F3C9H
GRPCGP: equ 0F3CBH
FORCLR: equ 0F3E9H
BAKCLR: equ 0F3EAH
BDRCLR: equ 0F3EBH
JIFFY: equ 0FC9EH

MSX1Logo_SPAN_BUFFER: equ 0E000H
MSX1Logo_SPAN_LINE_SIZE: equ 16

	org 4000H

	db "AB"
	dw MSX1Logo_Main
	dw 0, 0, 0, 0, 0, 0

MSX1Logo_Main: PROC
	call MSX1Logo_InitScreen
	call MSX1Logo_DrawPatterns
Loop:
	call MSX1Logo_DrawColors
	call MSX1Logo_WaitBetweenEffects
	call MSX1Logo_DrawColorsEffect2
	call MSX1Logo_WaitBetweenEffects
	call MSX1Logo_DrawColorsEffect3
	call MSX1Logo_WaitBetweenEffects
	call MSX1Logo_DrawColorsEffect4
	call MSX1Logo_WaitBetweenEffects
	call MSX1Logo_DrawColorsEffect5
	call MSX1Logo_WaitBetweenEffects
	call MSX1Logo_DrawColorsEffect6
	call MSX1Logo_WaitBetweenEffects
	call MSX1Logo_DrawColorsEffect7
	call MSX1Logo_WaitBetweenEffects
	call MSX1Logo_DrawColorsEffect8
	call MSX1Logo_WaitBetweenEffects
	call MSX1Logo_DrawColorsEffect9
	call MSX1Logo_WaitBetweenEffects
	jr Loop
	ENDP

MSX1Logo_WaitBetweenEffects:
	ld b,30
	call MSX1Logo_WaitDeciSeconds
	call MSX1Logo_ClearColors
	ld b,10
	call MSX1Logo_WaitDeciSeconds
	ret

MSX1Logo_InitScreen:
	ld a,15
	ld (FORCLR),a
	ld a,4
	ld (BAKCLR),a
	ld a,4
	ld (BDRCLR),a
	ld a,2
	call CHGMOD
	ret

MSX1Logo_DrawPatterns: PROC
	call MSX1Logo_DrawVectorEdges
	ld hl,(GRPCGP)
	ld de,65 * 32
	add hl,de
	exx
	ld hl,MSX1Logo_SPAN_BUFFER + 65 * MSX1Logo_SPAN_LINE_SIZE
	ld b,192
Loop:
	push bc
	push hl
	call MSX1Logo_DrawPatternLine
	pop hl
	pop bc
	ld de,MSX1Logo_SPAN_LINE_SIZE
	add hl,de
	djnz Loop
	ret
	ENDP

; hl = span edges
; hl' = pattern generator table position
MSX1Logo_DrawPatternLine: PROC
	ld c,0
	ld de,0001H
Loop:
	ld a,(hl)
	ld b,a
	sub c
	ret z
	ld c,b
	ld b,a
	inc hl
BitLoop:
	rlc d
	rl e
	jr nc,NoWrite
	ld a,e
	exx
	push hl
	rlc l
	rlc l
	rlc l
	call WRTVRM
	pop hl
	inc hl
	exx
	ld e,1
NoWrite:
	djnz BitLoop
	ld a,d
	cpl
	ld d,a
	jr Loop
	ENDP

MSX1Logo_DrawVectorEdges: PROC
	ld hl,MSX1Logo_SPAN_BUFFER
	ld de,MSX1Logo_SPAN_BUFFER + 1
	ld bc,256 * MSX1Logo_SPAN_LINE_SIZE - 1
	ld (hl),0
	ldir
	ld hl,MSX1Logo_polygon
	ld b,MSX1Logo_polygonCount - 1
Loop:
	push bc
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	dec hl
	push hl
	call MSX1Logo_DrawEdge
	pop hl
	pop bc
	djnz Loop
	ret
	ENDP

; e = x
; d = y
; c = x2
; b = y2
MSX1Logo_DrawEdge: PROC
	ld a,b
	sub d
	ret z
	jr nc,NoSwap
	ld d,b
	ld h,e
	ld e,c
	ld c,h
	neg
NoSwap:
	ld h,a  ; dy
	ld a,c
	sub e
	ld c,1
	jr nc,NoFlipX
	ld c,-1
	neg
NoFlipX:
	ld l,a  ; dx
	sra a
	sub h
	ld b,h
Loop:
	call MSX1Logo_DrawEdgePixel
	inc d
	add a,l
	jr nc,NoOverflow
StepLoop:
	bit 7,c
	jr nz,Decrement
	inc e
	jr Continue
Decrement:
	dec e
Continue:
	sub h
	jr nc,StepLoop
NoOverflow:
	djnz Loop
	ret
	ENDP

; e = x
; d = y
MSX1Logo_DrawEdgePixel: PROC
	push af
	push bc
	push de
	push hl
	ld l,d
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,MSX1Logo_SPAN_BUFFER - 1
	add hl,bc
Loop:
	inc hl
	ld a,(hl)
	and a
	jr z,Insert
	cp e
	jr c,Loop
	jr z,Remove
Insert:
	ld a,(hl)
	ld (hl),e
	inc hl
	ld e,a
	and a
	jr nz,Insert
	jr Continue
Remove:
	inc hl
	ld a,(hl)
	dec hl
	ld (hl),a
	inc hl
	and a
	jr nz,Remove
Continue:
	pop hl
	pop de
	pop bc
	pop af
	ret
	ENDP

MSX1Logo_DrawColors: PROC
	call DISSCR
	ld hl,(GRPCOL)
	ld de,0E3H * 8
	add hl,de
	ld b,10
Loop:
	push bc
	push hl
	ld bc,26 * 8
	ld a,0F1H
	call FILVRM
	pop hl
	pop bc
	ld de,32 * 8
	add hl,de
	djnz Loop
	call MSX1Logo_WaitFrame
	call ENASCR
	ret
	ENDP

MSX1Logo_DrawColorsEffect2: PROC
	ld a,56
Loop:
	call MSX1Logo_WaitFrame
	call MSX1Logo_DrawColorLine
	inc a
	call MSX1Logo_DrawColorLine
	inc a
	call MSX1Logo_DrawColorLine
	inc a
	call MSX1Logo_DrawColorLine
	inc a
	cp 136
	jr c,Loop
	ret
	ENDP

MSX1Logo_DrawColorsEffect3: PROC
	ld a,96
Loop:
	call MSX1Logo_WaitFrame
	call MSX1Logo_DrawColorLineMirror
	inc a
	call MSX1Logo_DrawColorLineMirror
	inc a
	cp 136
	jr c,Loop
	ret
	ENDP

MSX1Logo_DrawColorsEffect4: PROC
	ld a,56
Loop:
	call MSX1Logo_WaitFrame
	call MSX1Logo_DrawColorLineMirror
	inc a
	call MSX1Logo_DrawColorLineMirror
	inc a
	cp 96
	jr c,Loop
	ret
	ENDP

MSX1Logo_DrawColorsEffect5: PROC
	ld a,56
Loop:
	call MSX1Logo_WaitFrame
	call MSX1Logo_DrawColorLineMirror
	add a,2
	call MSX1Logo_DrawColorLineMirror
	add a,2
	cp 136
	jr c,Loop
	ret
	ENDP

MSX1Logo_DrawColorsEffect6: PROC
	ld a,56
Loop:
	call MSX1Logo_WaitFrame
	call MSX1Logo_DrawColorLineMirror
	add a,4
	call MSX1Logo_DrawColorLineMirror
	add a,4
	cp 136
	jr c,Loop
	ld a,57
Loop2:
	call MSX1Logo_WaitFrame
	call MSX1Logo_DrawColorLineMirror
	add a,4
	call MSX1Logo_DrawColorLineMirror
	add a,4
	cp 136
	jr c,Loop2
	ret
	ENDP

MSX1Logo_DrawColorsEffect7: PROC
	ld a,56
Loop:
	call MSX1Logo_WaitFrame
	call MSX1Logo_DrawColorLine
	add a,2
	call MSX1Logo_DrawColorLine
	add a,2
	call MSX1Logo_DrawColorLine
	add a,2
	call MSX1Logo_DrawColorLine
	add a,2
	cp 136
	jr c,Loop
	ld a,57
Loop2:
	call MSX1Logo_WaitFrame
	call MSX1Logo_DrawColorLineMirror
	add a,2
	call MSX1Logo_DrawColorLineMirror
	add a,2
	call MSX1Logo_DrawColorLineMirror
	add a,2
	call MSX1Logo_DrawColorLineMirror
	add a,2
	cp 136
	jr c,Loop2
	ret
	ENDP

MSX1Logo_DrawColorsEffect8: PROC
STEP: equ 10
	ld b,STEP
Loop:
	ld a,56 + STEP
	sub b
	push bc
	call MSX1Logo_WaitFrame
Loop2:
	call MSX1Logo_DrawColorLine
	add a,STEP
	cp 136
	jr c,Loop2
	pop bc
	djnz Loop
	ret
	ENDP

MSX1Logo_DrawColorsEffect9: PROC
STEP: equ 10
	ld b,STEP * 2
	ld a,56 - STEP * STEP - 1
Loop:
	push af
	push bc
	call MSX1Logo_WaitFrame
	ld b,STEP
Loop2:
	push bc
	cp 56
	jr c,Skip
	cp 136
	call c,MSX1Logo_DrawColorLine
Skip:
	pop bc
	add a,STEP - 1
	djnz Loop2
	pop bc
	pop af
	add a,STEP
	djnz Loop
	ret
	ENDP

; a = line
MSX1Logo_DrawColorLineMirror:
	call MSX1Logo_DrawColorLine
	ld c,a
	ld a,191
	sub c
	call MSX1Logo_DrawColorLine
	ld c,a
	ld a,191
	sub c
	ret

; a = line
MSX1Logo_DrawColorLine: PROC
	push af
	ld h,a
	and 07H
	add a,3 << 3
	ld l,a
	srl h
	srl h
	srl h
	ld bc,(GRPCOL)
	add hl,bc
	set 6,h
	ld de,8
	ld a,(VDP.DW)
	ld c,a
	ld b,26
	ld a,0F1H
Loop:
	inc c
	out (c),l
	out (c),h
	dec c
	out (c),a
	add hl,de
	djnz Loop
	pop af
	ret
	ENDP

MSX1Logo_ClearColors:
	call MSX1Logo_WaitFrame
	call DISSCR
	ld hl,(GRPCOL)
	ld de,0E0H * 8
	add hl,de
	ld bc,140H * 8
	ld a,04H
	call FILVRM
	call ENASCR
	ret

MSX1Logo_WaitFrame:
	push af
	push bc
	ld b,1
	call MSX1Logo_Wait
	pop bc
	pop af
	ret

; b = frames to wait
MSX1Logo_Wait: PROC
	ld a,(JIFFY)
	ld c,a
Loop:
	ld a,(JIFFY)
	sub c
	cp b
	jr c,Loop
	ret
	ENDP

; b = 1/10ths of a second to wait (max. 42)
MSX1Logo_WaitDeciSeconds: PROC
	ld a,(ROMVER1)
	bit 7,a
	jr nz,Freq50Hz
Freq60Hz:
	ld a,b
	add a,a
	add a,a
	add a,b
	add a,b
	ld b,a
	jp MSX1Logo_Wait
Freq50Hz:
	ld a,b
	add a,a
	add a,a
	add a,b
	ld b,a
	jp MSX1Logo_Wait
	ENDP

Vector: MACRO ?x, ?y
	x:
		db ?x
	y:
		db ?y
	_size:
	ENDM

MSX1Logo_polygon:
	Vector 40, 127
	Vector 54, 65
	Vector 69, 65
	Vector 76, 95
	Vector 83, 65
	Vector 98, 65
	Vector 109, 111
	Vector 139, 111
	Vector 142, 107
	Vector 139, 103
	Vector 121, 103
	Vector 112, 98
	Vector 107, 89
	Vector 107, 79
	Vector 112, 70
	Vector 121, 65
	Vector 172, 65
	Vector 184, 81
	Vector 195, 65
	Vector 213, 65
	Vector 193, 95
	Vector 215, 127
	Vector 197, 127
	Vector 184, 108
	Vector 172, 127
	Vector 154, 127
	Vector 175, 95
	Vector 165, 80
	Vector 126, 80
	Vector 123, 84
	Vector 126, 88
	Vector 144, 88
	Vector 153, 93
	Vector 158, 102
	Vector 158, 112
	Vector 153, 121
	Vector 144, 127
	Vector 112, 127
	Vector 97, 127
	Vector 90, 97
	Vector 83, 127
	Vector 69, 127
	Vector 62, 97
	Vector 55, 127
	Vector 40, 127
MSX1Logo_polygonCount: equ ($ - MSX1Logo_polygon) / Vector._size

;
	ds 08000H - $
