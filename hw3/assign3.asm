TITLE Integer Accumulator (assign3.asm)
;Assignment 3 - Number accumulation and calculations
;Luke Puppo - 10/21/18 - puppol@oregonstate.edu
;This program takes in negative numbers from the user until a non-neg number
;is put in. After this, the program calcuates the average of the inputted numbers.
;**EC: I numbered the lines for user input.



.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword


INCLUDE Irvine32.inc

.data
	; declare variables here
	
	programTitle	BYTE	"Welcome to the Integer Accumulator by Luke Puppo", 0Dh, 0Ah, 0
	extraCredit		BYTE	"**EC: I numbered the lines for user input.", 0Dh, 0Ah, 0

	userGreeting	BYTE	"What is your name? ", 0
	userGreeting2   BYTE	"Hello, ",0

	instructions1	BYTE	"Please enter numbers in [-100, -1].", 0Dh, 0Ah, 0
	instructions2	BYTE	"Enter a non-negative number when you are finished to see results.", 0Dh, 0Ah, 0

	enterNumPrompt  BYTE	". Enter Number: ", 0

	endNumsDisplay1	BYTE	"You entered ", 0
	endNumsDisplay2 BYTE	" valid numbers.", 0Dh, 0Ah, 0
	endSumDisplay	BYTE	"The sum of your valid numbers: ",0
	endRoundDisplay BYTE	"The rounded average is: ",0

	noValidInPrompt BYTE	"You did not enter any valid numbers.", 0Dh, 0Ah, 0
	tooLowPrompt	BYTE	"The number you put in is too low. Try again, remember, [-100, -1]",0

	goodBye			BYTE	"Thank you for using my program. Have a great day, ", 0

	; CONSTANTS
	lowerBound		=		-100


	; NEEDED VARS
	sum				DWORD	0
	tempCounter		DWORD	1


	; USER VARIABLES
	userName		BYTE	50 DUP (0)

.code
;This proc runs through the entire code as described in Assignment 3 Guidelines and Outline
main proc


	;-------  GREETING  -------
	; Greets the user

	mov edx, OFFSET programTitle
	call WriteString
	mov edx, OFFSET extraCredit
	call WriteString


	;------   USERINFO  --------
	; Asks the user for their name and finishes greeting them

	mov edx, OFFSET userGreeting
	call WriteString

	mov edx, OFFSET username		; Get username
	mov ecx, 50
	call ReadString				
									
	mov edx, OFFSET userGreeting2	; Print second greeting including user's name
	call WriteString
	mov edx, OFFSET username
	call WriteString

	call CrLf						; Prepare screen for next section
	call CrLf


	;------   DISPLAY INFO -------
	; Displays the instructions to the user

	mov edx, OFFSET instructions1
	call WriteString
	mov edx, OFFSET instructions2
	call WriteString


	
	;------  GET NUMS ------
	; Big boy to loop through and collect numbers from the user
	; Jumps out if a bad number is detected

	GetNumber:
		mov eax, tempCounter
		call WriteDec
		mov edx, OFFSET enterNumPrompt
		call WriteString
		call ReadInt					; Pulls in numbers
		cmp eax, lowerBound
		jl TooLowNum
		cmp eax, -1
		jg CalculateVals
		INC tempCounter
		add sum, eax
		jmp GetNumber



	; Uses the info collected and calculates values
	; Must decrement temp counter by 1 to adjust for
	; runtime usability for end user.

	CalculateVals:
		cmp tempCounter, 1
		je NoValidInputs					; Jumps out of no valid inputs

		mov edx, OFFSET endNumsDisplay1
		call WriteString

		DEC tempCounter						; Decs for correct calculations
		mov eax, tempCounter
		call WriteDec
		mov edx, OFFSET endNumsDisplay2		
		call WriteString


		mov edx, OFFSET endSumDisplay		; Displays sum value
		call WriteString
		mov eax, sum
		call WriteInt
		call CrLf


		mov edx, OFFSET endRoundDisplay		; Displays rounded num
		call WriteString
		mov eax, sum
		mov ebx, tempCounter
		cdq
		idiv ebx							; Signed division
		call WriteInt
		call CrLf
		jmp GoodByeLbl



	; Simply sends an error message and continues to end program

	NoValidInputs:
		mov edx, OFFSET NoValidInPrompt
		call WriteString



	;------ GOODBYE ------
	; End of Program
	; Thanks the user for using the program

	GoodByeLbl:
		mov edx, OFFSET goodBye
		call WriteString
		mov edx, OFFSET username
		call WriteString


	invoke ExitProcess,0

	TooLowNum:
		mov edx, OFFSET tooLowPrompt
		call WriteString
		call CrLf
		jmp GetNumber


	
main endp


end main