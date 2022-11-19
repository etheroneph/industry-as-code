DUAL_UNIVERSE_PATH ?= /mnt/c/Games/Dual\ Universe
	
build: 
	lua build_industry_config.lua > "${DUAL_UNIVERSE_PATH}/Game/data/lua/industry_config.lua"

format: build
	python3 format.py industry_as_code.lua
