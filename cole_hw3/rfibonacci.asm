loop:   LODD    pascnt: ; Number of fibs to do in cnt
        JZER    done:   ; No more iterations, go to done
        SUBD    c1:     ; Decrement the iterations
        STOD    pascnt: ; Store the decremented iterations var

p1:     LODD    daddr:  ; Load the pointer to the args
        PSHI            ; Push arg for fibonaci on stack
        ADDD    c1:     ; Increment pointer address
        STOD    daddr:  ; Store pointer for next d(n)
        CALL    fib:    ; Call function
        INSP    1       ; Increment stack pointer by 1

p2:     PUSH            ; Put return accumulator (fib(n)) on stack
        LODD    faddr:  ; Load pointer to result f(n)
        POPI            ; Pop result off stack into f(n)
        ADDD    c1:     ; Increment pointer address
        STOD    faddr:  ; Store increment pointer address for next f(n)
        JUMP    loop:   ; Repeat loop for next iteration

fib:    LODL    1       ; Fib func loads arg from stack
        JZER    fibzer: ; if fib(0) go to fibzer
        SUBD    c1:     ; decrement arg value in AC (arg-1)
        JZER    fibone: ; if fib(1) go to fibone

        PUSH            ; Push AC (n-1) to stack
        CALL    fib:    ; Call fib(n-1)
        PUSH            ; Push result of fib(n-1) to stack

        LODL    1       ; Load SP + 1 into AC ... (n-1)
        SUBD    c1:     ; Subtract 1 from (n-1) to get (n-2) arg
        PUSH            ; Push AC (n-2) to stack
        CALL    fib:    ; Call fib(n-2)

        ADDL    1       ; Add fib(n-1) to fib(n-2)
        INSP    3       ; Move SP to return address
        RETN            ; Return result in AC

fibzer: LODD    c0:     ; Returns 0
        RETN

fibone: LODD    c1:     ; Returns 1
        RETN

done:   HALT

    .LOC 100
d0:     3               ; The following values will be used as args to the fib function
        9
        18
        23
        25
f0:     0               ; The following values will be used to store the result of fib(...args)
        0
        0
        0
        0
daddr:  d0:             ; Pointer to d0
faddr:  f0:             ; Pointer to f0
c0:     0
c1:     1
pascnt: 5
