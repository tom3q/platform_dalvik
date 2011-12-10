%verify "executed"
%include "armv6-vfp/fbinop.S" {"instr":"fadds   s2, s0, s1"}
