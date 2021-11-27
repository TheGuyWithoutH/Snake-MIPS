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
    # TODO: Finish this procedure.
    stw		zero,		CP_VALID(zero)
    jmpi    init_game
    

    main_loop:
        call		wait

        main_input:
            call		get_input

        checkpoint:
            addi    t0,     zero,       5
            bne     v0,     t0,         no_checkpoint
            call    restore_checkpoint
            beq     v0,     zero,       main_input
            br      led_blink


        no_checkpoint:
            call        hit_test

        no_food_eaten:
            addi    t0,     zero,       1
            add     a0,     zero,       v0
            beq     v0,     t0,         food_eaten
            bne     v0,     zero,       init_game
            call    move_snake     
            br      main_display

        food_eaten:
            ldw     t0,     SCORE(zero)
            addi    t0,     t0,       1
            stw     t0,     SCORE(zero)
            call    display_score
            call    move_snake
            call    create_food

            #call    save_checkpoint
            beq     v0,     zero,       main_display
        
        led_blink:
            call    blink_score



        main_display:
            call		clear_leds
            call		draw_array

        br          main_loop

    wait:
        addi		t0,		zero,		25000
        addi        t1,     zero,       75

        loop_wait:
            beq		t0,		zero,		change_loop
            addi	t0,		t0,		    -1
            br		loop_wait
        
        change_loop:
            beq		t1,		zero,		end_wait
            addi	t1,		t1,		    -1
            addi		t0,		zero,		25000
            br		loop_wait
        
        end_wait:
            ret

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

    ldw t1, SCORE(zero) #get the current score
    addi t4, zero, 0 # Counter dizaine

    addi t0, zero, 10
    blt t1, t0, multiply_by_4                

    inferior_to_100:
        addi t1, t1, -10                #On décrémente t1 de 10
        addi t4, t4, 1                  #On ajoute 1 au conteur des dizaines
        bge t1, t0, inferior_to_100     #Tant que c'est supérieur à 10, on continue
                                        #Si inférieur à 10, on passe à la suite, c'est réel

    multiply_by_4:
        slli t1, t1, 2
        slli t4, t4, 2
    
    ldw t1, digit_map(t1)
    ldw t4, digit_map(t4)
    ldw t0, digit_map(zero)

    stw t0, SEVEN_SEGS(zero)      # Initiliaze the first 7 seg at 0
    stw t0, SEVEN_SEGS+4(zero)      # Initiliaze the second 7 seg at 0
    stw t4, SEVEN_SEGS+8(zero)       # Set the third 7 seg
    stw t1, SEVEN_SEGS+12(zero)  # Set the 4th 7 seg

    ret


; END: display_score


; BEGIN: init_game
init_game:
    stw		zero,		HEAD_X(zero)
    stw		zero,		HEAD_Y(zero)
    stw		zero,		TAIL_X(zero)
    stw		zero,		TAIL_Y(zero)

    addi    t0,         zero,       384
    addi    t1,         zero,       0

    reset_GSA:
        bge		t1,		t0,		    init_GSA
        stw     zero,       GSA(t1)
        addi    t1,     t1,         4
        br      reset_GSA

    init_GSA:
        addi	t0,	        zero,		 DIR_RIGHT  
        stw		t0,		    GSA(zero)

    stw		zero,		SCORE(zero)

    call    create_food

    call		clear_leds
    call		draw_array

    jmpi    main_loop

; END: init_game


; BEGIN: create_food
create_food:
    valid_food_position_generation:
        ldw t3, RANDOM_NUM(zero) # Generate random num
        andi t4, t3, 0xFF       # Get first byte (lowest byte)
        addi t0, zero,  96
        bge		t4,		t0,		valid_food_position_generation
        blt     t4,     zero,   valid_food_position_generation
        slli	t4,		t4,		    2
        ldw t5, GSA(t4)         # Retrieve cell content at first byte's adress
        beq t5, zero, set_food_in_game       # If content == 0, we can set the food (no snake & food at this position)
        br valid_food_position_generation   # Else : we loop into the branch until we find a valid position

    set_food_in_game:
        addi t7, zero, 5
        stw t7, GSA(t4)     # Add 5 to the GSA at the randomly generated valid position. 5 means that there's if food

    ret    

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

    get_direction:
        ldw		t0,		HEAD_X(zero)
        ldw		t1,		HEAD_Y(zero)
        slli	t2,		t0,		    3
        add		t2,		t2,		    t1
        slli	t2,		t2,		    2
        ldw		t3,		GSA(t2)

    modify_snake_head_pos:

        leftCaseHead:
            addi t4, zero, DIR_LEFT     #Leftwards
            bne t3, t4,  upCaseHead   # if direction isn't left => exit leftCase 
            addi t0, t0, -1 # X = X - 1
            stw t0, HEAD_X(zero)
            addi	t2,		t2,		    -32   #Add Direction to new Head Cell
            stw		t3,		GSA(t2)
            br modify_snake_tail_pos

        upCaseHead:
            addi t4, zero, DIR_UP #Upwards
            bne t3, t4,  downCaseHead  # if direction isn't up => exit upCase 
            addi t1, t1, -1 # Y = Y - 1
            stw t1, HEAD_Y(zero)
            addi	t2,		t2,		    -4    #Add Direction to new Head Cell
            stw		t3,		GSA(t2)
            br modify_snake_tail_pos

        downCaseHead:
            addi t4, zero, DIR_DOWN #Downwards
            bne t3, t4,  rightCaseHead  # if direction isn't down => exit downCase 
            addi t1, t1, 1 # Y = Y + 1
            stw t1, HEAD_Y(zero)
            addi	t2,		t2,		    4     #Add Direction to new Head Cell
            stw		t3,		GSA(t2)
            br modify_snake_tail_pos

        rightCaseHead:
            addi t0, t0, 1 # X = X + 1
            stw t0, HEAD_X(zero)
            addi	t2,		t2,		    32    #Add Direction to new Head Cell
            stw		t3,		GSA(t2)
            br modify_snake_tail_pos
        
    modify_snake_tail_pos:
        bne a0, zero, endMove 
        
        #If food not eaten, we cut the snake's tail by one unit, according to the direction
        food_not_eaten_case:

            ldw		t0,		TAIL_X(zero)
            ldw		t1,		TAIL_Y(zero)
            slli	t2,		t0,		    3
            add		t2,		t2,		    t1
            slli	t2,		t2,		    2
            ldw		t3,		GSA(t2)
            stw     zero,   GSA(t2)

            LeftCaseTail:
                addi t4, zero, DIR_LEFT     #Leftwards
                bne t3, t4,  upCaseTail   # if direction isn't left => exit leftCase 
                addi t0, t0, -1 # X = X - 1
                stw t0, TAIL_X(zero)
                br endMove

            upCaseTail:
                addi t4, zero, DIR_UP #Upwards
                bne t3, t4,  downCaseTail  # if direction isn't up => exit upCase 
                addi t1, t1, -1 # Y = Y + 1
                stw t1, TAIL_Y(zero)
                br endMove

            downCaseTail:
                addi t4, zero, DIR_DOWN #Downwards
                bne t3, t4,  rightCaseTail  # if direction isn't down => exit downCase 
                addi t1, t1, 1 # Y = Y - 1
                stw t1, TAIL_Y(zero)
                br endMove

            rightCaseTail:
                addi t0, t0, 1 # X = X + 1
                stw t0, TAIL_X(zero)
                br endMove


    endMove:
        ret
        
; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:

    addi t0, zero, 10
    ldw t1, SCORE(zero)

    blt t1, t0, check_multiple_10 #Si inférieur à 10, on check direct si c'est un multiple de 10

    modulo_10_loop:
        addi t1, t1, -10                #On décrémente t1 de 10
        bge t1, t0, modulo_10_loop     #Tant que c'est supérieur à 10, on continue

    check_multiple_10:
        beq t1, zero, copy_into_CP         # Multiple 10 => On copie

    addi v0, zero, 0                        #Sinon, on set v0 à 0
    br end_save

    copy_into_CP:
        addi v0, zero, 1
        stw v0, CP_VALID(zero)


        ldw t0, HEAD_X(zero)
        stw t0, CP_HEAD_X(zero)

        ldw t0, HEAD_Y(zero)
        stw t0, CP_HEAD_Y(zero)
        
        ldw t0, TAIL_X(zero)
        stw t0, CP_TAIL_X(zero)

        ldw t0, TAIL_Y(zero)
        stw t0, CP_TAIL_Y(zero)

        ldw t0, SCORE(zero)
        stw t0, CP_SCORE(zero)

        copy_GSA:
            addi t0, zero, 0
            addi t3, zero, 96
            96_loop:
                slli t2, t0, 2
                ldw t1, GSA(t2)
                stw t1, CP_GSA(t2)

                addi t0, t0, 1
                blt t0, t3, 96_loop    
    end_save:
        ret

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:

    addi t0, zero, 1
    ldw t1, CP_VALID(zero)
    beq t1, t0, restore

    addi v0, zero, 0
    br end_restore

    restore:
        addi v0, zero, 1

        ldw t0, CP_HEAD_X(zero)
        stw t0, HEAD_X(zero)

        ldw t0, CP_HEAD_Y(zero)
        stw t0, HEAD_Y(zero)
        
        ldw t0, CP_TAIL_X(zero)
        stw t0, TAIL_X(zero)

        ldw t0, CP_TAIL_Y(zero)
        stw t0, TAIL_Y(zero)

        ldw t0, CP_SCORE(zero)
        stw t0, SCORE(zero)

        restore_GSA:
            addi t0, zero, 0
            addi t3, zero, 96
            96_loop_v2:
                slli t2, t0, 2
                ldw t1, CP_GSA(t2)
                stw t1, GSA(t2)

                addi t0, t0, 1
                blt t0, t3, 96_loop_v2  
    
    end_restore:
        ret

; END: restore_checkpoint


; BEGIN: blink_score
blink_score:
    addi    t5,     zero, 5 # Blinking 5 times 
    add     t6,     zero,       ra

    blinking_loop:

        clear_7segs:
            stw zero, SEVEN_SEGS(zero)
            stw zero, SEVEN_SEGS+4(zero)
            stw zero, SEVEN_SEGS+8(zero) 
            stw zero, SEVEN_SEGS+12(zero)

        call    wait
        call    display_score
        call    wait
        addi t5, t5, -1
        bge t5, zero, blinking_loop

    jmp		t6

; END: blink_score

digit_map:
.word 0xFC ; 0
.word 0x60 ; 1
.word 0xDA ; 2
.word 0xF2 ; 3
.word 0x66 ; 4
.word 0xB6 ; 5
.word 0xBE ; 6
.word 0xE0 ; 7
.word 0xFE ; 8
.word 0xF6 ; 9
