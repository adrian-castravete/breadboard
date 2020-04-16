all: build

build:
	moonc *.moon

doc: documentation

documentation:
	ldoc --format markdown init.moon

requirements-debian: req-moonscript ldoc

req-deb-lua:
	sudo apt install lua5.1

req-deb-luarocks: req-deb-lua
	sudo apt install luarocks

req-moonscript: req-deb-luarocks
	luarocks install --local moonscript

ldoc:
	luarocks install --local ldoc
