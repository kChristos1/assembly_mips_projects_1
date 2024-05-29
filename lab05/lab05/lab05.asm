
# Christos Kostadimas AM: 2020030050
# Zografoula-Ioanna Neamonitaki AM: 2020030088

.data
	operation_msg: .asciiz "\nPlease determine operation, entry(E), inquiry(I), or quit(Q/q): \n"
	first_name_msg: .asciiz "Please enter first name: \n"
	last_name_msg: .asciiz "\nPlease enter last name: \n"
	phone_number_msg: .asciiz "Please enter phone number: \n"
	new_entry_msg: .asciiz "Thank you, the new entry is the following: \n"
	inquiry_msg: .asciiz "\nPlease enter the entry number you wish to retrieve: \n"
	error_msg: .asciiz "There is no such entry in the phonebook \n"
	full_msg: .asciiz "\nThe array is full you can only ask for an entry (I)\n"
	entry_msg: .asciiz "The Entry is: \n"
	
	.align 2
	array: .space 600
	.align 2
	string1: .space 66
	.align 2
	string2: .space 66
	
.text

main:
	la $s0, array		#set $s0 as a pointer in the begining of array
	move $s1, $s0		
	move $s3, $s0		
    addi $s4, $zero, 0  #$s4 is a counter for entries (initially zero) 
	

while_loop:	
	jal Prompt_User				#jump and link in Prompt_User

	move $s5, $v0				#move character user gave in $s5 

	beq $s5, 'E', Choice_E		#if user input is 'E'
	beq $s5, 'I', Choice_I      #if user input is 'I'
	beq $s5, 'Q', Exit			#if user input is 'Q'
	beq $s5, 'q', Exit          #if user input is 'q' 
	
	#if user gave something else than E,I,Q,q => ask for operation again 
	Prompt_User:
		la $a0, operation_msg	#load operation message
		addi $v0, $zero, 4		#print the message
		syscall
		
		#store the given character in $v0
		addi $v0, $zero, 12		#li $v0, 12
		syscall
		jr $ra

Choice_E:
	jal Get_Entry
	j while_loop

Choice_I:
	jal Print_Entry
	j while_loop



	

Get_Entry:
	beq $s4, 10, fullArray		#if there are 10 saved entries
	
	addi $sp, $sp, -4			#make space for 4 bytes in the stack
	sw $ra, 0($sp) 				#push $ra in the stack
	
	jal Get_Last_Name			
	addi $s3, $s3, 20	        #move the $s3 pointer by 20
	
	jal Get_First_Name			
	addi $s3, $s3, 20			
	
	jal Get_Number				
	addi $s3, $s3, 20			
	
	addi $s4, $s4, 1	        #increase $s4 by 1, means an entry has been successfully registered 
	
	                            #$s3 points with $s1 in the begining of the current entry (needed in Build_String) 
	addu $s3, $s1, $zero  #move $s3, $s1
	
	jal Build_String			
										#$s3 points in the begining of the next entry after excecution of Build_String 
	addu $s1, $s3, $zero #move $s1,s3	#$s1 is updated to point in the the begining of the next entry
									
								        
    lw $ra, 0($sp)				#pop $ra from the stack
	addi $sp, $sp, 4			#close space in the stack
	jr $ra						#return where Get_Entry was invoked
	   	


#function that lets user know he cant give more entries and the only thing
#he can do is to print one of the 10 existing entries or exit
fullArray:
	la $a0, full_msg			
    li $v0, 4				
    syscall
    #must return in main
	jr $ra




Get_Last_Name:
    la $a0, last_name_msg	
    addi $v0, $zero, 4				
	syscall
		
	addi $v0, $zero, 8 				#syscall for reading strings   
   	la $a0, ($s3)			#store string input in array on the corresponding address ( $s3 +... )
  	addi $a1, $zero, 20              #max length of string 
    syscall
    	
	jr $ra


Get_First_Name:
	la $a0, first_name_msg	
    addi $v0, $zero, 4				
	syscall
		
    addi $v0, $zero, 8			
   	la $a0, ($s3)			#store string input in array on the corresponding address ( $s3 + 20 +...)
    addi $a1, $zero, 20
    syscall
		
	jr $ra


Get_Number:
    la $a0, phone_number_msg		
    addi $v0, $zero, 4				
	syscall
		
	addi $v0, $zero, 8 				        
   	la $a0, ($s3) 			#store string input in array on the corresponding address ( $s3 +20 +20 +...)
    addi $a1, $zero, 20
    syscall
    	
	jr $ra




#1.loads characters (using bitmask method) from the "array" , 
#2.edits them 
#3.stores them in string1 and prints it
#Build_String does not invoke subrutines , no need to save $ra in the stack 
Build_String: 	
    #registers: 
	#$t2: is a pointer to the begining of string1
	#$t5: flag to let us know when to load a new word from the array[] 
	#$t6: counter for characters of the string1, indicates if i finished with an entry 
	#$t4: has the character that is about to be written in string1 array
	#$s4: contains the number of entries 

	addi $t2, $zero, 0				#initialize registers to 0			
    addi $t3, $zero, 0				
	addi $t4, $zero, 0				
	addi $t5, $zero, 0  		
	addi $t6, $zero, 0     			
		
	la $a0, new_entry_msg		
    addi $v0, $zero, 4				
	syscall		
		

	la $t2, string1			#load the address of string1 in $t2

    beq $s4, 10, caseTen	#if this is the tenth entry go to caseTen

	addi $t4, $s4, 48		#increase $s4 by 48 to get the corresponding ascii value on the console [1...9]
    sb $t4, 0($t2)			#store $t4 in the begining of string1 where $t2 points
    
	addi $t4, $zero, 0x0000002e	#li $t4, ...
    sb $t4, 1($t2)			#store   "."   in 1($t2)
    
	addi $t4, $zero, 0x00000020	#li $t4, ...	
    sb $t4, 2($t2)			#store   " "   in 2($t2)
    
	addi $t2, $t2, 3		#increase $t2 by 3
    j newWord
       	
	caseTen:
 		addi $t4, $zero, 0x00000031			#store "1" in $t2		
 		sb $t4, 0($t2)
 		
		addi $t4, $zero, 0x00000030			#store "0" in 1($t2)
 		sb $t4, 1($t2)
 		
		addi $t4, $zero, 0x0000002e			#store "." in 2($t2)
       	sb $t4, 2($t2)
       	
		addi $t4, $zero, 0x00000020			#store " " in 3($t2)
       	sb $t4, 3($t2)
       
	   	addi $t2, $t2, 4			#increase $t2 by 4	
       			
    newWord:
       	lw $t3, 0($s3)			#load word from CURRENT entry to $t3
       	loop:	                #entering this loop means that we are about to process a character 
			addi $t6, $t6, 1			        
			beq $t6, 67, printNewEntry  		#if $t6 is 67 print and exit
			andi $t4, $t3, 0x000000ff 			#select the first byte of the word (bitmask)
			beq $t4, 0x00000000, caseNull		#if $t4=null
			beq $t4, 0x0000000a, caseNewLine	#if $t4=\n
			sb $t4, 0($t2)						#store the byte
			srl $t3, $t3, 8						#shift $t3 right by 8 bits so we can process the next byte (8 bits) of the word(for next bitmask)
			addi $t5, $t5, 1			
			addi $t2, $t2, 1
			beq $t5, 4, wordCount			    #if $t5 is 4 get next word
			j loop
       		
	wordCount:	
       	addi $t5, $zero, 0				
       	addi $s3, $s3, 4			
       	j newWord	
       	
	caseNull:                      #ignores null characters from the readen word of array[] 
		srl $t3, $t3, 8	           #shift $t3 without storing the byte
		addi $t5, $t5, 1			
		beq $t5, 4, wordCount		
		j loop

    caseNewLine:	                #replaces new line (/n) character with a space ( ) 
        addi $t4, $zero, 0x00000020			
       	sb $t4, 0($t2)			
       	srl $t3, $t3, 8				
       	addi $t5, $t5, 1			
       	addi $t2, $t2, 1			
       	beq $t5, 4, wordCount	    #if $t5 is 4 change word
       	j loop
       	
	printNewEntry:	
       	la $a0, string1				
       	addi $v0, $zero, 4				
       	syscall
       	addi $t4, $zero, 0x00000000			#initialize $t4 to null
       	la $t2, string1				#load address of string1 in $t2
       	addi $t6, $zero, 0
    
	clear_loop: 
	    beq $t6, 15, return		    #if $t6 is 15 exit
		sw $t4, 0($t2)				#store the word in $t4 where $t2 points 
		addi $t6, $t6, 1			#makes string1 null
		addi $t2, $t2, 4			#counter for words
		j clear_loop
    
	return: 
       	jr $ra                      #jumps in main to go back in while loop 




#function used to find and print the entry user asked for 
#this function has to store $ra in the stack because it invokes Build_String2 using jal instruction
#register 
#$s4 : contains number of entries 
#$t7 : Number of entry user asked for 
Print_Entry:
	addi $t1, $zero, 0			#initialize registers to 0 
	addi $t7, $zero, 0			
	addi $t8, $zero, 0			
	addi $t9, $zero, 0			#$t9 is an array index, must be zero initially 
    addi $t6, $zero, 0 
    addi $t2, $zero, 0
	addi $t5, $zero, 0
	addi $t3, $zero, 0

	addi $sp, $sp, -4 
	sw $ra, 0($sp) 

	la $a0, inquiry_msg		
	addi $v0, $zero, 4			#print string 
	syscall
	
	addi $v0, $zero, 5			#read int (value returned in $v0)
	syscall			
	
	addu $t7, $v0, $zero	#move the content of $v0 to $t7

	#1st check 
	#blt $t7, 1 , Print_Error
	slti $t0, $t7, 1   #returns 1 in $t0 when $t7<1
	bne  $t0, $zero, Print_Error
	
	#2nd check, comparing $t7 to $s4 
	addi $t0, $zero, 0   #(initializing $t0 to zero) 
	
	addu $t6, $zero, $s4 #move $t6, $s4	
	slt $t0, $t6, $t7    #returns 1 in $t0 when $t6<$t7 ($s4<$t7) 
	bne  $t0, $zero, Print_Error #user asked for entry that's not yet registered 

    #re-initializing registers used for comparisons, they will be needed in Build_String2
	addi $t0, $zero, 0 
    addi $t6, $zero, 0 

	jal Build_String2

	lw $ra, 0($sp)
	addi $sp, $sp, 4 
	jr $ra



Print_Error:
	la $a0, error_msg		
	addi $v0, $zero, 4			
	syscall
	jr $ra  #returns in main's while_loop to ask for new operation 




#function that builds and prints the entry user asked for 
#registers:
#$s0: contains the first address of the "array"  
#$t9: index of "array"
#$t2: pointer to string2 

Build_String2:
	
	addi $t9, $t7, -1		#$t9 is used as array index, arrays are 0-BASED 5th element is in array[4] position
	addi $t1, $zero, 60		#initialize $t1 to 60 (60 is the total number of bytes each entry contains... 60 char's)
	mult $t9, $t1 			#multiplying $t9 by 60 gives us the index of Nth element of the array (if user gave 5 => $t9 gives array[4], 5th element) 
    mflo $t9                #mul $t9, $t9, $t1
				
				#δεν ήθελα να πω addresss κι είπα ινδεχ γιατι το αδδρεσσ το παιρνω με την αδδ της 335 
	
	addu $t8, $s0, $zero    #move $t8, $s0 		#$t8 points to $s0
	add $t8, $t8, $t9 	    #now $t8 contains the true address of the begining of the entry user asked for (OFFSET)
    
	la $a0, entry_msg		
	addi $v0, $zero, 4			
	syscall

    la $t2, string2			#load  the address of string2 in $t2	
    beq $t7, 10, caseTen2   #if this is the tenth entry
	addi $t4, $t7, 48		#increase $t7 by 48 to get the corresponding ascii value 
    sb $t4, 0($t2)			#store $t4 in $t2
    addi $t4, $zero, 0x0000002e		
    sb $t4, 1($t2)			#store '.' in 1($t2)
    addi $t4, $zero, 0x00000020		 
    sb $t4, 2($t2)			#store ' ' in 2($t2)
    addi $t2, $t2, 3		#increase $t2 by 3
    j newWord2
       		
	caseTen2:
 		addi $t4, $zero, 0x00000031			#store '1' in $t2		
 		sb $t4, 0($t2)
 		addi $t4, $zero, 0x00000030			#store '0' in 1($t2)
 		sb $t4, 1($t2)
 		addi $t4, $zero, 0x0000002e			#store '.' in 2($t2)
       	sb $t4, 2($t2)
    	addi $t4, $zero, 0x00000020			#store ' ' in 3($t2)
       	sb $t4, 3($t2)
       	addi $t2, $t2, 4			        #increase $t2 by 4 to store in the next byte later..
        #end of label
	
    newWord2:
       	lw $t3, 0($t8)		
       	loop2: 
			addi $t6, $t6, 1		#καουντερ			
       		beq $t6, 67, printEntry2			#if $t6 is 67 exit (max No Characters) 
       		andi $t4, $t3, 0x000000ff 		    #select the first byte of the word
       		beq $t4, 0x00000000, caseNull2		#if $t4 is null
       		beq $t4, 0x0000000a, caseNewLine2	#if $t4 is new line
       		sb $t4, 0($t2)					    #store the byte from $t4 in "string2" 
			addi $t2, $t2, 1
       		srl $t3, $t3, 8					#shift $t3 right by 8 bits
       		addi $t5, $t5, 1				#increase $t5, $t2 by 1
       		beq $t5, 4, wordCount2			#if $t5 is 4 change word
       		j loop2
    
	wordCount2:	
        addi $t5, $zero, 0			#initialiaze $t5 to 0
       	addi $t8, $t8, 4		#increase $s3 by 4
       	j newWord2
    
	caseNull2:
       	srl $t3, $t3, 8				#shift $t3 right by 8 bits
       	addi $t5, $t5, 1			#increase $t5 by 1
       	beq $t5, 4, wordCount2		#if $t5 is 4 change word
       	j loop2
    
	caseNewLine2:
       	addi $t6, $t6, 1
       	addi $t4, $zero, 0x00000020			#store ' ' in $t2
       	sb $t4, 0($t2)
		addi $t2, $t2, 1
       	srl $t3, $t3, 8				#shift $t3 right by 8 bits
       	addi $t5, $t5, 1			#increase $t5, $t2 by 1
       	beq $t5, 4, wordCount2		#if $t5 is 4 change word
       	j loop2
    
	printEntry2:
        la $a0, string2			
       	addi $v0, $zero, 4				
       	syscall
       			
		la $t0, string2				    #load  the address of string2 in $t0
		addi $t4, $zero, 0x00000000		#initialize $t4 to null
        addi $t6, $zero, 0
    
	clear2: 
        beq $t6, 15, return2			#if $t6 is 15 exit
       	sw $t4, 0($t0)				
       	addi $t6, $t6, 1			
       	addi $t0, $t0, 4			
       	j clear2
    
	return2: 
       	jr $ra

Exit:		
	addi $v0, $zero, 10		#exit program	
	syscall