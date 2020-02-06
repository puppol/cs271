TITLE Basic Calculator (assign1.asm)
;Assignemnt 1 - Simple Arithmetic and Loops
;Luke Puppo - 9/30/18 - puppol@oregonstate.edu
;This program calculates the sum, difference, product and quotient
;of two numbers and insures that second input number is smaller than the first. 

;EC: This insures the first is larger than the second
;EC: This loops back until the user is done


.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword


INCLUDE Irvine32.inc

.data
	; declare variables here
	intro1 BYTE "Assignment 1 Program by Luke Puppo",0

	prompt1 BYTE "Please give me the first number. This should be the larger of the two.   ",0
	prompt2 BYTE "Thank you. Please give me the second number. This should be smaller than the first.   ",0
	repeatPrompt BYTE "Press 1 if you would like to try again, anything else to exit.",0

	error1 BYTE "There was an issue with your inputs. Press 1 if you want to try again, or anything else to exit.",0

	ending BYTE "Thanks for using my program! Good-Bye",0


	; value prefixes
	sumPrefix BYTE "Sum: ",0
	differencePrefix BYTE "Difference: ",0
	productPrefix BYTE "Product: ",0
	quotientPrefix BYTE "Quotient: ",0
	remainderPrefix BYTE "Remainder: ",0
	plusSign BYTE " + ",0
	minusSign BYTE " - ",0
	multSign BYTE " * ",0
	divSign BYTE " / ",0
	equalSign BYTE " = ",0

	
	; user values
	firstNum DWORD ?
	secondNum DWORD ?
	temp DWORD ?

	; final values
	sum DWORD 0
	difference DWORD 0
	product DWORD 0
	quotient DWORD 0 
	remainder DWORD 0	


.code
main proc

	; introduction
	mov edx, OFFSET intro1
	call WriteString
	call CrLf

	

StartingLocation:

	;LOCATION FOR GETTING THE USER INPUT
	GetUserInputLocation:
	; get user input
		mov edx, OFFSET prompt1 ; GETS FIRST NUM
		call WriteString
		call CrLf
		call ReadInt
		mov firstNum, eax

		mov edx, OFFSET prompt2 ; GETS SECOND NUM
		call WriteString
		call CrLf
		call ReadInt
		mov secondNum, eax

		cmp firstNum, eax
		jl GetUserInputLocation ; Insures second is less than first
		

	; preform calculations
	mov eax, firstNum
	add eax, secondNum
	mov sum, eax

	mov eax, firstNum
	sub eax, secondNum
	mov difference, eax

	mov eax, firstNum
	imul eax, secondNum
	mov product, eax

	mov eax, firstNum
	cdq
	mov ebx, secondNum
	div ebx
	mov quotient, eax
	mov remainder, edx


	; return results to user

	;--------------SUM---------------

	mov edx, OFFSET sumPrefix
	call WriteString

	mov eax, firstNum
	call WriteDec
	mov edx, OFFSET plusSign
	call WriteString
	mov eax,  secondNum
	call WriteDec
	mov edx, OFFSET equalSign
	call WriteString

	mov eax, sum
	call WriteDec
	call CrLf


	;--------------MINUS--------------


	mov edx, OFFSET differencePrefix
	call WriteString

	mov eax, firstNum
	call WriteDec
	mov edx, OFFSET minusSign
	call WriteString
	mov eax,  secondNum
	call WriteDec
	mov edx, OFFSET equalSign
	call WriteString

	mov eax, difference
	call WriteDec
	call CrLf

	;--------------PRODUCT--------------

	mov edx, OFFSET productPrefix
	call WriteString

	mov eax, firstNum
	call WriteDec
	mov edx, OFFSET multSign
	call WriteString
	mov eax,  secondNum
	call WriteDec
	mov edx, OFFSET equalSign
	call WriteString

	mov eax, product
	call WriteDec
	call CrLf

	;--------------QUOTIENT--------------

	mov edx, OFFSET quotientPrefix
	call WriteString

	mov eax, firstNum
	call WriteDec
	mov edx, OFFSET divSign
	call WriteString
	mov eax,  secondNum
	call WriteDec
	mov edx, OFFSET equalSign
	call WriteString
	
	mov eax, quotient
	call WriteDec
	call CrLf

	;--------------REMAINDER--------------

	mov edx, OFFSET remainderPrefix
	call WriteString
	mov eax, remainder
	call WriteDec
	call CrLf



	; ask user if they wish to repeat
	mov edx, OFFSET repeatPrompt
	call WriteString
	call CrLf

	call ReadInt
	cmp eax, 1
	je StartingLocation
	jmp ExitLocation




ExitLocation:
	; goodbye
	mov edx, OFFSET ending
	call WriteString

	invoke ExitProcess,0


	
main endp


end main