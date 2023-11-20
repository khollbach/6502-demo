start:
  jsr init

loop:
  jsr drawMap
  jsr genMap
  jmp loop

init:
  ldx #0
  lda walls

;draw exactly 256 pixels of wall at top and bottom
drawinitialwalls:
  sta $200,x ;draw the top bit of wall
  sta $400,x ;draw the bottom bit of wall
  dex        ;count down from 0
  cpx #0     ;until we hit 0
  bne drawinitialwalls

  lda #$10
  sta $80
  ldx #$0f

;fill $81-$90 with $10 (initial wall offset)
setinitialwalloffsets:
  sta $81,x  ; target
  dex
  bpl setinitialwalloffsets
  rts

;--

drawMap:
  lda #$00
  sta $78
  lda #$20
  sta $79
  lda #$c0
  sta $7a
  lda #$e0
  sta $7b

  ldx #$0f
drawLoop:
  lda $81,x
  sta $82,x ;shift wall offsets along

  tay
  sty $02      ;store current wall offset in $02
  lda pixels,y ;lookup current wall offset in pixels
  sta $00      ;and store it in $00
  iny
  lda pixels,y ;lookup current wall offset + 1 in pixels
  sta $01      ;and store it in $01
               ;$00 now points to a two-byte pixel memory location

  lda walls
  ldy $78      ;top edge of wall
  sta ($00),y
  iny
  sta ($00),y

  ldy $7b
  sta ($00),y ;bottom edge of wall
  iny
  sta ($00),y

  ldy $79     ;top edge of tunnel
  lda #0      ;black for tunnel
  sta ($00),y
  iny
  sta ($00),y

  ldy $7a
  sta ($00),y ;bottom edge of tunnel
  iny
  sta ($00),y

  ; move offsets right two pixels
  inc $78
  inc $79
  inc $7a
  inc $7b
  inc $78
  inc $79
  inc $7a
  inc $7b
  dex
  bpl drawLoop
  rts

;---

genMap:
  lda $80 ;$80 is next wall inflection point
  cmp $81 ;$81 is next wall offset
  beq newinflectionpoint
  lda $80
  clc
  sbc $81 ;is next wall offset above or below inflection point?
  bpl raisewalls
  bmi lowerwalls
newinflectionpoint:
  lda $c000 ;$fe ; KEVAN: RNG (TODO) -- currently just reads last key-press
  and #$f ;make 4-bit
  asl     ;double (make even number)
  sta $80 ;set $80 to random value
  rts
lowerwalls:
  dec $81
  dec $81
  rts
raisewalls:
  inc $81
  inc $81
  rts

pixels:
  .byte $00,$02,$20,$02,$40,$02,$60,$02
  .byte $80,$02,$a0,$02,$c0,$02,$e0,$02
  .byte $00,$03,$20,$03,$40,$03,$60,$03
  .byte $80,$03,$a0,$03,$c0,$03,$e0,$03

walls:
  .byte $d
