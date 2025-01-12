.globl memset_aligned
memset_aligned:
  andi a3, a2, 3
  c.sub a2, a3
  packh a1, a1, a1
  packw a1, a1, a1
  c.beqz a3, 2f
1:
  c.sb a1, 0(a0)  # a3 = a2 % 4. We handle misalignment first
  c.addi a3, -1   # so that the rest of the loop is aligned.
  c.addi a0, 1    # This way, we adaptively handle the case where
  c.bnez a3, 1b   # __riscv_misaligned_avoid is defined.
2:
  c.beqz a2, 3f
  c.sw a1, 0(a0)
  c.addi a2, -4
  c.addi a0, 4
  c.bnez a2, 2b
3:
  ret

.globl memset_naive
memset_naive:
mv t1, a0
  beqz a2, 2f

1:
  sb a1, 0(t1)
  add   a2, a2, -1
  add   t1, t1, 1
  bnez a2, 1b

2:
  ret
