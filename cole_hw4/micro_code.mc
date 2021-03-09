0:mar := pc; rd; 				{ main loop  }
1:pc := 1 + pc; rd; 				{ increment pc }
2:ir := mbr; if n then goto 28; 		{ save, decode mbr }
3:tir := lshift(ir + ir); if n then goto 19; 	
4:tir := lshift(tir); if n then goto 11; 	{ 000x or 001x? }
5:alu := tir; if n then goto 9; 		{ 0000 or 0001? }
6:mar := ir; rd; 				{ 0000 = LODD }
7:rd; 						
8:ac := mbr; goto 0; 				
9:mar := ir; mbr := ac; wr; 			{ 0001 = STOD }
10:wr; goto 0; 					
11:alu := tir; if n then goto 15; 		{ 0010 or 0011? }
12:mar := ir; rd; 				{ 0010 = ADDD }
13:rd; 						
14:ac := ac + mbr; goto 0; 			
15:mar := ir; rd; 				{ 0011 = SUBD }
16:ac := 1 + ac; rd; 				{ Note: x - y = x + 1 + not y }
17:a := inv(mbr); 				
18:ac := a + ac; goto 0; 			
19:tir := lshift(tir); if n then goto 25; 	{ 010x or 011x? }
20:alu := tir; if n then goto 23; 		{ 0100 or 0101? }
21:alu := ac; if n then goto 0; 		{ 0100 = JPOS }
22:pc := band(ir, amask); goto 0; 		{ perform the jump }
23:alu := ac; if z then goto 22; 		{ 0101 = JZER }
24:goto 0;					{ jump failed }
25:alu := tir; if n then goto 27; 		{ 0110 or 0111? }
26:pc := band(ir, amask); goto 0; 		{ 0110 = JUMP }
27:ac := band(ir, amask); goto 0; 		{ 0111 = LOCO }
28:tir := lshift(ir + ir); if n then goto 40; 	{ 10xx or 11xx? }
29:tir := lshift(tir); if n then goto 35; 	{ 100x or 101x? }
30:alu := tir; if n then goto 33; 		{ 1000 or 1001? }
31:a := sp + ir; 				{ 1000 = LODL }
32:mar := a; rd; goto 7; 			
33:a := sp + ir; 				{ 1001 = STOL }
34:mar := a; mbr := ac; wr; goto 10; 		
35:alu := tir; if n then goto 38; 		{ 1010 or 1011? }
36:a := sp + ir; 				{ 1010 = ADDL }
37:mar := a; rd; goto 13; 			
38:a := sp + ir; 				{ 1011 = SUBL }
39:mar := a; rd; goto 16; 			
40:tir := lshift(tir); if n then goto 46; 	{ 110x or 111x? }
41:alu := tir; if n then goto 44; 		{ 1100 or 1101? }
42:alu := ac; if n then goto 22; 		{ 1100 = JNEG }
43:goto 0; 					
44:alu := ac; if z then goto 0; 		{ 1101 = JNZE }
45:pc := band(ir, amask); goto 0; 		
46:tir := lshift(tir); if n then goto 50; 	
47:sp := sp + (-1); 				{ 1110 = CALL }
48:mar := sp; mbr := pc; wr; 			
49:pc := band(ir, amask); wr; goto 0; 		
50:tir := lshift(tir); if n then goto 65; 	{ 1111, examine addr }
51:tir := lshift(tir); if n then goto 59; 	
52:alu := tir; if n then goto 56; 		
53:mar := ac; rd; 				{ 1111000 = PSHI }
54:sp := sp + (-1); rd; 			
55:mar := sp; wr; goto 10; 			
56:mar := sp; sp := sp + 1; rd; 		{ 1111001 = POPI }
57:rd; 						
58:mar := ac; wr; goto 10; 			
59:alu := tir; if n then goto 62; 		
60:sp := sp + (-1); 				{ 1111010 = PUSH }
61:mar := sp; mbr := ac; wr; goto 10; 		
62:mar := sp; sp := sp + 1; rd; 		{ 1111011 = POP }
63:rd; 						
64:ac := mbr; goto 0; 				
65:tir := lshift(tir); if n then goto 73; 	
66:alu := tir; if n then goto 70; 		
67:mar := sp; sp := sp + 1; rd; 		{ 1111100 = RETN }
68:rd; 						
69:pc := mbr; goto 0; 				
70:a := ac; 					{ 1111101 = SWAP }
71:ac := sp; 					
72:sp := a; goto 0; 				
73:alu := tir; if n then goto 76; 		
74:a := band(ir, smask); 			{ 1111110 = INSP }
75:sp := sp + a; goto 0; 			
76:tir := tir + tir; if n then goto 80;		
77:a := band(ir, smask); 			{ 11111110 = DESP }
78:a := inv(a); 				
79:a := a + 1; goto 75; 			
80:tir := tir + tir; if n then goto 115;		{ 1111 1111 1x = DIV or HALT }
81:alu := tir + tir; if n then goto 107;         { 1111 1111 01 = RSHIFT }
82:mar := sp; rd;			            { 1111 1111 00 = MULT }
83:rd;                                  { MBR now has number on stack }
84:a := mbr;                            { Put stack number in b register }
85:b := lshift(1);			            { Create mask to get operand }
86:b := lshift(b + 1);                  { Creating mask }
87:b := lshift(b + 1);                  { Creating mask }
88:b := lshift(b + 1);                  { Creating mask }
89:b := lshift(b + 1);                  { Creating mask }
90:b := b + 1;                          { Creating mask }
91:c := band(ir, b);                    { Put value of MULT operand in c register }
92:d := 0;                              { Set up d register to hold 'product' }
93:alu := c; if z then goto 99;         { If operand is 0. Answer is 0 }
94:d := d + a;                          { Add the result with the stack number }
95:alu := a; if n then goto 103;        { if stack number is negative check for overflow }
96:alu := d; if n then goto 102;        { if stack number is positive and result is negative, then overflow }
97:c := c + (-1); if z then goto 99;    { decrement counter until 0 }
98:goto 94;                             { if counter is still positive, keep adding }
99:mar := sp; mbr := d; wr;             { we have the result, so push it to the top of the stack }
100:wr;                                 { push it real good }
101:ac := 0; goto 0;                    { success: put 0 in ac and return }
102:ac := -1; goto 0;                   { failure: put -1 in ac and return }
103:e := inv(d);                        { if the stack number is negative }
104:e := e + 1;                         { take the absolute value of the result, i.e. positive value }
105:alu := e; if n then goto 102;       { if the result is negative then overflow }
106:goto 97;                            { go back to main adding loop }
107:a := lshift(1);			            { 1111 1111 01 = RSHIFT }
108:a := lshift(a + 1);                 { Creating mask }
109:a := lshift(a + 1);                 { Creating mask }
110:a := a + 1;                         { Creating mask }
111:b := band(ir, a);                   { Put value of RSHIFT operand in b register }
112:b := b + (-1); if n then goto 114;  { decrement counter until -1 }
113:ac := rshift(ac); goto 112;         { right shift the ac value }
114:goto 0;                             { start next instruction }
115:alu := tir + tir; if n then goto 179;   { 1111 1111 11 = HALT else DIV STARTS HERE}
116:mar := sp; sp := sp + 1; rd;        { Load top of stack }
117:rd;                                 { Reading ... }
118:a := mbr;                           { a = the dividend }
119:mar := sp; rd;                      { Load second to top of stack }
120:rd;                                 { Reading ... }
121:b := mbr;                           { b = the divisor }
122:alu := b; if z then goto 160;       { illegal - if divisor is 0: quotient = 0, remainder = -1}
123:alu := b; if n then goto 151;       { makeDPosB if divisor is negative, store abs value in d }
124:d := b;                             { if divisor is positive, store value in d }
125:alu := a; if n then goto 155;       { makeEPosA if dividend is negative, store abs value in e }
126:e := a;                             { if dividend is postive, store value in e }
127:d := inv(d);                        { Get negative of d }
128:d := d + 1;                         { so we can subtract it from e - the dividend }
129:c := e + d; if n then goto 158;     { dividend and divisor are both positive. subtract d }
130:d := inv(d);                        { Get positive value of d }
131:d := d + 1;                         { So we can reassign it to c }
132:ac := 1;                            { Counter for how many times divisor goes into dividend }
133:c := d;                             { Make copy of divisor - so we can double it }
134:c := inv(c);                        { Loop - inverse c }
135:c := c + 1;                         { Add 1 so c is negative. Now we can "subtract" it from e }
136:f := e + c; if z then goto 143;     { Store result of e - c in f, if result is 0 go to perfectDivision }
137:c := inv(c);                        { Revert c back to a positive number }
138:c := c + 1;                         { Reverting c ... }
139:alu := f; if n then goto 147;       { If result is negative goto overDivision }
140:ac := ac + 1;                       { Increase counter }
141:c := c + d;                         { Add divisor to itself because we increased counter }
142:goto 134;                           { goto Loop - repeat steps }
143:e := 0;                             { PerfectDivision - no remainder }
144:d := ac                             { Counter holds how many times divisor goes into dividend }
145:f := 0;                             { Set F as legal divison flag }
146:goto 164;                           { Check if any values were negative to adjust result }
147:e := f + d;                         { OverDivision - there is a remainder }
148:d := ac + (-1);                     { F - neg, d = divisor. Add to get remainder }
149:f := 0;                             { Set F as legal divison flag }
150:goto 164;                           { Check if any values were negative to adjust result }
151:d := inv(b);                        { makeDposB - Set d to the absolute value of b }
152:d := d + 1;                         { make d = abs(b) }
153:alu := a;                           { DEADCODE - Didn't want to renumber following lines }
154:goto 125;                           { Return to where it was called from }
155:e := inv(a);                        { makeEposA - Set e to the absolute value of a }
156:e := e + 1;                         { make e = abs(a) }
157:goto 127;                           { Return to where it was called from }
158:d := 0;                             { quot0remDiv - E is set, f is implicitly 0 and legal }
159:goto 170;                           { push the values to the stack }
160:d := 0;                             { illegalDivision - d = quotient }
161:e := (-1);                          { e = remainder }
162:f := (-1);                          { f = whether division was legal }
163:goto 170;                           { Push the values to the stack }
164:alu := a; if n then goto 167;       { checkIfNegative - if dividend is negative, go to dividendNeg}
165:alu := b; if n then goto 168;       { Dividend is positive, check if divisor is negative }
166:goto 170;                           { Push values on stack, if both are positive }
167:alu := b; if n then goto 170;       { dividendNeg - if divisor is negative go to push values }
168:d := inv(d)                         { oneNegative - else invert quotient}
169:d := d + 1;                         { Add 1 to flip sign }
170:sp := sp + (-1); 				    { PushValues - Move up the stack to prepare push }
171:sp := sp + (-1);
172:mar := sp; mbr := d; wr;            { Write quotient to stack }
173:wr;
174: sp := sp + (-1);
175:mar := sp; mbr := e; wr;            { Write remainder to stack }
176:wr;
177:ac := f; goto 0;                    { Return legal division flag in AC }
178:goto 0;
179:rd; wr; 					        { 1111 1111 11 = HALT }
