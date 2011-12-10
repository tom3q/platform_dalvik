%verify "executed"
%include "armv6-vfp/fbinop.S" {"instr":"fdivs   s2, s0, s1"}
