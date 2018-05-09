COPY_TARGET = /Volumes/MSXDOS2

all:
	mkdir -p bin
	java -jar tools/glass.jar src/MSX1Logo.asm bin/msx1logo.rom bin/msx1logo.sym

copy: all
	cp bin/msx1logo.rom $(COPY_TARGET)/
	diskutil umount $(COPY_TARGET)

run: all
	openmsx -cart bin/msx1logo.rom -machine Sony_HB-75P
