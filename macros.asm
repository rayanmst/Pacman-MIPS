.macro sprites (%posx, %posy, %movx, %movy, %id, %structname)
.data
%structname:
.align 2
	.word %posx 
	.word %posy
	.word %movx
	.word %movy
	.word %id
	
.end_macro

.macro buffer (%movx, %movy, %structname)
.data
%structname:
.align 2
	.word %movx
	.word %movy
	
.end_macro
