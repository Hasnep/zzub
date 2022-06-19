.PHONY: all linux windows macos

all: linux windows macos

linux:
	mkdir -p exported/linux/
	godot-4 --export linux exported/linux/zzub

windows:
	mkdir -p exported/windows/
	godot-4 --export windows exported/windows/zzub.exe

macos:
	mkdir -p exported/macos/
	godot-4 --export macos exported/macos/zzub
