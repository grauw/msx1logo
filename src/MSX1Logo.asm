;
; MSX1 logo
;
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
	ld hl,(GRPCGP)
	ld de,65 * 32
	add hl,de
	exx
	ld hl,MSX1Logo_bitmapTransitions
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
	push bc
	ld b,1
	call MSX1Logo_Wait
	pop bc
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

MSX1Logo_bitmapTransitions:
	db 54, 70, 83, 99, 121, 173, 195, 214
	db 54, 70, 83, 99, 118, 174, 194, 213
	db 54, 70, 83, 99, 116, 175, 194, 213
	db 54, 70, 83, 99, 114, 175, 193, 212
	db 53, 71, 82, 100, 113, 176, 192, 211
	db 53, 71, 82, 100, 112, 177, 192, 211
	db 53, 71, 82, 100, 111, 177, 191, 210
	db 53, 71, 82, 100, 110, 178, 190, 209
	db 52, 72, 81, 101, 110, 179, 190, 209
	db 52, 72, 81, 101, 109, 180, 189, 208
	db 52, 72, 81, 101, 109, 180, 188, 207
	db 52, 72, 81, 101, 108, 181, 188, 207
	db 51, 73, 80, 102, 108, 182, 187, 206
	db 51, 73, 80, 102, 108, 182, 186, 205
	db 51, 73, 80, 102, 107, 183, 186, 205
	db 51, 73, 80, 102, 107, 184, 185, 204
	db 50, 74, 79, 103, 107, 127, 166, 203
	db 50, 74, 79, 103, 107, 125, 166, 203
	db 50, 74, 79, 103, 107, 124, 167, 202
	db 50, 74, 79, 103, 107, 124, 168, 201
	db 50, 74, 79, 103, 107, 124, 168, 201
	db 49, 75, 78, 104, 107, 125, 169, 200
	db 49, 75, 78, 104, 107, 127, 170, 199
	db 49, 75, 78, 104, 107, 145, 170, 199
	db 49, 75, 78, 104, 107, 148, 171, 198
	db 48, 76, 77, 105, 108, 150, 172, 197
	db 48, 76, 77, 105, 108, 152, 172, 197
	db 48, 76, 77, 105, 108, 153, 173, 196
	db 48, 76, 77, 105, 109, 154, 174, 195
	db 47, 106, 109, 155, 174, 195
	db 47, 106, 110, 156, 175, 194
	db 47, 106, 110, 156, 174, 195
	db 47, 106, 111, 157, 173, 196
	db 46, 62, 63, 90, 91, 107, 112, 157, 173, 196
	db 46, 62, 63, 90, 91, 107, 113, 158, 172, 197
	db 46, 62, 63, 90, 91, 107, 114, 158, 171, 198
	db 46, 62, 63, 90, 91, 107, 116, 158, 171, 198
	db 45, 61, 64, 89, 92, 108, 118, 159, 170, 199
	db 45, 61, 64, 89, 92, 108, 121, 159, 169, 200
	db 45, 61, 64, 89, 92, 108, 139, 159, 169, 201
	db 45, 61, 64, 89, 92, 108, 141, 159, 168, 201
	db 44, 60, 65, 88, 93, 109, 142, 159, 167, 202
	db 44, 60, 65, 88, 93, 109, 142, 159, 167, 203
	db 44, 60, 65, 88, 93, 109, 142, 159, 166, 203
	db 44, 60, 65, 88, 93, 109, 141, 159, 165, 184, 185, 204
	db 44, 60, 65, 88, 93, 109, 139, 159, 165, 184, 186, 205
	db 43, 59, 66, 87, 94, 159, 164, 183, 187, 205
	db 43, 59, 66, 87, 94, 159, 163, 182, 187, 206
	db 43, 59, 66, 87, 94, 158, 163, 182, 188, 207
	db 43, 59, 66, 87, 94, 158, 162, 181, 189, 207
	db 42, 58, 67, 86, 95, 158, 161, 180, 189, 208
	db 42, 58, 67, 86, 95, 157, 161, 180, 190, 209
	db 42, 58, 67, 86, 95, 157, 160, 179, 191, 210
	db 42, 58, 67, 86, 95, 156, 159, 178, 192, 210
	db 41, 57, 68, 85, 96, 156, 159, 178, 192, 211
	db 41, 57, 68, 85, 96, 155, 158, 177, 193, 212
	db 41, 57, 68, 85, 96, 154, 157, 176, 194, 212
	db 41, 57, 68, 85, 96, 153, 157, 176, 194, 213
	db 40, 56, 69, 84, 97, 152, 156, 175, 195, 214
	db 40, 56, 69, 84, 97, 150, 155, 174, 196, 214
	db 40, 56, 69, 84, 97, 148, 155, 174, 196, 215
	db 40, 56, 69, 84, 97, 145, 154, 173, 197, 216
	db 0, 0

;
	ds 08000H - $
