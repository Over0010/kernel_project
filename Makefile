CC      := x86_64-elf-gcc
LD      := x86_64-elf-ld

CFLAGS  := -g -O2 -pipe -Wall -Wextra \
           -std=gnu11 -ffreestanding -fno-stack-protector \
           -fno-stack-check -fno-lto -fPIE -mno-80387 \
           -mno-mmx -mno-sse -mno-sse2 -mno-red-zone \
           

LDFLAGS := -m elf_x86_64 -nostdlib -static -pie \
           --no-dynamic-linker -z text -z max-page-size=0x1000 \
           -T linker.ld

SRCS := $(wildcard src/*.c)
OBJS := $(SRCS:.c=.o)

all: kernel.iso

src/%.c: src/%.o
	$(CC) $(CFLAGS) -c $< -o $@


kernel.elf: $(OBJS) linker.ld
	$(LD) $(LDFLAGS) $(OBJS) -o kernel.elf

kernel.iso: kernel.elf limine.conf
	rm -rf iso_root
	mkdir -p iso_root/boot/limine iso_root/EFI/BOOT
	cp kernel.elf iso_root/boot/
	cp limine.conf limine/limine-bios.sys limine/limine-bios-cd.bin \
	   limine/limine-uefi-cd.bin iso_root/boot/limine/
	cp limine/BOOTX64.EFI iso_root/EFI/BOOT/
	xorriso -as mkisofs -b boot/limine/limine-bios-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		iso_root -o kernel.iso
	./limine/limine bios-install kernel.iso
	rm -rf iso_root

run: kernel.iso
	qemu-system-x86_64 -cdrom kernel.iso -serial stdio -m 256M -display gtk

debug: kernel.iso
	qemu-system-x86_64 -cdrom kernel.iso -serial stdio -m 256M -s -S

clean:
	rm -rf src/*.o kernel.elf kernel.iso iso_root

.PHONY: all run debug clean
