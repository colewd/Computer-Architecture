readint: lodd on:               ; mic1 program to print string
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