; Pin connection:
; PD5 is connected to power button. It's high when idle. Sending a low pulse will simulate a "power button push" to turn on the mainboard.
; PD4 is connected to power LED. When the LED is off, this pin is low. When the LED is on, this pin is high. This will prevent PD5 to generate more "push" event.
;


.DEVICE ATtiny2313

.EQU    DIDR    = 0x01
.EQU    UBRRH   = 0x02
.EQU    UCSRC   = 0x03  
.EQU    ACSR    = 0x08
.EQU    UBRRL   = 0x09
.EQU    UCSRB   = 0x0A
.EQU    UCSRA   = 0x0B
.EQU    UDR     = 0x0C
.EQU    USICR   = 0x0D
.EQU    USISR   = 0x0E
.EQU    USIDR   = 0x0F
.EQU    PIND    = 0x10
.EQU    DDRD    = 0x11
.EQU    PORTD   = 0x12
.EQU    WDTCSR  = 0x21
.EQU    CLKPR   = 0x26
.EQU    MCUSR   = 0x34

; we are not using any interrupt. Thus no need to have IVT here. 

RESET:
;Turn off the wathch dog
    cli
    wdr
    in      r16, MCUSR
    andi    r16, 0xF7        ;clear WDRF 
    out     MCUSR, r16
    in      r16, WDTCSR
    ori     r16, 0x18        ;set WDCE and WDE 
    out     WDTCSR, r16
    ldi     r16, 0xF7
    out     WDTCSR, r16      ;clear WDE 

;Chage the clock pre-scaler to lower the clock frequency.
    ldi     r16, 0x80
    ldi     r17, 0x08
    out     CLKPR, r16
    out     CLKPR, r17

;PD4 input, pull-up disabled
    cbi     DDRD, 4
    cbi     PORTD, 4
 
;PD5 iuput, pull-up disabled
    cbi     DDRD, 5
    cbi     PORTD, 5 

;If the Power LED is on, just busy loop here.
loop:
    sbic    PIND, 4 
    rjmp    loop


    ldi     r16, 0
delay1:
    inc     r16,
    cpi     r16, 0xFF;
    brlo    delay1

;PD5 output low
    sbi     DDRD, 5

    ldi     r16, 0
delay2:
    inc     r16,
    cpi     r16, 0x30;
    brlo    delay2

;PD5 back to input. It will be pulled high by mainbaord.
    cbi     DDRD, 5

    ldi     r16, 0
delay3:
    inc     r16,
    cpi     r16, 0xFF;
    brlo    delay3

    rjmp    loop
