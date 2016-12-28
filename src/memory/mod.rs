// Copyright 2015 Philipp Oppermann. See the README.md
// file at the top-level directory of this distribution.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

pub use self::area_frame_allocator::AreaFrameAllocator;
pub use self::paging::remap_the_kernel;
use self::paging::PhysicalAddress;
use multiboot2::BootInformation;

mod area_frame_allocator;
mod paging;

pub const PAGE_SIZE: usize = 4096;

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct Frame {
    number: usize,
}

impl Frame {
    fn containing_address(address: usize) -> Frame {
        Frame { number: address / PAGE_SIZE }
    }

    fn start_address(&self) -> PhysicalAddress {
        self.number * PAGE_SIZE
    }

    fn clone(&self) -> Frame {
        Frame { number: self.number }
    }
}

pub trait FrameAllocator {
    fn allocate_frame(&mut self) -> Option<Frame>;
    fn deallocate_frame(&mut self, frame: Frame);
}

pub fn init(boot_info: &BootInformation) {
    assert_has_not_been_called!("memory::init must only be called once");

    let memory_map_tag = boot_info.memory_map_tag()
        .expect("Memory map tag required");

    let elf_sections_tag = boot_info.elf_sections_tag()
        .expect("Elf-sections tag required");

    let kernel_start = elf_sections_tag.sections()
        .filter(|s| s.is_allocated())
        .map(|s| s.addr)
        .min().unwrap();
    let kernel_end = elf_sections_tag.sections()
        .filter(|s| s.is_allocated())
        .map(|s| s.addr + s.size)
        .max().unwrap();

    println!("kernel_start: {:#x}, kernel_end: {:#x}", 
        kernel_start, 
        kernel_end);

    println!("multiboot_start: {:#x}, multiboot_end: {:#x}", 
        boot_info.start_address(), 
        boot_info.end_address());

    println!("memory areas:");
    for area in memory_map_tag.memory_areas() {
        println!("    start: {:#x}, length: {:#x}", area.base_addr, area.length);
    }

    println!("kernel sections:");
    for section in elf_sections_tag.sections() {
        println!("    addr: {:#x}, size: {:#x}, flags: {:#x}",
            section.addr, section.size, section.flags);
    }

    let mut frame_allocator = AreaFrameAllocator::new(
        kernel_start as usize, kernel_end as usize, 
        boot_info.start_address(), boot_info.end_address(),
        memory_map_tag.memory_areas());

    let mut active_table = remap_the_kernel(&mut frame_allocator, boot_info);

    use self::paging::Page;
    use bump_allocator::{HEAP_START, HEAP_SIZE};

    let heap_start_page = Page::containing_address(HEAP_START);
    let heap_end_page = Page::containing_address(HEAP_START + HEAP_SIZE - 1);

    for page in Page::range_inclusive(heap_start_page, heap_end_page) {
        active_table.map(page, paging::WRITABLE, &mut frame_allocator);
    }
}

