%verify "executed"
%verify "null object"
%verify "class cast exception thrown, with correct class name"
%verify "class cast exception not thrown on same class"
%verify "class cast exception not thrown on subclass"
%verify "class not resolved"
%verify "class already resolved"
    /*
     * Check to see if an object reference is an instance of a class.
     *
     * Most common situation is a non-null object, being compared against
     * an already-resolved class.
     */
    /* instance-of/jumbo vBBBB, vCCCC, class@AAAAAAAA */
    movzwl  8(rPC),%eax                 # eax<- CCCC
    GET_VREG_R %eax %eax                # eax<- vCCCC (obj)
    movl    rSELF,%ecx
    testl   %eax,%eax                   # object null?
    movl    offThread_methodClassDex(%ecx),%ecx  # ecx<- pDvmDex
    SPILL(rIBASE)                       # preserve rIBASE
    je      .L${opcode}_store           # null obj, not instance, store it
    movl    2(rPC),rIBASE               # edx<- AAAAAAAA
    movl    offDvmDex_pResClasses(%ecx),%ecx # ecx<- pDvmDex->pResClasses
    movl    (%ecx,rIBASE,4),%ecx        # ecx<- resolved class
    movl    offObject_clazz(%eax),%eax  # eax<- obj->clazz
    testl   %ecx,%ecx                   # have we resolved this before?
    je      .L${opcode}_resolve         # not resolved, do it now
.L${opcode}_resolved:  # eax<- obj->clazz, ecx<- resolved class
    cmpl    %eax,%ecx                   # same class (trivial success)?
    je      .L${opcode}_trivial         # yes, trivial finish
    /*
     * Trivial test failed, need to perform full check.  This is common.
     *  eax holds obj->clazz
     *  ecx holds class resolved from BBBB
     *  rINST has BA
     */
    movl    %eax,OUT_ARG0(%esp)
    movl    %ecx,OUT_ARG1(%esp)
    call    dvmInstanceofNonTrivial     # eax<- boolean result
    # fall through to ${opcode}_store

    /*
     * eax holds boolean result
     * rINST holds BBBB
     */
.L${opcode}_store:
    FETCH_INST_OPCODE 5 %ecx
    UNSPILL(rIBASE)
    ADVANCE_PC 5
    SET_VREG %eax rINST                 # vBBBB<- eax
    GOTO_NEXT_R %ecx

    /*
     * Trivial test succeeded, save and bail.
     *  r9 holds BBBB
     */
.L${opcode}_trivial:
    FETCH_INST_OPCODE 5 %ecx
    UNSPILL(rIBASE)
    ADVANCE_PC 5
    movl    $$1,%eax
    SET_VREG %eax rINST                 # vBBBB<- true
    GOTO_NEXT_R %ecx

    /*
     * Resolution required.  This is the least-likely path.
     *
     *  edx holds AAAAAAAA
     */
.L${opcode}_resolve:
    movl    rIBASE,OUT_ARG1(%esp)       # arg1<- AAAAAAAA
    movl    rSELF,%ecx
    movl    offThread_method(%ecx),%ecx
    movl    $$1,OUT_ARG2(%esp)          # arg2<- true
    movl    offMethod_clazz(%ecx),%ecx  # ecx<- method->clazz
    EXPORT_PC
    movl    %ecx,OUT_ARG0(%esp)         # arg0<- method->clazz
    call    dvmResolveClass             # eax<- resolved ClassObject ptr
    testl   %eax,%eax                   # success?
    je      common_exceptionThrown      # no, handle exception
/* Now, we need to sync up with fast path.  We need eax to
 * hold the obj->clazz, and ecx to hold the resolved class
 */
    movl    %eax,%ecx                   # ecx<- resolved class
    movzwl  8(rPC),%eax                 # eax<- CCCC
    GET_VREG_R %eax %eax                # eax<- vCCCC (obj)
    movl    offObject_clazz(%eax),%eax  # eax<- obj->clazz
    jmp     .L${opcode}_resolved
