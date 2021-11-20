;	set game state memory location
.equ    HEAD_X,         0x1000  ; Snake head's position on x
.equ    HEAD_Y,         0x1004  ; Snake head's position on y
.equ    TAIL_X,         0x1008  ; Snake tail's position on x
.equ    TAIL_Y,         0x100C  ; Snake tail's position on Y
.equ    SCORE,          0x1010  ; Score address
.equ    GSA,            0x1014  ; Game state array address

.equ    CP_VALID,       0x1200  ; Whether the checkpoint is valid.
.equ    CP_HEAD_X,      0x1204  ; Snake head's X coordinate. (Checkpoint)
.equ    CP_HEAD_Y,      0x1208  ; Snake head's Y coordinate. (Checkpoint)
.equ    CP_TAIL_X,      0x120C  ; Snake tail's X coordinate. (Checkpoint)
.equ    CP_TAIL_Y,      0x1210  ; Snake tail's Y coordinate. (Checkpoint)
.equ    CP_SCORE,       0x1214  ; Score. (Checkpoint)
.equ    CP_GSA,         0x1218  ; GSA. (Checkpoint)

.equ    LEDS,           0x2000  ; LED address
.equ    SEVEN_SEGS,     0x1198  ; 7-segment display addresses
.equ    RANDOM_NUM,     0x2010  ; Random number generator address
.equ    BUTTONS,        0x2030  ; Buttons addresses

; button state
.equ    BUTTON_NONE,    0
.equ    BUTTON_LEFT,    1
.equ    BUTTON_UP,      2
.equ    BUTTON_DOWN,    3
.equ    BUTTON_RIGHT,   4
.equ    BUTTON_CHECKPOINT,    5

; array state
.equ    DIR_LEFT,       1       ; leftward direction
.equ    DIR_UP,         2       ; upward direction
.equ    DIR_DOWN,       3       ; downward direction
.equ    DIR_RIGHT,      4       ; rightward direction
.equ    FOOD,           5       ; food

; constants
.equ    NB_ROWS,        8       ; number of rows
.equ    NB_COLS,        12      ; number of columns
.equ    NB_CELLS,       96      ; number of cells in GSA
.equ    RET_ATE_FOOD,   1       ; return value for hit_test when food was eaten
.equ    RET_COLLISION,  2       ; return value for hit_test when a collision was detected
.equ    ARG_HUNGRY,     0       ; a0 argument for move_snake when food wasn't eaten
.equ    ARG_FED,        1       ; a0 argument for move_snake when food was eaten

; initialize stack pointer
addi    sp, zero, LEDS

; main
; arguments
;     none
;
; return values
;     This procedure should never return.
main:
    ; TODO: Finish this procedure.
    callr	clear_leds
    


; BEGIN: clear_leds
clear_leds:
    stw     zero, LEDS(zero)
    stw     zero, LEDS+4(zero)
    stw     zero, LEDS+8(zero)
    ret

; END: clear_leds


; BEGIN: set_pixel
set_pixel:
    andi	t0,	    a0,		12
    andi    t1,		a0,		3
    slli	t1,		t1,		3
    add		t1,		t1,		a1
    addi	t1,		t1,		1
    ldw		t2,		LEDS(t0)
    or		t2,		t2,		t1
    stw		t2,		LEDS(t0)
    ret

; END: set_pixel


; BEGIN: display_score
display_score:

; END: display_score


; BEGIN: init_game
init_game:
    stw		zero,		HEAD_X(zero)
    stw		zero,		HEAD_Y(zero)
    stw		zero,		TAIL_X(zero)
    stw		zero,		TAIL_Y(zero)
    addi	t0,	        zero,		 DIR_RIGHT  
    stw		t0,		    GSA(zero)
    stw		zero,		SCORE(zero)

    # call    create_food
    

    jmpi    main_loop

; END: init_game


; BEGIN: create_food
create_food:

; END: create_food


; BEGIN: hit_test
hit_test:
    #Load current direction
    ldw		t0,		HEAD_X(zero)
    ldw		t1,		HEAD_Y(zero)
    slli	t2,		t0,		    3
    add		t2,		t2,		    t1
    slli	t2,		t2,		    2
    ldw		t3,		GSA(t2)

    #Get Next Cell and Check game limits
    left_hit:
        addi	t4,		zero,		DIR_LEFT
        bne		t3,		t4,		    up_hit
        addi	t4,		t2,		    -32
        ldw		t5,		GSA(t4)
        bne		t0,		zero,		check_cell
        addi	v0,		zero,		2
        br		end_hit
        
    up_hit:
        addi	t4,		zero,		DIR_UP
        bne		t3,		t4,		    down_hit
        addi	t4,		t2,		    -4
        ldw		t5,		GSA(t4)
        bne		t1,		zero,		check_cell
        addi	v0,		zero,		2
        br		end_hit

    down_hit:
        addi	t4,		zero,		DIR_DOWN
        bne		t3,		t4,		    down_hit
        addi	t4,		t2,		    4
        ldw		t5,		GSA(t4)
        addi	t4,		zero,		7
        bne		t1,		t4,		    check_cell
        addi	v0,		zero,		2
        br		end_hit

    right_hit:
        addi	t4,		zero,		DIR_RIGHT
        bne		t3,		t4,		    check_cell
        addi	t4,		t2,		    32
        ldw		t5,		GSA(t4)
        addi	t4,		zero,		11
        bne		t0,		t4,		    check_cell
        addi	v0,		zero,		2
        br		end_hit

    #Check Snake Body
    check_cell:
        addi	v0,		zero,		0               #no collision
        beq		t5,		zero,	    end_hit
        addi	v0,		zero,		1               #food collision
        addi	t0,		zero,		5
        beq		t5,		t0,	        end_hit
        addi	v0,		zero,		2               #body collision
    #Check Food

    end_hit:
        ret

; END: hit_test


; BEGIN: get_input
get_input:
    #Load current direction
    ldw		t0,		HEAD_X(zero)
    ldw		t1,		HEAD_Y(zero)
    slli	t0,		t0,		    3
    add		t3,		t0,		    t1
    slli	t3,		t3,		    2
    ldw		t4,		GSA(t3)
    
    #Load edgecapture
    ldw		t0,		BUTTONS+4(zero)
    andi	t0,		t0,		    31
    addi	t1,		zero,	    1
    
    # Test no button
    no_button:
        bne		t0,		zero,	left_button
        addi	v0,		zero,	BUTTON_NONE
    
    # Test left button
    left_button:
        # test if left pressed
        andi	t2,		t0,		1
        bne		t1,		t2,		up_button
        # test if direction not right
        addi	t1,		zero,	DIR_RIGHT
        beq		t4,		t1,	    up_button
        #Set return value
        addi	v0,		zero,	BUTTON_LEFT
    
    # Test up button
    up_button:
        srli	t2,		t0,		1
        andi	t2,		t2,		1
        bne		t1,		t2,		down_button
        # test if direction not down
        addi	t1,		zero,	DIR_DOWN
        beq		t4,		t1,	    down_button
        #Set return value
        addi	v0,		zero,	BUTTON_UP
    
    ; Test down button
    down_button:
        srli	t2,		t0,		2
        andi	t2,		t2,		1
        bne		t1,		t2,		right_button
        # test if direction not up
        addi	t1,		zero,	DIR_UP
        beq		t4,		t1,	    right_button
        #Set return value
        addi	v0,		zero,	BUTTON_DOWN
    
    ; Test right button
    right_button:
        srli	t2,		t0,		3
        andi	t2,		t2,		1
        bne		t1,		t2,		checkpoint_button
        # test if direction not left
        addi	t1,		zero,	DIR_LEFT
        beq		t4,		t1,	    checkpoint_button
        #Set return value
        addi	v0,		zero,	BUTTON_RIGHT

    ; Test checkpoint button
    checkpoint_button:
        srli	t2,		t0,		4
        andi	t2,		t2,		1
        bne		t1,		t2,		return
        addi	v0,		zero,	BUTTON_CHECKPOINT
    
    ; Return
    return:
        #Update new direction
        addi	t1,		zero,	BUTTON_CHECKPOINT
        beq		v0,		t1,		end
        addi	t1,		zero,	BUTTON_NONE
        beq		v0,		t1,		end
        stw		v0,		GSA(t3)
        
        end:
        #Reset edgecapture
        stw		zero,	BUTTONS+4(zero)
        ret

; END: get_input


; BEGIN: draw_array
draw_array:
    add	    t5,		zero,		zero
    addi	t3,		zero,		96
    add		t4,		zero,		ra
    

    loop_leds:
        #check if end of the array
        bge		t5,		t3,		    end_draw
        #Value of the current LED of the game
        slli	t6,		t5,		    2
        ldw		t1,		GSA(t6)
        addi	t5,		t5,		    1
        #If nothing in it, go to next led
        beq		t1,		zero,		loop_leds

        #Find the coordinates
        addi 	a1,		t5,		    -1
        andi	a1,		a1,		    7

        addi 	a0,		t5,		    -1
        srli	a0,		a0,		    3

        call	set_pixel
        br		loop_leds
    
    end_draw:
        jmp		t4

; END: draw_array


; BEGIN: move_snake
move_snake:

#Through X Head pos and Y head pos of snake, get snake's direction in GSA. Then do if statements: if dir = x => modify X_head & Y_HEAD accordingly
# Procedure  - - - -  - - - -  - - - -  - - - -  - - - -  - - - -  - - - - 
proc_retrieveDirectionWithCoordinates: # (X,Y) => (t3, t7). Output stored in t6
# Multiply X by 8
addi t0, zero, 0
addi t1, zero, 1
addi t2, zero, 9
conditionMultiplyBy8:
bne t1, t2, loopMultiplyBy8 # if compteur < 9 => loop

loopMultiplyBy8:
add t0, t0, t3  # X = t3
addi t1, t1, 1
br conditionMultiplyBy8

# Multiply 8X + Y by 4
multiplyBy4:
addi t4, zero, 0
addi t1, zero, 1
addi t2, zero, 5
add t5, t7, t0 #t5 = 8X + Y  # Y = t7

conditionMultiplyBy4:
bne t1, t2, loopMultiplyBy4 # if compteur < 5 => loop

loopMultiplyBy4:
add t4, t4, t5
addi t1,t1,1
br conditionMultiplyBy4

## Get direction's integer value corresponding to Snake's X_Head & Y_Head

ldw t6, GSA(t5)
ret 

### - - - - - - - - - -  Modify the Snake's HEAD - - - - - - - - - - ###

# Retrieve direction through procedure (stored in t6)
ldw t3, HEAD_X(zero)
ldw t7, HEAD_Y(zero)
call proc_retrieveDirectionWithCoordinates


# Modify HEAD_X and HEAD_Y coordinates through below proc

ldw t4, HEAD_X(zero)
ldw t5, HEAD_Y(zero)
call proc_modifyCoordinatesBasedOnDirection
stw t4, HEAD_X(zero)
stw t5, HEAD_Y(zero)

# Procedure  - - - -  - - - -  - - - -  - - - -  - - - -  - - - -  - - - - 
## Modify X_HEAD or Y_HEAD depending on the direction (through conditonal branching)
proc_modifyCoordinatesBasedOnDirection: ## /!\ (X,Y) => (t4,t5). Output : (t4, t5) 
addi t0, zero, 1 #Leftwards
addi t1, zero, 2 #Upwards
addi t2, zero, 3 #Downwards
addi t3, zero, 4 #Rightwards
addi t7, zero, 1 # Value 1 for substraction

beq t6, t0, leftCase # if direction is left => leftCase 
beq t6, t1, upCase  # if direction is up => upCase
beq t6, t2, downCase # ...
beq t6, t3, rightCase

leftCase:
sub t4, t4, t7 # X = X - 1 
upCase:
addi t5, t5, 1 # Y = Y + 1 
downCase:
sub t5, t5, t7 # Y = Y - 1
rightCase:
addi t5, t5, 1 # X = X + 1

ret 

### - - - - - - - - - -  Modify the Snake's TAIL - - - - - - - - - - ###

# Retrieve direction through procedure (stored in t6)
ldw t3, TAIL_X(zero)
ldw t7, TAIl_Y(zero)
call proc_retrieveDirectionWithCoordinates

# Modify TAIL_X and TAIL_Y through associated proc if no food is eaten (a0 = 0)

beq a0, zero, foodEatenCase

foodEatenCase:
ldw t4, TAIl_X(zero)
ldw t5, TAIL_Y(zero)
call proc_modifyCoordinatesBasedOnDirection
stw t4, TAIL_X(zero)
stw t5, TAIL_Y(zero)
ret 


ret

; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:

; END: restore_checkpoint


; BEGIN: blink_score
blink_score:

; END: blink_score
