.section .text
.code32

.globl _start
_start:
    mov $stack_top, %esp

    call save_multiboot_info
    call check_cpuid
    call check_long_mode

    call set_up_sse
    call set_up_page_tables
    call enable_paging

    jmp switch_to_gdt_long_mode


.section .bss

stack_bottom:
.skip 4096 # bytes
.skip 4096 # bytes
stack_top:


