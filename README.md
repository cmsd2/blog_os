# blogOS

This repository is derived from the code for the “Writing an OS in Rust” series at [os.phil-opp.com](http://os.phil-opp.com).

# License
The source code is dual-licensed under MIT or the Apache License (Version 2.0). This excludes the `posts` and `pages` directories.

# Dependencies

 1. x86_64-pc-elf toolchain: binutils and optionally gdb
 2. nightly rust
 3. xargo
 4. rust sources for xargo (`rustup component add rust-src`)
 5. grub-common: grub-mkrescue
 6. grub-pc-bin: /usr/lib/grub/i386-pc
 7. xorriso
