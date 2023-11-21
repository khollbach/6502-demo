start:
  jsr init
loop:
  jsr drawMap
  jsr updateMap
  jmp loop

init:
  sta $c050 ; text mode off

  ldx #$27
drawInitialScreen:
  lda walls
  ; Top
  sta $0400,x
  sta $0480,x
  sta $0500,x
  sta $0580,x
  sta $0600,x
  sta $0680,x
  sta $0700,x
  sta $0780,x
  ; Bottom
  sta $0450,x
  sta $04d0,x
  sta $0550,x
  sta $05d0,x
  sta $0650,x
  sta $06d0,x
  sta $0750,x
  sta $07d0,x

  lda tunnel
  sta $0428,x
  sta $04a8,x
  sta $0528,x
  sta $05a8,x
  sta $0628,x
  sta $06a8,x
  sta $0728,x
  sta $07a8,x

  dex
  bpl drawInitialScreen

  ; Set initial inflection point.
  lda #$10
  sta $94

  ; Fill $80..$94 with $10 (initial wall offset).
  ldx #$13
setinitialwalloffsets:
  sta $80,x
  dex
  bpl setinitialwalloffsets

  jsr seedRng

  rts

; ---

drawMap:

  ldx #$00
drawLoop:
  ; Draw walls.

  lda walls
  jsr $F864 ; SETCOL

  txa
  asl a
  tay ; y := 2*x (width)
  lda $80,x ; a := offsets[x] (height)
  sta $2d
  inc $2d
  jsr $F828 ; VLINE (scrambles a)

  lda $80,x
  clc
  adc #$0e ; a := offsets[x] + 0x0e
  sta $2d
  inc $2d
  jsr $F828

  iny ; y := 2*x + 1
  lda $80,x
  sta $2d
  inc $2d
  jsr $F828

  lda $80,x
  clc
  adc #$0e
  sta $2d
  inc $2d
  jsr $F828

  ; Draw tunnel.

  lda tunnel
  jsr $F864

  dey ; y := 2*x
  lda $80,x
  clc
  adc #$02 ; a := offsets[x] + 0x02
  sta $2d
  inc $2d
  jsr $F828

  lda $80,x
  clc
  adc #$0c ; a := offsets[x] + 0x0c
  sta $2d
  inc $2d
  jsr $F828

  iny ; y := 2*x + 1
  lda $80,x
  clc
  adc #$02
  sta $2d
  inc $2d
  jsr $F828

  lda $80,x
  clc
  adc #$0c
  sta $2d
  inc $2d
  jsr $F828

  ; Shift offsets over as we go.
  lda $80,x
  sta $7f,x

  inx
  cpx #$14
  bne drawLoop
  rts

; ---

updateMap:
  lda $94 ; Address of next inflection point.
  cmp $93 ; Address of next wall offset.
  beq newInflectionPoint
  lda $94
  clc
  sbc $93 ; Is the next wall offset above or below the inflection point?
  bpl raiseWalls
  bmi lowerWalls
newInflectionPoint:
  jsr rngNext
  lda $fe
  and #$f ; Random number in 0x00..0x10.
  asl     ; Double to account for each cell having top and bottom halves.
  sta $94 ; Random even number in 0x00..0x20.
  rts
lowerWalls:
  dec $93
  dec $93
  rts
raiseWalls:
  inc $93
  inc $93
  rts

seedRng:
  lda #$ab ; Use a fixed seed of $ab.
  sta $fe
  rts

; naive xorshift rng, from:
; https://codebase64.org/doku.php?id=base:small_fast_8-bit_prng
rngNext:
  lda $fe
  asl
  bcc noEor
  eor #$1d
noEor:
  sta $fe
  rts

tunnel:
  .byte $00
walls:
  .byte $cc
