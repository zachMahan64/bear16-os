# UTIL_MEM_MANAGER.ASM (WIP)
.text
.const TOP_OF_HEAP_PTR = 6656
.const STARTING_HEAP_PTR_VALUE = 16384
.const FREE_LIST_HEAD_LOC = 6558

.const NULL = 0

util_init_free_list:
    lea t0, FREE_LIST_HEAD_LOC
    sw t0, NULL
    ret

# HEAP ALLOCATION FUNCTIONS
util_malloc: # zeroes memory
    #LINKED FREE LIST WIP, NONSPLITTING/COALESCING
    # reserves a0 + 2 bytes and then store size in the base & return the ptr just above the base
    # a0 = num bytes
    call util_malloc_traverse_free_list # reuse a0
    lt util_malloc_bump_top_of_heap, rv, 16384 # free list corruption -> do our best to not break everything
    ne util_malloc_hit_in_free_list, rv, 0 # return & reuse rv since it already points to the valid mem addr found in free list
    #------BRANCH DIVIDE------#
    util_malloc_bump_top_of_heap:
    lw t0, TOP_OF_HEAP_PTR # <-- nothing suitable found in free list
    sw t0, a0 # save size to base of the allocated mem
    add t0, t0, 2 # move store ptr (t0) forward
    util_malloc_hit_in_free_list_exit:
    mov rv, t0 # base of the allocated memory + 2, where the allocated mem data starts -> return this!
    add t1, t0, a0 # end loop val / new top of heap value
    util_malloc_loop:
        sb t0, 0 # write zero/clear memory
        inc t0 # inc store location
        ult util_malloc_loop, t0, t1
    lea t2, TOP_OF_HEAP_PTR
    sw t2, t1 # store new top of heap value
    ret
    util_malloc_hit_in_free_list:
        mov t0, rv # getting ptr from free list
        add t0, t0, 2 # move store ptr (t0) forward
        jmp util_malloc_hit_in_free_list_exit
    util_malloc_traverse_free_list:
        # block layout:
        #   [curr    ] = size
        #   [curr + 2] = data
        # a0 = desired size
        lea t0, FREE_LIST_HEAD_LOC
        # t0 = head* = curr* = = &first
        mov t4, NULL # prev*
        util_malloc_traverse_free_list_loop:
        lw t1, t0 # get curr*
        eq ret_null, t1, NULL
        lw t2, t1 # get *curr (*curr = curr.size)
        ge util_malloc_traverse_free_list_suitable_size_found, t2, a0 # hit if curr.size >= desired size
        add t3, t1, 2 # move t3 to view curr->next
        lw t0, t3 # load addr of curr->next into t0
        mov t4, t1 # set prev* = this curr*
        ne util_malloc_traverse_free_list_loop, t0, NULL # loop if curr != NULL
        ret_null:
        mov rv, 0 # else return NULL
        ret
        util_malloc_traverse_free_list_suitable_size_found:
            # remove from list and patch hole
            # return ptr to free block
            mov rv, t1 # return curr
                #add t3, t2, 2 # move t3 to view curr->next
            lw t0, t3 # load addr of curr->next into t0

            eq patch_head, t4, NULL

            add t5, t4, 2 # get [prev + 2] = prev->next
            sw t5, t0 # store curr-> next into prev->next

            patch_head_exit:
            ret
        patch_head:
            lea t6, FREE_LIST_HEAD_LOC
            sw t6, t0         # new head = curr->next
            jmp patch_head_exit

util_free: # WIP, BUILD W/ LINKED FREE LIST (NO SORTING OR COALESENCE YET)
    # a0 = pointer to memory data (from a malloc return)
    # block layout:
    #   [a0 - 2] = size
    #   [a0    ] = data
    # we insert [a0 - 2] into free list
    # LINK STRUCT: {WORD: SIZE, WORD: NEXT*}
    sub t0, a0, 2               # t0 = start of block (where header begins)
    lw t1, FREE_LIST_HEAD_LOC   # t1 = old head of free list
    sw t0, 2, t1                # store old head into new block’s NEXT*
    lea t2, FREE_LIST_HEAD_LOC
    sw t2, t0                   # set free list head to this block
    ret

util_ralloc: # zeros memory
    # !!! REGION ALLOC, does not adjust TOP_OF_HEAP_PTR -> this function is dangerous altough useful in priveledged...
    # ...memory space
    # a0 = ptr to start of region
    # a1 = size/num bytes
    # ~ no rv becuz it would be the same as a0 (ptr to start is already known)
    lw t0, a0
    add t1, t0, a1 # end loop val
    util_ralloc_loop:
        sb t0, 0 # write zero/clear memory
        inc t0 # inc store location
        ult util_ralloc_loop, t0, t1
    ret
#STACK ALLOCATION -> inline when possible, but these may be useful
util_salloc:
    # a0 = num bytes to allocate on stack
    # a1 = jmp ret address
    sub sp, sp, a0
    jmp a1
util_sallocz:
    # a0 = num bytes to allocate on stack
    # ~ don't return anything, use fp for referencing local vars
    # jump w/ jal and return w/ retl
    mov t0, sp # t0 = end
    sub sp, sp, a0
    mov t1, sp # start, counter, & ptr
    util_sallocz_loop:
        sb t1, 0 # clear memory
        inc t1
        ult util_sallocz_loop, t1, t0
    retl

# HELPER/BASICS
util_get_top_of_heap_ptr:
    lw t0, TOP_OF_HEAP_PTR
    mov rv, t0
    ret


