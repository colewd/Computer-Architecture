addints: lodl 1
        addl 2
        push                    ; push result on stack
        insp 1
        jneg ovrflw:            ; if negative, it overflowed
        retn
ovrflw: lodd n1:                ; failed add - so return -1 in AC
        retn