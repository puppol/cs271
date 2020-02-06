TITLE Random Number Generation (assign5.asm)
;Assignment 5 - This program receives and generates random numbers.
;Luke Puppo - 11/6/18 - puppol@oregonstate.edu
; This program asks the user for a number n of random numbers
; to generate and then calculate metrics based off of and sort. 


.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword


INCLUDE Irvine32.inc


; Constants
	MIN = 10
	MAX = 200
	LO  = 100
	HI	= 999


.data
	; declare variables here
	intro1				BYTE	"Sorting random numbers    -    Luke Puppo", 0Ah, 0Dh, 0
	intro2				BYTE	"This program generates random numbers in the range [100 .. 999],", 0Ah, 0Dh, 0
	intro3				BYTE	"displays the original list, sorts the list, and calculates the", 0Ah, 0Dh, 0
	intro4				BYTE	"median value.  Finally, it displays the list sorted in descending order.", 0Ah, 0Dh, 0
	ec					BYTE	"**EC: Recursive Sorting algorithm.", 0Ah, 0Dh, 0

	promptNums			BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
	errorNums			BYTE	"Invalid input. Please do [10 .. 200]", 0Ah, 0Dh, 0



	userNum				DWORD	0
	randomNumArr		DWORD	MAX DUP(?)

	unsortedTitle		BYTE	"The unsorted random numbers: ", 0Ah, 0Dh, 0
	displayMedianText	BYTE	"The median value is: ",0
	sortedTitle			BYTE	"The sorted list is: ", 0Ah, 0Dh, 0
	spaces				BYTE	"    ",0



.code

; Description: Main program functionality
; Receives: None
; Returns: Outputs required by outline of Assignment 5
; Preconditions: All strings exist in .data
; Registers changed: edx and Sub-Proc changes
main proc

	call RANDOMIZE				; Set up randomness

	; ----- INTRODUCTION ------
	push OFFSET intro1			; -4 on stack
	push OFFSET intro2			; -4 on stack
	push OFFSET intro3			; -4 on stack
	push OFFSET intro4			; -4 on stack
	push OFFSET ec				; -4 on stack
	call introduction			; -24 total on stack after start call


	; ----- DATA COLLECTION ------
	push OFFSET promptNums		; -4 on the stack
	push OFFSET errorNums		; -4 on the stack
	push OFFSET userNum			; -4 on the stack
	call dataCollection			; -16 total on stack after start call


	; ------ FILL ARRAY -------
	push userNum				; -4 on the stack
	push OFFSET randomNumArr	; -4 on the stack
	call fillArray
	

	; ------ DISPLAY ARRAY ------
	push OFFSET randomNumArr
	push userNum
	push OFFSET unsortedTitle
	call displayArray


	; ------ SORT ARRAY ------
	push OFFSET randomNumArr
	push userNum
	call sortArray


	; ------ DISPLAY MEDIAN ------
	mov edx, OFFSET displayMedianText
	call WriteString
	push OFFSET randomNumArr
	push userNum
	call displayMedian

	call CrLf
	call CrLf


	; ------ DISPLAY ARRAY ------
	push OFFSET randomNumArr
	push userNum
	push OFFSET sortedTitle
	call displayArray

	invoke ExitProcess,0
	
main endp


; Description: Prints instructions to the user
; Receives: String offsets
; Returns: Instructions for the user
; Preconditions: Strings exist and are pushed to stack in the correct order
; Registers changed: edx
introduction proc
	push ebp					; -4 on stack
	mov ebp, esp

	; --- Gets intro strings
	mov edx, [ebp + 24]
	call WriteString
	mov edx, [ebp + 20]
	call WriteString
	mov edx, [ebp + 16]
	call WriteString
	mov edx, [ebp + 12]
	call WriteString
	mov edx, [ebp + 8]
	call WriteString

	pop ebp
	ret 20


introduction endp

; Description: Collects the num of random numbs from the user
; Receives: Strings to print to screen
; Returns: Number of random numbs
; Preconditions: Strings are not null
; Registers changed: eax, edx, edi
dataCollection proc		
	push ebp			; 4 on the stack
	mov ebp, esp


	GetUserData:
		mov edx, [ebp + 16]
		call WriteString
		call ReadDec
		cmp eax, MIN
		jl UserError
		cmp eax, MAX
		jg UserError
		mov edi, [ebp + 8]
		mov [edi], eax		; userNum reference
		
	pop ebp
	ret 12

	UserError:
		mov edx, [ebp + 12]
		call WriteString
		jmp GetUserData

dataCollection endp

; Description: Fills an array with random numbers
; Receives: Number of values to fill, and the array memory address
; Returns: A filled array's memory address
; Preconditions: Randomize has been called in main
; Registers changed: eax, ecx, edi
fillArray proc
	push ebp				; -4 on the stack
	mov ebp, esp

	mov ecx, [ebp + 12]		; userNum
	mov edi, [ebp + 8]		; randomNumArr

	AddArrVal:
		mov eax, HI
		sub eax, LO
		call RandomRange
		add eax, LO

		mov [edi], eax
		add edi, 4

		loop AddArrVal

	pop ebp
	ret 8

fillArray endp


; Description: Sorts an array in decending order
; Receives: Array and its length
; Returns: A sorted array
; Preconditions: Array and length are not null and are passed to stack correctly
; Registers changed:  eax, ebx, ecx, edx, edi, esi
sortArray proc
	push ebp
	mov ebp, esp

	mov edi, [ebp + 12]			; User Array
	mov ecx, [ebp + 8]			

	cmp ecx, 1					; Base Case
	je EndSorting

	push ecx					; Preserve outer loop counter
	dec ecx						; Dec for FOR loop
	InnerLoop:
		mov eax, [edi]			; First element
		mov ebx, [edi + 4]		; Second element
		cmp eax, ebx
		jl CallSwap				; Moves lower elem to right
		PostSwap:
			add edi, 4			; Continues through array
			loop InnerLoop
	
	pop ecx						; Restore outer loop counter
	dec ecx
	mov edi, [ebp + 12]			; Repoint edi to beginning of array
	push edi					; Push beginning of arr
	push ecx					; Push new updated outer loop counter
	call SortArray

	EndSorting:
		pop ebp
		ret 8

	CallSwap:
		push edi					; Push first elem
		mov esi, edi
		add esi, 4
		push esi					; Push second elem
		call exchangeElements
		jmp PostSwap


sortArray endp



; Description: Swaps two values
; Receives: Two memory addresses
; Returns: Swapped values
; Preconditions: Values come in the form of memory addresses
; Registers changed: eax, ebx, edi, esi
exchangeElements proc
	push ebp
	mov ebp, esp

	mov edi, [ebp + 12]		; First elem address
	mov esi, [ebp + 8]		; Second elem address

	mov eax, [edi]			; First elem
	mov ebx, [esi]			; Second elem

	mov [esi], eax
	mov [edi], ebx

	; Sanity Check
	mov eax, [edi]			; First elem
	mov ebx, [esi]			; Second elem

	pop ebp
	ret 8

exchangeElements endp



; Description: Displays the median value
; Receives: The array and the length
; Returns: A value (The median)
; Preconditions: Both inputs are not null
; Registers changed: eax, ebx, ecx, edx, edi
displayMedian proc
	LOCAL firstIndex:DWORD, secondIndex:DWORD, firstVal:DWORD, secondVal:DWORD

	mov edi, [ebp + 12]			; Array
	mov ecx, [ebp + 8]			; userNum (length)
	dec ecx

	mov ebx, 2
	mov eax, ecx					
	cdq
	div ebx
	mov firstIndex, eax
	sub ecx, eax
	mov secondIndex, ecx
	mov edx, firstIndex
	mov eax, [edi + (4*edx)]
	mov firstVal, eax
	mov edx, secondIndex
	mov eax, [edi + (4*edx)]
	mov secondVal, eax

	mov eax, firstVal
	add eax, secondVal
	cdq
	div ebx
	
	call WriteDec

	ret 8

displayMedian endp


; Description: Displays an array with a title prefix
; Receives: Array, user input, title of array
; Returns: Printed and formatted array
; Preconditions: Inputs must not be null
; Registers changed: eax, ebx, edx, edi
displayArray proc
	push ebp
	mov ebp, esp

	mov edi, [ebp + 16]		; arrayAddress
	mov ecx, [ebp + 12]		; userNums
	mov edx, [ebp + 8]		; title
	
	call WriteString

	DisplayNum:
		mov eax, [edi]
		call WriteDec
		mov edx, OFFSET spaces
		call WriteString
		
		add edi, 4

		mov eax, [ebp + 12]
		sub eax, ecx
		mov ebx, 10
		cdq
		div ebx
		cmp edx, 9
		je NewLine
		PostNewLine:
			loop DisplayNum

	call CrLf
	pop ebp
	ret 12

	NewLine:
		call CrLf
		jmp PostNewLine

displayArray endp

end main