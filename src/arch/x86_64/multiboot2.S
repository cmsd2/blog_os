.section .multiboot2_header
.code32

header_start:
    .int 0xe85250d6                // magic number (multiboot 2)
    .int 0                         // architecture 0 (protected mode i386)
    .int header_end - header_start // header length
    // checksum
    .int 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))
    //.int -(0xe85250d6 + 0 + (header_end - header_start))

    // insert optional multiboot tags here

    // required end tag
    .int 0    // type
    .int 0    // flags
    .int 8    // size
header_end:

