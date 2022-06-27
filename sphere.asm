.model tiny
.code
.startup
.386
	mov bx,118h
	mov ax,4F02h
	int 10h
	push 0A000h
	pop es
;	xor bp,bp		; current bank. very unlikely bp==2Fh at startup

	finit
				;ST(0)	 ST(1)	 ST(2)	 ST(3)	 ST(4)	 ST(5)	 ST(6)	 ST(7)
	mov di,767
	fild y			;j
@l1:	mov dx,di
	shr dx,4
	cmp dx,bp
	je short @skip
	xor bx,bx
;	push bx
	mov ax,4F05h
	int 10h
;	pop bx	; should be 0 after int
	mov bp,dx
@skip:	mov si,1023
	fld ST(0)		;j	j
	fld ST(0)		;j	j	j
	fadd lc			;ly	j	j
	fstp ly			;j	j
	fmul ST(0),ST(0)	;j2	j
	fild x			;i	j2	j
@l2:	fld ST(0)		;i	i	j2	j
	fld ST(0)		;i	i	i	j2	j
	fadd lc			;lx	i	i	j2	j
	fstp lx			;i	i	j2	j
	fmul ST(0),ST(0)	;i2	i	j2	j
	fadd ST(0),ST(2)	;Sum	i	j2	j
	fsubr r2		;r2-Sum	i	j2	j
	ftst
	fstsw ax
	sahf
	jc short @no
	fsqrt			;k	i	j2	j
	fld ST(0)		;k	k	i	j2	j
	fsubr lcz		;lz	k	i	j2	j
	fld ST(1)		;k	lz	k	i	j2	j
	fdiv r			;ca	lz	k	i	j2	j
	fxch ST(1)		;lz	ca	k	i	j2	j
	fld ST(0)		;lz	lz	ca	k	i	j2	j
	fmulp ST(3),ST(0)	;lz	ca	lz*k	i	j2	j
	fmul ST(0),ST(0)	;lz2	ca	lz*k	i	j2	j
	fld ly			;ly	lz2	ca	lz*k	i	j2	j
	fld ST(0)		;ly	ly	lz2	ca	lz*k	i	j2	j
	fmul ST(0),ST(7)	;ly*j	ly	lz2	ca	lz*k	i	j2	j
	faddp ST(4),ST(0)	;ly	lz2	ca	lzk+lyj	i	j2	j
	fmul ST(0),ST(0)	;ly2	lz2	ca	lzk+lyj	i	j2	j
	faddp ST(1),ST(0)	;lz2+ly2 ca	lzk+lyj	i	j2	j
	fld lx			;lx	lz2+ly2 ca	lzk+lyj	i	j2	j
	fld ST(0);		;lx	lx	lz2+ly2 ca	lzk+lyj	i	j2	j
	fmul ST(0),ST(5)	;lx*i	lx	lz2+ly2 ca	lzk+lyj	i	j2	j
	faddp ST(4),ST(0)	;lx	lz2+ly2	ca	s	i	j2	j
	fmul ST(0),ST(0)	;lx2	lz2+ly2	ca	s	i	j2	j
	faddp ST(1),ST(0)	;d2	ca	s	i	j2	j
	fsqrt			;d	ca	s	i	j2	j
	fmul r			;300d	ca	s	i	j2	j
	fdivp ST(2),ST(0)	;ca	-ct	i	j2	j
	fld ST(0)		;ca	ca	-ct	i	j2	j
	fmul ST(0),ST(2)	;-cact	ca	-ct	i	j2	j
	fmul ST(0),ST(0)	;cact2	ca	-ct	i	j2	j
	fmul ST(0),ST(0)	;cact4	ca	-ct	i	j2	j
	fxch ST(2)		;-ct	ca	cact4	i	j2	j
	fsubp ST(1),ST(0)	;ca+ct	cact4	i	j2	j
	fmul n01		;0.1()	cact4	i	j2	j
	faddp ST(1),ST(0)	;q	i	j2	j
	fmul n320		;320q	i	j2	j
	fistp color		;i	j2	j

	mov ax,color
	add al,80
	jmp short @pix

@no:	fcomp			;i	j2	j
	add cx,si
	xor cx,di
	rol cx,cl
	mov al,cl

@pix:	mov ah,al
	sub bx,4
	mov es:[bx],ax
	mov es:[bx+2],al

	fld1			;1	i	j2	j
	fsubp ST(1),ST(0)	;i-1	j2	j
	dec si
	jns @l2
	fcompp			;j
	fld1			;1	j
	fsubp ST(1),ST(0)	;j-1
	dec di
	jns @l1
;	fcomp           ; no need to clear stack at exit

	mov ah,10h
	int 16h
	mov ax,3
	int 10h
	retn
.data
x		dw	512
y		dw	384
n01		dd	0.1
n320		dd	320.0
r		dd	300.0
r2		dd	90000.0
lc		dd	4000.0
lcz		dd	-2000.0
ly		dt	?
lx		dt	?
lz		dt	?
color		dw	?
end
