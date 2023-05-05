il 9,256
il 18, 512
il 10,1
il 13,4
il 15,16
fsm 11,10
il 0,4
sf 0,10,0
il 1,4
sf 1,10,1
il 2,0
il 3,4
sf 3,10,3
mpya 12,0,13,3
mpy 14,12,15
mpya 16,3,13,1
mpy 17,16,15
a 21,17,9
lqd 6, 14, 0
lqd 7,21,0
fma 2,6,7,2
brnz 3,-12
mpya 19,0,13,1
mpy 20,19,15
a 22,20,18
stqd 2,22,0
brnz 1,-21
brnz 0,-23
nop
lnop
nop
lnop