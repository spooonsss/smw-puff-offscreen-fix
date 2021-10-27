; This fixes the puff of smoke (extended sprite 1) rendering routine
; so that offscreen puffs are properly erased


if read1($00FFD5) == $23
    sa1rom
    !sa1   = 1
    !BankB = $000000
	!Base1 = $3000
	!Base2 = $6000
else
    !sa1   = 0
    !BankB = $800000
    !Base1 = $0000
    !Base2 = $0000
endif

org $02A36C|!BankB
autoclean JSL patch
; A!=0: continue rendering; A=0: extended sprite was erased
BEQ ret
JMP $A386 ; continue with Store the tile number to OAM
ret:
RTS

freecode
; y=OAM index
; x=extended sprite index
patch:
    LDA.w $171F|!Base2,X        ;$02A1B1    |
    SEC                         ;$02A1B4    |
    SBC $1A                     ;$02A1B5    |
    STA $01                     ;$02A1B7    |
    LDA.w $1733|!Base2,X        ;$02A1B9    |\
    SBC $1B                     ;$02A1BC    || Erase sprite if horizontally offscreen.
    BNE CODE_02A211             ;$02A1BE    |/
    LDA.w $1715|!Base2,X        ;$02A1C0    |
    SEC                         ;$02A1C3    |
    SBC $1C                     ;$02A1C4    |
    STA $02                     ;$02A1C6    |
    LDA.w $1729|!Base2,X        ;$02A1C8    |\
    SBC $1D                     ;$02A1CB    ||
    BNE CODE_02A211             ;$02A1CD    || Erase sprite if vertically offscreen.
    LDA $02                     ;$02A1CF    ||
    CMP.b #$F0                  ;$02A1D1    ||
    BCS CODE_02A211             ;$02A1D3    |/

    STA.w $0201|!Base2,Y        ;$02A1D5    |\
    LDA $01                     ;$02A1D8    || Upload X and Y position to OAM.
    STA.w $0200|!Base2,Y        ;$02A1DA    |/

    LDA #$01
    RTL


erase:
CODE_02A211:
    LDA.b #$00
    STA.w $170B|!Base2,X
    ; LDA #$00
    RTL

