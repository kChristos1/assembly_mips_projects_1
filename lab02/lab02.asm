#lab 02 assembly
#Zografoula-Ioanna Neamonitaki AM 2020030088
#Christos Kostadimas AM 2020030050

#data declaration section 
.data															     
	message: .asciiz "Please enter a string (100 characters max):\n"				#used for user interface  
	message2: .asciiz "\nThe Processed string is:\n"
	unprocessed_str:  .space 100									#the input that the user will give 
	processed_str:    .space 100  									#the result to be printed on screen


#instructions section follows  
.text																
	main:
    	addi $t0, $zero, 0      #counter used for storing each character of string
	addi $t6, $zero, 0 	#space counter  
        addi $t7,$zero, 32	#ascii value of ' ' (space) 
        addi $t2, $zero, 10     #ascii value of '\n' 
	addi $t8, $zero, 1	#used as a constant in branch equal

        jal get_input	#invoking the functions using jal instruction so $ra stores the address of the next instruction to be excecuted (i.e. next invocation) 
        jal process	
	jal print_out 
		
	addi $v0, $zero, 10     #10 is the system code for exiting the program
        syscall


	#functions/procedures 
	get_input: 
        addi $v0, $zero, 4	     # 4 is the code to print Strings
	la $a0,message		
	syscall  
	addi $v0, $zero, 8	     # 8 is the code to read string
	la $a0, unprocessed_str	   
	addi $a1, $zero, 100         #maximum number of characters that can be read	
	syscall
	   jr $ra
		
    process: 
    	loop:                                 #the loop is used for 1)reading a character from the unprocessed_str array
		lb $t1, unprocessed_str($t0)  #and for 2)processing the character
		add $t4, $t1, $zero 
	
		beq $t4, $t2, exit_loop       #if the character is \n, then store it and stop reading characters (exit_loop) 

		slti $t3, $t1, 'a'	      #if $t1 >= 'a' jump to case 1 to ckeck if it's a lower case letter or a symbol
		beq  $t3, $zero , case1
		j case2   		      #else jump to case 2( symbol or number)


		
		case1:                       #check if the character $t1<='z' and store it as it is(lower case alphabet)
	        addi $t5 ,$zero, 'z' 
		slt $t3, $t5, $t1
		beq  $t3, $zero, store
		j convertSymbol              #if not it's a symbol according to the ascii table, so convert it 
					
		

		case2: 
		slt $t3, $t1, 'A'            #check if $t1>='A', and go to case 3 to confirm if its capital or symbol 
	        beq  $t3, $zero, case3 
		j case4                      #if not it has to be a number or a symbol 

		

		case3:
		addi $t5, $zero, 'Z'        #check if its an upper case letter ($t1<='Z')
		slt $t3, $t5, $t1
		beq  $t3, $zero, convertCapital	
		j convertSymbol             #if not then its for sure a symbol according to the above checks
	


		case4:
		slti $t3,$t1, '0'           #check if $t1>='0' (symbol or number)
		beq  $t3,$zero, case5  
		j convertSymbol



		case5:
	        addi $t5, $zero, '9'        #check if t1<='9' (only numbers)
		slt $t3,$t5,$t1
		beq  $t3,$zero, store				
		j convertSymbol             #if not then its for sure a symbol because we checked all the other cases above
	
	        

		#convert the symbol into ' '
		convertSymbol: 

	        beq  $t6, $t8, skipspace   #if $t6 is equal to 1 then go to skipspace
		addi $t1, $zero, 32        #transform symbol into spaxe
		addi $t6, $zero, 1         #add 1 to counter $t6
		j store                    #jump to store
			

                
		skipspace:                 #function to skip space
	        
               
	        addi $t6, $zero, 0         #make the counter 0 again
		addi $t1, $t1, 1           #move to the next letter without storing it in the new string
		j loop                     #go to loop
			
			
		#in this label we convert a letter from upper case to lower case letter, and then we store it						
		convertCapital:
		addi $t1,$t1, 32
		j store

	
		store:
		sb $t1, processed_str($t0)
		addi $t0, $t0, 1
		j loop
			
				 
			
		exit_loop: 
		sb $t4, processed_str($t0)
                jr $ra


   
     #print the processed string 
     print_out:

     addi $v0, $zero, 4         #printing the message2
     la $a0, message2
     syscall

     addi $v0, $zero, 4	        # 4 is the code to print Strings
     la $a0, processed_str		
     syscall
     jr $ra