# Ho va ten : Pham Nang Tu
# MSSV      : 25522003
# Lop       : CE119.R11.VMTN.1
# Bai tap   : CE119 - Lab 02

.data
# Du lieu TN2 va Phan mo rong (MSSV d=3)
scores:     .word 9, 6, 0, 1, 5, 8, 10, 5, 9, 1, 7, 6
grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
            .align 2
hist:       .word 0, 0, 0, 0

s_min:      .asciiz "min="
s_max:      .asciiz " max="
s_g0:       .asciiz "g0="
s_g1:       .asciiz " g1="
s_g2:       .asciiz " g2="
s_g3:       .asciiz " g3="
s_nl:       .asciiz "\n"
str_g:      .asciiz "g"
str_colon:  .asciiz ": "

# Du lieu TN3 (Chuoi ca nhan P voi k=6)
str_P:      .asciiz "([{([{}]}])"
s_tn3_msg:  .asciiz "Kiem tra chuoi P: ($v0, $v1) = ("
s_comma:    .asciiz ", "
s_close:    .asciiz ")\n"

.text
main:
    # ------------------ 1. THUC HIEN TN2 ------------------
    la   $s0, scores
    li   $s1, 12
    la   $s2, grade_tab
    la   $s3, hist

    # Goi stats
    move $a0, $s0
    move $a1, $s1
    jal  stats
    move $s4, $v0           # min
    move $s5, $v1           # max

    # Goi histogram
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $s3
    jal  histogram

    # In min, max
    li   $v0, 4
    la   $a0, s_min
    syscall
    li   $v0, 1
    move $a0, $s4
    syscall
    li   $v0, 4
    la   $a0, s_max
    syscall
    li   $v0, 1
    move $a0, $s5
    syscall
    li   $v0, 4
    la   $a0, s_nl
    syscall

    # In g0, g1, g2, g3
    li   $v0, 4
    la   $a0, s_g0
    syscall
    li   $v0, 1
    lw   $a0, 0($s3)
    syscall
    li   $v0, 4
    la   $a0, s_g1
    syscall
    li   $v0, 1
    lw   $a0, 4($s3)
    syscall
    li   $v0, 4
    la   $a0, s_g2
    syscall
    li   $v0, 1
    lw   $a0, 8($s3)
    syscall
    li   $v0, 4
    la   $a0, s_g3
    syscall
    li   $v0, 1
    lw   $a0, 12($s3)
    syscall
    li   $v0, 4
    la   $a0, s_nl
    syscall

    # ------------------ 2. PHAN MO RONG ------------------
    move $a0, $s3
    li   $a1, 4
    jal  draw_hist

    # ------------------ 3. THUC HIEN TN3 ------------------
    la   $a0, str_P
    jal  check_brackets
    move $s6, $v0           # vi tri
    move $s7, $v1           # ma loi

    li   $v0, 4
    la   $a0, s_tn3_msg
    syscall
    li   $v0, 1
    move $a0, $s6
    syscall
    li   $v0, 4
    la   $a0, s_comma
    syscall
    li   $v0, 1
    move $a0, $s7
    syscall
    li   $v0, 4
    la   $a0, s_close
    syscall

    # Ket thuc chuong trinh an toan
    li   $v0, 10
    syscall

# stats: tim min va max cua mang word
# Tham so : $a0 = dia chi mang, $a1 = so phan tu n
# Tra ve  : $v0 = min, $v1 = max
# Su dung : $t0, $t1
stats:
    lw   $v0, 0($a0)
    move $v1, $v0
    addi $a0, $a0, 4
    addi $a1, $a1, -1
st_loop:
    beq  $a1, $zero, st_done
    lw   $t0, 0($a0)
    slt  $t1, $t0, $v0
    beq  $t1, $zero, st_chkmax
    move $v0, $t0
st_chkmax:
    slt  $t1, $v1, $t0
    beq  $t1, $zero, st_next
    move $v1, $t0
st_next:
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    st_loop
st_done:
    jr   $ra

# histogram: dem so sinh vien moi nhom
# Tham so : $a0 = scores, $a1 = n, $a2 = grade_tab, $a3 = hist
# Tra ve  : khong co
# Su dung : $t0, $t1, $t2, $t3, $t4
histogram:
hg_loop:
    beq  $a1, $zero, hg_done
    lw   $t0, 0($a0)
    addu $t1, $a2, $t0
    lbu  $t2, 0($t1)
    sll  $t2, $t2, 2
    addu $t3, $a3, $t2
    lw   $t4, 0($t3)
    addi $t4, $t4, 1
    sw   $t4, 0($t3)
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    hg_loop
hg_done:
    jr   $ra

# draw_hist: ve pho diem bang ky tu |
# Tham so : $a0 = hist, $a1 = so nhom
# Tra ve  : in bieu do ra console
# Su dung : $t0, $t1, $t2, $t3, $t4
draw_hist:
    move $t0, $a0
    move $t1, $a1
    li   $t2, 0
dh_group_loop:
    beq  $t1, $zero, dh_done
    li   $v0, 4
    la   $a0, str_g
    syscall
    li   $v0, 1
    move $a0, $t2
    syscall
    li   $v0, 4
    la   $a0, str_colon
    syscall

    lw   $t3, 0($t0)
    li   $t4, 0
dh_bar_loop:
    beq  $t4, $t3, dh_bar_done
    li   $v0, 11
    li   $a0, 124           # ky tu '|'
    syscall
    addi $t4, $t4, 1
    j    dh_bar_loop
dh_bar_done:
    li   $v0, 11
    li   $a0, 10            # xuong dong '\n'
    syscall

    addi $t0, $t0, 4
    addi $t2, $t2, 1
    addi $t1, $t1, -1
    j    dh_group_loop
dh_done:
    jr   $ra

# check_brackets: kiem tra ngoac can bang bang stack
# Tham so : $a0 = dia chi chuoi .asciiz
# Tra ve  : $v0 = vi tri, $v1 = ma loi
# Su dung : $t0, $t1, $t2, $t3, $t4, $t5, $t9
check_brackets:
    move $t9, $sp
    move $t0, $a0
    li   $t1, 0
cb_loop:
    lb   $t2, 0($t0)
    beq  $t2, $zero, cb_eos
    addi $t1, $t1, 1
    addi $t0, $t0, 1

    li   $t3, 40            # '('
    beq  $t2, $t3, cb_push
    li   $t3, 91            # '['
    beq  $t2, $t3, cb_push
    li   $t3, 123           # '{'
    beq  $t2, $t3, cb_push

    li   $t3, 41            # ')'
    beq  $t2, $t3, cb_chk_close
    li   $t3, 93            # ']'
    beq  $t2, $t3, cb_chk_close
    li   $t3, 125           # '}'
    beq  $t2, $t3, cb_chk_close

    j    cb_loop

cb_push:
    addi $sp, $sp, -4
    sw   $t2, 0($sp)
    j    cb_loop

cb_chk_close:
    beq  $sp, $t9, cb_err_empty
    lw   $t4, 0($sp)
    addi $sp, $sp, 4

    li   $t3, 41
    bne  $t2, $t3, cb_try_bracket
    li   $t5, 40
    bne  $t4, $t5, cb_err_mismatch
    j    cb_loop
cb_try_bracket:
    li   $t3, 93
    bne  $t2, $t3, cb_try_brace
    li   $t5, 91
    bne  $t4, $t5, cb_err_mismatch
    j    cb_loop
cb_try_brace:
    li   $t5, 123
    bne  $t4, $t5, cb_err_mismatch
    j    cb_loop

cb_err_mismatch:
    move $v0, $t1
    li   $v1, 1
    move $sp, $t9
    jr   $ra
cb_err_empty:
    move $v0, $t1
    li   $v1, 2
    move $sp, $t9
    jr   $ra
cb_eos:
    bne  $sp, $t9, cb_err_unclosed
    li   $v0, 0
    li   $v1, 0
    move $sp, $t9
    jr   $ra
cb_err_unclosed:
    addi $v0, $t1, 1
    li   $v1, 3
    move $sp, $t9
    jr   $ra