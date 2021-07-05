; ##############################
; # Written by: Kolet Ido      #
; #	Teacher: Weinstein Arik    #
; #	School: Amit Bar-Ilan      #
; #	Year: 2020                 #
; ##############################

.286													; change to .286 proccesor in order to use bitmap
IDEAL
MODEL small
STACK 100h

DATASEG

;==================================================================================================================================================


; ###########################################################
; # Constants: Colors									    #
; ###########################################################
BLU equ 0C7h											; Blue color
GRN equ 2												; Green color
RED equ 4												; Red color
YLO equ 2Bh												; Yellow color
GRY equ 1Ah												; Grey color
BLK equ 0												; Black color
WHT equ 15 												; White color 

; ###########################################################
; # Constants: Timer									    #
; ###########################################################
CLOCK equ es:6Ch
TIME_DELAY_ALIENS 	equ 5
TIME_DELAY_SHOOT 	equ 2

; ###########################################################
; # Constants: Shoot size									#
; ###########################################################
SHOOT_WIDTH equ 1
SHOOT_HEIGHT equ 6

; ###########################################################
; # Constants: Check aliens									#
; ###########################################################
IGNORE_MSB_MASK equ 10000000b

; ###########################################################
; # Constants: Spaceship & Aliens size						#
; ###########################################################
SPACESHIP_Y equ 172
SPACESHIP_X_SIZE equ 1Bh
SPACESHIP_XY_SIZE equ 191Bh

ALIEN_X_SIZE  equ 16h
ALIEN_XY_SIZE equ 1016h

; ###########################################################
; # Constants: Aliens get down when touch side				#
; ###########################################################
ALIEN_GET_DOWN equ 5

;****************************************************************************************************

; ###########################################################
; # Variables: Game flag								    #
; ###########################################################
run db 1

; ###########################################################
; # Variables: score									    #
; ###########################################################
score_msg	db 'Score: $'
score 		db 0

; ###########################################################
; # Variables: Screens									    #
; ###########################################################
start_bg db 'mainBG.bmp',0
lose_bg db 'lose.bmp',0
win_bg db 'win.bmp',0
inst_bg	db 'inst.bmp',0

; ###########################################################
; # Variables: Sound									    #
; ###########################################################
no_music dw '$'
music dw offset no_music
note dw 0

sound_win 	dw 1522, 1522, 30, 1140, 1140, 30, 905, 905, 905, 30, 761, 761
			dw 30, 30, 30, 30, 905, 905, 30, 761, 761, 761, 761, 761, '$'
			
sound_lose 	dw 4832, 4832, 4832, 4832, 30, 5119, 5119, 5119, 5119, 30
			dw 5424, 5424, 5424, 5424, 30, 5746, 5746, 5746, 5746, 30
			dw 6088, 6088, 6088, 6088, 30, 6450, 6450, 6450, 6450, 30
			dw 6833, 6833, 6833, 6833, 6833, 6833, 6833, '$'
			
sound_gun 	dw 2048, 1024, 512, 256, 128, '$'

sound_hit  	dw 1208, 1521, 1208,'$'

; ###########################################################
; # Variables: Timer				 	 				    #
; ###########################################################
last_music dw ?
last_aliens dw ?
last_shoot dw ?

; ###########################################################
; # Variables: Shoot				 	 				    #
; ###########################################################
shoot_flag db 0
shoot_x dw ?
shoot_y dw ?

; ###########################################################
; # Variables: Image file opening	 	 				    #
; ###########################################################
file_name 	db ?
file_handle dw ?
header 		db 54 dup (0)
palette 	db 256*4 dup (0)
scr_line 	db 320 dup (0)
error_msg 	db 'Error', 13, 10,'$'

; ###########################################################
; # Bitmap: General variables							    #
; ###########################################################	
image_x_size  db ?
image_yx_size dw ?
image_x       dw ?
image_y       dw ?
image   	  dw ?
	
; ###########################################################
; # Bitmap: Spaceship & info							    #
; ###########################################################	
spaceship_x dw 146

spaceship  	db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU	
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED ,RED ,RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU		
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU	
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU		
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED ,RED ,BLK ,BLK ,BLK ,RED ,RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU		
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED ,RED ,BLK ,BLK ,GRN ,BLK ,BLK ,RED ,RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU		
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED ,RED ,BLK ,BLK ,GRN ,GRN ,GRN ,BLK ,BLK ,RED ,RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU		
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED ,RED ,RED ,BLK ,GRN ,GRN ,GRN ,GRN ,GRN ,BLK ,RED ,RED ,RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU		
			db BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED ,RED ,RED ,RED ,BLK ,GRN ,GRN ,GRN ,GRN ,GRN ,BLK ,RED ,RED ,RED ,RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU		
			db BLU ,BLU ,BLU ,BLU ,RED ,RED ,RED ,RED ,RED ,RED ,BLK ,BLK ,GRN ,GRN ,GRN ,BLK ,BLK ,RED ,RED ,RED ,RED ,RED ,RED ,BLU ,BLU ,BLU ,BLU		
			db BLU ,BLU ,BLU ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,BLK ,BLK ,GRN ,BLK ,BLK ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,BLU ,BLU ,BLU		
			db BLU ,BLU ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,BLK ,BLK ,BLK ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,BLU ,BLU
			db BLU ,BLU ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,BLU ,BLU
			db RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED
			db RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED		
			db RED ,RED ,RED ,RED ,BLU ,BLU ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,RED ,BLU ,BLU ,RED ,RED ,RED ,RED		
			db RED ,RED ,RED ,RED ,BLU ,BLU ,RED ,RED ,GRY ,GRY ,RED ,RED ,GRY ,GRY ,GRY ,RED ,RED ,GRY ,GRY ,RED ,RED ,BLU ,BLU ,RED ,RED ,RED ,RED		
			db RED ,RED ,BLU ,BLU ,BLU ,BLU ,RED ,RED ,GRY ,GRY ,RED ,RED ,GRY ,GRY ,GRY ,RED ,RED ,GRY ,GRY ,RED ,RED ,BLU ,BLU ,BLU ,BLU ,RED ,RED		
			db RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRY ,GRY ,BLU ,BLU ,GRY ,GRY ,GRY ,BLU ,BLU ,GRY ,GRY ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED		
			db RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRY ,GRY ,BLU ,BLU ,GRY ,GRY ,GRY ,BLU ,BLU ,GRY ,GRY ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED	
			db RED ,RED ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,YLO ,YLO ,BLU ,BLU ,YLO ,YLO ,YLO ,BLU ,BLU ,YLO ,YLO ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,RED ,RED		
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,YLO ,YLO ,BLU ,BLU ,YLO ,YLO ,YLO ,BLU ,BLU ,YLO ,YLO ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU		
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,YLO ,YLO ,BLU ,BLU ,YLO ,YLO ,YLO ,BLU ,BLU ,YLO ,YLO ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU
			db BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,YLO ,YLO ,YLO ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU		

; ###########################################################
; # Bitmap: alien & info								    #
; ###########################################################	
alien_x dw 26											; Single alien current location (X)	
alien_y dw 20											; Single alien current location (Y)	

start_x dw 26											; Aliens block borders
start_y dw 20
end_x dw 299
end_y dw 120

direction db 1											; Aliens movement direction

alien_row_1 db 01111111b 								; Alive aliens = 1, death = 0 (MSB doesn't count)
alien_row_2	db 01111111b
alien_row_3	db 01111111b
alien_row_4	db 01111111b

prev_alien_x dw 26										; Previous aliens block borders
prev_alien_y dw 20	
prev_start_x dw 26
prev_start_y dw 20

hands_flag db 0											; Hands up / down bitmap is drawn

num_bit dw 7											; side_left 0's index

side_right 	db 11111110b								; Most right alien alive
side_left	db 10111111b								; Most left alien alive

cur_alien_row db ?										; Row for current handeling	   

cur_bit db ?											; Used for mask - checking which aliens is alive
					
alien_down 	db BLU	,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU
			db BLU	,BLU ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU
			db GRN	,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN
			db GRN 	,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN
			db GRN 	,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN
			db GRN 	,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN
			db GRN 	,GRN ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN
			db GRN 	,GRN ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN
			db BLU 	,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU
			
alien_up 	db BLU	,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU
			db GRN 	,GRN ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN
			db GRN 	,GRN ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN
			db GRN 	,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN
			db GRN 	,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN
			db GRN 	,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN
			db GRN	,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN
			db GRN	,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN
			db GRN 	,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN
			db BLU 	,BLU ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,BLU ,BLU ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU
			db BLU 	,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU
			db BLU 	,BLU ,GRN ,GRN ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,BLU ,GRN ,GRN ,BLU ,BLU


;==================================================================================================================================================

CODESEG

;==================================================================================================================================================

; Macros ;
;****************************************************************************************************

; ###########################################################
; # Macro: MAC_PRINT_SQUARE                  				#
; # 	   print square on canvas by params					#
; ###########################################################
macro MAC_PRINT_SQUARE x1, y1, x2, y2, color
	push x1											; Insert params for print_square proc
	push y1
	push x2
	push y2
	push color
	call print_square								; Draw the square
endm MAC_PRINT_SQUARE


; ###########################################################
; # Macro: MAC_LOAD_IMAGE    		               			#
; # 	   Open BG image file, print it to screen and       #
; # 	   close it.									    #
; ###########################################################
macro MAC_LOAD_IMAGE file									
	lea ax, [file]									; Move the offset of the image file into ax 
    call open_file									; Open file and draw image
    call read_header
    call read_palette
    call copy_pal
    call copy_bitmap
	call close_file									; Close file
endm MAC_LOAD_IMAGE

; ###########################################################
; # Macro: MAC_START_SOUND   		               			#
; # 	   Open the speaker & play frequency.			    #
; ###########################################################
macro MAC_START_SOUND
	in al, 61h 
	or al, 00000011b 
	out 61h, al 
	mov al, 0b6h 
	out 43h, al 
	mov ax, [note]
	out 42h, al 
	mov al, ah 
	out 42h, al									; Sending upper byte
endm MAC_START_SOUND

; ###########################################################
; # Macro: MAC_STOP_SOUND   		               			#
; # 	   Close the speaker.							    #
; ###########################################################
macro MAC_STOP_SOUND
	in  al, 61h 
	and  al, 11111100b 
	out  61h, al
endm MAC_STOP_SOUND


;****************************************************************************************************
; Upload background images ;
;****************************************************************************************************

; ###########################################################
; # procedure: open_file    		       					#
; # 	  	   get the file offset in ax and open it -		#
; # 	       if there's a problem print error message.	#
; #			   {From the book pages 280-285}				#
; ###########################################################

proc open_file
	mov dx, ax											; move dx, offset file_name
    mov ah, 3Dh											; open accsses mode
    xor al, al											; read only  
    int 21h

    jc openerror										; if there's an error - print error message
    mov [file_handle], ax								; move the file handle into it var
    ret

openerror:												; print error message
    mov dx, offset error_msg
    mov ah, 9h
    int 21h
    ret
endp open_file


; ###########################################################
; # procedure: read_header  		       				    #
; # 	  	   Read BMP file header, 54 bytes  				#
; #			   {From the book pages 280-285}				#
; ###########################################################

proc read_header
    mov ah,3fh											
    mov bx, [file_handle]
    mov cx,54
    mov dx,offset header
    int 21h
    ret
endp read_header


; ###########################################################
; # procedure: read_palette  		   					    #
; # 	  	   Read BMP file color palette, 			    #
; #      	   256 colors * 4 bytes (400h)    			    #
; #			   {From the book pages 280-285}				#
; ###########################################################

proc read_palette
    mov ah,3fh
    mov cx,400h
    mov dx,offset palette
    int 21h
    ret
endp read_palette


; ###########################################################
; # procedure: copy_pal		  		       					#
; # 	   	   Copy the colors palette to the video memory  #
; #        	   The number of the first color should be		#
; #        	   sent to port 3C8h.							#
; #        	   The palette is sent to port 3C9h				#
; #			   {From the book pages 280-285}				#														
; ###########################################################

proc copy_pal	
    mov si,offset palette								; Copy starting color to port 3C8h
    mov cx,256
    mov dx,3C8h
    mov al,0

    out dx,al											

    inc dx												; Copy palette itself to port 3C9h

PalLoop:
														; Note: Colors in a BMP file are saved as BGR values rather than RGB.

    mov al,[si+2] 										; Get red value.
    shr al,2 											; Max. is 255, but video palette maximal

    out dx,al 											; Send it.
    mov al,[si+1] 										; Get green value.
    shr al,2
    out dx,al 											; Send it.
    mov al,[si] 										; Get blue value.
    shr al,2
    out dx,al 											; Send it.
    add si,4 											; Point to next color.

														; (There is a null chr. after every color.)
    loop PalLoop
    ret
endp copy_pal


; ###########################################################
; # procedure: copy_bitmap	  		       					#
; # 	   	   BMP graphics are saved upside-down.		    #
; #        	   Read the graphic line by line 				#
; #        	   (200 lines in VGA format),					#
; #        	   displaying the lines from bottom to top.		#
; #			   {From the book pages 280-285}				#														
; ###########################################################

proc copy_bitmap
    mov ax, 0A000h
    mov es, ax
    mov cx,200
	
PrintBMPLoop:
    push cx
														; di = cx*320, point to the correct screen line
	dec cx
    mov di,cx
    shl cx,6
    shl di,8
    add di,cx
														; Read one line
    mov ah,3fh
    mov cx,320
    mov dx, offset scr_line
    int 21h
														; Copy one line into video memory
    cld 
														; Clear direction flag, for movsb
    mov cx,320
    mov si,offset scr_line
    rep movsb 
														; Copy line to the screen
    pop cx
    loop PrintBMPLoop
    ret
endp copy_bitmap


; ###########################################################
; # procedure: close_file	  		       					#
; # 	   	   close the file in file_handle				#
; #			   {From the book pages 280-285}				#														
; ###########################################################

proc close_file
	mov ah,3Eh
	mov bx, [file_handle]
	int 21h
	ret
endp close_file

;****************************************************************************************************
; Draw squar / line ;
;****************************************************************************************************

; ###########################################################
; # Procedure: h_line                                       #
; # This procedure draws an horizontal line according to a  #
; # given location.                                         #
; #                                                         #
; # Input parametrs:                                        #
; #  1. [bp+10] - x first pixel  (left column)              #
; #  2. [bp+ 8] - x last pixel   (right column)             #
; #  3. [bp+ 6] - row number                                #
; #  4. [bp+ 4] - color                                     #
; #                                                         #
; ###########################################################

proc h_line
	push bp           
	mov bp,sp

	; save registers
	push ax                
	push bx
	push cx
	push dx
	
	mov cx, [bp+10]        		 					 	; x 1st (left) pixel to draw, used also as loop counter 
	
HLoop:
	  mov ah, 0ch              							; int 10h/0ch
	  mov bx, [bp+4]          							; color -> al 
	  mov al, bl 		       
	  mov dx, [bp+6]	       							; raw  -> dx
	  int 10h                  							; draw the pixel 
	  inc cx
	  cmp cx, [bp+8]	         						; x first == x last 
	  jbe HLoop                							; if below or equal do additional iteration

	; restore registers 	
	pop dx            
	pop cx
	pop bx
	pop ax
	pop bp
	
	ret 8
endp h_line

; ###########################################################
; # Procedure: print_square                                 #
; #                                                         #
; # This procedure draws square ( or rectangular) according #
; # x, y location and height/width                          #
; #                                                         #
; # Input parametrs:                                        #
; #  1. [bp+12] - x first pixel  (1st col)                  #
; #  2. [bp+10] - y first pixel  (lst row )                 #
; #  3. [bp+ 8] - square/rect width  (x first+width)        #
; #  4. [bp+ 6] - square/rect. height (y first+height)      #
; #  5. [bp+ 4] - color                                     #
; #                                                         #
; ###########################################################
proc print_square
    push bp
	mov bp, sp
	
	push ax              								; save registers
	push cx
	push di
	
	mov ax, [bp + 12]   							  	; get X first location (most left)
	add ax, [bp + 8]      								; last X =  X first + Width -> ax
	 
	mov di, [bp + 10]     								; Y first to di 
	mov cx, [bp + 6]      								; height -> cx for loop counting
	
PrintSquar_loop:
	push [bp+ 12]           							; x first 
    push ax                						 		; x last 
    push di	                							; y (row number)
	push [bp + 4]          								; color
	 
	call h_line              							; draw single hor. line
	inc di                  							; inc y value
    loop PrintSquar_loop   								; go print new hor. line 
	
	pop di               								; restore registers
	pop cx
	pop ax
	pop bp

	ret 10  
endp print_square

;****************************************************************************************************
; Draw bitmap ;
;****************************************************************************************************

; ###########################################################
; # procedure: draw_bitmap & put_pixel       				#
; # 	   	   draws bitmap according to params:			#
; #        	   image_yx_size, image_x, image_y, image.		#
; #			   {From auxiliary package}						#
; ###########################################################

proc draw_bitmap
	mov ax,0a000h										; Advanced vga ???
    mov es,ax											; Advanced vga ???
	
    mov dx, [image_yx_size]
    mov ax, [image_x]
    mov bx, [image_y]
    mov si, [image] 
    
Cycle:
    mov cl, [si]
    pusha
    call put_pixel
    popa
    inc si
    inc ax
    dec dl
    jnz Cycle
    mov dl,[image_x_size]
    mov ax,[image_x]
    inc bx
    dec dh
    jnz Cycle
    ret   
endp draw_bitmap

proc put_pixel
    mov di,0
    mov dx,bx
    shl dx,8
    shl bx,6
    add di,ax
    add di,bx
    add di,dx
    mov al,cl
    stosb
    ret
endp put_pixel

; ###########################################################
; # Procedure: draw_spaceship	  		       				#
; # 	   	   draws spaceship - move the spaceship data to #
; #        	   draw_bitmap params and call it.				#
; ###########################################################
proc draw_spaceship
	push ax
    mov ax,[spaceship_x]								; Move spaceship X location
    mov [image_x],ax									; ... Into bitmap print params
    mov [image_y], SPACESHIP_Y							; Move spaceship Y location into bitmap print params
   
    mov [image_x_size],SPACESHIP_X_SIZE 				; Move spaceship X size into bitmap print params
    mov [image_yx_size],SPACESHIP_XY_SIZE	 			; Move spaceship X&Y size into bitmap print params
    mov [image],offset spaceship						; Move the bitmap itself into bitmap print params
    call draw_bitmap									; Draw the spaceship bitmap
	pop ax
    ret
endp draw_spaceship

; ###########################################################
; # procedure: draw_single_alien	  		       			#
; # 	   	   draws alien - move the alien data to 		#
; #        	   draw_bitmap params and call it.				#
; ###########################################################
proc draw_single_alien
    mov ax,[alien_x]									; Move alien X location
    mov [image_x],ax									; ... Into bitmap print params
    mov ax,[alien_y]									; Move spaceship Y location
    mov [image_y],ax									; ... Into bitmap print params

    mov [image_x_size],ALIEN_X_SIZE 					; Move alien X size into bitmap print params
    mov [image_yx_size],ALIEN_XY_SIZE	 				; Move alien X&Y size into bitmap print params
    mov [image],offset alien_down						; Move the bitmap itself into bitmap print params
	
	cmp [hands_flag], 0
	je exit_draw_single_alien
	mov [image],offset alien_up						; Move the bitmap itself into bitmap print params
	
exit_draw_single_alien:	
    call draw_bitmap									; Draw the alien bitmap	
    ret
endp draw_single_alien
	
	
; ###########################################################
; # procedure: draw_new_aliens	  		       				#
; # 	   	   draws all the aliens that weren't killed.	#
; ###########################################################
proc draw_new_aliens
		push dx										; Store registers
		push cx
		push ax
		
		mov ax, [prev_start_x]						; Move the prev init block loc to the prev single alien location variables
		mov [prev_alien_x], ax							
		mov ax, [prev_start_y]							
		mov [prev_alien_y], ax
		
		mov ax, [start_x]							; Move the init block loc to the single alien
		mov [alien_x], ax							; Move the init block loc to the single alien
		mov ax, [start_y]							; Move the init block loc to the single alien
		mov [alien_y], ax							
		
		mov dl, [alien_row_1]						; Load the first row into cur row for the proc 
		mov [cur_alien_row], dl

		call draw_row								; Draw row of aliens and check for kill
		
		mov dl, [cur_alien_row]						; Update cur row 
		mov [alien_row_1], dl
		
		call next_row
		
		mov dl, [alien_row_2]						; Load the second row into cur row for the proc 
		mov [cur_alien_row], dl
		
		call draw_row								; Draw row of aliens and check for kill
		
		mov dl, [cur_alien_row]						; Update cur row 
		mov [alien_row_2], dl
		
		call next_row
		
		mov dl, [alien_row_3]						; Load the third row into cur row for the proc 
		mov [cur_alien_row], dl	
		
		call draw_row								; Draw row of aliens and check for kill

		mov dl, [cur_alien_row]						; Update cur row 
		mov [alien_row_3], dl
		
		call next_row
		
		mov dl, [alien_row_4]						; Load the fourth row into cur row for the proc 
		mov [cur_alien_row], dl
		
		call draw_row								; Draw row of aliens and check for kill
		
		mov dl, [cur_alien_row]						; Update cur row 
		mov [alien_row_4], dl

exit_draw_new_aliens:		
		pop ax										; Restore registers
		pop cx
		pop dx
		ret
endp draw_new_aliens


; ###########################################################
; # procedure: draw_row			  		       				#
; # 	   	   draw a row of aliens	and check for hit		#
; ###########################################################

proc draw_row
	push cx												; Store registers value
	push ax
	push dx

	sub [alien_x], 41									; Sub distance between aliens in order to add it first in loop and go over all the aliens in row
	sub [prev_alien_x], 41  							; Do the same for the prev location
	mov cx, [num_bit]									; Init print loop - side_left index pointer
	mov al, [side_left]									; side_left is the opposite of the init cur bit mask
	not al												; Put in al the opposite of side_left
	mov [cur_bit], al
		
draw_aliens_loop:
	add [alien_x], 41									; Advance X loc for cur alien 
	add [prev_alien_x], 41								; Advance X loc for cur cover 
	push cx												; Protect cx counter value
	mov dl, IGNORE_MSB_MASK								; Put in dl mask to ignore msb + cur bit mask
	add dl, al
	
	and dl, [cur_alien_row]								; Check if the current alien is alive
	cmp al, dl
	jne alien_death										; If it's death, jump - don't draw it
	
	call alien_cover
	
	cmp [shoot_flag], 0									; If there is no shoot - there is no chance he died this round
	je not_death

	push ax												; Sotre registers in order to save the values 		
	push bx
	
	mov ax, [alien_x]									; Set ax as alien X loc - up left corner
	mov bx, [alien_y]									; Set bx as alien Y loc - up left corner
	
	cmp ax, [shoot_x]									; Check if the shoot is left to the alien
	jg restore_reg										; If so, there is no hit
	
	cmp bx, [shoot_y]									; Check if the shoot is up to the alien
	jg restore_reg										; If so, there is no hit

	add ax, 22											; Set ax as alien X loc - down right corner
	add bx, 16											; Set bx as alien Y loc - down right corner

	cmp ax, [shoot_x]									; Check if the shoot is right to the alien
	jl restore_reg										; If so, there is no hit
	
	cmp bx, [shoot_y]									; Check if the shoot is down to the alien
	jl restore_reg										; If so, there is no hit
	
	call hit											; Hit case
	
	pop bx												; Restore registers
	pop ax
	jmp alien_death										; Don't draw the alien
	
restore_reg:											; Restore registers - prevent (pop > push)
	pop bx
	pop ax

not_death:												; * If alien is alive *	
	push ax												; Store registers
	push dx
	call draw_single_alien								; Draw the alien
	pop dx												; Restore registers
	pop ax
	
alien_death:											; * Do for every alien - alive and death *					
	pop cx
	push bx						
	mov bl, 2											; Move bl 2 in order to divide al by 2
	div bl												; Divide al by 2
	pop bx
	mov [cur_bit], al									; Update cur bit
	loop draw_aliens_loop
	
	pop dx												; Restore registers
	pop ax
	pop cx

	ret
endp draw_row


; ###########################################################
; # procedure: next_row	  		       						#
; # 	   	   Move to next line - "/r/n".					#
; ###########################################################
proc next_row
	push ax
	
	add [alien_y], 22									; Current line down
	mov ax, [start_x]									; Reset x location
	mov [alien_x], ax
	
	add [prev_alien_y], 22								; Previous line down
	mov ax, [prev_start_x]								; Reset x location
	mov [prev_alien_x], ax
	
	pop ax
	ret
endp next_row

; ###########################################################
; # procedure: alien_cover 		       						#
; # 	   	   Draw cover on the prev location of alien.	#
; ###########################################################
proc alien_cover
	cmp [start_x], 26									; Check if on first frame		
	jne not_start										; If so, dont draw cover
	
	cmp [start_y], 20									; Check if on first frame	
	jne not_start										; If so, dont draw cover
	jmp exit_alien_cover
	
not_start:												; * If not first farme *
	push ax												; Store registers
	push bx
	
	mov ax, [prev_alien_x]								; Draw cover of screen color on the prev alien loc
	sub ax, 2
	MAC_PRINT_SQUARE ax, [prev_alien_y], 19h, 10h, BLU
	
	pop bx												; Restore registers
	pop ax	
	
exit_alien_cover:	
	ret
endp alien_cover


;****************************************************************************************************
; Movement ;
;****************************************************************************************************

; ###########################################################
; # Procedure: update_aliens_location				     	#
; # 	   	   Change aliens location - right left and down #
; ###########################################################
proc update_aliens_location

	push ax			 									; Store block location in order to draw cover to each alien
	mov ax, [start_x]									; Store prev x block location in prev_start_x
	mov [prev_start_x], ax
	mov ax, [start_y]									; Store prev y block location in prev_start_y
	mov [prev_start_y], ax
	pop ax
	
	cmp [direction], 1									; Check movement direction
	jne aliensLeft										; If direction = 0 --> moving left - jump to label
	cmp [end_x], 317									; Else, moving right, check if get close to right side of frame	
	jg downChangeDirection								; If getting close, change direction and move down
	add [start_x], 3									; Else, move to the right
	add [end_x], 3										; Else, move to the right
	jmp exit_update_aliens_location_proc				; Get out of proc
	
aliensLeft:												; * Move the aliens to the left *
	cmp [start_x], 6									; Check if get close to left side of frame	
	jl downChangeDirection								; If getting close, change direction and move down
	sub [start_x], 3									; Else, move to the left
	sub [end_x], 3										; Else, move to the left
	jmp exit_update_aliens_location_proc				; Get out of proc
	
downChangeDirection:									; * Move the aliens down and change direction *
	cmp [end_y], 176									; Check if aliens get too close to spaceship - finish game
	jl gameNotOver										; If not, move the aliens down
	mov [run], 0										; Else, turn game flag off 
	
gameNotOver:											; * Move the aliens down and change direction *
	add [start_y], ALIEN_GET_DOWN						; Move down
	add [end_y], ALIEN_GET_DOWN							; Move down
	xor [direction], 1110b								; Change direction   0 <-> 1 , using mask & xor

exit_update_aliens_location_proc:
	xor [hands_flag], 11111110b							; Change the hands situation
	ret	
endp update_aliens_location	


; ###########################################################
; # procedure: aliens_border_hor		  		       		#
; # 	   	   Update alien's end_y - allows aliens			#
; #			   reach the floor								#
; ###########################################################
proc aliens_border_hor
	push ax												; Store ax
	
	mov ax, [start_y]									; Init the end_y to strat_y
	mov [end_y], ax
	
	cmp [alien_row_4], 0								; If there's fourth row 
	je no_fourth_line									
	add [end_y], 100									; Set end_y = 100 + strat_y 
	jmp boreder_determined								; After setting end_y get out of proc
	
no_fourth_line:	
	cmp [alien_row_3], 0								; If there's third row 
	je no_third_line
	add [end_y], 75										; Set end_y = 75 + strat_y 
	jmp boreder_determined								; After setting end_y get out of proc

no_third_line:
	cmp [alien_row_2], 0								; If there's second row 
	je no_second_line
	add [end_y], 50										; Set end_y = 50 + strat_y 
	jmp boreder_determined								; After setting end_y get out of proc

no_second_line:
	cmp [alien_row_1], 0								; If there's second row 
	je no_first_line
	add [end_y], 25										; Set end_y = 25 + strat_y 
	jmp boreder_determined
	
no_first_line:
	mov [run], 2										; If all aliens killed - "winner winner chicken dinner"

boreder_determined:		
	pop ax												; Retore ax
	ret
endp aliens_border_hor


; ###########################################################
; # procedure: aliens_border_ver		  		       		#
; # 	   	   Update alien's start_x, end_x - allows		#
; #			   aliens reach the sides						#
; ###########################################################
proc aliens_border_ver
	push ax												; Store ax
	
	mov al, [alien_row_1]								; Sum in al the "or" of all the rows - check where there are aliens
	or al, [alien_row_2]
	or al, [alien_row_3]
	or al, [alien_row_4]
	mov ah, al											; Copy al to ah
	
	or al, [side_right]									; Sum the rows and side_right by "or"
	cmp al, [side_right]								; Check if it's same as side_right				
	jne check_left										; If not - no change
	rol [side_right], 1									; Else, there is a coulmn the were killed move the pointer bit left
	sub [end_x], 41										; Update end_x
	
check_left:
	or ah, [side_left]									; Sum the rows and side_left by "or"
	cmp ah, [side_left]									; Check if it's same as side_left	
	jne exit_aliens_border_ver							; If not - no change
	ror [side_left], 1									; Else, there is a coulmn the were killed move the pointer bit right
	dec [num_bit]										; Decrease num_bit counter by 1
	add [start_x], 41									; Update start_x
	
	
exit_aliens_border_ver:
	pop ax												; Restore ax
	ret
endp aliens_border_ver


; ###########################################################
; # Procedure: spaceship_movement				     		#
; # 	   	   Check if spaceship moved or player shot	 	#
; #            or if so, move / create shoot(keyboard input)#
; ###########################################################
proc spaceship_movement
	push ax												; Back up ax in stack
	mov ah, 1											; Check for keyboard click
	int 16h
	jz exit_spaceship_movement_proc						; If there is no click, exit proc 
	mov ah, 0											; Else, ah = scan code & clear keyboard buffer
	int 16h
	
	cmp ah, 4Dh											; If D key clicked --> move the spaceship right
	jne notRight										; Else, jump to left movement check
	cmp [spaceship_x], 289								; Check if too close to right frame border
	jg exit_spaceship_movement_proc						; If so, don't move
	add [spaceship_x], 3								; Else, move 3 px to right
	jmp spaceship_moved									; And get out of proc
	
notRight:												; * Check if moving to the left *
	cmp ah, 4Bh											; If A key clicked --> move the spaceship left
	jne notLeft											; Else, jump to shoot check
	cmp [spaceship_x], 4								; Check if too close to left frame border
	jl exit_spaceship_movement_proc						; If so, don't move
	sub [spaceship_x], 3								; Else, move 3 px to left
	jmp spaceship_moved									; And get out of proc
	
notLeft:												; * Check if player shot *
	cmp ah, 39h											; If Space key clicked --> shoot
	jne exit_spaceship_movement_proc					; Else, other key clicked --> get out of proc
	cmp [shoot_flag], 1									; Check if there is already a shoot
	je exit_spaceship_movement_proc						; If so, don't allow another one --> get out of proc
	pop ax												; Restore ax value (current time)
	mov [last_shoot], ax								; There is a new shoot, init start time to cut time
	push ax												; Push ax in order to pop at the end of proc (prevent pop > push)
	mov [shoot_flag], 1									; Turn on shoot flag
	mov ax, [spaceship_x]								; Shoot X loc is at the middle of spaceship
	add ax, 13											; ... Put the accurate location of the shoot
	mov [shoot_x], ax									; ... In shoot_x var
	mov ax, SPACESHIP_Y									; Initiate the shot Y location 
	sub ax, 8											; ... To the (spaceship Y location -8)
	mov [shoot_y], ax									; ...
	mov [music], offset sound_gun						; Start shoot music
	MAC_PRINT_SQUARE [shoot_x], [shoot_y], SHOOT_WIDTH, SHOOT_HEIGHT, WHT	; Draw the shoot

spaceship_moved:	
	MAC_PRINT_SQUARE 0, 172, 320, 26, BLU				; If there is a movement, cover the spaceship
	
exit_spaceship_movement_proc:
	pop ax												; Restore ax (current time)
	ret
endp spaceship_movement	


; ###########################################################
; # Procedure: shoot	  				       				#
; # 	   	   If there is a shoot & min time of ticks  	#
; #            passed & shoot don't go out of frame   		#
; #   		   --> move shoot								#
; ###########################################################
proc shoot
	cmp [shoot_flag], 0									; Check if there is a shoot
	je exit_shoot_proc									; IF there is no shoot --> get our of proc
	
	call load_cur_time												; Cur time in ax, back up in dx
	sub dx, [last_shoot]								; Check how much time passed since last move
	cmp dx, TIME_DELAY_SHOOT							; Check if the time that passed > frame refresh const 
	jl exit_shoot_proc									; If less - don't refresh
	mov [last_shoot], ax								; If more - update last_frame timer
	
	cmp [shoot_y], 20									; Check if the shoot get out of frame										
	jle shootDone										; If so, zero shoot variables
	MAC_PRINT_SQUARE [shoot_x], [shoot_y], SHOOT_WIDTH, SHOOT_HEIGHT, BLU
	sub [shoot_y], 4									; Else, move bullet up (4 px)
	MAC_PRINT_SQUARE [shoot_x], [shoot_y], SHOOT_WIDTH, SHOOT_HEIGHT, WHT
	jmp exit_shoot_proc									; When done, exit proc
	
shootDone:												; * Shoot missed *
	MAC_PRINT_SQUARE [shoot_x], [shoot_y], SHOOT_WIDTH, SHOOT_HEIGHT, BLU	; Cover the shoot
	mov [shoot_flag], 0									; Init shot flag
	mov [shoot_x], 0									; Init shot X loc
	mov [shoot_y], 0									; Init shot Y loc
	
exit_shoot_proc:	
	ret
endp shoot


;****************************************************************************************************
; Sound ;
;****************************************************************************************************

; ###########################################################
; # procedure: play_sound 		       						#
; # 	   	   Play cur note in music						#
; ###########################################################
proc play_sound
	push bx												; Store registers
	push dx
	
	MAC_STOP_SOUND										; Open speaker
	
	mov bx, [music]										; Put the sound in bx
	
	cmp [byte ptr bx], '$'								; Check if sound array ended
	je end_play_sound									; If so don't play sound

	mov dx, [bx]										; Else move the sound to dx
	mov [note], dx										; Move the sound to note
	add [music], 2										; Increase music to next note
	
	MAC_START_SOUND										; Close speaker
	
end_play_sound:	
	pop dx												; Restore registers 
	pop bx
	
	ret
endp play_sound


; ###########################################################
; # procedure: end_screen_sound 							#
; # 	   	   Play sound in end screen and wait for 		#
; # 		   H click.										#
; ###########################################################
proc end_screen_sound
	push ax												; Store registers
	push dx

next_check:
	mov ah, 1											; Check for keyboard click
	int 16h
	jz no_click											; If there is no click, exit proc 
	mov ah, 0											; Else, ah = scan code & clear keyboard buffer
	int 16h
	
	cmp ah, 23h											; If H key clicked 
	je end_sound										; --> get out of proc 
	
no_click:
	call load_cur_time									; Load time to ax
	cmp ax, [last_music]								; Check if there was a clock tick
	je next_check										; If not, don't play sound
	
	mov [last_music], ax								; Else, Updae time and play sound
	call play_sound
	jmp next_check

end_sound:	
	pop dx												; Restore registers
	pop ax
	
	ret
endp end_screen_sound	


;****************************************************************************************************
; Other ;
;****************************************************************************************************


; ###########################################################
; # procedure: setup_game_screen	  		       			#
; # 	   	   Transfer to graphic mode, init CLOCK, 		#
; # 	   	   init timers, init game variables 			#
; ###########################################################
proc setup_game_screen
	mov ax, 13h											; Transfer to graphic mode - restore BIOS pallete
    int 10h	
	
	mov ax, 40h											; Init CLOCK
	mov es, ax											; Init CLOCK
	mov ax, [CLOCK]										; Init CLOCK

	mov [last_music], ax								; Init last_music to first tick
	mov [last_aliens], ax								; Init last_aliens to first tick
	mov [last_shoot], ax								; Init last_shoot to first tick
	
	mov [run], 1										; Init game flag to run
	mov [direction], 1									; Init direction to right
	
	mov [start_x], 26									; Init aliens' X start pos
	mov [start_y], 20									; Init aliens' Y start pos
	mov [end_x], 299									; Init aliens' X end pos
	mov [end_y], 120									; Init aliens' Y end pos
	
	mov [spaceship_x], 146								; Init spaceship X pos
	
	mov [shoot_flag], 0									; Init shoot flag to no shoot
	mov [shoot_x], 0									; Init shoot loc to 0
	mov [shoot_y], 0									; Init shoot loc to 0
	
	mov [alien_row_1], 01111111b 						; Init aliens alive rows
	mov [alien_row_2], 01111111b 						; Init aliens alive rows
	mov [alien_row_3], 01111111b 						; Init aliens alive rows
	mov [alien_row_4], 01111111b 						; Init aliens alive rows
	
	mov [score], 0										; Init score
	
	mov [num_bit], 7									; Init num_bit

	mov [side_right], 11111110b							;Init side_right
	mov [side_left], 10111111b							;Init side_left

	mov [prev_alien_x], 26								; Init prev_alien_x
	mov [prev_alien_y], 20								; Init prev_alien_y
	mov [prev_start_x], 26								; Init prev_start_x
	mov [prev_start_y], 20								; Init prev_start_y
	
	mov [hands_flag], 0									; Init hands_flag
	
	mov [music], offset no_music						; Init music to nothing
	mov [note], 0										; Init note
	
	
	MAC_PRINT_SQUARE 0, 0, 320, 200, BLU				; Draw first frame
	call print_score_text
	call draw_new_aliens
	call draw_spaceship
	
	ret
endp setup_game_screen


; ###########################################################
; # Procedure: print_score_text			       				#
; # 	   	   print "Score: XX" in the up left corner		#
; ###########################################################
proc print_score_text
	push ax												; Store registers
	push bx
	push dx
	
	mov dl, 0											; Dl = column
	mov dh, 0											; Dh = row
	mov bh, 0											; Bh = page number
	mov ah, 02h											; Set cursor position
	int 10h
	
	mov dx, offset score_msg							; Dx = score_msg
	mov ah, 09h											; Print string
	int 21h
	
	mov dl, 6											; Dl = column
	mov dh, 0											; Dh = row
	mov bh, 0											; Bh = page number
	mov ah, 02h											; Set cursor position
	int 10h
	
	cmp [score], 9										; If the score is less then 9 print only one digit
	jg two_digits_score									; Else, jump to dual digit print
	
	mov al, [score]										; Al = char to print
	add al, 30h											; Add the ascii value of '0' to get the wanted digit
	mov bl, WHT											; White text color
	mov ah, 0Eh											; Print the char
	int 10h
	jmp exit_print_score_text							; Print finished - get out of proc
	
two_digits_score:										; * If the score is two digits *
	xor ah, ah											; Zero ah 
	mov al, [score] 									; Al = score
	mov bl, 10											; Bl = 10
	div bl												; Divide score by 10 --> (al = tens, ah = units)
	push ax												; Push ax to protect the units
	add al, 30h											; Add the ascii value of '0' to get the wanted digit
	mov bl, WHT											; White text color
	mov ah, 0Eh											; Print the char
	int 10h
	
	mov dl, 7											; Dl = column
	mov dh, 0											; Dh = row
	mov bh, 0											; Bh = page number
	mov ah, 02h											; Set cursor position
	int 10h
	
	pop ax												; Get units value
	mov al, ah											; Move it to al (char to print)
	add al, 30h											; Add the ascii value of '0' to get the wanted digit
	mov bl, WHT											; White text color
	mov ah, 0Eh 										; Print the char
	int 10h
	
exit_print_score_text:
	pop dx												; Restore registers
	pop bx
	pop ax
	
	ret
endp print_score_text


; ###########################################################
; # Procedure: load_cur_time				     			#
; # 	   	   Insert current time into ax and dx (backup)	#
; ###########################################################
proc load_cur_time
	mov ax, 40h											; Init CLOCK
	mov es, ax											; Init CLOCK
	mov ax, [CLOCK]										; Init CLOCK
	mov dx, ax											; Move the time to dx in order to use both ax and dx 
	
	ret
endp load_cur_time


; ###########################################################
; # Procedure: alien_timer				     				#
; # 	   	   Check if alien movement is required -	 	#
; #            if so, move (ticks constant)					#
; ###########################################################
proc alien_timer
	call load_cur_time
	;mov dx, ax											; Backup time into dx in order to change it	
	sub dx, [last_aliens]								; Check how much time passed since last aliens movement
	cmp dx, TIME_DELAY_ALIENS							; Check if the time that passed > movement const 
	jl exit_alien_timer_proc							; If less - don't move
	mov [last_aliens], ax								; If more - update last_aliens timer to cur time
	call update_aliens_location							; Move aliens
	call draw_new_aliens

exit_alien_timer_proc:	
	ret
endp alien_timer


; ###########################################################
; # Procedure: get_keyboard_click			     			#
; # 	   	   Wait for keyboard click and put scan code	#
; #     	   in ah										#
; ###########################################################
proc get_keyboard_click
waitForClick:											; Loop anchor
	mov ah, 1											; Check for click in keyboard buffer
	int 16h
	jz waitForClick										; If there is no click wait for click
	mov ah, 0											; Read key and clear buffer
	int 16h
	ret
endp get_keyboard_click


; ###########################################################
; # procedure: hit 		       								#
; # 	   	   Hit case - kill alien.						#
; ###########################################################
proc hit
	mov al, [cur_bit]									; Set al as the current bit that is under check now
	sub [cur_alien_row], al								; Sub it from the aliens in the row in order to kill him - turm bit off
	mov [shoot_flag], 0									; Init shoot
	MAC_PRINT_SQUARE [shoot_x], [shoot_y], SHOOT_WIDTH, SHOOT_HEIGHT, BLU	; Cover the shoot which hit
	inc [score]											; Increase score counter
	mov [music], offset sound_hit						; Hit sound
	call print_score_text								; Draw the new score
	ret
endp hit


; ###########################################################
; # procedure: game_cycle				  		       		#
; # 	   	   loop of procedures of the game cycle 		#
; #            until game over								#
; ###########################################################
proc game_cycle
game_loop:
	call load_cur_time 									; Get cur time and put it in ax & dx
	call shoot											; Move shoot if necessary (- every 2 ticks = 0.11 sec)
	call spaceship_movement								; Check for spaceship movement or shoot (- always)
	call alien_timer									; Move aliens (- every 6 ticks = 0.33 sec)
	call aliens_border_hor
	call aliens_border_ver
	call draw_spaceship
	
	call load_cur_time									; Load time to ax
	cmp ax, [last_music]								; Check if there was a clock tick
	je no_sound											; If not, don't play sound
	mov [last_music], ax								; Else, Updae time and play sound
	call play_sound
no_sound:

	cmp [run], 1										; If aliens don't reach space ship height
	je game_loop										; Keep being in cycle

exit_game_cycle:
	ret
endp game_cycle


; ###########################################################
; # Procedure: game_over_background		       				#
; # 	   	   print win / lose background + score			#
; ###########################################################
proc game_over_background
	cmp [run], 0										; Check if win or lose (win = 2, lose = 0)
	jne win_load
	mov [music], offset sound_lose						; Start lose sound
	MAC_LOAD_IMAGE lose_bg								; Load lose background
	jmp print_score										; If lose bac was prited get out of proc
	
win_load:
	mov [music], offset sound_win						; Start win sound
	MAC_LOAD_IMAGE win_bg								; Print win background
		
print_score:	
	push ax												; Store registers
	push bx
	push dx
	
	mov dl, 24											; Dl = column
	mov dh, 13											; Dh = row
	mov bh, 0											; Bh = page number
	mov ah, 02h											; Set cursor position
	int 10h
	
	cmp [score], 9										; If the score is less then 9 print only one digit
	jg end_two_digits_score								; Else, jump to dual digit print
	
	mov al, [score]										; Al = char to print				
	add al, 30h											; Add the ascii value of '0' to get the wanted digit
	mov bl, 0FFh										; White text color after pallete changes
	mov ah, 0Eh											; Print the char
	int 10h
	jmp exit_game_over_background						; Print finished - get out of proc
	
end_two_digits_score:									; * If the score is two digits *
	xor ah, ah											; Zero ah 
	mov al, [score] 									; Al = score
	mov bl, 10											; Bl = 10
	div bl												; Divide score by 10 --> (al = tens, ah = units)
	push ax												; Push ax to protect the units
	add al, 30h											; Add the ascii value of '0' to get the wanted digit
	mov bl, 0FFh										; White text color after pallete changes
	mov ah, 0Eh											; Print the char
	int 10h
	
	mov dl, 25											; Dl = column
	mov dh, 13											; Dh = row
	mov bh, 0											; Bh = page number
	mov ah, 02h											; Set cursor position
	int 10h
	
	pop ax												; Get units value
	mov al, ah											; Move it to al (char to print)
	add al, 30h											; Add the ascii value of '0' to get the wanted digit
	mov bl, 0FFh										; White text color after pallete changes
	mov ah, 0Eh											; Print the char
	int 10h
	
exit_game_over_background:
	pop dx												; Restore registers
	pop bx
	pop ax	
	ret
endp game_over_background


; ###########################################################
; # Procedure: main						       				#
; # 	   	   main function - screens logic				#
; ###########################################################
proc main
	mov ax, 13h											; Transfer to graphic mode
    int 10h

main_screen:
	MAC_LOAD_IMAGE start_bg								; Load Home background
	
main_options:											; * Main menu *
	call get_keyboard_click								; Get keyboard click from player
	
	cmp ah, 1h											; If Esc key clicked
	je exit_main										; --> exit
	
	cmp ah, 17h											; If I key clicked
	je instruction_screen								; --> instructions
	
	cmp ah, 19h											; If P key clicked
	je game												; --> game screen
	
	jmp main_options									; If other key clicked --> wait for another key
	
instruction_screen:
	MAC_LOAD_IMAGE inst_bg								; Load Instruction background

instruction_options:									; * Instruction menu *
	call get_keyboard_click								; Get keyboard click from player
	
	cmp ah, 23h											; If H key clicked
	je main_screen										;  --> back to main screen
	
	jmp instruction_options								; If other key clicked --> wait for another key	

game:	
	call setup_game_screen								; Init variables & game screen
	call game_cycle

game_over:												; * Game over menu *	
	call game_over_background							; Load win/lose background
	call end_screen_sound

	jmp main_screen	
	
exit_main:
	ret
endp main


;****************************************************************************************************

;====================================================================================================

; ********
; * Main *
; ********

start:
	mov ax, @data
	mov ds, ax
	
	call main
    
;===================================================================================================
exit:													; * Exit game *
    mov ax, 2											; Change to text mode
    int 10h
	
    mov ax, 4c00h
    int 21h
	
END start