.section .text
.code32

// Check for SSE and enable it. If it's not supported throw error "a".
.globl set_up_sse
set_up_sse:
    // check for SSE
    mov $1, %eax
    cpuid
    test $0x2000000, %edx
    jz .no_sse

    // enable sse
    mov %cr0, %eax
    and $0xFFFB, %ax      // clear coprocessor emulation CR0.EM
    or $0x2, %ax          // set coprocessor monitoring  CR0.MP
    mov %eax, %cr0
    mov %cr4, %eax
    or $0x600, %ax        // set CR4.OSFXSR and CR4.OSXMMEXCPT at the same time
    mov %eax, %cr4

    ret
.no_sse:
    mov $0x61, %al
    jmp error

