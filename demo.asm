start:
  jsr init
loop:
  jsr drawMap
  jsr updateMap
  jmp loop

init:
  sta $c050 ; text mode off

  ldx #$27
drawinitialwalls:
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

  ; Tunnel
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
  bpl drawinitialwalls

  ; Set initial inflection point.
  lda #$10
  sta $90

  ; Fill $80..$90 with $10 (initial wall offset).
  ldx #$0f
setinitialwalloffsets:
  sta $80,x
  dex
  bpl setinitialwalloffsets

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
  cpx #$10
  bne drawLoop
  rts

; ---

updateMap:
  lda $90 ; $90 is next wall inflection point
  cmp $8f ; $8f is next wall offset
  beq newinflectionpoint
  lda $90
  clc
  sbc $8f ; Is next wall offset above or below inflection point?
  bpl raisewalls
  bmi lowerwalls
newinflectionpoint:
  lda $c000 ;$fe ; KEVAN: RNG (TODO) -- currently just reads last key-press
  and #$f ; Make 4-bit.
  asl     ; Double (make even number)
  sta $90 ; Set $90 to random value.
  rts
lowerwalls:
  dec $8f
  dec $8f
  rts
raisewalls:
  inc $8f
  inc $8f
  rts

tunnel:
  .byte $00
walls:
  .byte $cc
