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

; END: init_game


; BEGIN: create_food
create_food:

; END: create_food


; BEGIN: hit_test
hit_test:

; END: hit_test


; BEGIN: get_input
get_input:
    ldw		t0,		BUTTONS+4(zero)
    andi	t0,		t0,		    31
    addi	t1,		zero,	    1
    
    ; Test no button
    no_button:
        bne		t0,		zero,	left_button
        addi	v0,		zero,	BUTTON_NONE
    
    ; Test left button
    left_button:
        andi	t2,		t0,		1
        bne		t1,		t2,		up_button
        addi	v0,		zero,	BUTTON_LEFT
    
    ; Test up button
    up_button:
        srli	t2,		t0,		1
        andi	t2,		t2,		1
        bne		t1,		t2,		down_button
        addi	v0,		zero,	BUTTON_UP
    
    ; Test down button
    down_button:
        srli	t2,		t0,		2
        andi	t2,		t2,		1
        bne		t1,		t2,		right_button
        addi	v0,		zero,	BUTTON_DOWN
    
    ; Test right button
    right_button:
        srli	t2,		t0,		3
        andi	t2,		t2,		1
        bne		t1,		t2,		checkpoint_button
        addi	v0,		zero,	BUTTON_RIGHT

    ; Test checkpoint button
    checkpoint_button:
        srli	t2,		t0,		4
        andi	t2,		t2,		1
        bne		t1,		t2,		return
        addi	v0,		zero,	BUTTON_CHECKPOINT
    
    ; Return
    return:
        ret
       

; END: get_input


; BEGIN: draw_array
draw_array:

; END: draw_array


; BEGIN: move_snake
move_snake:

#Through X Head pos and Y head pos of snake, get snake's direction in GSA.
# Procedure  - - - -  - - - -  - - - -  - - - -  - - - -  - - - -  - - - - 
proc_retrieveDirectionWithCoordinates: # (X,Y) => (t3, t7). Output stored in t6
# Multiply X by 8
procedure 
addi t0, zero, 0
addi t1, zero, 1
addi t2, zero, 9
conditionMultiplyBy8:
blt t1, t2, loopMultiplyBy8 # if compteur < 9 => loop

loopMultiplyBy8:
add t0, t0, t3  # X = t3
addi t1, t1, 1
br conditionMultiplyBy8

# Multiply 8X + Y by 4
multiplyBy4:
addi t4, zero, 0
addi t1, zero, 1
addi t2, zero 5
add t5, t7, t0 #t5 = 8X + Y  # Y = t7

conditionMultiplyBy4:
blt t1, t2, loopMultiplyBy4 # if compteur < 5 => loop

loopMultiplyBy4:
add t4, t4, t5
addi t1,t1,1
br conditionMultiplyBy4

## Get direction's integer value corresponding to Snake's X_Head & Y_Head

stw t6, GSA(t5)
ret 

### - - - - - - - - - -  Modify the Snake's HEAD - - - - - - - - - - ###

# Retrieve direction through procedure (stored in t6)
stw t3, HEAD_X
stw t7, HEAD_Y
call proc_retrieveDirectionWithCoordinates


# Modify HEAD_X and HEAD_Y coordinates through below proc

stw t4, HEAD_X
stw t5, HEAD_Y
call proc_modifyCoordinatesBasedOnDirection
stw HEAD_X, t4
stw HEAD_Y, t5

# Procedure  - - - -  - - - -  - - - -  - - - -  - - - -  - - - -  - - - - 
## Modify X_HEAD or Y_HEAD depending on the direction (through conditonal branching)
proc_modifyCoordinatesBasedOnDirection: ## /!\ (X,Y) => (t4,t5). Output : (t4, t5) 
addi t0, zero, 1 #Leftwards
addi t1, zero, 2 #Upwards
addi t2, zero, 3 #Downwards
addi t3, zero, 4 #Rightwards

beq t6, t0, leftCase # if direction is left => leftCase 
beq t6, t1, upCase  # if direction is up => upCase
beq t6, t2, downCase # ...
beq t6, t3, rightCase

leftCase:
subi t4, t4, 1 # X = X - 1 
upCase:
addi t5, t5, 1 # Y = Y + 1 
downCase:
subi t5, t5, 1 # Y = Y - 1
rightCase:
addi t5, t5, 1 # X = X + 1

ret 

### - - - - - - - - - -  Modify the Snake's TAIL - - - - - - - - - - ###

# Retrieve direction through procedure (stored in t6)
stw t3, TAIL_X
stw t7, TAIl_Y
call proc_retrieveDirectionWithCoordinates

# Modify TAIL_X and TAIL_Y through associated proc if no food is eaten (a0 = 0)

beq a0, zero, foodEatenCase

foodEatenCase:
stw t4, TAIl_X
stw t5, TAIL_Y
call proc_modifyCoordinatesBasedOnDirection
stw TAIl_X, t4
stw TAIL_Y, t5
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
