LUA_LIB_DIR := /usr/local/lib/lua/5.3/
BIN_DIR     := /usr/local/bin

all: help

.PHONY: help
help:
	@echo 'To install ROM_maker, run `sudo make install`'.
	@echo 'To uninstall it, run `sudo make uninstall`'.

.PHONY: install
install:
	mkdir -p $(LUA_LIB_DIR) $(BIN_DIR)
	cp ./byte_stream.lua $(LUA_LIB_DIR)/byte_stream.lua
	cp ./ROM_maker.lua $(BIN_DIR)/ROM_maker

.PHONY: uninstall
uninstall:
	rm -f $(LUA_LIB_DIR)/byte_stream.lua
	rm -f $(BIN_DIR)/ROM_maker

