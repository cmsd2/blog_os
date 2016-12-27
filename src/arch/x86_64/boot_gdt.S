.section .text
.code32

.globl switch_to_gdt_long_mode
switch_to_gdt_long_mode:

    lgdt (gdt_pointer)
    mov $0x10, %ax
    mov %ax, %ss
    mov %ax, %ds
    mov %ax, %es

    jmp $0x08, $_long_mode_start

    movl $0x2f4b2f4f, (0xb8000)

    cli
    hlt


.section .rodata
gdt_pointer:
    .short (gdt64_end - gdt64 - 1)
    .int gdt64
.align 8
gdt64:
    .int 0, 0

    // code selector 0x8: base 0x0, limit 0x0, 64bit
    .byte 0x0, 0x0, 0, 0, 0, 0x9a, 0x20, 0x0

    // data selector 0x10: base 0x0, limit 0x0
    .byte 0x0, 0x0, 0, 0, 0, 0x92, 0x0, 0x0

gdt64_end:
