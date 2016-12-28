// Copyright 2015 Philipp Oppermann. See the README.md
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#![feature(lang_items)]
#![feature(const_fn, unique)]
#![feature(step_by)]
#![feature(alloc)]
#![feature(collections)]
#![no_std]

extern crate rlibc;
extern crate spin;
extern crate multiboot2;
#[macro_use]
extern crate bitflags;
extern crate x86;
extern crate bump_allocator;
extern crate alloc;
#[macro_use]
extern crate collections;
#[macro_use]
extern crate once;

#[macro_use]
mod vga_buffer;
mod memory;

use vga_buffer::*;
use core::fmt::Write;
use memory::*;

#[no_mangle]
pub extern fn rust_main(multiboot_magic: usize, multiboot_info: usize) {
    vga_buffer::clear_screen();

    println!("Hello World{}", "!");

    println!("Multiboot magic number was {:x}", multiboot_magic);
    if multiboot_magic == 0x2badb002 {
        panic!("Multiboot1 not currently supported");
    }

    let boot_info = unsafe{ multiboot2::load(multiboot_info) };

    enable_nxe_bit();
    enable_write_protect_bit();

    memory::init(boot_info);

    println!("still dancing");

    loop{}
}

fn enable_nxe_bit() {
    use x86::msr::{IA32_EFER, rdmsr, wrmsr};

    let nxe_bit = 1 << 11;
    unsafe {
        let efer = rdmsr(IA32_EFER);
        wrmsr(IA32_EFER, efer | nxe_bit);
    }
}

fn enable_write_protect_bit() {
    use x86::controlregs::{cr0, cr0_write};

    let wp_bit = 1 << 16;
    unsafe { cr0_write(cr0() | wp_bit) };
}

#[cfg(not(test))]
#[lang = "eh_personality"]
extern "C" fn eh_personality() {}

#[cfg(not(test))]
#[lang = "panic_fmt"]
#[no_mangle]
#[allow(private_no_mangle_fns)]
extern "C" fn panic_fmt(fmt: core::fmt::Arguments, file: &str, line: u32) -> ! {
    println!("\n\nPANIC in {} at line {}:", file, line);
    println!("    {}", fmt);
    loop {}
}

#[allow(non_snake_case)]
#[no_mangle]
pub extern "C" fn _Unwind_Resume() -> ! {
    loop {}
}
