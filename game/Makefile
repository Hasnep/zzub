gdscript_files := $(shell find . -name '*.gd')

.PHONY: format

format:
	sd '^@onready' 'onready'   $(gdscript_files)
	sd '(\S)=(\S)' '$$1 = $$2' $(gdscript_files)
	-gdformat --line-length 88 $(gdscript_files)
	sd '^onready' '@onready'   $(gdscript_files)
