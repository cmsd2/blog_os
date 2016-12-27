.section .text
.code32

.globl save_multiboot_info
save_multiboot_info:
    mov %eax, (_multiboot_info_magic)
    mov %ebx, (_multiboot_info_ptr)
    ret


.globl check_cpuid
check_cpuid:
    pushf                // Store the FLAGS-register.
    pop %eax             // Restore the A-register.
    mov %eax, %ecx       // Set the C-register to the A-register.
    xor $0x200000, %eax  // Flip the ID-bit, which is bit 21.
    push %eax            // Store the A-register.
    popf                 // Restore the FLAGS-register.
    pushf                // Store the FLAGS-register.
    pop %eax             // Restore the A-register.
    push %ecx            // Store the C-register.
    popf                 // Restore the FLAGS-register.
    xor %ecx, %eax       // Do a XOR-operation on the A-register and the C-register.
    jz .no_cpuid         // The zero flag is set, no CPUID.
    ret                  // CPUID is available for use.
.no_cpuid:
    mov $0x31, %al
    jmp error


.globl check_long_mode
check_long_mode:
    mov $0x80000000, %eax   // Set the A-register to 0x80000000.
    cpuid                   // CPU identification.
    cmp $0x80000001, %eax   // Compare the A-register with 0x80000001.
    jb .no_long_mode        // It is less, there is no long mode.
    mov 0x80000001, %eax    // Set the A-register to 0x80000001.
    cpuid                   // CPU identification.
    test $0x20000000, %edx  // Test if the LM-bit is set in the D-register.
    jz .no_long_mode        // They aren't, there is no long mode.
    ret
.no_long_mode:
    mov $0x32, %al
    jmp error


.globl error
error:
    movl $0x4f524f45, (0xb8000)
    movl $0x4f3a4f52, (0xb8004)
    movl $0x4f204f20, (0xb8008)
    mov %al, (0xb800a)
    hlt

.section .bss

.globl _multiboot_info_magic
_multiboot_info_magic:
.int 0

.globl _multiboot_info_ptr
_multiboot_info_ptr:
.int 0


