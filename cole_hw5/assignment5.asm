start:  loco sum:               ; push address of var to store result
        push
        call addInput:          ; call add function
        halt
addInput: lodd on:              ; load 8
        stod 4095               ; turn on transmitter
        call xbsywt:            ; transmit busy wait
        loco str1:              ; load address of prompt string
        call nextw:             ; print prompt
        call bgndig:            ; scan in number
        stod binum1:            ; store number
        call xbsywt:            ; wait for transmitter
        loco str1:              ; load address of prompt string
        call nextw:             ; print prompt again
        call bgndig:            ; scan in second number
        stod binum2:            ; store second number
        addd binum1:            ; add first number to second number
        push                    ; push result on stack
        insp 2
        pop                     ; pop address of result variable
        desp 3
        popi                    ; store the result (at SP) in address in AC
        desp 1                  ; point SP back at result
        call xbsywt:            ; wait for transmitter
        loco str2:              ; load result string
        call nextw:             ; print out result string
        pop                     ; pop result off stack
        jneg ovrflw:            ; if negative, it overflowed
        call xbsywt:            ; wait for transmitter
        call encode:            ; encode string to be printed out
        lodd c0:                ; successful add - so return 0 in AC
        retn
ovrflw: call xbsywt:            ; wait for transmitter
        loco str3:              ; load overflow string
        call nextw:             ; print overflow string
        lodd n1:                ; failed add - so return -1 in AC
        retn
nextw:  pshi                    ; push two letters
        addd c1:                ; increment pointer to string, to point to next 2 chars
        stod pstr1:             ; save newly incremented pointer in pstr1
        pop                     ; two chars on in AC
        jzer crnl:              ; if string finished, go to crnl. if false - there's atleast 1 letter in AC
        stod 4094               ; send it to transmitter, least significant 8 bits
        push                    ; push whole 16 bits (two letters)
        subd c255:              ; see if AC has two characters. Get 2nd char
        jneg crnl:              ; there's not two characters
        call sb:                ; swap bites. Swaps position of 1st and 2nd char.
        insp 1                  ; Clear stack from sb call.
        push                    ; Save result of sb on stack. xbsywt will clobber AC
        call xbsywt:            ; wait for transmitter to get ready
        pop                     ; Get result back in AC
        stod 4094               ; send to transmitter
        call xbsywt:            ; transmit busy wait
        lodd pstr1:             ; load pointer to next two chars
        jump nextw:             ; loop back
crnl:   lodd cr:                ; loads carriage return
        stod 4094               ; send it to transmitter.
        call xbsywt:            ; wait for transmitter to get ready
        lodd nl:                ; load AC with new line.
        stod 4094               ; send to transmitter
        call xbsywt:            ; wait for transmitter to get ready
        insp 1
        retn
bgndig: lodd on:                ; mic1 program to print string
        stod 4093               ; and scan in a 1-5 digit number
        call rbsywt:            ; using CSR memory locations
        lodd 4092
        subd numoff:            ; remove ascii bias to get binary
        push
nxtdig: call rbsywt:
        lodd 4092
        stod nxtchr:
        subd nl:
        jzer endnum:
        mult 10
        lodd nxtchr:
        subd numoff:
        addl 0
        stol 0
        jump nxtdig:
endnum: pop
        retn 
xbsywt: lodd 4095
        subd mask:
        jneg xbsywt:
        retn
rbsywt: lodd 4093
        subd mask:
        jneg rbsywt:
        retn
sb:     loco 8                  ; circular shift 8 bits
loop1:  jzer finish:
        subd c1:
        stod lpcnt:
        lodl 1
        jneg add1:
        addl 1
        stol 1
        lodd lpcnt:
        jump loop1:
add1:   addl 1
        addd c1:
        stol 1
        lodd lpcnt:
        jump loop1:
finish: lodl 1
        retn
encode: lodd sum:       ; load sum
        halt
        jzer cout:      ; if zero, then done. Print string
        lodd c10:       ; load divisor, 10
        push            ; put on stack for div arg
        lodd sum:       ; load sum
        push            ; put on stack for div arg
        div             ; divide sum / 10
        insp 1          ; move sp to remainder
        pop             ; get remainder
        addd numoff:    ; add bias to number
        insp 2
        push            ; put on stack
        desp 3          ; point to quotient
        pop             ; get answer of multiplication
        insp 2
        stod sum:       ; update sum
        jump encode:
cout:   pop             ; get last number in ascii representation
        subd numoff:    ; subtract ascii bias to get binary representation
        jneg done:      ; if it is less than 0, we are done
        addd numoff:    ; convert back to ascii
        stod 4094       ; send to transmitter
        call xbsywt:    ; wait for transmitter
        jump cout:      ; loop
done:   addd numoff:    ; convert back to ascii
        push            ; push it on to stack
        call xbsywt:    ; wait for transmitter
        lodd nl:        ; load new line
        stod 4094       ; send to transmitter
        call xbsywt:    ; wait for transmitter
        lodd cr:        ; load carriage return
        stod 4094       ; send to transmitter
        retn
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