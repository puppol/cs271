TITLE Basic Calculator (assign1.asm)
;Assignemnt 2 - Fibonacci Numbers and Strings
;Luke Puppo - 10/7/18 - puppol@oregonstate.edu
; This program prompts the user for their name and greets them
; It then asks the user for the number of Fibonacci numbers to calculate
; It verifies that number is in bounds
; Then it prints all required numbers to the screen
; Finally it thanks the user and exits cleanly



.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword


INCLUDE Irvine32.inc

.data
	; Text Outputs for the user
	intro1 BYTE "Programmed by Luke Puppo.",0
	intro2 BYTE "This program calculates Fibonacci numbers for you.",0

	userGreetingP1 BYTE "Firstly, what's your name? ",0
	userGreetingP2 BYTE "Hello ",0
	userGreetingP3 BYTE ", thanks for using my program. Let's begin.",0

	userGoodbye1 BYTE "Thanks for using my program ",0
	userGoodbye2 BYTE "! Have a great day!",0

	numFibPrompt BYTE "How many fibonacci numbers would you like to calculate? I can handle 1 - 46",0
	fibNumTooBig BYTE "That number was out of bounds.",0

	; User inputs
	username BYTE 50 DUP(0)
	userNumFibNumbers DWORD ?


	; Fib Variables
	prevFib DWORD 0
	nextFib DWORD 1
	spaces BYTE "     ",0
	UPPERLIMIT = 46
	loopCounter DWORD 0
	

.code
main proc

	; ---------------------------
	; GREETING

	mov edx, OFFSET intro1
	call WriteString
	call CrLf
	mov edx, OFFSET intro2
	call WriteString
	call CrLf


	; ---------------------------
	; USER INSTRUCTIONS
	; Gets the users name and greets them

	mov edx, OFFSET userGreetingP1
	call WriteString

	mov ecx, 50          ; Max username size
	mov edx, OFFSET username    ; String to be read into
	call ReadString

	mov edx, OFFSET userGreetingP2   ; Hello
	call WriteString
	mov edx, OFFSET username         
	call WriteString
	mov edx, OFFSET userGreetingP3   ; After username
	call WriteString
	call CrLf


	; ------------------------------------------
	; GET USER FIB NUMBERS
	; Prompts the user for the number of fibonacci numbers 
	;    they want calculated
	; Reprompts if the number is out of bounds

	GetUserFibNumber:
		; Prompt user for number
		mov edx, OFFSET numFibPrompt
		call WriteString
		call CrLf

		call ReadInt
		mov userNumFibNumbers, eax

		cmp userNumFibNumbers, UPPERLIMIT
		jg UserNumberFailed
		cmp userNumFibNumbers, 1
		jl UserNumberFailed


	; -----------------------------------
	; DISPLAY FIBS
	; Calculates and displays the numbers
	; Up to and including the number the user put in 

	mov ecx, userNumFibNumbers

	DisplayFibs:
		inc loopCounter           ; Used for new lines
		mov eax, nextFib		  ; Prints number and spaces
		call WriteDec
		mov edx, OFFSET spaces
		call WriteString

		mov ebx, nextFib          ; Calculates the next fib num
		add eax, prevFib
		mov nextFib, eax
		mov prevFib, ebx

		; Checks if next line is needed
		; Uses div 5 to determine conditional
		mov eax, loopCounter
		mov ebx, 5
		cdq
		div ebx
		cmp edx, 0
		je MakeNewLine

		PostCheckLabel:
			loop DisplayFibs



	; ------------------------------
	; GOODBYE
	; Thanking the user for using the program

	call CrLf                      ; Makes new line for readability
	mov edx, OFFSET userGoodbye1
	call WriteString
	mov edx, OFFSET username
	call WriteString
	mov edx, OFFSET userGoodbye2
	call WriteString

	; END OF MAIN FLOW
	invoke ExitProcess,0


	; Loop to tell the user their number went out of bounds
	UserNumberFailed:
		mov edx, OFFSET fibNumTooBig
		call WriteString
		call CrLf
		jmp GetUserFibNumber     ; Back to top


	; Func to insure control flow is correct
	; Space to add more user prompts if needed for future improvements
	MakeNewLine:
		call CrLf
		jmp PostCheckLabel


	
main endp
end main