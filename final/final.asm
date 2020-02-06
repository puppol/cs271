TITLE Integer Reading and Low Level IO (final.asm)
;Assignment 6 - This program reads integers and finds the average
;Luke Puppo - 12/2/18 - puppol@oregonstate.edu
;This program gathers numbers from the user and finds the sum
;and average of the values. Uses macros for reading strings.


.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword


INCLUDE Irvine32.inc




; MACROS
displayString MACRO stringAddr
	pushad
	mov edx, stringAddr
	call WriteString
	popad
ENDM




getString MACRO promptAddr, inputAddr, inputSize
	push ecx
	push edx

	displayString promptAddr
	mov ecx, inputSize
	mov edx, inputAddr
	call ReadString

	pop edx
	pop ecx
ENDM



clearString MACRO userString
	pushad
	mov edi, userString

	mov ecx, 12
	cld
	L1:
		mov al, 0
		stosb
		loop L1

	popad
ENDM


.data
	
	intro1			BYTE		"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0Ah, 0Dh
					BYTE		"Written by: Luke Puppo", 0Ah, 0Dh, 0Ah, 0Dh
	
	
					BYTE		"Please provide 10 unsigned decimal integers.", 0Ah, 0Dh
					BYTE		"Each number needs to be small enough to fit inside a 32 bit register.", 0Ah, 0Dh
					BYTE		"After you have finished inputting the raw numbers I will display a list", 0Ah, 0Dh
					BYTE		"of the integers, their sum, and their average value.", 0Ah, 0Dh, 0
	
	
	prompt1			BYTE		"Please enter an unsigned number: ", 0
	error1			BYTE		"ERROR: You did not enter an unsigned number or your number was too big.", 0Ah, 0Dh, 0

	final1			BYTE		"You entered the following numbers: ",0
	final2			BYTE		"The sum of these numbers is: ",0
	final3			BYTE		"The average is:",0


	userString		BYTE		12 DUP(0)
	userVal			DWORD		0
	userValsArr		DWORD		10 DUP(?)
	tempVal			DWORD		0



.code

; Description: Main program functionality
; Receives: None
; Returns: All reqs
; Preconditions: All strings exist in .data
; Registers changed: Sub-Routines
main proc
	
	push OFFSET intro1				; -4 
	call introduction

	push OFFSET prompt1
	push OFFSET error1
	push OFFSET userString
	push OFFSET userVal
	push OFFSET userValsArr
	call buildUserArray

	push OFFSET final1
	push OFFSET final2
	push OFFSET final3
	push OFFSET tempVal
	push OFFSET userString
	push OFFSET userValsArr
	call displayFinals

	invoke ExitProcess,0
main endp

	; Description: Prints the introduction to the user
	; Receives: intro string
	; Returns: Output to user
	; Preconditions: Value exists
	; Registers changed: None
	introduction PROC
		push ebp					; -4 on stack
		mov ebp, esp

		displayString [ebp + 8]

		pop ebp
		ret 4

	introduction ENDP


	; Description: Reads a value in from the user and stores it
	; Receives: promptAddr, errorAddr, inputAddr, userValAddr
	; Returns: Int
	; Preconditions: Passed values exist
	; Registers changed: eax, ebx, ecx, edi, esi
	readVal PROC					;promptAddr, errorAddr, inputAddr, userValAddr
		;8 PromptAddr
		;12 ErrorAddr
		;16 InputAddr
		;20 userValAddr

		push ebp
		mov ebp, esp
		pushad

		Top:
			mov eax, 12
			getString [ebp + 8], [ebp + 16], eax


			cmp eax, 0
			je BadInput1
			mov eax, 0
			mov ebx, 10

			mov esi, [ebp + 16]						; Load user input


			mov ecx, eax
			cld
			VerifyString:								
				push eax
				lodsb
				cmp al, 0
				je Done
				cmp al, 48
				jl BadInput2
				cmp al, 57
				jg BadInput2
			
				sub al, 48							; Convert char to int
				mov dl, al
			
				pop eax
				push edx
				mul ebx
				jc BadInput3
				pop edx

				movzx edx, dl
				add eax, edx


				loop VerifyString

		BadInput1:
			displayString [ebp + 12]
			jmp Top

		BadInput2:
			displayString [ebp + 12]
			pop eax
			jmp Top

		BadInput3:
			displayString [ebp + 12]
			pop edx
			jmp Top


		Done:
			pop eax
			;If it gets here its good
			mov edi, [ebp + 20]
			mov [edi], eax

		popad
		pop ebp
		ret 16
		
	readVal ENDP

	; Description: Writes an integer to the screen
	; Receives: valueMemAddr, writeStringAddr
	; Returns: Prints to the screen an integer
	; Preconditions: Passed values exist
	; Registers changed: eax, ebx, ecx, edi, al, dl
	writeVal PROC							
		push ebp
		mov ebp, esp
		pushad
		; 8 valueMemAddr
		; 12 writeStringAddr
													; Get value
		mov edi, [ebp + 8]
		mov eax, [edi]

		mov edi, [ebp + 12]							; Get string storage addr

		mov ecx, 1
		

		Convert:									; Dissasembles int, pushes to stack
			mov ebx, 10
			xor edx, edx
			div ebx
			push edx
			cmp eax, 0
			je RebuildStart
			inc ecx
			jmp Convert


		RebuildStart:
			clearString edi
		

		Rebuild:									; Converts ints to chars
			pop edx
			add edx, 48
			mov al, dl
			stosb
			loop Rebuild

		displayString [ebp + 12]
		popad
		pop ebp
		ret 8
	
	writeVal ENDP


	; Description: Asks the user for 10 inputs and builds an array
	; Receives: Prompts and values, see pushes in main PROC
	; Returns: A filled array with values
	; Preconditions: Passed data exists and is in correct order
	; Registers changed: eax, ebx, ecx, edi, esi
	buildUserArray PROC
		push ebp
		mov ebp, esp

		mov ecx, 10
		mov ebx, 0
		GetVals:
			push [ebp + 12]
			push [ebp + 16]
			push [ebp + 20]
			push [ebp + 24]
			call ReadVal
			

			mov esi, [ebp + 12]						;OFFSET userVal
			mov eax, [esi]							;userVal
			
			mov edi, [ebp + 8]						;OFFSET userValArr
			mov [edi + ebx], eax
			add ebx, 4

			loop GetVals

		pop ebp
		ret 20
	buildUserArray ENDP


	; Description: Calculates and displays the information required
	; Receives: userValArr, userString 
	; Returns: Prints the required outputs to the screen
	; Preconditions: Passed in the correct order and exist
	; Registers changed: eax, ebx, ecx, edx, edi, esi
	displayFinals PROC
		push ebp
		mov ebp, esp
		
		mov ebx, 0

		xor edx, edx
		mov edi, [ebp + 8]							;OFFSET userValArr
		mov esi, [ebp + 12]							;OFFSET userString

		mov ecx, 10
		displayString [ebp + 28]
		PrintAndSum:
			clearString esi							;Cleans holder string

			push esi
			push edi
			call WriteVal

			mov al, ' '
			call WriteChar

			add edx, [edi]
			add edi, 4
			loop PrintAndSum


		call CrLf

													; Print sum
		displayString [ebp + 24]
		mov edi, [ebp + 16]
		mov [edi], edx
		
		push [ebp + 12]
		push [ebp + 16]
		call CrLf
		call WriteVal

		call CrLf
													;Print average
		displayString [ebp + 20]
		mov ebx, 10
		mov eax, edx
		xor edx, edx								;Calc avg, prevents cdq integer overflow
		div ebx
		mov [edi], eax
		mov eax, [edi]

		push [ebp + 12]
		push edi
		call CrLf
		call WriteVal

		pop ebp
		ret 24
	displayFinals ENDP 


end main