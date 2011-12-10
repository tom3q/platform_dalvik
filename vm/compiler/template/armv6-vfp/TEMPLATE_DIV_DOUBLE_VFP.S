%verify "executed"
%include "armv6-vfp/fbinopWide.S" {"instr":"fdivd   d2, d0, d1"}
