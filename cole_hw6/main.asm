main:   loco sum:               ; push address of var to store result
        push
        lodd on:                ; load 8
        stod 4095               ; turn on transmitter
        call xbsywt:            ; transmit busy wait
        loco str1:              ; load address of prompt string
        call writestr:          ; print prompt
        call readint:           ; scan in number
        push                    ; push first number on stack
        call xbsywt:            ; wait for transmitter
        loco str1:              ; load address of prompt string
        call writestr:          ; print prompt again
        call readint:           ; scan in second number
        push                    ; push second number on stack
        call addints:           ; add numbers
        insp 1
        push                    ; store result
        stod sum:               ; store result in sum
        loco str2:              ; load result string address
        call writestr:          ; print result string
        pop                     ; pop result off stack
        jneg badAdd:            ; if overflowed, print that it overflowed
        call xbsywt:            ; wait for transmitter
        call writeint:          ; encode string to be printed out
        halt
badAdd: call xbsywt:            ; wait for transmitter
        loco str3:              ; load overflow string
        call writestr:          ; print overflow stringloco str3:
        halt
numoff: 48
nxtchr: 0
numptr: binum1:
binum1: 0
binum2: 0
lpcnt:  0
mask:   10
on:     8
nl:     10
cr:     13
n1:     -1
c0:     0
c1:     1
c10:    10
c255:   255
sum:    0
pstr1:  0
str1:   "PLEASE ENTER AN INTEGER BETWEEN 1 AND 32767"
str2:   "THE SUM OF THESE INTEGERS IS:"
str3:   "OVERFLOW, NO SUM POSSIBLE"