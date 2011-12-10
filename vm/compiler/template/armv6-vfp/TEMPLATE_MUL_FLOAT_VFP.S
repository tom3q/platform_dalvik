%verify "executed"
%include "armv6-vfp/fbinop.S" {"instr":"fmuls   s2, s0, s1"}
