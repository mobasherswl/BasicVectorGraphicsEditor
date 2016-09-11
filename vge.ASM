comment #

Ahmed Mobasher Khan
mobasherswl@yahoo.com
#

.model small
.386
.stack 100h

bufsize = 200

sRect struc
	x1 DW 0
	y1 DW 0
	x2 DW 0
	y2 DW 0
	ecol DB 0
	fcol DB 0
sRect ENDS

.data
	close	sRect<619,5,629,15,4,4>; close button
	titler	sRect<0,0,639,20,8,1>; title bar
	nonclnt	sRect<0,21,60,479,8,7>;left gray area
	curdim 	sRect<>; temporary use
	clrscr	sRect<62,22,639,479,15,15>; white/drawing area
	color	sRect 16 Dup(<>); left color tool
	selcol	sRect<15,185,30,200,15,0>; selected fill color
	lincol	sRect<30,185,45,200,15,0>; selected line color
	shary	sRect 4 Dup(<,,,,15,0>); shape tool
	buffer	sRect bufsize Dup(<>); stores attributes of drawn objects
	selrct	DW	0; contains offset of selected object
	bufidx	DW	0; points to currently free buffer area
	bufcnt	DW	0; stores number of objects drawn
	curCol	DB	2; contains color of line to be drawn
	curX	DW	60; contains starting x
	curY	DW	0; contains starting y
	desX	DW	60; contains ending x
	desY	DW	479; contains ending y
	mouseX	DW	0; stores mouse x
	mouseY	DW	0; store mouse y
	lBtn	DW	0; stores status of left mouse button click 0 for none 1 for clicked
	rBtn	DW	0; right mouse button 0 for none 1 for click
	premode DB	0; stores previous graphics mode
	draw	DB	0; status whether object is being drawn or not
	shape	DB	0; which shape to be drawn 0 for HLine 1 for Vline 2 for Rect 3 to delete
	egcol	DB	0; color of edge or line
	pick	DB	0; whether object is picked or not

.code
; Sets mode
	pSetMode PROC uses ax
	
		mov ah,0fh
		int 10h
	
		;save mode 
		mov premode,al
	
		;new mode
		mov ah,00h
		mov al,12h
		int 10h 

		Ret
	pSetMode ENDP
; draws horizontal line
	pHLine PROC uses ax bx cx dx
		mov cx,curX
		mov dx,curY
		mov al,curcol
		.if cx > desX
			mov bx,cx
			mov cx,desX
			mov desX,bx
		.endif
		xor bx,bx
		mov ah,0ch
		.while cx <= desX && cx < 640 && dx < 480
			int 10h
			inc cx
		.endw
		RET
	pHLine ENDP
; draws vertical line	
	pVLine PROC uses ax bx cx dx
		mov cx,curX
		mov dx,curY
		mov al,curcol
		.if dx > desY
			mov bx,cx
			mov cx,desX
			mov desY,bx
		.endif
		xor bx,bx
		mov ah,0ch
		.while dx <= desY && cx < 640 && dx < 480
			int 10h
			inc dx
		.endw
		RET
	pVLine ENDP
; sets value of curx & cury variables
	mSetCurXY macro x,y
		mov curx,x
		mov cury,y
	endm            
; sets value of desx & desy variables
	mSetDesXY macro x,y
		mov desx,x
		mov desy,y
	endm            
;draws rectangle pointed by si
	pRect proc uses cx dx ax bx
		mov cx,(srect ptr[si]).x1
		mov dx,(srect ptr[si]).y1
		mov ax,cx
		mov bx,dx
		msetcurxy cx,dx
		mov cx,(srect ptr[si]).x2
		mov dx,(srect ptr[si]).y2
		.if ax > cx && bx > dx
			mov (srect ptr[si]).x1,cx
			mov (srect ptr[si]).x2,ax
			mov (srect ptr[si]).y1,dx
			mov (srect ptr[si]).y2,bx
		.elseif ax > cx && bx < dx
			mov (srect ptr[si]).x1,cx
			mov (srect ptr[si]).x2,ax
		.elseif ax < cx && bx > dx
			mov (srect ptr[si]).y1,dx
			mov (srect ptr[si]).y2,bx
		.endif
		
		mov cx,(srect ptr[si]).x1
		mov dx,(srect ptr[si]).y1
		msetcurxy cx,dx
		mov cx,(srect ptr[si]).x2
		mov dx,(srect ptr[si]).y2
		msetdesxy cx,dx
		xor bx,bx
		.if curx != cx && cury != dx
			inc curx
			inc cury
			dec desx
			inc bx
		.endif		
		mov cl,(srect ptr[si]).fcol
		mov curCol,cl
		mov cx,cury
		.while cx < desy
			call phline
			inc cx
			mov cury,cx                
		.endw
		.if bx == 1
			dec curx
			dec cury
			inc desx
		.endif
		mov cx,(srect ptr[si]).y1
		mov cury,cx
		mov cl,(srect ptr[si]).ecol
		mov curCol,cl
		call phline
		call pvline
		mov cx,desy
		mov cury,cx
		call phline
		mov cx,(srect ptr[si]).y1
		mov cury,cx
		mov cx,desx
		mov curx,cx
		call pvline
		ret 
	pRect endp
; checks for mouse	
	pResetMouse proc uses ax
		clc
		mov ax,0
		int 33h
		.if ax==0
			stc
		.endif
		ret
	pResetMouse endp
; shows mouse cursor	
	pShowMouse proc uses ax
		mov ax,1
		int 33h
		ret
	pShowMouse endp
; hides mouse cursor	
	pHideMouse proc uses ax
		mov ax,2
		int 33h
		ret
	pHideMouse endp
; gives coordinates of mouse cursor & mouse buttons status
	pMouseStatus proc uses ax bx cx dx
		mov lBtn,0
		mov rBtn,0
		mov ax,3
		int 33h
		mov mousex,cx
		mov mousey,dx
		.if bx==1
			mov lBtn,1
		.elseif bx==2
			mov rBtn,1
		.elseif bx==3
			mov rBtn,1
			mov lBtn,1
		.endif
		ret
	pMouseStatus endp
; draws color tools on left	
	pDrawColor proc uses si dx cx ax
		mov si,offset color
		mov dx,60
		xor cx,cx
		.while dx < 166
			mov (sRect ptr[si]).x1,15
			mov (sRect ptr[si]).y1,dx
			mov (sRect ptr[si]).x2,30
			add dx,15
			mov (sRect ptr[si]).y2,dx
			mov (sRect ptr[si]).ecol,15
			mov (sRect ptr[si]).fcol,cl
			
			call prect
			
			add si,size srect
			sub dx,15
			inc cl
			
			mov (sRect ptr[si]).x1,30
			mov (sRect ptr[si]).y1,dx
			mov (sRect ptr[si]).x2,45
			add dx,15
			mov (sRect ptr[si]).y2,dx
			mov (sRect ptr[si]).ecol,15
			mov (sRect ptr[si]).fcol,cl
			
			call prect
			
			add si,size srect
			inc cl
		.endw
		mov si,offset selcol
		call prect
		mov si,offset lincol
		call prect		
		ret
	pDrawColor endp
; copies values of si to curdim	
	mCopyToCurdim macro
		push ax
			mov ax,(srect ptr[si]).x1
			mov curdim.x1,ax
			mov ax,(srect ptr[si]).y1
			mov curdim.y1,ax
			mov ax,(srect ptr[si]).x2
			mov curdim.x2,ax
			mov ax,(srect ptr[si]).y2
			mov curdim.y2,ax
			mov al,(srect ptr[si]).ecol
			mov curdim.ecol,al
			mov al,(srect ptr[si]).fcol
			mov curdim.fcol,al
		pop ax
	endm
; chooses selected color from tool	
	pColorChooser proc uses si cx dx ax bx
		mov si,offset color
		mov cx,mousex
		mov dx,mousey
		xor bx,bx
		.while bx < 16
			mCopyToCurdim
			mov al,(srect ptr[si]).fcol
			.if cx > curdim.x1 && cx < curdim.x2 && dx > curdim.y1 && dx < curdim.y2
				.if  egcol == 1 && lincol.fcol != al
					mov si,offset lincol
					mov lincol.fcol,al
					call phidemouse
					call prect
					call pshowmouse
					jmp pccexit
				.elseif egcol == 0 && selcol.fcol != al
					mov si,offset selcol
					mov selcol.fcol,al
					call phidemouse
					call prect
					call pshowmouse
					jmp pccexit
				.endif
			.endif
			add si,size srect
			inc bx
		.endw
		pccexit: ret
	pColorChooser endp
; changes color of selected tools	
	mSelHLine macro col
        mov curx,18
        mov cury,212
        mov desx,27
        mov desy,217
        mov curcol,col
        call phline
	endm
; changes color of selected tools		
	mSelVLine macro col
	    mov curx,38
        mov cury,207
        mov desx,38
        mov desy,217
        mov curcol,col
        call pvline
	endm
; changes color of selected tools		
	mSelRect macro col
        mov curdim.x1,17
        mov curdim.y1,222
        mov curdim.x2,28
        mov curdim.y2,233
        mov curdim.ecol,col
        mov curdim.fcol,0
        mov si,offset curdim
        call prect
	endm
; draws shape tools	
	pDrawShape proc uses si dx
		mov si,offset shary
		mov dx,205
		.while dx < 221
			mov (sRect ptr[si]).x1,15
			mov (sRect ptr[si]).y1,dx
			add dx,15
			mov (sRect ptr[si]).x2,30
			mov (sRect ptr[si]).y2,dx
            
            call prect 
           
			add si,size srect
			sub dx,15

			mov (sRect ptr[si]).x1,30
			mov (sRect ptr[si]).y1,dx
			add dx,15
			mov (sRect ptr[si]).x2,45
			mov (sRect ptr[si]).y2,dx
			
			call prect
			
			add si,size srect
		.endw
		mov dl,7
		mSelHLine dl

		mov dl,4
		mSelVLine dl
		mSelRect dl
       
		ret
	pDrawShape endp
; selects shape clicked by the user	
	pChooseShape proc uses si cx dx ax bx
		mov si,offset shary
		xor ax,ax
		mov cx,mousex
		mov dx,mousey
		.while al < 4
			mCopyToCurdim
			.if cx > curdim.x1 && cx < curdim.x2 && dx > curdim.y1 && dx < curdim.y2 && shape != al
				mov shape,al
				mov dl,4
				call phidemouse
				mSelHLine dl
				mSelVLine dl
				mSelRect dl
				mov dl,7
				.if al == 0
					mSelHLine dl
				.elseif al == 1
					mSelVLine dl
				.elseif al == 2
					mSelRect dl
				.endif
				call pshowmouse
				jmp pcsexit
			.endif
			add si,size srect
			inc al
		.endw
		pcsexit: ret
	pChooseShape endp
; checks which color selection is selected	
	pEdgeColor proc uses cx dx
		mov cx,mousex
		mov dx,mousey
		.if cx > lincol.x1 && cx < lincol.x2 && dx > lincol.y1 && dx < lincol.y2
			mov egcol,1
		.elseif cx > selcol.x1 && cx < selcol.x2 && dx > selcol.y1 && dx < selcol.y2
			mov egcol,0
		.endif
		ret
	pEdgeColor endp
; adds objects data to buffer array
	pAddBuffer proc uses si ax
		mov si,bufidx
		mov ax,curx
		mov (srect ptr[si]).x1,ax
		mov ax,cury
		mov (srect ptr[si]).y1,ax
		mov ax,desx
		mov (srect ptr[si]).x2,ax
		mov ax,desy
		mov (srect ptr[si]).y2,ax
		mov al,selcol.fcol
		mov (srect ptr[si]).fcol,al
		mov al,lincol.fcol
		mov (srect ptr[si]).ecol,al
		add si,size srect
		mov bufidx,si
		inc bufcnt
		ret
	pAddBuffer endp
; checks for selection of objects
	pChooseRect proc uses si cx dx ax
		.if bufcnt > 0
			mov si,bufidx
			sub si,size srect		
			mov ax,bufcnt
			mov cx,mousex
			mov dx,mousey
			.while ax > 0
				mCopyToCurdim
				.if cx >= curdim.x1 && cx <= curdim.x2 && dx >= curdim.y1 && dx <= curdim.y2
					mov pick,1
					mov selrct,si
					jmp pcaExit
				.endif
				sub si,size srect
				dec ax
			.endw
		.endif
		pcaExit: ret
	pChooseRect endp
; repaints all objects drawn	
	pRepaintAll proc uses si ax cx dx bx
		mov si,offset buffer
		xor ax,ax
		.while ax < bufcnt
			mov cx,(srect ptr[si]).x1
			mov dx,(srect ptr[si]).y1
			mSetCurXY cx,dx
			mov cx,(srect ptr[si]).x2
			mov dx,(srect ptr[si]).y2
			mSetDesXY cx,dx
			mov bl,(srect ptr[si]).ecol
			mov curCol,bl
			.if curx == cx
				call pvline
			.elseif cury == dx
				call phline
			.else
				call prect
			.endif
			add si,size srect
			inc ax
		.endw
		ret
	pRepaintAll endp
; places object at the specific position	
	pDropRect proc uses cx dx si
		mov cx,mousex
		mov dx,mousey
		mov curdim.x1,cx
		mov curdim.y1,dx
		mov si,selrct
		mov cx,(srect ptr[si]).x1
		mov dx,(srect ptr[si]).x2
		sub dx,cx
		add dx,curdim.x1
		mov curdim.x2,dx
		mov cx,(srect ptr[si]).y1
		mov dx,(srect ptr[si]).y2
		sub dx,cx
		add dx,curdim.y1
		mov curdim.y2,dx
		mov cl,(srect ptr[si]).ecol
		mov curdim.ecol,cl
		mov cl,(srect ptr[si]).fcol
		mov curdim.fcol,cl
		
		mov (srect ptr[si]).ecol,15
		mov (srect ptr[si]).fcol,15
		call prect
		
		mov cx,curdim.x1
		mov (srect ptr[si]).x1,cx
		mov cx,curdim.y1
		mov (srect ptr[si]).y1,cx
		mov cx,curdim.x2
		mov (srect ptr[si]).x2,cx
		mov cx,curdim.y2
		mov (srect ptr[si]).y2,cx  
		mov cl,curdim.ecol
		mov (srect ptr[si]).ecol,cl
		mov cl,curdim.fcol
		mov (srect ptr[si]).fcol,cl
		
		call pRepaintAll

		mov pick,0
		ret
	pDropRect endp
; deletes selected object	
	pDelRect proc uses si di
		mov si,selrct
		mov (srect ptr[si]).ecol,15
		mov (srect ptr[si]).fcol,15
		call prect
		.if bufcnt == 1
			mov bufidx,offset buffer
			mov bufcnt,0
		.else
			mov si,selrct
			mov di,si
			add si,size srect
			.while si != bufidx
				mCopyToCurdim
				mov cx,curdim.x1
				mov (srect ptr[di]).x1,cx
				mov cx,curdim.y1
				mov (srect ptr[di]).y1,cx
				mov cx,curdim.x2
				mov (srect ptr[di]).x2,cx
				mov cx,curdim.y2
				mov (srect ptr[di]).y2,cx
				mov cl,curdim.ecol
				mov (srect ptr[di]).ecol,cl
				mov cl,curdim.fcol
				mov (srect ptr[di]).fcol,cl
				add si,size srect
				add di,size srect
			.endw
			mov bufidx,di
			dec bufcnt
		.endif
		mov pick,0
		call pRepaintAll
		
		ret
	pDelRect endp
; clears all drawing area & resets object array	
	pClearAll proc uses si
		mov bufidx,offset buffer
		mov bufcnt,0
		mov pick,0
		mov si,offset clrscr
		call prect
		ret
	pClearAll endp
; checks whether click was in the close area
	pclose proc uses cx dx
		mov cx,mousex
		mov dx,mousey
		.if cx >= close.x1 && cx <= close.x2 && dx >= close.y1 && dx <= close.y2
			.exit
		.endif		
		ret
	pclose endp
	
	main:
		mov ax,@data
		mov ds,ax

		mov bufidx,offset buffer

		call pSetMode
		mov si,offset titler
		call prect
		mov si,offset close
		call prect
		mov si,offset nonclnt
		call prect
		call pDrawColor
		call pDrawShape
 		call pClearAll
		call pResetMouse
		call pShowMouse
		
		.while bufcnt < bufsize
			call pMouseStatus
			.if rBtn == 1 && shape == 3
				call phidemouse
				call pClearAll
				call pshowmouse
			.elseif lBtn == 1 && draw == 0
				.if mousex > 61 && mousey > 21
					mov draw,1
					mov cx,mousex
					mov curx,cx
					mov cx,mousey
					mov cury,cx
					call pChooseRect
				.else
					call pclose
					call pEdgeColor
					call pcolorchooser
					call pChooseShape
				.endif
			.elseif lBtn == 0 && draw == 1
				.if mousex > 61 && mousey > 21
					.if pick == 0
						mov draw,0
						mov cx,mousex
						mov desx,cx
						mov cx,mousey
						mov desy,cx
						mov cl,lincol.fcol
						mov curCol,cl
						call phidemouse
						.if shape == 0
							mov cx,cury
							mov desy,cx
							call pAddBuffer
							call phline
						.elseif shape == 1
							mov cx,curx
							mov desx,cx
							call pAddBuffer
							call pvline
						.elseif shape == 2
							mov cx,curx
							mov curdim.x1,cx
							mov cx,cury
							mov curdim.y1,cx
							mov cx,desx
							mov curdim.x2,cx
							mov cx,desy
							mov curdim.y2,cx
							mov cl,lincol.fcol
							mov curdim.ecol,cl
							mov cl,selcol.fcol
							mov curdim.fcol,cl
							mov si,offset curdim
							call prect
							mov cx,curdim.x1
							mov curx,cx
							mov cx,curdim.y1
							mov cury,cx
							mov cx,curdim.x2
							mov desx,cx
							mov cx,curdim.y2
							mov desy,cx
							call pAddBuffer
						.endif
						call pshowmouse
					.elseif pick == 1
						mov draw,0
						call phidemouse
						.if shape != 3
							call pDropRect
						.else
							call pDelRect
						.endif
						call pshowmouse
					.endif
				.endif
			.endif
		.endw

		exitprog: .exit
	end main