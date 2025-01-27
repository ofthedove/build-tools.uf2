uf2conv_tools_mkfile_path:=$(abspath $(lastword $(MAKEFILE_LIST)))
uf2conv_tools_current_path:=$(patsubst %/,%,$(dir $(uf2conv_tools_mkfile_path)))

# Prefer python3 if installed. Fallback to python 2.
# It would be preferable to include python as a submodule, but unfortunately python isn't portable
ifneq (, $(shell which python3 ))
   PYTHON:=python3
else ifneq (, $(shell which python ))
   PYTHON:=python
else
  $(error "Python must be installed to generate UF2 files!")
endif

UF2PATH:=$(uf2conv_tools_current_path)/uf2
UF2CONV:=$(UF2PATH)/utils/uf2conv.py

# Takes an elf file and makes a BIN
# $1 objcopy location
define create_bin
	@echo Creating $@
	@$1 -O binary $< $@
endef

# Takes a BIN file and makes a U2F
# $1 u2fconv.py location
define create_uf2
	@echo Creating $@
	@$1 $(UF2CONV) -c -o $@ $< # Need to add contitional different start address for metro M4 targets, this is only good for M0
endef

$(OUTPUT_DIR)/$(TARGET).bin: $(OUTPUT_DIR)/$(TARGET).elf
	$(call create_bin,$(OBJCOPY))

$(OUTPUT_DIR)/$(TARGET).uf2: $(OUTPUT_DIR)/$(TARGET).bin
	$(call create_uf2,$(PYTHON))
