KERNEL_LMA = 0x100000;
KERNEL_VMA = 0xC0000000;

ENTRY(_start)

SECTIONS {
    . = KERNEL_LMA;

    .rodata : ALIGN(4K)
    {
        _rodata = .;
        KEEP(*(.multiboot2_header))
        KEEP(*(.multiboot_header))
        *(.rodata .rodata.*)
    }

    .text : ALIGN(4K)
    {
        _code = .;
        *(.text .text.*)
    }

    .data : ALIGN(4K)
    {
        _data = .;
        *(.data .data.*)
    }

    .bss : ALIGN(4K)
    {
        _bss = .;
        *(COMMON)
        *(.bss .bss.*)
    }

    .gcc_except_table : ALIGN(4K) 
    {
        *(.gcc_except_table)
    }

    .got : ALIGN(4K)
    {
        *(.got*)
    }

    .debug : ALIGN(4K)
    {
        *(.debug*)
    }
}
