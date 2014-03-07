
.include "m32def.inc"

.org    0x0000
.include "SetupInterrupts.asm"   ;setup Interrupts
.org    0x0060
Reset:
.include "SetupStack.asm"       ;setup the stack
.include "SetupSerial.asm"      ;setup serial connection
.include "SetupIO.asm"

    sei                         ;enable interrupts
    jmp     Main
    
;****
;ROUTINES
;****
RX_ISR: ;We always recive 3 bytes, put them in R16:R18
push    R16 ;Push  to stack
push    R17
push    R18
in      R16,UDR ;read recived into R16
;wait for new byte
RX_WAIT1:
SBIS    UCSRA,RXC
RJMP    RX_WAIT1
in  R17,UDR     ;Read into R17
RX_WAIT2:
SBIS    UCSRA,RXC
RJMP    RX_WAIT2
in    R18,UDR   ;Read into R18
CALL STATESET
pop     R18
pop     R17
pop     R16
RETI

;TRANSMIT:
;sbis    UCSRA,UDRE
;rjmp    TRANSMIT    ;wait for free line
;out     UDR,R16
;TX_WAIT2:
;sbis    UCSRA,UDRE
;rjmp    TX_WAIT2
;out     UDR,R17
;TX_WAIT3:
;sbis    UCSRA,UDRE
;rjmp    TX_WAIT3
;out     UDR,R18
;RET

;**************
STATESET:
CPI R16,0x55
BRNE    STATESET1
CALL     SET
STATESET1:
CPI R16,0xAA
BRNE    STATERET
CALL     GET
STATERET:
RET
;******************
SET:
out PORTB,R17
RET
;*********
GET:
push    R17
push    R18
push    R19
ldi     R17,0xBB
in      R19,PORTB
CALL    TRANSREPLY
pop     R17
pop     R18
pop     R19
RET
;******

TRANSREPLY:  ;Sends the data in R17:R19
SBIS    UCSRA,UDRE
RJMP    TRANSREPLY
out     UDR,R17
A:
SBIS    UCSRA,UDRE
RJMP    A
out     UDR,R18
B:
SBIS    UCSRA,UDRE
RJMP    B
out     UDR,R19
RET

;******
;*MAIN
;******
Main:
RJMP    Main




