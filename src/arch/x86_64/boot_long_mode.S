.section .text

.globl _long_mode_start
_long_mode_start:
    mov $0x2f592f412f4b2f4f, %rax
    mov %rax, (0xb8000)

    mov $0, %rdi
    movl (_multiboot_info_magic), %edi

    mov $0, %rsi
    movl (_multiboot_info_ptr), %esi

    call rust_main

.os_returned:
    // rust main returned, print `OS returned!`
    mov $0x4f724f204f534f4f, %rax
    mov %rax, (0xb8000)
    mov $0x4f724f754f744f65, %rax
    mov %rax, (0xb8008)
    mov $0x4f214f644f654f6e, %rax
    mov %rax, (0xb8010)

    cli
    hlt
