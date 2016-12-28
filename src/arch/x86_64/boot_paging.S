.section .text
.code32

.globl set_up_page_tables
set_up_page_tables:
    mov $p4_table, %eax
    or $3, %eax // present + writable
    mov %eax, (511 * 8) + p4_table

    // map first P4 entry to P3 table
    mov $p3_table, %eax
    or $3, %eax // present + writable
    mov %eax, (p4_table)

    // map first P3 entry to P2 table
    mov $p2_table, %eax
    or $3, %eax // present + writable
    mov %eax, (p3_table)

    mov $0, %ecx        // counter variable
    mov $p2_table, %edx
.map_p2_table:
    // map ecx-th P2 entry to a huge page that starts at address 2MiB*ecx
    mov $0x200000, %eax  // 2MiB
    mul %ecx             // start address of ecx-th page
    or $0x83, %eax // present + writable + huge
    mov %eax, p2_table(, %ecx, 8) // map ecx-th entry

    inc %ecx             // increase counter
    cmp $512, %ecx       // if counter == 512, the whole P2 table is mapped
    jne .map_p2_table    // else map the next entry

    ret


.globl enable_paging
enable_paging:
    // load P4 to cr3 register (cpu uses this to access the P4 table)
    mov $p4_table, %eax
    mov %eax, %cr3

    // enable PAE-flag in cr4 (Physical Address Extension)
    mov %cr4, %eax
    or $32, %eax
    mov %eax, %cr4

    // set the long mode bit in the EFER MSR (model specific register)
    mov $0xC0000080, %ecx
    rdmsr
    or $256, %eax
    wrmsr

    // enable paging in the cr0 register
    mov %cr0, %eax
    or $0x80000000, %eax
    mov %eax, %cr0

    ret



.section .bss

.align 4096
p4_table:
    .skip 4096
p3_table:
    .skip 4096
p2_table:
    .skip 4096

