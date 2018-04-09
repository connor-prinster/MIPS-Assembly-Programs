## Data declaration section 
.data
#messages
enterThings: .asciiz "\n Enter 10 numbers (no spaces)\n"
premsg: .asciiz  "\n---Presorting---\n: "  # Prompt
posmsg: .asciiz  "\n---PostSorted---\n"
newLine: .asciiz "\n"                      # Newline character
listOfNum: .asciiz "           "           # An empty 10 char whitespace string

.text 

main:
#===============================================================================================================================================
    la $a0, enterThings		# Load address of first string
    li $v0, 4        		# Load Opcode 4 to print string
    syscall			# print first string
    la $a0, premsg   		# Load address of second string
    li $v0, 4        		# Load Opcode 4 to print string
    syscall			# print second string
    
    #Read User Input into address of listOfNum (This idea and similar code between '##...# lines was pulled from https://stackoverflow.com/users/2330303/james-choi)
    ##########################################################################################################################################
    la $a0,listOfNum  # Load address of listOfNum into syscall argument a0
    li $a1,11         # Load sizeOfInput+1 into syscall argument a1
    li $v0,8          # Load Opcode: 8 (Read String)
    syscall
    #-----------------------------------------------------------------------
    #Define total num of chars (in this case, t9
    li $s7,10           # s7 now holds the upper index
    #-----------------------------------------------------------------------
    #call the "functions"
    la $s0, listOfNum    # Load base address to listOfNum into $t9
    jal sort
    jal print
    j exit
    ##########################################################################################################################################
#================================================================================================================================================
sort:   
#================================================================================================================================================
	#---------------------------------------------------------------------------------------------
	add $t9,$zero,$zero #set t9 (or 'int i' in C++) to 0
	iLoop:
        beq $t9,$s7,done 	#if the sentinel value is found, jump to Done

        sub $t7,$s7,$t9		#for loop of i goes up until n-1, so we set it to ( 10 - i - 1 ) here
        addi $t7,$t7,-1		#	"	"	"	"	"	"	"	"
	#---------------------------------------------------------------------------------------------
        add $t8,$zero,$zero	#set t9 (or 'int i' in C++) to 0
        jLoop:
            beq $t8,$t7,continue	#if the sentinel value is found, jump to continue to push back up to iLoop
	
            add $t6,$s0,$t8		#loading 'j' and 'j+1' into s1 and s2 respectively for future comparisons
            lb  $s1,0($t6)		#accessing the 'current base' of the array OR J
            lb  $s2,1($t6)		#accessing the 'current base' + 1 of the array OR J+1
            
            sgt $t2, $s1,$s2		#essentially checking to see if (j) > (j + 1)
            				#	if so, t2 will equal 1 and then will eventually swap and store
            beq $t2, $zero, good	#if t2 equals 1 (or anything other than 0, really) then program
            				#	will continue onward. Otherwise, break to "good:"
            				
            sb  $s2,0($t6)	#(j) > (j + 1) so J+1 is stored where J originally was
            sb  $s1,1($t6)	#(j) > (j + 1) so J is stored where J+1 originally was
	#-------------------------------------------------------------------------------------------------------------------------------
       		good:
            		addi $t8,$t8,1 	#since (j) < (j + 1) no swap is required but the j-counter is incremented by one
            		j jLoop		#with the j-counter incremented by one, it returns back to the beginning of jloop to check for 
            				#	a sentinel value to continue onwards again
		#-------------------------------------------------------------------------------------
        	continue:
        		addi $t9,$t9,1	#increment the i-counter
        		j iLoop		#because sentinel value is found, return back to beginning of iLoop
        #-------------------------------------------------------------------------------------------------------------------------------
#================================================================================================================================================
print:
    la $a0,newLine	#load the string "newLine" declared in the beginning section
    li $v0,4		#load the system code thing that will print the la value
    syscall 		#print newLine

    
    add $t6,$zero,$zero 	#set an l-value to zero to make sure that it doesn't print any further than its bounds
	#--------------------------------------------------------------------------------------------------
    	lPrint:
        	beq $t6,$s7,done 	#check for sentinel value. If found, break to done:
        				#	will end the program if sentinel value is found

        	add $t8,$s0,$t6 	#reuse t8 (int i = 0) from the iLoop and reset to the base of the array
        	lb $a0, 0($t8)  	#Load the 'current base' of the array
        	li $v0, 11      	#Load opcode to print a0
        	syscall         	#print the char currently in a0

        	addi $t6,$t6,1  	#increment the 'current base' by one
        	j lPrint		#since the sentinel value is not found, jump to beginning of lPrint
     	#--------------------------------------------------------------------------------------------------
#================================================================================================================================================

done:
    jr $ra	#jumps back to jal print on line 42
exit:
		#escape the program by running off the end of the program
