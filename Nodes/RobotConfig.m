% Stores M frame and Body frame screw axes (B), allows for offsets

M=[ 1 0 0 10;
   0 1 0 10;
   0 0 1 10;
   0 0 0 1];

w1=[0 ; 0 ; 1];
w2=[0 ; 1 ; 0];
w3=[0 ; 1 ; 0];
w4=[0 ; 0 ; 1];
w5=[0 ; 1 ; 0];

r1=[0 ; 0 ; 0];
r2=[2 ; 0 ; 0];
r3=[4 ; 0 ; 0];
r4=[6 ; 2 ; 0];
r5=[8 ; 2 ; 0];

v1=cross(r1,w1);
v2=cross(r2,w2);
v3=cross(r3,w3);
v4=cross(r4,w4);
v5=cross(r5,w5);

S1=[w1;v1];
S2=[w2;v2];
S3=[w3;v3];
S4=[w4;v4];
S5=[w5;v5];