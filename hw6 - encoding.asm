.data
  string0:  .asciiz "MyfavoriteSubRedditInvolvesDogzZ"
  string1:  .asciiz "MyfavoriteSubRedditInvolvesDogzZ"		#this string should be the exact opposite of the encoded string
  #string1:  .asciiz "NzgbwpsjufTvcSfeejuJowpmwftEphaA"		#uncomment version of string1 this to check if the encoded string is identical to this
  corr_data: .asciiz "The two strings are identical"
  inco_data: .asciiz "The two strings are not identical"
  enco_data: .asciiz "The encoded string is:   "
  orig_data: .asciiz "Comparison string is:    "
  new_line: .asciiz "\n"	# Newline character
.text

#===========================================================
main:
	la $a0, string0		#loading string0 into $a0
	la $a1, string1		#loading string1 into $a1
	jal strencode		#call the strencode procedure
#===========================================================
finishing_remarks:
	
	add $t9, $zero, $zero	#initializing t9 for use just in case
	add $t9, $zero, $v0	#storing whatever value v0 came back with into t9 before printing out the next strings
	li $v0, 4
	la $a0, enco_data
	syscall		#prints the string 'enco_data'
	li $v0, 4
	la $a0, string0
	syscall		#prints the newly encoded string
	li $v0, 4
	la $a0, new_line
	syscall		#prints the 'new_line" character 
	
	li $v0, 4
	la $a0, orig_data
	syscall		#prints the string 'orig_data'
	li $v0, 4
	la $a0, string1
	syscall		#prints the newly encoded string
	li $v0, 4
	la $a0, new_line
	syscall		#prints the 'new_line" character 
	
	beq $t9, 1, neq		#if v0 is not 0 (strings are not identical), then move to neq:
	eq:				#v0 returned with true
		li $v0, 4
		la $a0, corr_data
		syscall
		j quit			#program finishes
	neq:				#v0 returned with false
		li $v0, 4
		la $a0, inco_data
		syscall
		j quit			#program cuts to the prodedure 'quit' which 'falls off the file'
#===================================================================================================================================
#-----------------------------------------------------------------------------------------------------------------------------------
#===================================================================================================================================
strcmp:
	add $t0, $zero, $a0	#$t0 now contains the edited version of string0
	add $t1, $zero, $a1	#$t1 contains string1
	addi $v0, $zero, 1	#v0 is essentially a bool here set as 1 (false)
	comparison_loop:
		lb $t2, 0($t0)	#t2 now contains the value of the incremented string1
		lb $t3, 0($t1)	#t3 	"	"	"	"	"     string0
		beqz $t2, finishing_remarks	#if string1's (unedited version) current value is at 0, 
						#then string is over
		addi $v0, $zero, 1		#v0 is reset to false just in case these next spots are unequal
		bne $t2, $t3, finishing_remarks		#if specific spots in strings are not equal, go to ending function
		add $v0, $zero, $zero		#v0 is set to true since it's made it past the not-equal check
		addi $t0, $t0, 1			#increment t0
		addi $t1, $t1, 1			#increment t1
		j comparison_loop	#both values have been incremented, now going back to beginning of
					#comparison loop
#===================================================================================================================================
#-----------------------------------------------------------------------------------------------------------------------------------
#===================================================================================================================================
strencode:	#replace vals in memory (we assume all passed values are letters (upper/lower))
	add $t0, $0, $0		#initialize t0 to 0
	add $t0, $0, $a0	#load base address of a0(string0) into t0
	editing_loop:		#inside of here is where the encoding actually happens.
		lb $t9, 0($t0)
		beq $t9, 0, strcmp	#if the string's current value is at 0, then string
					#is over and now jumps to strcmp to compare
					#the strings
		if_z_then:				#check if it's z, if so, then reset to a
			lb $t1, 0($t0)				#load the i-th bit into t1
			bne $t1, 122, else_if_Z_then		#branch to checking if t0 == Z if condition t0 != z
			addi $t1, $t1, -25			#since value is a, decrement t0 to a
			jal increment_anyways			#since we incremented, we don't want to change it further, so jump to last
		else_if_Z_then:				#check if it's Z, if so, then reset to A	
			bne $t1, 90, else_if_space_then		#branch to just adding one if t0 != Z
			addi $t1, $t1, -25			#since value is Z, decrement t0 to A
			j increment_anyways			#since we incremented, we don't want to change it further, so jump to last
		else_if_space_then:			#check if it's a space, if so, then don't add anything
			bne $t1, 32, else_then			#if not a space, branch to the end
			#increment nothing			#--------------------------------#
			j increment_anyways			#since we incremented, we don't want to change it further, so jump to last
		else_then:				#no issues, add one
			addi $t1, $t1, 1 			#increment letter by one
			sb $t0, 0($t0)
		increment_anyways:			#no matter what, the incrementing has got to increment
			sb $t1, 0($t0)				#store incremented letter into its originals value's space in the string
			addi $t0, $t0, 1			#increments to next spot in string
			j editing_loop				#incrementing is over, byte is stored, jump to beginning of loop
#===================================================================================================================================

quit:
