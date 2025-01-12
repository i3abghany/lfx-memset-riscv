.globl memset_aligned
memset_aligned:
  andi a3, a2, 3
  c.sub a2, a3
  packh a1, a1, a1
  packw a1, a1, a1
  c.beqz a3, 2f
1:
  c.sb a1, 0(a0)
  c.addi a3, -1
  c.addi a0, 1
  c.bnez a3, 1b
2:
  c.beqz a2, 3f
  c.sw a1, 0(a0)
  c.addi a2, -4
  c.addi a0, 4
  c.bnez a2, 2b
3:
  ret