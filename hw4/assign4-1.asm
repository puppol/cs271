TITLE *** (assign3.asm)
;Assignment 4 - Brief description
;Luke Puppo - 10/28/18 - puppol@oregonstate.edu
;This program...




.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword


INCLUDE Irvine32.inc

.data
	; declare variables here
	greeting		BYTE	"Composite Numbers    Programmed by Luke Puppo", 0Ah, 0Dh, 0

	instruction1	BYTE	"Enter the number of composite numbers you would like to see.", 0Ah, 0Dh, 0
	instruction2	BYTE	"I'll accept orders for up to 400 composites.", 0Ah, 0Dh, 0

	promptForNum	BYTE	"Enter the number of composites to display [1 .. 400]: ", 0	
	outOfBounds		BYTE	"Out of bounds. Try again.", 0Ah, 0Dh, 0
	inBoundsStr		BYTE	"Number was IN RANGE", 0Ah, 0Dh, 0
	spaces			BYTE	"   ", 0

	farewellStr		BYTE	"Results were verified by Luke's algorithm. Thanks for using my program!", 0Ah, 0Dh, 0


	; Constants
	upperLimit = 400
	lowerLimit = 1


	; Variables
	userInput		DWORD	?
	tempInt			DWORD	?
	tempCounterMain	DWORD	?
	tempCounter		DWORD	?
	numComps		DWORD	?
	primeArr		DWORD	2, 3, 5, 7, 11, 13, 17		; If divisible by this, composite
	primeArrSize	DWORD	7

	

.code
main proc
	call introduction

	call getUserData

	call showComposites

	call farewell

	invoke ExitProcess,0
	
main endp


; -----
; Simply lays out the instructions for the user
; No inputs
	introduction proc

		mov edx, OFFSET greeting
		call WriteString
		call CrLf

		mov edx, OFFSET instruction1
		call WriteString
		mov edx, OFFSET instruction2
		call WriteString

		ret
	introduction endp


; -----
; Gets user input and validates that input to make sure 
; that it is in bounds
; Calls validate

	getUserData proc
		L1:
			mov edx, OFFSET promptForNum
			call WriteString
			call ReadDec
			mov userInput, eax

			call validate						; Returns 0 if invalid
			cmp tempInt, 0
			je L1

		
		ret
	getUserData endp

; Helper function called by getUserData
; Verifies that the input from user in in bounds

	validate proc
		cmp userInput, upperLimit
		jg outBounds
		cmp userInput, lowerLimit
		jl outBounds
		jmp inBounds

		
		outBounds:
			mov edx, OFFSET outOfBounds
			call WriteString
			mov tempInt, 0
			ret

		inBounds:
			mov tempInt, 1
			ret
	validate endp


; -----
; Calculates composite numbers
; Uses array of the first 7 prime numbers as divisors
; Calls isComposite to verify each number
; Handles printing to the screen

	showComposites proc
		mov ecx, userInput
		mov tempCounterMain, 1
		loopThroughNums:						; Main loop, increments from 1-n
			mov eax, tempCounterMain
			mov tempInt, eax

			pushad
			call isComposite					; In = tempInt, out = tempInt (1 or 0)				
			popad

			cmp tempInt, 0						; Handles output from isComposite
			je elseCase
			jmp isComp

			isComp:
				inc numComps
				mov eax, tempCounterMain
				call WriteDec
				mov edx, OFFSET spaces
				call WriteString

												; Handles new line every 10
				mov eax, numComps
				mov ebx, 10
				cdq
				div ebx
				cmp edx, 0
				je newLineCase

		
				inc tempCounterMain
				loop loopThroughNums
				ret

				newLineCase:
					call CrLf
					inc tempCounterMain
					loop loopThroughNums
					ret

			elseCase:
				inc tempCounterMain
				inc ecx
				loop loopThroughNums
				ret						; If that was last number


		ret
	showComposites endp

; In charge of testing wether or not an integer is composite
; Inputs: tempInt as the value to check if composite or not
; Returns 1 or 0 in tempInt if compsite or not

	isComposite proc
		cmp tempInt, 1						; Edge case 
		je notComp

		mov ecx, primeArrSize
		mov esi, OFFSET primeArr		
		mov tempCounter, 0

		checkPrimeArray:					; Loops through the prime array and divides by each value
			mov eax, tempCounter
			mov ebx, [esi + (4 * eax)]

			mov eax, tempInt

			cmp eax, ebx					; Edge case check
			je notComp

			cdq
			div ebx
			cmp edx, 0						; If divs with remainder 0, isComp
			je isComp
			inc tempCounter
			loop checkPrimeArray
			

		notComp:
			mov tempInt, 0
			ret

		isComp:
			mov tempInt, 1
			ret
	isComposite endp

; -----
; Says goodbye to the user
; No inputs
	farewell proc
		call CrLf
		mov edx, OFFSET farewellStr
		call WriteString

		ret
	farewell endp



end main