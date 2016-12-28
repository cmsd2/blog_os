arch := x86_64
triple := ${arch}-pc-elf-
kernel := build/kernel-$(arch).bin
iso := build/os-$(arch).iso
target ?= $(arch)-unknown-linux-gnu
rust_os := target/$(target)/debug/libblog_os.a

AS := ${triple}as
CC := ${triple}gcc
LD := ${triple}ld
NASM := nasm
ASFLAGS += -g
CFLAGS += -Wall -D_KERNEL -g -O0
GCCFLAGS += -nostdlib -ffreestanding
GCCLDFLAGS += -Wl,-n -Wl,--gc-sections -g -O0
LDFLAGS += -n --gc-sections 
#LIBS += -lgcc
NASMFLAGS += -felf64

linker_script := src/arch/$(arch)/linker.ld
grub_cfg := src/arch/$(arch)/grub.cfg
gas_source_files := $(wildcard src/arch/$(arch)/*.S)
nasm_source_files := $(wildcard src/arch/$(arch)/*.asm)
c_source_files := $(wildcard src/arch/$(arch)/*.c)

nasm_object_files = $(patsubst src/%, build/%, $(nasm_source_files:%.asm=%.o))
gas_object_files = $(patsubst src/%, build/%, $(gas_source_files:%.S=%.o))
c_object_files = $(patsubst src/%, build/%, $(c_source_files:%.c=%.o))

#object_files += $(patsubst src/%, build/%, $(nasm_object_files))
#object_files += $(patsubst src/%, build/%, $(gas_object_files))
#object_files += $(patsubst src/%, build/%, $(c_object_files))

object_files += $(nasm_object_files)
object_files += $(gas_object_files)
object_files += $(c_object_files)


.PHONY: all clean run iso debug cargo

.SUFFIXES: .S

all: $(kernel)


cargo:
	cargo rustc --target $(target) -- -C no-redzone

print-%:
	@echo '$*=$($*)'

clean:
	@rm -r build

run: $(iso)
	qemu-system-x86_64 -cpu qemu64 -no-reboot -no-shutdown -d cpu_reset,guest_errors,int -cdrom $(iso)

debug: $(iso)
	qemu-system-x86_64 -s -S -cpu core2duo -no-reboot -no-shutdown -d cpu_reset,guest_errors -cdrom $(iso)

iso: $(iso)

$(iso)-isolinux: $(kernel) iso/boot/isolinux/isolinux.cfg
	cp -R iso build/
	cp $(kernel) build/iso/boot/kernel.bin

	xorriso -as mkisofs -o $(iso) -b boot/isolinux/isolinux.bin -c boot/isolinux/isolinux.cat -no-emul-boot -boot-load-size 4 -boot-info-table build/iso/

$(iso): $(kernel) $(grub_cfg)
	mkdir -p build/isofiles/boot/grub
	cp $(kernel) build/isofiles/boot/kernel.bin
	cp $(grub_cfg) build/isofiles/boot/grub
	grub-mkrescue /usr/lib/grub/i386-pc -o $(iso) build/isofiles
	#rm -r build/isofiles

$(kernel): cargo $(rust_os) $(object_files) $(linker_script)
	$(LD) $(LDFLAGS) -T$(linker_script) -o $(kernel) $(object_files) $(rust_os) $(LIBS)

# compile assembly files
build/arch/$(arch)/%.o: src/arch/$(arch)/%.S
	@mkdir -p $(shell dirname $@)
	$(AS) $(ASFLAGS) -c $< -o $@

build/arch/$(arch)/%.o: src/arch/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	$(NASM) $(NASMFLAGS) $< -o $@

build/arch/$(arch)/%.o: src/arch/$(arch)/%.c
	@mkdir -p $(shell dirname $@)
	$(AS) $(ASFLAGS) -c $< -o $@

