#lab 01 assembly
#Zografoula-Ioanna Neamonitaki AM 2020030088
#Christos Kostadimas AM 2020030050


#data declaration section  
.data
	
	warning_msg: .asciiz "\nThe maximum number of characters that this program can store is 100
			      \nThe string that has been stored after passing the limit is:\n"
	interface1:  .asciiz "\nPlease enter your character:\n"
	interface2:  .asciiz "\nThe string is:\n"
	final_string: .space 100	                  #An array of 100 bytes to store the characters that the user gives
						          #Note that the above array can hold 100 chars since: sizeof(char)=1 byte

#instructions section: 
.text
	main:
	    
		li $t1, 64  							#loading ascii value 64 in $t1 for the '@' terminating character
		li $t2, 0   						        #defining counter so we can increment the positions in final_string array 
		li $t3, 100         						#max size of characters that can be stored in the array
		
		loop:  				
			    li $v0, 4					        #loading immidiate 4 in $v0, 4 is the system call code for printing a string
			    la $a0, interface1				     
			    syscall						#excecuting the code 
			  
			    li $v0, 12						#loading immidiate 12 in $v0 is the system call for reading a char and storing it in $v0						
			    syscall
				move $t0 , $v0				        #copying the given input from $v0 to $t0 
		
			    beq $t0, $t1, exit_label				#checking if the given character (in $t0) is equal to the terminating character '@' 
													#if not then we store it in the array
			    sb $t0, final_string($t2)           		#storing $t0's value in the final_string($t2) place of the array [here we access RAM] 
				
			    addi $t2,$t2,1 					#incrementing the counter's previous value by 1, since sizeof(char)= 1 [byte]
				
			    beq $t3, $t2, warning_label		                #checking if user gave more than 100 characters					

			    j loop							   
		
		exit_label:
				li $v0, 4
				la $a0, interface2
				syscall 

				li $v0, 4							
			        la $a0, final_string			     
			        syscall	
				
				li $v0, 10					#telling the system to stop excecuting the program
				syscall 
				
		warning_label: 
				
				li $v0, 4
				la $a0, warning_msg 				#informing the user that he wants to give more than 100 chars by printing warning_msg 
				syscall								
				
				li $v0, 4							
			        la $a0, final_string			        #printing the final string after passing the limit 
			        syscall	

				li $v0, 10							
				syscall 