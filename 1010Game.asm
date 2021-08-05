; Name: Amit Stein
; Date: 7/7/2016
; The Aim: This is a single player game just for fun.
; In the game, the player need to place shapes of cubes into a 10*10 matrix by clicking on the matrix.
; the shapes changes every turn and are shown at the side of the matrix, to let the player know what is his current shape.
; to place the shape on the matrix, the player must click on it, then the shape will be placed on the click place.
; the mouse is the top left cube of the shape, so that how the player know where the shape will be placed.
; according to his click when they are full.
; the player must make sure to have a place for the shapes in the matrix, unless he lose.
; the columns and the rows of the matrix are cleared 
; thats game I do with a one D array in the memory.
; every time the user click on the matrix I calculate the place of the click in the one D array by methods that I wrote
; and then I print the shape (of cours before printing I need to check if there is place for the shape in the matrix,
; unless the player lose).
; if the player made a full line, the line will be cleared from the screen in a nice graphic.



IDEAL
;==============================
;matrix important information:
;==============================
MAT_HIGHT_IN_MEMORY equ 10
MAT_WIDTH_IN_MEMORY equ 10
MAT_HIGHT_IN_SCREEN equ MAT_HIGHT_IN_MEMORY*CELL_HIGHT_IN_SCREEN					
MAT_WIDTH_IN_SCREEN equ MAT_WIDTH_IN_MEMORY*CELL_WIDTH_IN_SCREEN

CONVERTER_FACTOR equ 17 ; 17 pixels hight and width (square) for each cell in the board - 
						; can divide from screen to memory, and mul from memory to screen by this number.						
CELL_HIGHT_IN_SCREEN equ CONVERTER_FACTOR ;17 pixels hight
CELL_WIDTH_IN_SCREEN equ CONVERTER_FACTOR ; 17 pixels width

COLS_SPACES_FROM_LEFT_FOR_BOARD equ 7
ROWS_SPACES_FROM_TOP_FOR_BOARD equ 13

					
MAT_TOTAL_LENGTH_IN_MEMORY equ MAT_WIDTH_IN_MEMORY*MAT_HIGHT_IN_MEMORY ;(100)	
MAT_TOTAL_LENGTH_ON_SCREEN equ MAT_WIDTH_IN_SCREEN*MAT_HIGHT_IN_SCREEN   ;(28900)





;colors options for cells and borders:
BlackColor equ 0
BlueColor equ 1
GreenColor equ 2
CyanColor equ 3
RedColor equ 4
MagentaColor equ 5
BrownColor equ 6
LightGrayColor equ 7
DarkGreyColor equ 8
LightBlueColor equ 9
LightGreenColor equ 10
LightCyanColor equ 11
LightRedColor equ 12
LightMagentaColor equ 13
YellowColor equ 14
WhiteColor equ 15

;Borders Color: 
BORDER_COLOR equ WhiteColor ;this is the boarders color.
COVER_FULL_LINE_COLOR equ BlackColor ;this is the color around the full lines.

;Shapes Colors: 
ONE_SQUARE_SHAPE_COLOR equ LightBlueColor
TWO_SQUARES_DOWN_SHAPE_COLOR equ LightGreenColor
TWO_SQUARES_RIGHT_SHAPE_COLOR equ YellowColor
TWO_SQUARES_DOWN_RIGHT_SHAPE_COLOR equ LightCyanColor



;important points on the screen:
;==============================
;shapes point:
X_Of_The_Start_Shapes_Point equ 184
Y_Of_The_Start_Shapes_Point equ 99
;score point:
X_Of_The_Start_Score_Point equ 63 ;(80*25)
Y_Of_The_Start_Score_Point equ 10 ;(80*25)
;high score point:
X_Of_The_Start_High_Score_Point equ 63 ;(80*25)
Y_Of_The_Start_High_Score_Point equ 8 ;(80*25)


MODEL small


STACK 0f500h


DATASEG	
	 RndCurrentPos dw start ; start of code segment - will help to get good rnd number - Random current position
	 
	 ; the array of the cubes - the array is filled with
	 Board db (MAT_HIGHT_IN_MEMORY * MAT_WIDTH_IN_MEMORY) dup (BlackColor)
	 
	 ShapeKind db 0 	; 1 -  one square, 2 - two squares down, 3 - two squares right, 4 - two squares down right
	 
	 ;mouse clicks position
	 Xclick dw ? 
	 Yclick dw ?
	 
	 ;we want to save the indexes of the full lines and then clear the at once
	 Full_Rows db MAT_HIGHT_IN_MEMORY dup ('!') ;the array of the indexes of the full rows
	 Full_Cols db MAT_WIDTH_IN_MEMORY dup ('!') ;the array of the indexes of the full cols
	 
	 Number_Of_Full_Rows dw 0 ;word because we put it in cx
	 Number_Of_Full_Cols dw 0;word because we put it in cx
	 Number_Of_Full_Lines db 0 ;will effect the score
	 
	 ; boolian variables to check if we the lines are fulland we need to sign them and clear them.
	 Are_There_Full_Rows db 0
	 Are_There_Full_Cols db 0
	 Are_There_Full_Lines db 0
  

	 ipAdress dw ? ;for methods that uses stack by pushing the 
	
	
	 ;=============================================================================
	 ;boolian variables for the methodes in the program:
	 
	 Got_Click_On_New_Game db 0 ; for method Check_Click_On_New_Game_Option
	 Got_Click_On_Rules db 0 ; for method Check_Click_On_Rules_Option - check if was click on the button
	 Got_Click_On_Exit_Program db 0 ; for method Check_Click_On_Exit_Program - check if was click on the button
	 Got_Click_On_Back db 0 ; for method Check_Click_On_Back - check if was click on the button
	 
	 Got_Click_On_Mat db 0 ; for method Check_Click_On_Mat
	 CanPlace db 0 ; for method Check_If_Can_Place_shape_On_Click_Point
	 Mat_Has_Place db 0 ; for method Check_If_Can_Place_shape_In_Mat	 
	 
	 IsEmpty db 0 ; for the methods inside Check_If_Can_Place_shape_On_Click_Point
	 IsFull db 0 ; for methods:  List_Full_Rows , List_Full_Cols
	 
	 GameWasOver db 0 
	 ;=============================================================================

	 
	 ;=============================================================================
	 ;score and high score:
	 
	 Score dw 0 ;the score of the game
	 Score_String db "Score:$"	 
	 
	 High_Score dw 0 ;the high score which will be copied to a file and be saved also after the player exit the game.
	 High_Score_String db "High Score:$"
	 ;=============================================================================

	 
	 ;=============================================================================	
	 ;the rules:
	 
	 RulesPage db 13, 10
			db "                 Rules:"
			db 13, 10
			db 13, 10
			db "  see which type of shape you got, "
			db 13, 10
			db "  find it a place in the board"
			db 13, 10
			db "  and get points :)."		
			db 13, 10
			db 13, 10
			db "  if you don't have place for the"
			db 13, 10
			db "  shape, you lose :("
			db 13, 10
			db 13, 10
			db "  the mouse is the left top cube of "
			db 13, 10
			db "  the shape."
			db 13, 10
			db 13, 10
			db "  Every time that a line will be filled,"
			db "  it will be earased from the board"
			db 13, 10
			db "  and your points will be raised."
			db 13, 10
			db 13, 10
			db "  Try to get the maximum points you can.$"
	 ;=============================================================================			
			
			
	 Welcome db 13,10
			db 13,10
			db 13,10
			db 13,10
			db "                Hello!"
			db 13,10
			db 13,10
			db "      Welcome to the game: 1010!"
			db 13,10
			db 13,10
			db 13,10
			db 13,10
			db 13,10
			db 13,10
			db "     Press anywhere to continue...$"
			
			
		
	 Rules_Click_String db "Rules$"
	 
	 Back_String db "Back$"
	 
	 NewGameString db "New Game$"
	 
	 Game_over_String db "Game Over :($"
	 
	 Exit_Program_Char db 'X'
	 
	 

	
	FileName db 'HighScor.txt',0 	; the file that have the high score - we need a file to save the high score so if the user quit the game,
									; we can save his high score for the next time he will enter the game.
	FileLength dw 4 ; the lengh of the high score file - 4 bytes
	FileHandle dw ? ; the file handle - a number that we get at opening the file and we need it to
	WriteBuffer db 4 dup (?)
	ReadBuffer db 4 dup (?)
	
	 
	 
CODESEG
start:
	 mov ax, @data ; only ax can be moved to ds because this is how the the computer built - the idea is to save place to other wires in the computer.
	 mov ds, ax ;put in ds the data of this program (all the variables of the data segment)
	 
	 call SetGraphic ;set to graphic mode 320*200

	 
Welcome_Page:	 

	 mov dx, offset Welcome
	 mov ah,9
	 int 21h	 	 
	 call ShowMouse
	 
	 call Read_High_Score ;read the high score from a file to be able to know it and print it at the beginning.
	 
	 call Wait_To_Left_Click_Press ;press anywhere to continue
	 	 
		 
	 jmp Start_New_Game
	 
	 
;==============================================================================
Rules_Page:
	 call HideMouse	 
	 call ClearScrean
	 
	 call Put_Cursor_On_Top_Left_Screen
	 mov dx, offset RulesPage
	 mov ah,9
	 int 21h
	 
	 call Draw_Back_Rect
	 call Put_Cursor_On_Back
	 mov dx, offset Back_String
	 mov ah, 9
	 int 21h
	 
	 call Draw_Exit_Program_Rect
	 call Put_Cursor_On_Exit_Program
	 mov dl, [Exit_Program_Char]
	 mov ah, 2
	 int 21h
	 
	 call ShowMouse
	 
Click_Back_Or_Exit:
	 call Wait_To_Left_Click_Press
	 
	 call Check_Click_On_Back
	 cmp [Got_Click_On_Back],1 ;if the click was on the back option rect we want to come back to the game screen.
	 jz Was_Click_Back
	 call Check_Click_On_Exit_Program ; if the click was on the Exit option rect we want to exit the program.
	 cmp [Got_Click_On_Exit_Program], 1
	 jnz Relative_Jump1
	 jmp Exit	 
	 Relative_Jump1:
	 jmp Click_Back_Or_Exit
	 
	 
Was_Click_Back:	 
	 
	 call HideMouse

	 call ClearScrean
	 
	 ; things that have been cleard because of the click on the rules option and we want them back on the screen so
	 ; the player will be able to click on them again. new game, rules, exit and ofcours the matrix and the shape on the side. 
	 
	 call Draw_New_Game_Option_Rect
	 call Put_Cursor_On_New_Game_Option
	 mov dx, offset NewGameString
	 mov ah, 9
	 int 21h
	 
	 call Draw_Rules_Option_Rect
	 call Put_Cursor_On_Rules_Option
	 mov dx, offset Rules_Click_String
	 mov ah, 9
	 int 21h
	 
	 call Draw_Exit_Program_Rect
	 call Put_Cursor_On_Exit_Program
	 mov dl, [Exit_Program_Char]
	 mov ah, 2
	 int 21h
	 
	 ;parameter for the method that draw the shape on the shapes point:
	 mov cx, X_Of_The_Start_Shapes_Point 
	 mov dx, Y_Of_The_Start_Shapes_Point
	 mov si, (CELL_HIGHT_IN_SCREEN - 1) ;CELL_HIGHT_IN_SCREEN - 1 pixel for the border at the Down
	 mov di, (CELL_WIDTH_IN_SCREEN - 1) ; CELL_WIDTH_IN_SCREEN - 1 pixel for the border at the left	 
	 call GetShapeColor ; al will have the color and will be effected by the variable ShapeKind.	 
	 call DrawShape; acording to the ShapeKind
 	 
	 call PrintBoard
	 call Draw_Board_Borders
	 
	 call Put_Cursor_On_Score_Position
	 call PrintScore
	 
	 call Put_Cursor_On_High_Score_Position
	 call Print_High_Score
	 
	 cmp [GameWasOver], 0
	 jz Game_Did_Not_Over
	 call Put_Cursor_On_Game_Over
	 mov dx, offset Game_over_String
	 mov ah, 9
	 int 21h
	 
Game_Did_Not_Over:

	 call ShowMouse
	 
	 jmp Back_From_Rules_Page
	 
	 
;==========================================================================
;==========================================================================	 	 
;at the start we want first to draw the board and the other 3 options
Start_New_Game:	

 	 call HideMouse	 ;before drawing on the screen because we dont want the moue to bother us.
	 
	 call ClearScrean	  

	 call Draw_New_Game_Option_Rect
	 call Put_Cursor_On_New_Game_Option
	 mov dx, offset NewGameString
	 mov ah, 9
	 int 21h
	 
	 call Draw_Rules_Option_Rect
	 call Put_Cursor_On_Rules_Option
	 mov dx, offset Rules_Click_String
	 mov ah, 9
	 int 21h
	 
	 call Draw_Exit_Program_Rect
	 call Put_Cursor_On_Exit_Program
	 mov dl, [Exit_Program_Char]
	 mov ah, 2
	 int 21h
	 
	 call Set_Board_Empty_In_Memory ;set the board to empty.	 
	 call PrintBoard ; the print the board
	 call Draw_Board_Borders ;print borders for the board
	 
	 mov [Score], 0 ; set score
	 call Put_Cursor_On_Score_Position
	 call PrintScore
	 
	 call Put_Cursor_On_High_Score_Position
	 call Print_High_Score ;print the high score
	 
	 
	 call ShowMouse ;after drawing on the screen.
	 

;==========================================================================
;==========================================================================	 
Game_Turn:

	 call Get_Rnd_In_ShapeKind

	 call HideMouse
	 
	 ;parameter for the method that draw the shape on the shapes point:
	 mov cx, X_Of_The_Start_Shapes_Point 
	 mov dx, Y_Of_The_Start_Shapes_Point
	 mov si, (CELL_HIGHT_IN_SCREEN - 1) ;CELL_HIGHT_IN_SCREEN - 1 pixel for the border at the Down
	 mov di, (CELL_WIDTH_IN_SCREEN - 1) ; CELL_WIDTH_IN_SCREEN - 1 pixel for the border at the left
	 call GetShapeColor ; al will have the color and will be effected by the variable ShapeKind.
	 call DrawShape; according to the ShapeKind
	 
	 call ShowMouse	 
	 
	 call Check_If_Can_Place_shape_In_Mat ; before the clicks we want to if there is place for the shape
	 cmp [Mat_Has_Place],1
	 jz Relative_Jump2
	 jmp Game_Over
Relative_Jump2:
	 
ClickOnMat:
	 call Wait_To_Left_Click_Press
	 ; after the click we want to see where was the click and according to that, we will act.
	 
	 call Check_Click_On_New_Game_Option ; check if the click was on new game rect option on the screen, if the click was there, we want to restart everything besides the high score.
	 cmp [Got_Click_On_New_Game], 1
	 jnz Relative_Jump3
	 jmp Start_New_Game
Relative_Jump3:	 

	 call Check_Click_On_Rules_Option ; check if the click was on rules rect option on the screen, if the click was there, we want to clear the screen, print the rules and wait to another click.
	 cmp [Got_Click_On_Rules], 1
	 jnz Relative_Jump4
	 jmp Rules_Page
Relative_Jump4:
Back_From_Rules_Page:
	 
	 call Check_Click_On_Exit_Program ; check if the click was on exit rect option on the screen, if the click was there, we want to exit the program.
	 cmp [Got_Click_On_Exit_Program], 1
	 jnz Relative_Jump5
	 jmp Exit	 
Relative_Jump5:

	 call Check_Click_On_Mat ; every shape has different area in the matrix that the user can click on according to the number of cubes the shape has.
	 cmp [Got_Click_On_Mat],1 
	 jnz ClickOnMat	 
	 
	 
Continue:
	 
	 Call Check_If_Can_Place_shape_On_Click_Point ; check if there is place for the shape at the place the user clicked on.
	 cmp [CanPlace],0
	 jnz Relative_Jump6
	 jmp CheckPlaceInMatAgain ; we need this method because we don't wand to start the loop for the beginning and random new shape.
							  ; if there is place for shape on the matrix, it means that the game didn't over yet and the user can try and place the shape again.
							  ; else, there is not a place for the shape in the matrix an the game is over.

Relative_Jump6:	 
	 ; input to Input_Shape_To_Memory_mat method that insert the shape into the memory board
	 mov ax,[Xclick]
	 call Convert_Screen_X_To_Memory_X
	 mov ax,[Yclick]
	 call Convert_Screen_Y_To_Memory_Y
	 call Input_Shape_To_Memory_mat
	 
	 
	 
	 call Count_Full_Lines	
	 
	 cmp [Are_There_Full_Lines], 1
	 jz ThereAreFullLines
	 jmp  NO_CLEAR
	 
ThereAreFullLines:
	 call HideMouse
	 
	 Call Clear_Board_From_Screen	 
	 call PrintBoard
	 call Draw_Board_Borders
	 
	 call ShowMouse	 	 
	 
	 call Full_Lines_Change_Color_With_Delay ; nice animation of full lines disapear	
	 
	 call HideMouse	
	 call Clear_Full_Lines  			;this methode will clear the full rows and cols from the memory mat
	 call ShowMouse
	 
	 ; at this moment, until lable NO_CLEAR, we set al the variables of the rows and the cols exept of
	 ; the lines variables because we need them to calculate the score.
	 cmp [Are_There_Full_Rows], 0
	 jbe Clear_Col_Arr
	 
	 
	 call SetUp_Full_Rows_Arr
	 mov [Number_Of_Full_Rows], 0
	 mov [Are_There_Full_Rows], 0

Clear_Col_Arr:	 
	 cmp [Are_There_Full_Cols], 0
	 jbe NO_CLEAR
	 
	 call SetUp_Full_Cols_Arr	  
	 mov [Number_Of_Full_Cols], 0 
	 mov [Are_There_Full_Cols], 0
	 
	 
NO_CLEAR:
										;count the number of them together for the Score. 
	 Call Calc_Score 					;this method will add to the score the number of cubes in the shape and the result
										;from Add_Score_Full_Lines_Points method.
	 mov bx, [Score] ;we can not compare between memory and memory so bx helps us.
	 cmp bx, [High_Score] ; if the score is higher then the high score, we need to change the hight score.
	 jb Cont ;that means the score is not higher then the high score so we don't need to change the high score.
	 mov [High_Score], bx ;the score was higher then the high score so we chabge the high score.
	 call Write_High_Score_To_File ; here we write the high score to a file so we will be able 
			; to remmember it also after the player will exit the program.

	 
Cont:	
	 mov [Number_Of_Full_Lines], 0
	 mov [Are_There_Full_Lines], 0
	 
	 call HideMouse
	 
	 Call Clear_Board_From_Screen	 
	 call PrintBoard
	 call Draw_Board_Borders


	 
	 ; we need to erase the shape from the screen because in the next loop,
	 ; another shape will be drawn on the same pount and we dont want them to be one on the other
	 ; parameter for the method that draw the shape on the shapes point:
	 mov cx, X_Of_The_Start_Shapes_Point 
	 mov dx, Y_Of_The_Start_Shapes_Point
	 mov si, (CELL_HIGHT_IN_SCREEN - 1) ;CELL_HIGHT_IN_SCREEN - 1 pixel for the border at the Down
	 mov di, (CELL_WIDTH_IN_SCREEN - 1) ; CELL_WIDTH_IN_SCREEN - 1 pixel for the border at the left
	 mov al, BlackColor ; that will erase the shape from the screen because the screen is black.
	 call DrawShape	 
	 
	 call Put_Cursor_On_Score_Position
	 call PrintScore ;print the score without clearing it from the screen first because its done automaticly by the system כנראה.
	 
	 call Put_Cursor_On_High_Score_Position
	 call Print_High_Score

	 call ShowMouse
	 

	 
	 jmp Game_Turn
	 
CheckPlaceInMatAgain:
	 call Check_If_Can_Place_shape_In_Mat
	 cmp [Mat_Has_Place],1
	 jnz Game_Over ;when there is no place to the shape in the marix
	 jmp ClickOnMat
	 
Game_Over:
	 mov [GameWasOver],1 ;we want to know if we need to print the game over string after comming back from the rules screen
	 call HideMouse
	 
	 call Put_Cursor_On_Game_Over
	 mov dx, offset Game_over_String
	 mov ah, 9
	 int 21h
	 
	 call ShowMouse 

	 ;this click is to see whether the user want to start a new game, see the rules or exit the program
ClickAgain:	 
	 call Wait_To_Left_Click_Press
	 
	 ; after game over a click on the mat will not do anithing
	 call Check_Click_On_New_Game_Option
	 cmp [Got_Click_On_New_Game], 1
	 jnz Relative_Jump7
	 jmp Start_New_Game
Relative_Jump7:
	 
	 call Check_Click_On_Rules_Option
	 cmp [Got_Click_On_Rules], 1
	 jnz Relative_Jump8
	 jmp Rules_Page
Relative_Jump8:
	 
	 call Check_Click_On_Exit_Program
	 cmp [Got_Click_On_Exit_Program], 1
	 jnz Relative_Jump9
	 jmp Exit	 
Relative_Jump9:	 

	 jmp ClickAgain ; that means the user click on an meaningless point and he need to click again antil he will click on one of the three options

Exit:
	 
	 call SetText

	 mov ax, 4C00h ; returns control to dos
	 int 21h
	 
	; put some data in Code segment in order to have enough bytes to xor with in random  mathod
	SomeRNDData	    db 227	,111	,105	,1		,127
					db 234	,6		,116	,101	,220
					db 92	,60		,21		,228	,22
					db 222	,63		,216	,208	,146
					db 60	,172	,60		,80		,30
					db 23	,85		,67		,157	,131
					db 120	,111	,105	,49		,107
					db 148	,15		,141	,32		,225
					db 113	,163	,174	,23		,19
					db 143	,28		,234	,56		,74
					db 223	,88		,214	,122	,138
					db 100	,214	,161	,41		,230
					db 8	,93		,125	,132	,129
					db 175	,235	,228	,6		,226
					db 202	,223	,2		,6		,143
					db 8	,147	,214	,39		,88
					db 130	,253	,106	,153	,147
					db 73	,140	,251	,32		,59
					db 92	,224	,138	,118	,200
					db 244	,4		,45		,181	,62
					
					
	 
;==========================
;==========================
;==== Procedures  Area ====
;==========================
;==========================


;========================================
; Description: open HighScor file so we will  be able to read or right.
; Input: nothing.
; Output: nothing.
; Registers Usage: ax, bx.
;========================================
proc file_open
	
	 push ax
	 push bx
	 push dx
	
	 mov ah, 3Dh
	 mov al, 2
	 lea dx, [FileName]
	 int 21h	
	 mov [FileHandle], ax
	
	 pop dx
	 pop bx
	 pop ax
	 ret
endp file_open

;========================================
; Description: Close HighScor file so we will not be able to read or right.
; Input: nothing.
; Output: nothing.
; Registers Usage: ax, bx.
;========================================
proc file_close
	 push ax
	 push bx
	 
	 mov ah, 3Eh
	 mov bx, [FileHandle]
	 int 21h
	 
	 pop bx
	 pop ax
	 ret 
endp file_close 

;========================================
; Description: Read from the HighScor file 4 bytes, every byte is a number in hexa.
; Input: nothing.
; Output: the numbers from the file in ReadBuffer variable.
; Registers Usage: ax, bx, cx, dx.
;========================================
proc Write_to_File
	 push ax
	 push bx
	 push cx
	 push dx
	 
	 call file_open ; before writing to file we must open it first.
	 
	 mov ah,40h
	 mov bx,[FileHandle]
	 mov cx, [FileLength]
	 mov dx,  offset WriteBuffer
	 int 21h
	  
	 call file_close ; we must close the file after we finished our work on it.
	 
	 pop dx
	 pop cx
	 pop bx
	 pop ax	 
	 ret
endp Write_to_File

;========================================
; Description: Read from the HighScor file 4 bytes, every byte is a number in hexa.
; Input: nothing.
; Output: the numbers from the file in ReadBuffer variable.
; Registers Usage: ax, bx, cx, dx.
;========================================
proc Read_From_File
	 push ax
	 push bx
	 push cx
	 push dx
	 
	 call file_open  ; before reading from a file we must open it first.
	 
	 mov ah, 3Fh
 	 mov bx,[FileHandle]
	 mov cx, [FileLength]
	 mov dx, offset ReadBuffer
	 int 21h
	 
	 call file_close ; we must close the file after we finished our work on it.
	 
	 pop dx
	 pop cx
	 pop bx
	 pop ax	 
	 ret
endp Read_From_File
	

;========================================
; Description: Write the high score to HighScor file.
; An explain for the method:
; the HighScor file has 4 ascii digits in hexa .
; every digit in the file is ascii one byte.
; the problem is that we need every nibble digit to be a byte so we will be able to insert the value to the file.
; the solution is that I did some masks and commands like shr, shl and logical comendands: or, and ,not and xor to make every nibble become a byte in the momory.
; Then i add rto the numbers 30h and to the letters 37h to convert the numbers in the memory to ascii cose.
; Finally, I copied the 4 bytes in the High Score from the memory to the file.

; Input: nothing (the file).
; Output: Variable High_Score with the right values from the file
; Registers Usage: ax, bx, cx, dx.
;========================================		
proc Write_High_Score_To_File
	 push ax
	 push bx
	 push cx
	 push dx
 
	 mov dx, [High_Score]
	 mov bx, offset WriteBuffer
	 
	 mov ah, dh 
	 shr ah,4 
	 mov [byte bx], ah ;converting the forth nibble to the left place of byte ah
	 
	 inc bx	; next digit

	 mov ah, dh 
	 and ah, 00001111b
	 mov [byte bx], ah ;this will not change the left nibble of ah, it will only put the third nibble in the right of ah.
	 
	 inc bx	; next digit
	 
	 mov ah, dl
	 shr ah,4 
	 mov [byte bx], ah ; converting the second nibble to the left place of byte al
	 
	 inc bx	; next digit

	 mov ah, dl
	 and ah, 00001111b
	 mov [byte bx], ah ;this will not change the left nibble of al, it will only put the first nibble in the right of al.
	 
	 
	 mov bx, offset WriteBuffer	 
	 mov cx, [FileLength]
@@Convert_To_Ascii:

	 cmp [byte bx],0Ah ; check if the number is above 9 because above 9 there are letters and the letters start 7 places after number 9.
	 jb RegularConvert 
	 
	 add [byte bx], 37h; need to add 7 because the letters start 7 chars after number 9.
	 jmp @@NextByte
	 
	 ; now the High_Score is 4 bytes for every number or letter in the WriteBuffer in the memory.
	 ; we just need to convert every number or letter to ascii code.
RegularConvert:
	 add [byte bx], 30h	 
	 
@@NextByte:
	 inc bx
	loop @@Convert_To_Ascii
	
	 ;now we are ready to write the High_Score variable to the HighScor file	
	 call Write_to_File
	 
	 pop dx
	 pop cx
	 pop bx
	 pop ax
	 ret 
endp Write_High_Score_To_File
	
;========================================
; Description: Read the high score from HighScor file.
; An explain for the method:
; the HighScor file has 4 ascii digits in hexa .
; every digit in the file is ascii one byte.
; the problem is that we need every hexa digit to be a nibble so we will be able to insert the value to High_Score variable.
; the solution is that i read al the ascii hexa digits into 4 bytes in the memory, converted them to a number (buy subtracting 30h from the numbers qnd 37h fron the letters)
; and then I did some masks and commands like shr, shl and logical comendands: or, and ,not and xor to make every byte become a nibble in a register.
; finally I copied the register to the High_Score variable.

; Input: nothing (the file).
; Output: Variable High_Score with the right values from the file
; Registers Usage: ax, bx, cx, dx.
;========================================	
proc Read_High_Score
	 push ax
	 push bx
	 push cx
	 push dx

	 
	 call Read_From_File
	 
	 ;first we want to convert every byte tfrom ascii code to a regular number or letter.
	 mov  bx, offset ReadBuffer
	 mov cx, [FileLength]
@@Convert_To_Number:
	 cmp [byte bx],41h ;start of the letters in ascii code
	 jb @@RegularConvert 
	 
	 sub [byte bx], 37h; need to sub 7 because the letters start 7h chars after number 9 (30h + 7h).
	 jmp @@NextByte
	
@@RegularConvert:	 
	 sub [byte bx], 30h ; convert the ascii number to a regular number 
	 
@@NextByte:	 
	 inc bx
	 loop @@Convert_To_Number
	 
	  ; in this moment, every byte of the ReadBuffer array is a number or a letter but not ascii any more.
	  ; every number or letter is at the right nibble of the byte.
	  ; now we want to make the 4 bytes become a word so that is what we do in the next lines.
	 mov  bx, offset ReadBuffer
	 
	 mov ah,[byte bx] 
	 shl ah,4 ;mov the number from the right nibble of ah to the left nibele
	 
	 inc bx	

	 mov dl, [byte bx] 
	 or ah, dl ;copy the number to the right nibble of ah without touching the left nibble
	 
	 inc bx	
	 
	 mov al,[byte bx] 
	 shl al,4;mov the number from the right nibble of al to the left nibele
	 
	 inc bx	

	 mov dl, [byte bx] ;copy the number to the right nibble of al without touching the left nibble
	 or al, dl
	 
	 ;now we have the 4 bytes in the memory inside ax as a word so we can move it to the high score.
	 mov [High_Score], ax
	 
	 pop dx
	 pop cx
	 pop bx
	 pop ax
	 ret
endp Read_High_Score





;========================================
; Description: check if the click were at the Exit Program rectangle borders.
; Input: nothing.
; Output: Got_Click_On_Exit_Program variable is true (1) if there is place for the shape on the matrix , else false (0).
; Registers Usage: cx, dx.
;========================================
proc Check_Click_On_Exit_Program
	 push dx
	 push cx
	 
	 mov cx, [XClick]
	 mov dx, [YClick]

;min y	 
	 cmp dx,7
	 jb @@PutFalse
	 
;max y	 
	 cmp dx,(7 + 11)
	 ja @@PutFalse
	
;min x
	 cmp cx,302
	 jb @@PutFalse

;max x	 
	 cmp cx,(302 + 11)
	 ja @@PutFalse
	 jmp @@PutTrue
	 
	 
@@PutTrue:
	 mov [Got_Click_On_Exit_Program], 1
	 jmp @@ExitProc
	 
@@PutFalse:
	 mov [Got_Click_On_Exit_Program], 0
	 jmp @@ExitProc
	 
@@ExitProc:	
	 pop cx
	 pop dx
	 ret
endp Check_Click_On_Exit_Program

;========================================
; Description: draw the rect of the Exit Program option.
; Input: nothing.
; Output: rectangle at the wanted place.
; Registers Usage: ax, cx, dx, si, si.
;========================================
proc Draw_Exit_Program_Rect
	 push si
	 push di
	 push cx
	 push dx
	 push ax
	 
	 mov si, 12
	 mov di, 12
	 mov dx,7
	 mov cx, 302
	 mov al, RedColor
	 call Rect
	 
	 
	 pop ax
	 pop dx
	 pop cx
	 pop di
	 pop si	 
	 ret
endp Draw_Exit_Program_Rect

;========================================
; Description: put the cursor on the start of the Exit Program option.
; Input: nothing.
; Output: cursor at the wanted place.
; Registers Usage: ax, bx, dx.
;========================================
proc Put_Cursor_On_Exit_Program
	 push ax
	 push bx
	 push dx
	 
	 mov ah,2
	 mov bh,0	
	 mov dl, 78
	 mov dh, 1
	 int 10h	
	 
	 pop dx
	 pop bx
	 pop ax
	 ret
endp Put_Cursor_On_Exit_Program


;========================================
; Description: check if the click were at the Back rectangle borders.
; Input: nothing.
; Output: Got_Click_On_Back variable is true (1) if there is place for the shape on the matrix , else false (0).
; Registers Usage: cx, dx.
;========================================
proc Check_Click_On_Back
	 push dx
	 push cx
	 
	 mov cx, [XClick]
	 mov dx, [YClick]
;min y		 
	 cmp dx,171
	 jb @@PutFalse
	 
;max y	
	 cmp dx,(171 + 17)
	 ja @@PutFalse
	 
;min x		
	 cmp cx,140
	 jb @@PutFalse
	 
;max x	
	 cmp cx,(140 + 40)
	 ja @@PutFalse
	 jmp @@PutTrue
	 
	 
@@PutTrue:
	 mov [Got_Click_On_Back], 1
	 jmp @@ExitProc
	 
@@PutFalse:
	 mov [Got_Click_On_Back], 0
	 jmp @@ExitProc
	 
@@ExitProc:	
	 pop cx
	 pop dx
	 ret
endp Check_Click_On_Back

;========================================
; Description: draw the rect of the Back option.
; Input: nothing.
; Output: rectangle at the wanted place.
; Registers Usage: ax, cx, dx, si, si.
;========================================
proc Draw_Back_Rect
	 push si
	 push di
	 push cx
	 push dx
	 push ax
	 
	 mov si,18
	 mov di, 41
	 mov dx,171
	 mov cx, 140
	 mov al, CyanColor
	 call Rect
	 
	 
	 pop ax
	 pop dx
	 pop cx
	 pop di
	 pop si	 
	 ret
endp Draw_Back_Rect

;========================================
; Description: put the cursor on the start of the Back option.
; Input: nothing.
; Output: cursor at the wanted place.
; Registers Usage: ax, bx, dx.
;========================================
proc Put_Cursor_On_Back
	 push ax
	 push bx
	 push dx
	 
	 mov ah,2
	 mov bh,0	
	 mov dl, 18
	 mov dh, 22
	 int 10h	
	 
	 pop dx
	 pop bx
	 pop ax
	 ret
endp Put_Cursor_On_Back


;========================================
; Description: check if the click were at the Rules rectangle borders.
; Input: nothing.
; Output:; Output: Got_Click_On_Rules variable is true (1) if there is place for the shape on the matrix , else false (0).
; Registers Usage: cx, dx.
;========================================
proc Check_Click_On_Rules_Option
	 push dx
	 push cx
	 
	 mov cx, [XClick]
	 mov dx, [YClick]
	 
;min y		 
	 cmp dx,36
	 jb @@PutFalse
	 
;max y	
	 cmp dx,(36 + 17)
	 ja @@PutFalse
	
;mit x
	 cmp cx,219
	 jb @@PutFalse

;max x 
	 cmp cx,(219 + 50)
	 ja @@PutFalse
	 jmp @@PutTrue
	 
@@PutTrue:
	 mov [Got_Click_On_Rules], 1
	 jmp @@ExitProc
	 
@@PutFalse:
	 mov [Got_Click_On_Rules], 0
	 jmp @@ExitProc
	 
@@ExitProc:	
	 pop cx
	 pop dx
	 ret
endp Check_Click_On_Rules_Option

;========================================
; Description: draw the rect of the Rules option.
; Input: nothing.
; Output: rectangle at the wanted place.
; Registers Usage: ax, cx, dx, si, si.
;========================================
proc Draw_Rules_Option_Rect
	 push si
	 push di
	 push cx
	 push dx
	 push ax
	 
	 mov si,18
	 mov di, 51
	 mov dx,36
	 mov cx, 219
	 mov al, CyanColor
	 call Rect
	 
	 
	 pop ax
	 pop dx
	 pop cx
	 pop di
	 pop si	 
	 ret
endp Draw_Rules_Option_Rect

;========================================
; Description: put the cursor on the start of the Rules option.
; Input: nothing.
; Output: cursor at the wanted place.
; Registers Usage: ax, bx, dx.
;========================================
proc Put_Cursor_On_Rules_Option
	 push ax
	 push bx
	 push dx
	 
	 mov ah,2
	 mov bh,0	
	 mov dl, 68
	 mov dh, 5
	 int 10h	
	 
	 pop dx
	 pop bx
	 pop ax
	 ret
endp Put_Cursor_On_Rules_Option


;========================================
; Description: put the cursor on the top left corner of the screen to write the pragraph of the rules.
; Input: nothing.
; Output: cursor in the wanted place.
; Registers Usage: ax, bx, dx.
;========================================
proc Put_Cursor_On_Top_Left_Screen
	 push ax
	 push bx
	 push dx
	 
	 mov ah,2
	 mov bh,0	
	 mov dl, 0
	 mov dh, 0
	 int 10h	
	 
	 pop dx
	 pop bx
	 pop ax
	 ret
endp Put_Cursor_On_Top_Left_Screen

;========================================
; Description: check if the click were at the New Game rectangle borders.
; Input: nothing.
; Output:; Output: Got_Click_On_New_Game variable is true (1) if there is place for the shape on the matrix , else false (0).
; Registers Usage: cx, dx.
;========================================
proc Check_Click_On_New_Game_Option
	 push dx
	 push cx
	 
	 mov cx, [XClick]
	 mov dx, [YClick]
	 
;min y
	 cmp dx,12
	 jb @@PutFalse

;max y
	 cmp dx,(12 + 17)
	 ja @@PutFalse
	 
;min x
	 cmp cx,211
	 jb @@PutFalse

;max x
	 cmp cx,(211 + 73)
	 ja @@PutFalse
	 jmp @@PutTrue
	 
@@PutTrue:
	 mov [Got_Click_On_New_Game], 1
	 jmp @@ExitProc
	 
@@PutFalse:
	 mov [Got_Click_On_New_Game], 0
	 jmp @@ExitProc
	 
@@ExitProc:	
	 pop cx
	 pop dx
	 ret
endp Check_Click_On_New_Game_Option

;========================================
; Description: draw the rect of the New Game option.
; Input: nothing.
; Output: rectangle at the wanted place.
; Registers Usage: ax, cx, dx, si, si.
;========================================
proc Draw_New_Game_Option_Rect
	 push si
	 push di
	 push cx
	 push dx
	 push ax
	 
	 mov si,18
	 mov di, 74
	 mov dx,12
	 mov cx, 211
	 mov al, GreenColor
	 call Rect
	 
	 
	 pop ax
	 pop dx
	 pop cx
	 pop di
	 pop si	 
	 ret
endp Draw_New_Game_Option_Rect

;========================================
; Description: put the cursor on the start of the New Game option place.
; Input: nothing.
; Output: cursor at the wanted place.
; Registers Usage: ax, bx, dx.
;========================================
proc Put_Cursor_On_New_Game_Option
	 push ax
	 push bx
	 push dx
	 
	 mov ah,2
	 mov bh,0	
	 mov dl, 67
	 mov dh, 2
	 int 10h	
	 
	 pop dx
	 pop bx
	 pop ax
	 ret
endp Put_Cursor_On_New_Game_Option

;========================================
; Description: Set the board empty in the memory - it will happen at the beginning and evey time the player will choose New Game option.
; Input: nothing.
; Output:; Output: the board in the memory and on the screen is cleared and.
; Registers Usage: cx, bx.
;========================================
proc Set_Board_Empty_In_Memory
	 push bx
	 push cx
	 
	 mov cx, MAT_TOTAL_LENGTH_IN_MEMORY
	 mov bx, offset Board
ClearCell:
	 mov [byte bx], BlackColor
	 inc bx
	 loop ClearCell
	 
	 pop cx
	 pop bx
	 ret
endp Set_Board_Empty_In_Memory


;========================================
; Description: put the cursor on the start of the Game Over place.
; Input: nothing.
; Output: cursor at the wanted place.
; Registers Usage: ax, bx, dx.
;========================================
proc Put_Cursor_On_Game_Over
	 push ax
	 push bx
	 push dx
	 
	 mov ah,2
	 mov bh,0	
	 mov dl, 58
	 mov dh, 44
	 int 10h	
	 
	 pop dx
	 pop bx
	 pop ax
	 ret
endp Put_Cursor_On_Game_Over





;========================================
; Description: clear the screan with rect method.
; Input: nothing.
; Output: the screan cleared - black.
; Registers Usage: si, di, cx, dx, ax.
;========================================
proc ClearScrean
	 push si
	 push di
	 push cx
	 push dx
	 push ax
	 
	 mov si,200
	 mov di, 320
	 mov cx, 0
	 mov dx,0
	 mov al, BlackColor
	 call Rect
	 
	 
	 pop ax
	 pop dx
	 pop cx
	 pop di
	 pop si	 
	 ret
endp ClearScrean





;========================================
; Description: print the High Score: first print the string High_Score_String variable and then the High Score in decimal numbers - Score variable.
; Input: the variable High Score.
; Output: cursor at the wanted place.
; Registers Usage: ax, dx.
;========================================
proc Print_High_Score
	 push ax
	 push dx
	 
	 mov dx, offset High_Score_String
	 mov ah,9
	 int 21h
	 
	 mov ax, [High_Score]
	 call ShowAxDecimal
	 
	 pop dx
	 pop ax
	 ret
endp Print_High_Score

;========================================
; Description: put the cursor on the start of the High_Score place.
; Input: X_Of_The_Start_High_Score_Point and  Y_Of_The_Start_High_Score_Point are consts.
; Output: cursor at the wanted place.
; Registers Usage: ax, bx, dx.
;========================================
proc Put_Cursor_On_High_Score_Position
	 push ax
	 push bx
	 push dx
	 
	 mov ah,2
	 mov bh,0	
	 mov dl, X_Of_The_Start_High_Score_Point
	 mov dh, Y_Of_The_Start_High_Score_Point
	 int 10h	
	 
	 pop dx
	 pop bx
	 pop ax
	 ret
endp Put_Cursor_On_High_Score_Position


;========================================
; Description: print the score: first print the string Score_String variable and then the score in decimal numbers - Score variable.
; Input: the variable Score.
; Output: cursor at the wanted place.
; Registers Usage: ax, dx.
;========================================
proc PrintScore
	 push ax
	 push dx
	 
	 mov dx, offset Score_String
	 mov ah,9
	 int 21h
	 
	 mov ax, [Score]
	 call ShowAxDecimal
	 
	 pop dx
	 pop ax
	 ret
endp PrintScore


;========================================
; Description: put the cursor on the start of the Score place.
; Input: X_Of_The_Start_Score_Point and Y_Of_The_Start_Score_Point are consts.
; Output: cursor at the wanted place.
; Registers Usage: ax, bx, dx.
;========================================
proc Put_Cursor_On_Score_Position
	 push ax
	 push bx
	 push dx
	 
	 mov ah,2
	 mov bh,0	
	 mov dl, X_Of_The_Start_Score_Point
	 mov dh, Y_Of_The_Start_Score_Point
	 int 10h	
	 
	 pop dx
	 pop bx
	 pop ax
	 ret
endp Put_Cursor_On_Score_Position


;================================================
; Description - Write on screen the value of ax (decimal)
;               the practice :  
;				Divide AX by 10 and put the Mod on stack 
;               Repeat Until AX smaller than 10 then print AX (MSB) 
;           	then pop from the stack all what we kept there. 
; INPUT: AX
; OUTPUT: Screen 
; Register Usage: AX, BX, CX, DX
;================================================
proc ShowAxDecimal
	 push bx
	 push cx
	 push dx
	 push ax
	 
	 ; check if negative - if the last bit is 1 it is negative
	 test ax,08000h 
	 jz PositiveAx
	   
	 neg ax ; make it positive
	   
PositiveAx:
	 mov cx,0   ; will count how many time we did push 
	 mov bx,10  ; the divider
   
put_mode_to_stack:
       
	 xor dx,dx ;because when we divide in word, dx get the mode
	 div bx
	 add dl,30h ; - convert it to ascii - the result must be under 10 so there aren't letters
				 ; (the letters start 7 places after the last number - 9 - and we need to add 37h to get there)
	 ; dl is the current LSB digit 
	 ; we can't push only dl so we push all dx
	 push dx ;put mode in stack
	 inc cx ;must count the number of pushes so we know how much to pop
	   
	 cmp ax,9 ; check if it is the last time to div
	 jg put_mode_to_stack

	 cmp ax,0
	 jz Pop_And_Print ; jump if ax was totally 0, if ax = 0 we can start to pop the modes.
	 
	 ; ax is between 1 to 9, instead of pushing it to the stack we can just print it,
	 ; this is the first digit of the decimal number.
	 add al,30h	  
	 mov dl, al    
	 mov ah, 2h
	 int 21h ; show first digit MSB
	 
	 ;cx have the number of pops to do.     
Pop_And_Print: 
	 pop ax ; remove all rest LIFO (reverse) (MSB to LSB)
	   
	 mov dl, al
	 mov ah, 2h
	 int 21h ; show all rest digits
	   
	 loop Pop_And_Print
		
	 pop ax
	 pop dx
	 pop cx
	 pop bx
	   
	 ret
endp ShowAxDecimal


;========================================
; Description: put a random number of shape in the variable ShapeKind (every shape by its friquance).
; Input: nothing
; Output: the random number in the variable ShapeKind.
; Registers Usage: ax, bx.
;========================================
proc Get_Rnd_In_ShapeKind
	 push bx
	 push ax
	 
	 mov bl,1
	 mov bh,100	 
	 call RandomByCs
	 
	 cmp al, 10
	 jbe Rnd_One_Square_Shape ;10%
	 
	 cmp al, 35
	 jbe Rnd_Two_Squares_Down_Shape ;25%
	 
	 cmp al, 60 
	 jbe Rnd_Two_Squares_Right_Shape ;25%
	 
	 jmp Rnd_Two_Squares_Down_Right_Shape ; 40%
	 
Rnd_One_Square_Shape:	 
	 mov [ShapeKind],1
	 jmp @@ExitProc
	 
Rnd_Two_Squares_Down_Shape:
	 mov [ShapeKind],2
	 jmp @@ExitProc
		 
Rnd_Two_Squares_Right_Shape:
	 mov [ShapeKind],3
	 jmp @@ExitProc	

Rnd_Two_Squares_Down_Right_Shape:
	 mov [ShapeKind],4
	 jmp @@ExitProc
		 
@@ExitProc:		 
	 pop ax
	 pop bx
	 
	 ret
endp Get_Rnd_In_ShapeKind

;=======================================================================================
; Description  : get RND between any bl and bh includs (0 - 255).
; Input        : 1. Bl = min (from 0) , BH = Max (till 255).
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0 .
;				 3. EndOfCsLbl: is label at the end of the program, one line above END start.		
; Output:        Al = rnd num from bl to bh  (example: 50 - 150)
; More Info:
; 	Bl must be less than Bh. 
; 	In order to get good random value again and again the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
;=======================================================================================
proc RandomByCs
	 push es
	 push si
	 push di
	
	 mov ax, 40h ;the place where the clock erite the time (like a000 in graphic screen)
	 mov	es, ax
	
	 sub bh,bl  ; we will make rnd number between 0 to the delta (הפרש) between bl and bh 
			   ; Now bh holds only the delta
			   ; after we will find a random number between 0 the delta,
			   ; we will add the rendom number bl so the random number will be between bl to bh.
	 cmp bh,0 ;if bh 0 it means that bl and bh are equal and the number will not be random.
	 jz @@ExitP
 
	 mov di, [word RndCurrentPos] ; move di some adress in the beginning of CODSEG
	 call MakeMask ; will put in si the right mask according to  the delta (bh) (example for 0 - 28 will put 11111b in si (31d). )
				  ; the mask have the minimum number of bites of the range of the delta number.
				  
RandLoop: ;  generate (יצירת) random number	:
	 ; we cn't use only the clock because if we will use the randome methode two times one after the other,
	 ; it will give us the same clock value
	 mov ax, [es:06ch] ; read timer counter - in es [0040h:06ch] according to 1/100 a second.
	 mov ah, [byte cs:di] ; read one byte from memory (from semi random byte at cs) - will make it more random
	 xor al, ah ; xor memory and counter - will make it more random
	
	 ; Now inc di in order to get a different number next time
	 inc di 
	 cmp di,(EndOfCsLbl - start - 1) ; di goes on this program if it got out of the program we need to take it back
										 ;di will be increased in 1 every time this methode is called so the random
										 ;number will be differen.
	 jb @@Continue 
	 mov di, offset start ; that means di have passed the last command in that program and we need
						   ; to take him back to the beginning.
@@Continue:
	 mov [word RndCurrentPos], di ; here we take back di to the beginning of this program.
	
	 and ax, si ; filter result between 0 and si (the mask) -
				; now we want to be in the range so the filter will make all the bits 0
				; and save the bits that are in the filter rang
				
	 cmp al,bh  ; do again if above the delta - rare or can not happen - al the random number with the filter,
				; bh - the maximum number of the random - must not be above - so we need to do make a new random number.
	 ja RandLoop
	
	 add al,bl  ; add the lower limit to the rnd num
				 ; now al have a random number.
				 
@@ExitP:	
	 pop di
	 pop si
	 pop es
	 ret
endp RandomByCs

;========================================
; Description: make mask acording to bh size.
; Input: nothing
; Output: Si = mask put 1 in all bh range
; example:  if bh 4 or 5 or 6 or 7 si will be 7
; 		   if Bh 64 till 127 si will be 127
; Registers Usage: nothing.
;========================================
Proc MakeMask    
    push bx

	mov si,1
    
@@again:
	shr bh,1
	cmp bh,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right so in the end si will have 1 at all the bits of bh.
	inc si ;this add one to the right bit after that shl command have done and the right bit is 0.
	
	jmp @@again
	
@@EndProc:
    pop bx
	ret
endp  MakeMask





;========================================
; Description: set the Score after the turn acording to the shape that were inserted and the full lines
; input: nothing
; Output: Score variable ready to be printed on the screen (the variable is with right values)
; Registers Usage: nothing.
;========================================
proc Calc_Score
	 Call Add_Score_Full_Lines_Points

	 cmp [ShapeKind],1
	 jz @@One_Square_Points
	 
	 cmp [ShapeKind],2
	 jz @@Two_Squares_Points
	 
	 cmp [ShapeKind],3
	 jz @@Two_Squares_Points
	 
	 cmp [ShapeKind],4
	 jz @@Three_Squares_Points
	  
@@One_Square_Points:
	 add [score], 1 ; one point for one square
	 jmp @@EndProc

@@Two_Squares_Points:
	 add [score], 2 ; two points for two squares
	 jmp @@EndProc
	 
@@Three_Squares_Points:
	 add [score], 3 ; three points for three squars
	 jmp @@EndProc
	 
@@EndProc:

	 ret
endp Calc_Score


;========================================
; Description: add to the Score the points from the full lines.
; if the number of full lines is, for example: 3, the points for the full lines points are: (1*MAT_HIGHT_IN_MEMORY + 2*MAT_HIGHT_IN_MEMORY + 3*MAT_HIGHT_IN_MEMORY)
; input: nothing
; Output: Score variable plus the full lins points. 
; Registers Usage: nothing.
;========================================
proc Add_Score_Full_Lines_Points
	 push ax
	 push cx
	 push bx
	 
	 xor ax,ax
	 xor cx,cx
	 xor bx,bx
	 
	 cmp [Number_Of_Full_Lines], 0
	 jz @@EndProc
	 
	 mov cl, [Number_Of_Full_Lines]
	 mov ax, MAT_HIGHT_IN_MEMORY ; 10
	 mov bl, 1
GiveScore:
	 mul bl 
	 add [Score], ax
	 	 
	 mov ax,MAT_HIGHT_IN_MEMORY; 10
	 inc bl
	 loop GiveScore
	 
@@EndProc:
	 pop bx
	 pop cx
	 pop ax	 
	 ret
endp Add_Score_Full_Lines_Points


;========================================
; Description: A delay which will show the border around a line on the screen for a short time before
; it changes to another color.
; input: nothingal = color around the full lines.
; Output: short time delay of the whole program - nothing will happan at the time of the delay.
; Registers Usage: ax.
;========================================
proc Full_Lines_Change_Color_With_Delay
	 push ax
	 
	 call ChangeColorDelay
	 call ChangeColorDelay
	 
	 
	 mov al, COVER_FULL_LINE_COLOR
	 call Sign_Full_Lines ;sign the full lines	 
	 call ChangeColorDelay
	 call ChangeColorDelay
	 
	 mov al, BORDER_COLOR
	 call Sign_Full_Lines ;sign the full lines	 
	 call ChangeColorDelay
	 call ChangeColorDelay
	 
	 mov al, COVER_FULL_LINE_COLOR
	 call Sign_Full_Lines ;sign the full lines	 
	 call ChangeColorDelay
	 call ChangeColorDelay
	 
	 mov al, BORDER_COLOR
	 call Sign_Full_Lines ;sign the full lines	 
	 call ChangeColorDelay
	 call ChangeColorDelay
	 call ChangeColorDelay 
	 
	 pop ax
	 ret
endp Full_Lines_Change_Color_With_Delay

;========================================
; Description: A delay which will show the border around a line on the screen for a short time before
; it changes to another color.
; input: nothingal = color around the full lines.
; Output: short time delay of the program.
; Registers Usage: cx.
;========================================
proc ChangeColorDelay
	push cx
	mov cx ,2000
@@Self1:
	
	push cx
	mov cx,1000

@@Self2:	
	loop @@Self2
	
	pop cx
	loop @@Self1

	 pop cx
	ret
	
endp ChangeColorDelay


;========================================
; Description: Draw lines around the borders of all the full lines (rows and cols) on the screen.
; input: al = color around the full lines.
; Output: on the borders of al the full lines on the screen will be the color from the input.
; Registers Usage: nothing.
;========================================
Proc Sign_Full_Lines
	 cmp [Are_There_Full_Lines], 1
	 jnz @@ExitProc
	 
	 cmp [Number_Of_Full_Cols], 0
	 jbe @@Sign_Full_Rows
	 
	 mov [Are_There_Full_Cols], 1
	 
	 call HideMouse		 
	 call Sign_Cols ; print line around the full cols 
	 call ShowMouse

@@Sign_Full_Rows:
	 cmp [Number_Of_Full_Rows], 0
	 jbe @@ExitProc ; means that there are only full cols
	 
	 mov [Are_There_Full_Rows], 1
	 
	 call HideMouse	 
	 call Sign_Rows ; print line around the full rows 
	 call ShowMouse

@@ExitProc:
	 ret
endp Sign_Full_Lines

;========================================
; Description: Draw lines around the borders of all the full rows on the screen.
; input: al = color
; Output: on the borders of al the full rows on the screen will be the color from the input.
; Registers Usage: ax, bx, cx, dx.
;========================================
proc Sign_Rows
	 push ax
	 push bx
	 push cx
	 push dx
	 
	 mov cx, [Number_Of_Full_Rows]
	 mov bx, offset Full_Rows
SignRows:
	 push cx
	 xor dx,dx
	 mov dl, [byte bx]
	 call Draw_Border_Around_Cleared_Row
	 
	 inc bx ;next full row
	 
	 pop cx
	 loop SignRows
	 
	 pop dx
	 pop cx
	 pop bx
	 pop ax
	 ret
endp Sign_Rows

;========================================
; Description: Draw lines around the borders of all the full cols on the screen.
; input: al = color
; Output: on the borders of al the full cols on the screen will be the color from the input.
; Registers Usage: ax, bx, cx, dx.
;========================================
proc Sign_Cols
	 push ax
	 push bx
	 push cx
	 push dx
	 
	 mov cx, [Number_Of_Full_Cols]
	 mov bx, offset Full_Cols
@@SignCols:
	 push cx
	 xor cx,cx
	 mov cl, [byte bx]
	 call Draw_Border_Around_Cleared_Col
	 
	 inc bx ;next full col
	 
	 pop cx
	 loop @@SignCols
	 
	 pop dx
	 pop cx
	 pop bx
	 pop ax
	 ret
endp Sign_Cols


;========================================
; Description: Draw lines around the borders of a row on the screen.
; input: al = color, dx = row number in memory mat
; Output: on the borders of the row on the screen will be the color from the input.
; Registers Usage: ax, cx, dx, si, di.
;========================================
proc Draw_Border_Around_Cleared_Row
	 push si
	 push cx
	
	; converting the memory row index, to the screen
	 push ax ; save ax because al have the color.
	 mov ax, dx
	 call MulFromMemoryToScreen	 
	 mov dx,ax ; col in the screen	 	 
	 pop ax ; now al have the color - in this point we don't need ax anymore for the multiplying.	 
	 add dx, ROWS_SPACES_FROM_TOP_FOR_BOARD
	 
	 mov cx, COLS_SPACES_FROM_LEFT_FOR_BOARD ; 0 in the memory mat
	 
	
	mov si, MAT_WIDTH_IN_SCREEN
	call DrawHorizontalLine ; top horizontal

	 
	mov si, CELL_HIGHT_IN_SCREEN
	call DrawVerticalLine ; top horizontal
	
	add dx, CELL_HIGHT_IN_SCREEN
	mov si, (MAT_WIDTH_IN_SCREEN + 1); +1 because the last border - pixel, is not in the screen matrix
	call DrawHorizontalLine 

	sub dx, CELL_HIGHT_IN_SCREEN
	add cx, MAT_WIDTH_IN_SCREEN
	mov si, (CELL_WIDTH_IN_SCREEN + 1) ; +1 because the last border - pixel, is not in the screen matrix	
	call DrawVerticalLine
	
	 pop cx
	 pop si
	 
	 ret
endp Draw_Border_Around_Cleared_Row

;========================================
; Description: Draw lines around the borders of a column on the screen.
; input: al = color, cx = col number in memory mat
; Output: on the borders of the col on the screen will be the color from the input.
; Registers Usage: ax, cx, dx, si, di.
;========================================
proc Draw_Border_Around_Cleared_Col
	 push si
	 push dx
	 
	; converting the memory col index, to the screen
	 push ax ; save ax because al have the color.
	 mov ax, cx
	 call MulFromMemoryToScreen	 
	 mov cx,ax ; col in the screen	 
	 pop ax; now al have the color - in this point we don't need ax anymore for the multiplying.
	 add cx, COLS_SPACES_FROM_LEFT_FOR_BOARD
	 
	 mov dx, ROWS_SPACES_FROM_TOP_FOR_BOARD ; 0 in the memory mat
	 
	
	mov si, MAT_HIGHT_IN_SCREEN
	call DrawVerticalLine ;left vertical

	 
	mov si, CELL_WIDTH_IN_SCREEN 	
	call DrawHorizontalLine ; top horizontal
	
	add cx, CELL_WIDTH_IN_SCREEN
	mov si, MAT_HIGHT_IN_SCREEN
	call DrawVerticalLine ;right vertical

	sub cx, CELL_WIDTH_IN_SCREEN
	add dx, MAT_HIGHT_IN_SCREEN
	mov si, (CELL_WIDTH_IN_SCREEN + 1)	
	call DrawHorizontalLine ;low horizontal
	
	 pop dx
	 pop si
	 
	 ret
endp Draw_Border_Around_Cleared_Col


;========================================
; Description: count how much full lines we have to calculate the Score.
; input: nothing
; Output: set the variables: Full_Rows - indexes of rows, Full_Cols - indexes of cols, Number_Of_Full_Rows,
; Number_Of_Full_Cols, Number_Of_Full_Lines, Are_There_Full_Rows, Are_There_Full_Cols, Are_There_Full_Lines
; Registers Usage: bx, cx, dx.
;========================================
proc Count_Full_Lines
	 push bx
	 push cx
	 push dx
	 
	 call List_Full_Rows ; put in Full_Rows array the y of the full rows
	 call List_Full_Cols ; put in Full_Cols array the x of the full columns
	 
	 
	 mov bx, offset Full_Rows
	 xor dx,dx
@@Count_Rows:
	 cmp [byte bx], '!'
	 jz @@First_Count_Check
	 
	 inc [Number_Of_Full_Rows] ; to know how mush rows we need to restore to '!' in the end of the turn
	 inc [Number_Of_Full_Lines]; will help to caculate the Score
	 inc bx
	 jmp @@Count_Rows
	 
@@First_Count_Check:	 
	 cmp [Number_Of_Full_Rows], 0
	 jbe @@SecondCount
	 
	 mov [Are_There_Full_Rows], 1 ;there are full rows
	 
	 
@@SecondCount:
	 
	 mov bx, offset Full_Cols	 
	 xor cx,cx
@@Count_Cols:
	 cmp [byte bx], '!'
	 jz @@Second_Count_Check
	 
	 inc [Number_Of_Full_Cols] ; to know how mush cols we need to restore to '!' in the end of the turn
	 inc [Number_Of_Full_Lines]; help the Score
	 inc bx
	 jmp @@Count_Cols
	 
@@Second_Count_Check:
	 cmp [Number_Of_Full_Cols], 0
	 jbe Check_Full_Lines
	 
	 mov [Are_There_Full_Cols], 1 ;there are full rows
	 
	 
Check_Full_Lines:	 
	 cmp [Number_Of_Full_Lines], 0
	 jbe @@EndProc
	 
	 mov [Are_There_Full_Lines], 1
	 
@@EndProc:
	 pop dx
	 pop cx
	 pop bx
	 
	 ret
endp Count_Full_Lines

;========================================
; Description: Clear the the full lines from the memory (put BlackColor - empty).
; input: nothing
; Output: the lines that were full will be empty in the memory.
; Registers Usage: bx, cx, dx.
;========================================
proc Clear_Full_Lines
	 push bx
	 push cx
	 push dx
	 
	 call List_Full_Rows ; put in Full_Rows array the y of the full rows
	 call List_Full_Cols ; put in Full_Cols array the x of the full columns
	 
	 
	 mov bx, offset Full_Rows
	 xor dx,dx
@@Clear_Rows:
	 cmp [byte bx], '!'
	 jz @@ClearAndCountCols
	 
	 mov dl, [byte bx]
	 call Clear_Row

	 inc bx
	 jmp @@Clear_Rows
	 

@@ClearAndCountCols:
	 
	 mov bx, offset Full_Cols	 
	 xor cx,cx
@@Clear_Cols:
	 cmp [byte bx], '!'
	 jz @@EndProc
	 
	 mov cl, [byte bx]
	 call Clear_Col
	 
	 inc bx
	 jmp @@Clear_Cols
	 
@@EndProc:
	 pop dx
	 pop cx
	 pop bx
	 
	 ret
endp Clear_Full_Lines


;========================================
; Description:  clear the x of the every full row from the variable Full_Rows array in the memory matrix
; input: nothing
; Output: Full_Cols array variable in the memory matrix is full of '!'.
; Registers Usage: bx, cx.
;========================================
proc SetUp_Full_Rows_Arr
	 push bx
	 push cx
	 
	 mov cx, [Number_Of_Full_Rows]
	 mov bx, offset Full_Rows
@@SetUp_Full_Rows_Arr_Loop:
	 mov [byte bx], '!'
	 inc bx
	 loop @@SetUp_Full_Rows_Arr_Loop 
	 
	 pop cx
	 pop bx
	 ret
endp SetUp_Full_Rows_Arr

;========================================
; Description: put the x of the full rows in Full_Rows array so we will be able to know were are the rows that need to be cleared.
; if we would have cleared the full rows before we knew the places (y) of the full cols, the method that clear the rows might clear also
; some cells from the full cols and then they will not be full and will not be cleard at the time that the methode that clear cols will run.
; input: nothing
; Output: the x of the every full row in Full_Rows array in the memory matrix
; Registers Usage: bx, cx, dx.
;========================================
proc List_Full_Rows
	 lea bx, [Full_Rows]
	 mov dx, 0
@@LoopOnRows:
	 call Check_If_Row_Full  ;this method change IsFull variable
	 cmp [IsFull],1
	 jz @@Add_To_Clear_List ;this means that there is a full row and we want to add it to Full_Rows array that will help to get the places of these rows and the number of them (in the future).
	 jmp @@NextRow
	  
@@Add_To_Clear_List:
	 mov [Byte bx], dl ;arrray of bytes
	 inc bx
	 
@@NextRow:
	 inc dx  ;next x in the memoty matrix
	 cmp dx, MAT_HIGHT_IN_MEMORY
	 jb @@LoopOnRows
	 
	 ret
endp List_Full_Rows


;========================================
; Description: check if a row is full (if every cell in the row is not empty) .
; input: dx = y of the row
; Output: IsEmpty variable is true (1) if the row is full, else false (0).
; Registers Usage: cx, dx.
;========================================
proc Check_If_Row_Full
	 push cx

	 mov cx, 0
@@LoopOnRow:
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1 ;1 means true (empty)
	 jz @@PutFalse ;if at least one square in the col is empty, it isn't full.
	 
	 inc cx ;we add 1 to cx before the check so it will do on loop 9 but not on 10 
	 cmp cx, MAT_WIDTH_IN_MEMORY ;number of cols that can be in one row.
								;we add 1 to dx before the check so it will do on loop 9 but not on 10
	 jb @@LoopOnRow
	 
@@PutTrue:	 
	 mov [IsFull],1
	 jmp @@EndProc
	 
@@PutFalse:
	 mov [IsFull],0
	 
@@EndProc:	 
	 pop cx
	 
	 ret
endp Check_If_Row_Full


;========================================
; Description: clear one row from the memory array
; input: dx = y of the row
; Output: every cell in the row is empty (black)
; Registers Usage: ax, cx, dx.
;========================================
proc Clear_Row
	 push cx
	 push ax

	 mov cx, 0
	 mov al, BlackColor
@@LoopOnRow:
	 call Input_Color_To_One_Memory_Cell

	 inc cx ; go to the next cell until the row end
	 cmp cx, MAT_WIDTH_IN_MEMORY ;we add 1 to cx before the check so it will do on loop 9 but not on 10.
	 jb @@LoopOnRow ; because if I would have use loop command,
					; it could has stop the loop at 0, which is bad because the col 0 will never be cleared.
					; that the reason I did a loop on my self. 
	 pop ax
	 pop cx
	 ret
endp Clear_Row


;========================================
; Description:  clear the y of the every full col from Full_Cols array variable in the memory matrix
; input: nothing
; Output: Full_Cols array variable in the memory matrix is full of '!'.
; Registers Usage: bx, cx.
;========================================
proc SetUp_Full_Cols_Arr
	 push bx
	 push cx
	 
	 mov cx,[Number_Of_Full_Cols]
	 mov bx, offset Full_Cols
@@SetUp_Full_Cols_Arr_Loop:
	 mov [byte bx], '!'
	 inc bx
	 loop @@SetUp_Full_Cols_Arr_Loop
	 
	 pop cx
	 pop bx
	 ret
endp SetUp_Full_Cols_Arr

;========================================
; Description: put the y of the full cols in Full_Cols array so we will be able to know were are the cols that need
; to be cleared. if we would have cleared the full cols before we knew the places (x) of the full rows, the method that
; clear the cols might clear also some cells from the full rows and then they will not be full and will not be cleard
; at the time that the methode that clear rows will run.
; input: nothing
; Output: the y of the every full col in Full_Cols array in the memory matrix.
; Registers Usage: bx, cx, dx.
;========================================
proc List_Full_Cols
	 push bx
	 push cx
	 
	 lea bx, [Full_Cols]
	 mov cx, 0
@@LoopOnCols:
	 call Check_If_Col_Full ;this method change IsFull variable
	 cmp [IsFull],1
	 jz @@Add_To_Clear_List ;this means that there is a full column and we want to add it to Full_Cols array that will help to get the places of these columns and the number of them (in the future).
	 jmp @@NextCol
	  
@@Add_To_Clear_List:
	 mov [Byte bx], cl ;arrray of bytes
	 inc bx
 
@@NextCol:
	 inc cx ;next Y in the memoty matrix
	 cmp cx, MAT_WIDTH_IN_MEMORY ;number of cols that can be in one row.
						      ;we add 1 to cx before the check so it will do on loop 9 but not on 10
	 jb @@LoopOnCols
	 
	 pop cx
	 pop bx
	 ret
endp List_Full_Cols



;========================================
; Description: check if a column is full (if every cell in the column is not empty) .
; input: cx = x of the column
; Output: IsEmpty variable is true (1) if the column is full, else false (0).
; Registers Usage: cx, dx.
;========================================
proc Check_If_Col_Full
	 push dx

	 mov dx, 0
@@LoopOnCol:
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1 ;1 means true (empty)
	 jz @@PutFalse ;if at least one square in the column is empty, the column isn't full.
	 
	 inc dx
	 cmp dx, MAT_HIGHT_IN_MEMORY  ;number of rows that can be in one col.
								;we add 1 to dx before the check so it will do on loop 9 but not on 10
	 jb @@LoopOnCol
	 
@@PutTrue:	 
	 mov [IsFull],1
	 jmp @@EndProc
	 
@@PutFalse:
	 mov [IsFull],0
	 
@@EndProc:	 
	 pop dx
	 
	 ret
endp Check_If_Col_Full


;========================================
; Description: clear one column from the memory array
; input: cx = x of the col
; Output: every cell in the column is empty (black)
; Registers Usage: ax, cx, dx.
;========================================
proc Clear_Col
	 push dx
	 push ax

	 mov dx, 0
	 mov al, BlackColor
@@LoopOnCol:
	 call Input_Color_To_One_Memory_Cell
	 
	 inc dx ;go to the next cell until the column end
	 cmp dx, MAT_HIGHT_IN_MEMORY
	 jb @@LoopOnCol ; because if I would have use loop command,
					; it could has stop the loop at 0, which is bad because the row 0 will  never be cleared.
					; that the reason I did a loop on my self. 
	 
	 pop ax
	 pop dx 
	 ret
endp Clear_Col


;========================================
; Description: draw the shape according to ShapeKind variable .
; Input: cx = X of the start shapes point in the screen.
;		 dx = Y of the start shapes point in the screen.
;		 si = the hight of the cell on the screen.
;		 di = the width of the cell on the screen.
; Output: the shape on the the screen.
; Registers Usage: nothing.
;========================================
proc DrawShape
	 
	 cmp [ShapeKind],1
	 jz @@Draw_One_Square ;only calls rect method but we want a better name instead of rect.
	 
	 cmp [ShapeKind],2
	 jz @@Draw_Two_Squares_Down
	 
	 cmp [ShapeKind],3
	 jz @@Draw_Two_Squares_Right
	 
	 cmp [ShapeKind],4
	 jz @@Draw_Two_Squares_Down_Right
	 
	 
@@Draw_One_Square:
	 call Draw_One_Square_Shape
	 jmp @@EndProc


@@Draw_Two_Squares_Down:
	 call Draw_Two_Squares_Down_Shape
	 jmp @@EndProc

@@Draw_Two_Squares_Right:
	 call Draw_Two_Squares_Right_Shape
	 jmp @@EndProc
	 
@@Draw_Two_Squares_Down_Right:
	 call Draw_Two_Squares_Down_Right_Shape

@@EndProc:
	 ret
endp DrawShape


;========================================
; Description: check if can place the shape (if one of the squars are empty) .
; Input: nothing (use ShapeKind variable)
; Output: Mat_Has_Place variable is true (1) if there is place on the matrix, else false (0).
; Registers Usage: nothing.
;========================================
proc Check_If_Can_Place_shape_In_Mat ; boolian variables 1 for true if can place the shape, else 0 (false). המשתנה ישתנה בתוך התת פעולות
	 cmp [ShapeKind],1
	 jz @@One_Square_Check
	 
	 cmp [ShapeKind],2
	 jz @@Two_Squares_Down_Check
	 
	 cmp [ShapeKind],3
	 jz @@Two_Squares_Right_Check
	 
	 cmp [ShapeKind],4
	 jz @@Two_Squares_Down_Right_Check
	  
@@One_Square_Check:
	 call Check_if_there_is_One_Square_Shape_Empty_In_Mat ;in the method the variable is change
	 jmp @@EndProc


@@Two_Squares_Down_Check:
	 call Check_if_there_are_two_Square_Down_Shape_Empty_In_Mat ;in the method the variable is change
	 jmp @@EndProc

@@Two_Squares_Right_Check:
	 call Check_if_there_are_two_Square_Right_Shape_Empty_In_Mat ;in the method the variable is change
	 jmp @@EndProc
	 
@@Two_Squares_Down_Right_Check:
	 call Check_if_there_are_Two_Squares_Down_Right_Shape_Empty_In_Mat

@@EndProc:

	 ret
endp Check_If_Can_Place_shape_In_Mat


;========================================
; Description: check if one of the squars are empty. this proc doesn't use x or y because it goes one time on the array
; Input: nothing
; Output: Mat_Has_Place variable is true (1) if there is place on the matrix, else false (0).
; Registers Usage: cx, bx.
;========================================
proc Check_if_there_is_One_Square_Shape_Empty_In_Mat
	 push bx
	 push cx
	 
	 lea bx, [Board]
	 mov cx, MAT_TOTAL_LENGTH_IN_MEMORY
CheckLoop:
	 cmp [byte bx], BlackColor ;if the cell is empty
	 jz @@PutTrue
	 
	 inc bx
	 loop CheckLoop
	 
@@PutFalse:
	 mov [Mat_Has_Place],0
	 jmp @@ExitProc
@@PutTrue:
	 mov [Mat_Has_Place],1
	 
@@ExitProc:
	 pop cx
	 pop bx
	 
	 ret
endp Check_if_there_is_One_Square_Shape_Empty_In_Mat


;========================================
; Description: check if can place the shape - if the matrix has a place for two squares that goes down.
; Input: nothing
; Output: Mat_Has_Place variable is true (1) if there is place for the shape on the matrix , else false (0).
; Registers Usage: cx, dx.
;========================================
proc Check_if_there_are_two_Square_Down_Shape_Empty_In_Mat
	 push cx
	 push dx
	 
	 mov cx, 0 
@@loopOut:
	 mov dx, 0
@@LoopIn:	
	 
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1
	 jz @@SecondCellCheck
	 jmp @@NextCheck
	 
	 
@@SecondCellCheck:
	 inc dx
	 call Check_One_Square_Empty
	 dec dx
	 cmp [IsEmpty],1
	 jz @@PutTrue
	 	 
@@NextCheck:	 
	 inc dx
	 
	 cmp dx, (MAT_HIGHT_IN_MEMORY - 1) ;one before the last one because we don't wang to be out of the array range.
	 jb @@LoopIn
	 
	 inc cx
	 cmp cx, MAT_WIDTH_IN_MEMORY
	 jb @@LoopOut ; 0-9 so until below 10
	 	 
@@PutFalse:
	 mov [Mat_Has_Place],0 ; it will be here if there is no place for the shape
	 jmp @@ExitProc	 
	 
@@PutTrue:
	 mov [Mat_Has_Place],1
	 
@@ExitProc:

	  pop dx
	  pop cx
	 ret
endp Check_if_there_are_two_Square_Down_Shape_Empty_In_Mat


;========================================
; Description: check if can place the shape - if the matrix has a place for for two squares that goes right.
; Input: nothing
; Output: Mat_Has_Place variable is true (1) if there is place for the shape on the matrix , else false (0).
; Registers Usage: cx, dx.
;========================================
proc Check_if_there_are_two_Square_Right_Shape_Empty_In_Mat
	 push dx
	 push cx
	 
	 mov dx, 0 
@@loopOut:
	 mov cx, 0
@@LoopIn:	
	 
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1
	 jz @@SecondCellCheck
	 jmp @@NextCheck
	 
	 
@@SecondCellCheck:
	 inc cx
	 call Check_One_Square_Empty
	 dec cx
	 cmp [IsEmpty],1
	 jz @@PutTrue
	 
@@NextCheck:	 
	 inc cx
	 
	 cmp cx, (MAT_WIDTH_IN_MEMORY - 1) ;one before the last one because we don't wang to be out of the array range.
	 jb @@LoopIn
	 
	 inc dx
	 cmp dx, MAT_HIGHT_IN_MEMORY
	 jb @@LoopOut ; 0-9 so until below 10
	 
@@PutFalse:
	 mov [Mat_Has_Place],0 ; it will be here if there is no place for the shape
	 jmp @@ExitProc	 
	 
@@PutTrue:
	 mov [Mat_Has_Place],1

	 
@@ExitProc:
	 pop cx
	 pop dx
	 
	 ret
endp Check_if_there_are_two_Square_Right_Shape_Empty_In_Mat

;========================================
; Description: check if can place the shape - if the matrix has a place for for two squares that goes right and down.
; Input: nothing
; Output: Mat_Has_Place variable is true (1) if there is place for the shape on the matrix , else false (0).
; Registers Usage: cx, dx.
;========================================
proc Check_if_there_are_Two_Squares_Down_Right_Shape_Empty_In_Mat
	 push dx
	 push cx
	 
	 mov dx, 0 
@@loopOut:
	 mov cx, 0
@@LoopIn:	
	 
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1
	 jz @@SecondCellCheck
	 jmp @@NextCheck
	 
	 
@@SecondCellCheck:
	 inc cx
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1
	 jz @@thirdCellCheck
	 jmp @@NextCheck
	 
@@thirdCellCheck:
	 dec cx
	 
	 inc dx
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1
	 jz @@PutTrue

	 dec dx
	 
@@NextCheck:	 
	 inc cx	 
	 cmp cx, (MAT_WIDTH_IN_MEMORY - 1) ;one before the last one because we don't want to be out of the array range.
	 jb @@LoopIn
	 
	 inc dx
	 cmp dx, (MAT_HIGHT_IN_MEMORY - 1) ;one before the last one because we don't want to be out of the array range.
	 jb @@LoopOut ; 0-8 so until below 9
	 
@@PutFalse:
	 mov [Mat_Has_Place],0 ; it will be here if there is no place for the shape
	 jmp @@ExitProc	 
	 
@@PutTrue:
	 mov [Mat_Has_Place],1

	 
@@ExitProc:
	 pop cx
	 pop dx
	 
	 ret
endp Check_if_there_are_Two_Squares_Down_Right_Shape_Empty_In_Mat



;========================================
; Description: changr the color .
; Input: X of a point in the mat in memory, Y of a point in the mat in memory.
;		 the proc uses XClick And YClick.
; Output: CanPlace variable is true (1) if click was on the matrix, else false (0).
; Registers Usage: nothing.
;========================================
proc Check_If_Can_Place_shape_On_Click_Point ; boolian variables 1 for true if can place the shape, else 0 (false).
;parameters for all of the the methods that check if some squars are empty:
	 mov ax, [Xclick]
	 call Convert_Screen_X_To_Memory_X
	 mov cx, ax		 
	 mov ax, [Yclick]
	 call Convert_Screen_Y_To_Memory_Y
	 mov dx, ax
	 
	 cmp [ShapeKind],1
	 jz @@One_Square_Check
	 
	 cmp [ShapeKind],2
	 jz @@Two_Squares_Down_Check
	 
	 cmp [ShapeKind],3
	 jz @@Two_Squares_Right_Check
	 
	 cmp [ShapeKind],4
	 jz @@Two_Squares_Down_Right_Check
	  
@@One_Square_Check:
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1
	 jz @@PutTrue ;if the cells of the shape are empty, we can place the shape there
	 jmp @@PutFalse

@@Two_Squares_Down_Check:
	 call Check_Two_Squares_Down_Empty
	 cmp [IsEmpty],1
	 jz @@PutTrue ;if the cells of the shape are empty, we can place the shape there
	 jmp @@PutFalse

@@Two_Squares_Right_Check:
	 call Check_Two_Squares_Right_Empty	
	 cmp [IsEmpty],1
	 jz @@PutTrue ;if the cells of the shape are empty, we can place the shape there
	 jmp @@PutFalse
	 
@@Two_Squares_Down_Right_Check:
	 call Check_Two_Squares_Down_Right_Empty
	 cmp [IsEmpty],1
	 jz @@PutTrue ;if the cells of the shape are empty, we can place the shape there
	 jmp @@PutFalse	 

	  
@@Putfalse:	 
	 mov [CanPlace],0
	 jmp @@EndProc
	 
@@PutTrue:
	 mov [CanPlace],1

@@EndProc:

	 ret
endp Check_If_Can_Place_shape_On_Click_Point


;========================================
; Description: check if one square on the matrix is empty.
; Input: cx  = X in memory
;		 dx = Y in memory
; Output: IsEmpty variable is true (1) if the square is empty, else false (0).
; Registers Usage: al, cx, dx.
;========================================
proc Check_One_Square_Empty
	 call Read_Color_From_One_Memory_Cell
	 cmp al, BlackColor
	 jz PutTrue ; empty
	 
PutFalse:
	 mov [IsEmpty], 0
	 jmp @@EndProc
	 
	 
PutTrue:
	 mov [IsEmpty], 1
	 jmp @@EndProc

@@EndProc:
	 
	 ret
endp Check_One_Square_Empty


;========================================
; Description: check if two squares that goes down on the matrix are empty.
; Input: cx  = X in memory
;		 dx = Y in memory
;		 (1 = true = empty, else not empty)
; Output: IsEmpty variable is true (1) if the square is empty, else false (0).
; Registers Usage: al, dx, cx.
;========================================
proc Check_Two_Squares_Down_Empty
 
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1 
	 jz @@NextCheck
	 jmp @@PutFalse
	 
@@NextCheck:	 
	 inc dx ; next down square
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1
	 jz @@PutTrue
	 
@@PutFalse:
	 mov [IsEmpty], 0
	 jmp @@EndProc
	 
	 
@@PutTrue:
	 mov [IsEmpty], 1
	 jmp @@EndProc	 
	 
@@EndProc:
	 ret
endp Check_Two_Squares_Down_Empty


;========================================
; Description: check if two squares that goes right on the matrix are empty.
; Input: cx  = X in memory
;		 dx = Y in memory
;		 (1 = true = empty, else not empty)
; Output: IsEmpty variable is true (1) if the square is empty, else false (0).
; Registers Usage: al, cx, dx.
;========================================
proc Check_Two_Squares_Right_Empty
 
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1 
	 jz @@NextCheck
	 jmp @@PutFalse
	 
@@NextCheck:	 
	 inc cx ; next right square
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1
	 jz @@PutTrue
	 
@@PutFalse:
	 mov [IsEmpty], 0
	 jmp @@EndProc
	 
	 
@@PutTrue:
	 mov [IsEmpty], 1
	 jmp @@EndProc	 
	 
@@EndProc:
	 ret
endp Check_Two_Squares_Right_Empty


;========================================
; Description: check if two squares that goes down and right on the matrix are empty.
; Input: cx  = X in memory
;		 dx = Y in memory
;		 (1 = true = empty, else not empty)
; Output: IsEmpty variable is true (1) if the square is empty, else false (0).
; Registers Usage: al, cx, dx.
;========================================
proc Check_Two_Squares_Down_Right_Empty
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1 
	 jz @@SecondCheck
	 jmp @@PutFalse
	 
@@SecondCheck:
	 inc cx ; next right square 
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1 
	 jz @@ThirdCheck
	 jmp @@PutFalse

@@ThirdCheck:
	 dec cx
	 
	 inc dx
	 call Check_One_Square_Empty
	 cmp [IsEmpty],1
	 jz @@PutTrue
	 
@@PutFalse:
	 mov [IsEmpty], 0
	 jmp @@EndProc
	 

@@PutTrue:
	 mov [IsEmpty], 1
	 jmp @@EndProc
	 
	 
@@EndProc:
	 ret
endp Check_Two_Squares_Down_Right_Empty

;========================================
; Description: input the color of the shape in the memory matrix. .
; Input: X of a point in the matrix in memory, Y of a point in the matrix in memory.
; Output: the shape in the memory matrix.
; Registers Usage: nothing.
;========================================
proc Input_Shape_To_Memory_mat
	 call GetShapeColor
	 cmp [ShapeKind], 1
	 jz @@One_Square_Input
	 
	 cmp [ShapeKind], 2
	 jz @@Two_Squares_Down_Input
	 
	 cmp [ShapeKind], 3
	 jz @@Two_Squares_Right_Input
	 
	 cmp [ShapeKind], 4
	 jz @@Two_Squares_Down_Right_Input
	  
@@One_Square_Input:
	 call Input_Color_To_One_Memory_Cell ;input the colour of the shape in the click square
	 jmp @@EndProc

	 
@@Two_Squares_Down_Input:
	 call Input_Color_To_Two_Down_Memory_Cells
	 jmp @@EndProc

@@Two_Squares_Right_Input:
	 call Input_Color_To_Two_Right_Memory_Cells
	 jmp @@EndProc
	 
@@Two_Squares_Down_Right_Input:
	 call Input_Color_To_Three_Down_Right_Memory_Cells
	 jmp @@EndProc	 

@@EndProc: 
	
	 ret
endp Input_Shape_To_Memory_mat


;========================================
; Description: check if there was click on the matrix - every shape have a different area
; where the mouse can be clicked according to the shape width and hight.

; Input: nothing (XClick and YClick is uses for this proc))
; Output: Check_Click_On_Mat variable is true (1) if click was on the matrix, else false (0).
; Registers Usage: nothing.
;========================================
proc Check_Click_On_Mat
@Check_AboveEqual_Min_X:
	 cmp [Xclick], (COLS_SPACES_FROM_LEFT_FOR_BOARD) ;must not be right -1
	 jb @Put_False	 
@Cont_Check_AboveEqual_Min_Y:
	 cmp [Yclick],(ROWS_SPACES_FROM_TOP_FOR_BOARD) ;must not be right -1
	 jb @Put_False
	
	 cmp [ShapeKind], 1
	 jz @@One_Square_Space_Click
	 
	 cmp [ShapeKind], 2
	 jz @@Two_Squares_Down_Space_Click
	 
	 cmp [ShapeKind], 3
	 jz @@Two_Squares_Right_Space_Click
	 
	 cmp [ShapeKind], 4
	 jz @@Two_Squares_Down_Right_Space_Click
	 
;ShapeKind = 1 - One Square shape
@@One_Square_Space_Click: 
Check_BelowEqual_Max_X1:
	 cmp [Xclick],(COLS_SPACES_FROM_LEFT_FOR_BOARD + MAT_WIDTH_IN_SCREEN - 1) ; -1 because the last pixel is not on the
																			   ; matrix, we will not be able to click on
																			   ; the last right border (we put the border
																			   ; in one pixel after the last pixel of the mat).
	 jbe @Cont_Check_BelowEqual_Max_Y1	
	 jmp @Put_False 
	 
@Cont_Check_BelowEqual_Max_Y1:
	 cmp [Yclick],(ROWS_SPACES_FROM_TOP_FOR_BOARD + MAT_HIGHT_IN_SCREEN - 1) ; -1 because the last pixel is not on the
																			  ; matrix, we will not be able to click on
																			  ; the last down border (we put the border in
																			  ; one pixel after the last pixel of the matrix).
	 jbe @Put_True
	 jmp @Put_False
	 
;ShapeKind = 2 - Two Squares Down shape
@@Two_Squares_Down_Space_Click:
Check_BelowEqual_Max_X2:
	 cmp [Xclick],(COLS_SPACES_FROM_LEFT_FOR_BOARD + MAT_WIDTH_IN_SCREEN - 1) ; - CELL_WIDTH_IN_SCREEN because ther is no
																				  ; place for another square after the last
																				  ; square - the shape is two squars to the 
																				  ; right.
																				   
	 jbe @Cont_Check_BelowEqual_Max_Y2	
	 jmp @Put_False 
	 
@Cont_Check_BelowEqual_Max_Y2:
	 cmp [Yclick],(ROWS_SPACES_FROM_TOP_FOR_BOARD + MAT_HIGHT_IN_SCREEN  - 1) - CELL_HIGHT_IN_SCREEN 
																			   ; - CELL_HIGHT_IN_SCREEN because ther is no
																			   ; place for another square after the last square
																			   ; - the shape is two squars to the Down.
	 jbe @Put_True
	 jmp @Put_False
	  
;ShapeKind = 3 - Two Squares Right shape
@@Two_Squares_Right_Space_Click:	 
Check_BelowEqual_Max_X3:
	 cmp [Xclick],(COLS_SPACES_FROM_LEFT_FOR_BOARD + MAT_WIDTH_IN_SCREEN - 1) - CELL_WIDTH_IN_SCREEN 
																			   ; - CELL_WIDTH_IN_SCREEN because ther is no
																			   ; place for another square after the last square
																			   ; - the shape is two squars to the right.
	 jbe @Cont_Check_BelowEqual_Max_Y3	
	 jmp @Put_False 
	 
@Cont_Check_BelowEqual_Max_Y3:
	 cmp [Yclick],(ROWS_SPACES_FROM_TOP_FOR_BOARD + MAT_HIGHT_IN_SCREEN - 1) ; -1 because the last pixel is not on the
																			  ; matrix, we will not be able to click on
																			  ; the last down border (we put the border in
																			  ; one pixel after the last pixel of the matrix).
	 jbe @Put_True
	 jmp @Put_False

;ShapeKind = 4 - Three Squares Down Right shape
@@Two_Squares_Down_Right_Space_Click:
Check_BelowEqual_Max_X4:
	 cmp [Xclick],(COLS_SPACES_FROM_LEFT_FOR_BOARD + MAT_WIDTH_IN_SCREEN - 1) - CELL_WIDTH_IN_SCREEN 
																			   ; - CELL_WIDTH_IN_SCREEN because there is no
																			   ; place for another square after the last square
																			   ; - the shape is two squars to the right.
	 jbe @@Cont_Check_BelowEqual_Max_Y4	
	 jmp @Put_False 
	 
@@Cont_Check_BelowEqual_Max_Y4:
	 cmp [Yclick],(ROWS_SPACES_FROM_TOP_FOR_BOARD + MAT_HIGHT_IN_SCREEN  - 1) - CELL_HIGHT_IN_SCREEN 
																			   ; - CELL_HIGHT_IN_SCREEN because ther is no
																			   ; place for another square after the last square
																			   ; - the shape is two squars to the Down.	 



@Put_True:
	 mov [Got_Click_On_Mat],1
	 jmp @@ExitProc
	 
@Put_False:
	 mov [Got_Click_On_Mat],0
	 
@@ExitProc:

ret
endp Check_Click_On_Mat

;========================================
; Description: put in al the color of the shape acording to type of the shae
; Input: nothing (use ShapeKind variable)
; Output:  al = the color of the shape.
; Registers Usage: al.
;========================================
proc GetShapeColor
	 cmp [ShapeKind],1
	 jz Get_One_Square_Shape_Color
	 cmp [ShapeKind],2
	 jz Get_Two_Squares_Down_Shape_Color
	 cmp [ShapeKind],3
	 jz Get_Two_Squares_Right_Shape_Color
	 cmp [ShapeKind],4
	 jz Get_Two_Squares_Down_Right_Shape_Color
	 
Get_One_Square_Shape_Color:
	 mov al,ONE_SQUARE_SHAPE_COLOR
	 jmp @@ExitProc
	 
Get_Two_Squares_Down_Shape_Color:
	 mov al,TWO_SQUARES_DOWN_SHAPE_COLOR
	 jmp @@ExitProc

Get_Two_Squares_Right_Shape_Color:
	 mov al,TWO_SQUARES_RIGHT_SHAPE_COLOR
	 jmp @@ExitProc
	 
Get_Two_Squares_Down_Right_Shape_Color:
	 mov al,TWO_SQUARES_DOWN_RIGHT_SHAPE_COLOR
	 jmp @@ExitProc
	 
@@ExitProc:
	 ret
endp GetShapeColor

;========================================
; Description: draw the one square shape on the shapes point on the screen.
; Input: cx = X of the start shapes point in the screen.
;		 dx = Y of the start shapes point in the screen.
;		 si = the hight of the cell on the screen.
;		 di = the width of the cell on the screen.
; Output: the Shape on the screen.
; Registers Usage: cx, dx, si, di.
;========================================
proc Draw_One_Square_Shape
	 call Rect
ret
endp Draw_One_Square_Shape


;========================================
; Description: draw two square shape: start from the shapes point on the screen (Down Diraction).
; Input: cx = X of the start shapes point in the screen.
;		 dx = Y of the start shapes point in the screen.
;		 si = the hight of the cell on the screen.
;		 di = the width of the cell on the screen.
; Output: the Shape on the screen.
; Registers Usage: cx, dx, si, di.
;========================================
proc Draw_Two_Squares_Down_Shape
	 push dx ; to save the 
	 call Draw_One_Square_Shape
	 add dx, CELL_HIGHT_IN_SCREEN ; not -1 because we want to draw two squars with a space for a border between them.
	 call Draw_One_Square_Shape
	 pop dx
	 ret
endp Draw_Two_Squares_Down_Shape

;========================================
; Description: draw two squares shape: start from the shapes point on the screen (right Diraction).
; Input: nothing.
; Output: the Shape on the shapes point on the screen.
;; Registers Usage: cx, dx, si, di.
;========================================
proc Draw_Two_Squares_Right_Shape
	 push cx
	 push dx
	 
	 call Draw_One_Square_Shape
	 add cx, CELL_WIDTH_IN_SCREEN ; not -1 because we want to draw two squars with a space for a border between them.
	 call Draw_One_Square_Shape
	 pop cx
	 pop dx
	 ret
endp Draw_Two_Squares_Right_Shape

;========================================
; Description: draw two squares down and right shape: start from the shapes point on the screen.
; Input: nothing.
; Output: the Shape on the shapes point on the screen.
;; Registers Usage: cx, dx, si, di.
;========================================
proc Draw_Two_Squares_Down_Right_Shape
	 push cx
	 push dx
	 
	 call Draw_One_Square_Shape
	 
	 add cx, CELL_WIDTH_IN_SCREEN ; not -1 because we want to draw two squars with a space for a border between them.
	 call Draw_One_Square_Shape
	 
	 sub cx, CELL_WIDTH_IN_SCREEN
	 add dx, CELL_HIGHT_IN_SCREEN
	 call Draw_One_Square_Shape
	 
	 pop dx	 
	 pop cx
	 ret
endp Draw_Two_Squares_Down_Right_Shape




;========================================
; Description: print the board with the colors on the screen
; Input: nothing
; Output: the Board with the colors on the screen but without the borders.
; Registers Usage: ax, bx, cx ,dx , si, di.
;========================================
Proc PrintBoard
	 push ax
	 push bx
	 push cx
	 push dx
	 push si
	 push di
	 
	 mov bx, offset Board
 	 mov si,CONVERTER_FACTOR ;17
	 mov di,CONVERTER_FACTOR ;17
	 mov cx,MAT_HIGHT_IN_MEMORY ; 10
ILoop:
	 push cx ;save cx value
	 mov cx,MAT_WIDTH_IN_MEMORY ; 10
JLoop:
	 push cx ;for the middle loop
	 
	 sub bx,offset Board ; the parameter for this methode is the place, not the offset
	 
	 push bx
	 call Convert_Memory_Y_To_Screen_Y
	 push bx
	 call Convert_Memory_X_To_Screen_X
	 add bx,offset Board ; ; need to return to the origin array so al in the next code line, will get the right color
	 mov al,[byte bx]; color
	 call Rect
	 
	 
	 inc bx ;next color
	 
	 pop cx
  loop JLoop	
	 
	 pop cx	 
  loop ILoop
 
	 pop di
	 pop si
	 pop dx
	 pop cx
	 pop bx
	 pop ax
ret
endp PrintBoard

;========================================
; Description: Erase the board from the screen
; Input: nothing
; Output: the Board on the screen without the borders but all the colors are black so it earase the board from the screen but do not change any thing in the memory.
; Registers Usage: ax, bx, cx ,dx , si, di.
;========================================
Proc Clear_Board_From_Screen
	 push ax
	 push bx
	 push cx
	 push dx
	 push si
	 push di
	 
 	 mov si,CONVERTER_FACTOR ;17 - input to rect method
	 mov di,CONVERTER_FACTOR ;17 - input to rect method
	 mov cx,MAT_HIGHT_IN_MEMORY ; 10
	 xor bx,bx
@@ILoop:
	 push cx ;save cx value
	 mov cx,MAT_WIDTH_IN_MEMORY ; 10
@@JLoop:
	 push cx ;for the middle loop
	 
	 push bx
	 call Convert_Memory_Y_To_Screen_Y
	 push bx
	 call Convert_Memory_X_To_Screen_X
	 mov al,BlackColor; color
	 call Rect
	 
	 
	 inc bx ;next color
	 
	 pop cx
  loop @@JLoop	
	 
	 pop cx	 
  loop @@ILoop
  
	 ;this will clear from the screen the two lines that out of the matrix:
	 mov dx, (ROWS_SPACES_FROM_TOP_FOR_BOARD + MAT_HIGHT_IN_SCREEN)
	 mov cx, COLS_SPACES_FROM_LEFT_FOR_BOARD
	 mov si, (MAT_WIDTH_IN_SCREEN + 1)
	 mov al, BlackColor
	 Call DrawHorizontalLine
	 
	 mov cx, (COLS_SPACES_FROM_LEFT_FOR_BOARD + MAT_WIDTH_IN_SCREEN)
	 mov dx, ROWS_SPACES_FROM_TOP_FOR_BOARD
	 mov si, (MAT_HIGHT_IN_SCREEN + 1)
	 mov al, BlackColor
	 Call DrawVerticalLine


	 pop di
	 pop si
	 pop dx
	 pop cx
	 pop bx
	 pop ax
ret
endp Clear_Board_From_Screen

;========================================
; Description: Drawing the borders of the Board on the screen considering all the properties of the board
; top and left of the screen, hight and width of Board in memory and on screen (giving names and not numbers so we can change any time).  
; Input: nothing
; Output: Borders at the Board place.
; Registers Usage: ax, bx, cx.
;========================================
proc Draw_Board_Borders
	 push ax
	 push bx
	 push cx
	 push dx
	 push si
	 push di
	 push bp
	 
	 mov bx, offset Board 
	 
	 sub bx,offset Board ; the parameter for this methode is the place, not the offset
	 push bx
	 call Convert_Memory_Y_To_Screen_Y
	 push bx
	 call Convert_Memory_X_To_Screen_X
	 add bx,offset Board ; need to return to the origin array
	 mov si, (MAT_HIGHT_IN_SCREEN + 1) ; 180 + 1 we want the point of the last square to be fille as well so there is no hole. 
	 mov al, BORDER_COLOR
	 mov bp,MAT_WIDTH_IN_MEMORY ;10 - but this will happen 11 times because the condition for exit is in the end of the loop.
	 
PrintVarticals:
	 call DrawVerticalLine
	 add cx, CELL_WIDTH_IN_SCREEN ;next border
	 cmp bp,0
	 jz @@continue
	 
	 dec bp
	 jmp PrintVarticals
	 
@@continue:	 

	 sub bx,offset Board ; the parameter for this methode is the place, not the offset
	 push bx
	 call Convert_Memory_Y_To_Screen_Y
	 push bx
	 call Convert_Memory_X_To_Screen_X
	 add bx,offset Board ; need to return to the origin array
	 mov si, (MAT_WIDTH_IN_SCREEN + 1)	 ; 180 + 1 we want the point of the last square to be fille as well so there is no hole.
	 mov al, BORDER_COLOR
	 mov bp,MAT_HIGHT_IN_MEMORY ;10 - but this will happen 11 times because the condition for exit is in the end of the loop.
PrintHorizontals:
	 call DrawHorizontalLine
	 add dx, CELL_HIGHT_IN_SCREEN ;next border
	 cmp bp,0
	 jz ExitProc
	 
	 dec bp
	 jmp PrintHorizontals
	 
ExitProc:
;keeping all the registers that have been used
	 pop bp
	 pop di
	 pop si
	 pop dx
	 pop cx
	 pop bx
	 pop ax
ret
endp Draw_Board_Borders




;========================================
; Description: convert a y of a point on the screen to a y of a point in the memory matrix.
; Input: ax = a y of a point in the screen
; OutPut: dx = the y of the point in the memory
; Registers Usage: ax, dx.
;========================================
proc Convert_Screen_Y_To_Memory_Y

	 cmp ax, ROWS_SPACES_FROM_TOP_FOR_BOARD ; ax must always be above
	 jb @@put_0_In_Cx
	 sub ax, ROWS_SPACES_FROM_TOP_FOR_BOARD
	 jmp @@cont
@@put_0_In_Cx:
	 mov dx,0 ; dx = y in memory
	 jmp @@end
@@cont:
	 call DivFromScreenToMemory
	 and ah, 0 ;al have the result
	 mov dx,ax; dx = y in memory
	 
@@end:
	 ret
endp Convert_Screen_Y_To_Memory_Y

;========================================
; Description: convert a x of a point on the screen to a x of a point in the memory matrix.
; Input: ax = a x of a point in the screen
; OutPut: dx = the x of the point in the memory
; Registers Usage: ax, cx.
;========================================
proc Convert_Screen_X_To_Memory_X
	 cmp ax, COLS_SPACES_FROM_LEFT_FOR_BOARD ; ax must always be above
	 jb put_0_In_Cx
	 sub ax, COLS_SPACES_FROM_LEFT_FOR_BOARD
	 jmp @@cont
put_0_In_Cx:
	 mov cx,0 ; cx = x in memory
	 jmp @@end
@@cont:
	 call DivFromScreenToMemory	
	 and ah, 0 ;al have the result
	 mov cx,ax; cx = x in memory
	 
@@end:
ret
endp Convert_Screen_X_To_Memory_X


;========================================
; Description: div ax by 17 because every cell in the memory mat is 17 pixels on the screen.
; Input: ax - the x or the y of a point on the screen.
; Output: al - the x or the y of a point in the memory.
; Registers Usage: ax, bx.
;========================================
proc DivFromScreenToMemory
	 push bx
	 
	 mov bl ,CONVERTER_FACTOR ;div by 17
	 div bl	 
	 
	 pop bx
ret
endp DivFromScreenToMemory 



;========================================
; Description: convert a Y of a point in the memory matrix to a Y of a point on screen.
; Input: ax = a Y of a point in the memory
; OutPut: dx = the Y of the point in the screen
; Registers Usage: ax, dx.
;========================================
proc Convert_Memory_Y_To_Screen_Y 
	 pop [ipAdress]
	 pop ax; parameter	 
	 push bx ;saving bx value.
	 call Get_Memory_Y_In_Memory_Place_In_Arr
	 call MulFromMemoryToScreen	 
	 mov dx,ax; row in the screen
	 
	 add dx, ROWS_SPACES_FROM_TOP_FOR_BOARD
	 
	 pop bx
	 push [ipAdress]
	 ret
endp Convert_Memory_Y_To_Screen_Y

;========================================
; Description: putting into ax the Y in memory "matrix" of a place in the memory oneD Array (dividing by mat hight and getting the result.
; Input: ax - a place (not offset) in the oneD Mat Array.
; Output: ax - the memory Y in the matrix of the memory place in oneD arr.
; Registers Usage: ax, bx.
;========================================
proc Get_Memory_Y_In_Memory_Place_In_Arr
	 push bx
	 
	 mov bl ,MAT_WIDTH_IN_MEMORY ; 10 - ax must be divided by the width of the matrix.
	 div bl ; the result is the columns and the mod is the rows
	 mov ah,0 ; al have the result - row in memory
	 
	 pop bx
ret
endp Get_Memory_Y_In_Memory_Place_In_Arr


;========================================
; Description: convert a x of a point in the memory matrix to a x of a point on screen.
; Input: ax = a x of a point in the memory
; OutPut: cx = the x of the point in the screen
; Registers Usage: ax, cx.
;========================================
proc Convert_Memory_X_To_Screen_X
	 pop [ipAdress]
	 
	 pop ax; parameter
	 push bx ;saving bx value
	 
	 call Get_Memory_X_In_Memory_Place_In_Arr
	 call MulFromMemoryToScreen	 
	 mov cx,ax ; col in the screen
	 
	 add cx, COLS_SPACES_FROM_LEFT_FOR_BOARD
	 
	 pop bx	 
	 push [ipAdress]
ret
endp Convert_Memory_X_To_Screen_X

;========================================
; Description: putting into ax the X in memory "matrix" of a place in the memory oneD Array (dividing by mat hight and getting the mod.
; Input: ax - a place (not offset) in the oneD Mat Array.
; Output: ax - the memory X in the matrix of the memory place in oneD arr.
; Registers Usage: ax, bx.
;========================================
proc Get_Memory_X_In_Memory_Place_In_Arr
	 push bx
	 
	 mov bl ,MAT_WIDTH_IN_MEMORY ; 10 - ax must be divided by the width of the matrix.
	 div bl ; the result is the columns and the mod is the rows	 	 
	 shr ax,8 ;moving the mod in ah to all ax (ah has the row in memory and we want to mul it by 17,
				;so we need to move it to al and put 0 in ah.
	 
	 pop bx
ret
endp Get_Memory_X_In_Memory_Place_In_Arr

;========================================
; Description: mul ax by 17 because every cell in the memory mat is 17 pixels on the screen.
; Input: ax - the x or the y of a point in the memory.
; Output: ax - the x or the y of a point on the screen.
; Registers Usage: ax, bx.
;========================================
proc MulFromMemoryToScreen 
	 push bx
	 
	 mov bl ,CONVERTER_FACTOR ;mul by 17
	 mul bl	 
	 
	 pop bx
ret
endp MulFromMemoryToScreen 





;========================================
; Description: Read one color from 2D array cell.
; Input: dx = row  (y)
;		cx = col (x)    
; Output: al = Color
; Registers Usage: ax, bx, cx, dx, si 
;========================================
proc Read_Color_From_One_Memory_Cell
	 push bx
	 push cx
	 push dx
	 
	 mov bl,MAT_WIDTH_IN_MEMORY
	 mov ax,dx
	 mul bl
	 add ax , cx ;add the cols
	 mov bx,ax ; ax have the result - the place in oneD arr (not offset)
	 mov si, offset Board
	 mov al,[si + bx] ;moving the color from the array into al
	 
	 pop dx
	 pop cx
	 pop bx
	 ret
endp Read_Color_From_One_Memory_Cell

;========================================
; Description: input a color to one cell in the memory matrix using the oneD array.
; Input: cx = X in the memory
;		 dx = Y in the memory
;	     al = color
; Output: the colour in its place in the memory matrix
; Registers Usage: ax, bx, cx, dx, si 
;========================================
proc Input_Color_To_One_Memory_Cell
	 push bx
	 push cx
	 push dx
	 push ax
	 mov bl,MAT_WIDTH_IN_MEMORY
	 mov ax,dx
	 mul bl
	 add ax, cx ;add the cols
	 mov bx,ax ; ax have the result - the place in oneD arr (not offset)
	 mov si, offset Board
	 pop ax
	 mov [bx + si],al ;moving the color into the array
	 
	 pop dx
	 pop cx
	 pop bx
	 ret
endp Input_Color_To_One_Memory_Cell

;========================================
; Description: input a color to two cells (Right Diraction) in the memory matrix.
; Input: cx = X in the memory
;		 dx = Y in the memory
;	     al = color
; Output: the two colours in their place in the memory matrix
; Registers Usage: cx
;========================================
proc Input_Color_To_Two_Right_Memory_Cells
	 push cx ; ; just to save the click point in the memory
	 call Input_Color_To_One_Memory_Cell ;input the colour of the shape in the click square	
	 inc cx
	 call Input_Color_To_One_Memory_Cell ;input the colour of the shape in the click square + one square right
	 pop cx
	 ret
endp Input_Color_To_Two_Right_Memory_Cells

;========================================
; Description: input a color to two cells (down Diraction) in the memory matrix.
; Input: cx = X in the memory
;		 dx = Y in the memory
;	     al = color
; Output: the two colours in their place in the memory matrix
; Registers Usage: dx
;========================================
proc Input_Color_To_Two_Down_Memory_Cells
	 push dx ; just to save the click point in the memory
	 call Input_Color_To_One_Memory_Cell ;input the colour of the shape in the click square	
	 inc dx
	 call Input_Color_To_One_Memory_Cell ;input the colour of the shape in the click square + one square down
	 pop dx
	 ret
endp Input_Color_To_Two_Down_Memory_Cells

proc Input_Color_To_Three_Down_Right_Memory_Cells
	 push cx
	 push dx
	 
	 call Input_Color_To_One_Memory_Cell ;input the colour of the shape in the click square	
	 
	 inc cx 
	 call Input_Color_To_One_Memory_Cell ;input the colour of the shape in the click square + one square right
	 
	 dec cx
	 inc dx
	 call Input_Color_To_One_Memory_Cell ;input the colour of the shape in the click square + one square down
	 
	 pop dx
	 pop cx
	 ret
endp Input_Color_To_Three_Down_Right_Memory_Cells





;========================================
; Description: draw a rectangle on the screen using DrawVerticalLine method.
; Input: si - hight
;		 di - width
;		 cx,dx (col,row) - start point of the Rectangle (going right and down)
;		 al - the color of the rectangle
; Output: a rectangle on the screen
; Registers Usage: ax, si, di, dx, cx 
;========================================
; cx = col dx= row al = color si = height di = width 
proc Rect
	 push cx
	 push dx
	 push ax
	 push si
	 push di	
	
	 cmp si,0 ;check if the hight is not 0
	 jz @@EndRect
	 cmp di,0 ;check if the width is not 0 in the beginning
	 jz @@EndRect
	
NextVerticalLine:	
	
	 cmp di,0 ; count the times that DrawVerticalLine method will be called (width)
	 jz @@EndRect
	
	 call DrawVerticalLine
	 inc cx
	 dec di 
	 jmp NextVerticalLine
	
@@EndRect:
	 pop di
	 pop si
	 pop ax
	 pop dx
	 pop cx	
	 ret
endp Rect

;========================================
; Description: draw one Horizontal Line	on the screen using int 10,c (put pixel)
; Input: si - how much pixels to draw
;		 cx,dx (col,row) - start point of the Horizontal line - going right
;		 al - the color
; Output: one Horizontal Line on the screen
; Registers Usage: ax, si, cx (dx doesn't change).
;========================================
proc DrawHorizontalLine	
	 push si
	 push cx
	 push ax
DrawLine:
	 cmp si,0  
	 jz ExitDrawLine ;if si 0, there is no reason to print a pixel because we can't print 0 pixels
	 
	 mov ah,0ch	
	 int 10h    ; put pixel
	 	
	 inc cx ; go to next X on the screen
	 dec si ; the length get smaller every time we put pixel so there will be si pixels on the screen.
	 jmp DrawLine
		
ExitDrawLine:
	 pop ax
	 pop cx
	 pop si
	 ret
endp DrawHorizontalLine

;========================================
; Description: draw one Vertical Line on the screen using int 10,c (put pixel)
; Input: si - how much pixels to draw
;		 cx,dx (col,row) - start point of the Vertical line - going Down
;		 al - the color
; Output: one Vertical Line on the screen
; Registers Usage: ax, si, dx (cx doesn't change).
;========================================
proc DrawVerticalLine	near
	 push si
	 push dx
	 push ax
 
DrawVertical:
	 cmp si,0
	 jz @@ExitDrawLine	;if si 0, there is no reason to print a pixel because we can't print 0 pixels
	 
	 mov ah,0ch	
	 int 10h    ; put pixel
	
	
	 inc dx ; go to next Y on the screen
	 dec si ; the length get smaller every time we put pixel so there will be si pixels on the screen.
	 jmp DrawVertical
	
	
@@ExitDrawLine:
	 pop ax
	 pop dx
	 pop si
	ret
endp DrawVerticalLine





;========================================
; Description: wait until there is a left click Press on the mouse
; Input: nothing.
; Output: Xclick and Yclick variables have the point of the click on the screen.
; Registers Usage: ax, bx, cx, dx, si 
;========================================
proc Wait_To_Left_Click_Press
	 push ax
	 push bx
	 push cx
	 push dx
	 push si
	
@@ClickWaitWithDelay:
	 mov cx,1000 
@@ag:	
	 loop @@ag

	 mov ax,5h ; press information about the mouse
	 mov bx,0 ; check if left button was pressed (1 is for right button)
	 int 33h
		
	 cmp bx, 0
	 jna @@ClickWaitWithDelay  ; mouse wasn't pressed because bx count the buttons that pressed
	 test ax,1 ; check if the first bit is 1 by doing and and with 1 and checking the zero flag.
	 jz @@ClickWaitWithDelay   ; Left wasn't releases, try again - if zwro flag is on it means ax = 0
	
	 shr cx, 1 ;the Mouse default is 640X200 So divide 640 by 2 to get the real column of the press.
	 mov [Xclick], cx ; row
	 mov [Yclick], dx ; col
	 
	 pop si
	 pop dx
	 pop cx
	 pop bx
	 pop ax

	 ret
endp Wait_To_Left_Click_Press





;========================================
; Description: Set the screen to Mode 13h - an IBM VGA BIOS mode. It is the specific standard 256-color mode. 320 X 200 pixels.
; Input: nothing
; Output: mode change to graphic
; Registers Usage: ax 
;========================================
proc  SetGraphic
	 push ax	 
	 mov ax,13h   				  
	 int 10h	 
	 pop ax
	 ret
endp SetGraphic

;========================================
; Description: Set the screen to text mode 80 X 45 pixels.
; Input: nothing
; Output: mode change to graphic
; Registers Usage: ax 
;========================================
proc SetText
	 push ax	 
	 mov ax,3
	 int 10h	 
	 pop ax
	 ret 
endp SetText





;========================================
; Description: Show the mouse on the screen.
; Input: nothing
; Output: mouse on the screen
; Registers Usage: ax 
;========================================
proc ShowMouse
	 push ax
	 mov ax,01h
	 int 33h	 
	 pop ax
	 ret 
endp ShowMouse

;========================================
; Description: Hide the mouse from the screen.
; Input: nothing
; Output: hide mouse from the screen
; Registers Usage: ax 
;========================================
proc HideMouse
	 push ax
	 mov ax,02h
	 int 33h
	 pop ax
	 ret 
endp HideMouse





EndOfCsLbl:
END start	