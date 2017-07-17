######################################
# Makefile by CubeMX2Makefile.py
######################################

.DEFAULT_GOAL := all

######################################
# target
######################################
TARGET = $TARGET

######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
OPT = -Og

#######################################
# pathes
#######################################
# Build path
BUILD_DIR = build
DEP_DIR = .dep
CLEAN_DIRS = $$(BUILD_DIR) $$(DEP_DIR)
BUILD_FILES =

######################################
# source
######################################
$C_SOURCES
$CXX_SOURCES
$ASM_SOURCES

#######################################
# binaries
#######################################
CC = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
AS = arm-none-eabi-gcc -x assembler-with-cpp
CP = arm-none-eabi-objcopy
AR = arm-none-eabi-ar
SZ = arm-none-eabi-size
HEX = $$(CP) -O ihex
BIN = $$(CP) -O binary -S

#######################################
# CFLAGS
#######################################
# macros for gcc
$AS_DEFS
$C_DEFS
$CXX_DEFS
# includes for gcc
$AS_INCLUDES
$C_INCLUDES
$CXX_INCLUDES
# compile gcc flags
ASFLAGS = $MCU $$(AS_DEFS) $$(AS_INCLUDES) $$(OPT) -Wall -fdata-sections -ffunction-sections
CFLAGS = $MCU $$(C_DEFS) $$(C_INCLUDES) $$(OPT) -Wall -fdata-sections -ffunction-sections
CXXFLAGS = $MCU $$(CXX_DEFS) $$(CXX_INCLUDES) $$(OPT) -Wall -fdata-sections -ffunction-sections
ifeq ($$(DEBUG), 1)
CFLAGS += -g -gdwarf-2
CXXFLAGS += -g -gdwarf-2
endif
# Generate dependency information
CFLAGS += -std=c99 -MD -MP -MF $$(DEP_DIR)/$$(@F).d
CXXFLAGS += -MD -MP -MF $$(DEP_DIR)/$$(@F).d

#######################################
# LDFLAGS
#######################################
# link script
$LDSCRIPT
# libraries
LIBS = -lc -lm -lnosys
LIBDIR =
LDFLAGS = $LDMCU -specs=nano.specs -T$$(LDSCRIPT) $$(LIBDIR) $$(LIBS) -Wl,-Map=$$(BUILD_DIR)/$$(TARGET).map,--cref -Wl,--gc-sections

-include inc.mk

# default action: build all
BUILD_FILES += $$(BUILD_DIR)/$$(TARGET).elf $$(BUILD_DIR)/$$(TARGET).hex $$(BUILD_DIR)/$$(TARGET).bin
all: $$(BUILD_FILES)

#######################################
# build the application
#######################################
# list of objects
OBJECTS = $$(addprefix $$(BUILD_DIR)/,$$(notdir $$(C_SOURCES:.c=__c.o)))
vpath %.c $$(sort $$(dir $$(C_SOURCES)))
OBJECTS += $$(addprefix $$(BUILD_DIR)/,$$(notdir $$(CXX_SOURCES:.cpp=__cpp.o)))
vpath %.cpp $$(sort $$(dir $$(CXX_SOURCES)))
# list of ASM program objects
OBJECTS += $$(addprefix $$(BUILD_DIR)/,$$(notdir $$(ASM_SOURCES:.s=__s.o)))
vpath %.s $$(sort $$(dir $$(ASM_SOURCES)))

$$(BUILD_DIR)/%__c.o: %.c Makefile | $$(BUILD_DIR)
	$$(CC) -c $$(CFLAGS) -Wa,-a,-ad,-alms=$$(BUILD_DIR)/$$(notdir $$(<:.c=__c.lst)) $$< -o $$@

$$(BUILD_DIR)/%__cpp.o: %.cpp Makefile | $$(BUILD_DIR)
	$$(CXX) -c $$(CXXFLAGS) -Wa,-a,-ad,-alms=$$(BUILD_DIR)/$$(notdir $$(<:.cpp=__cpp.lst)) $$< -o $$@

$$(BUILD_DIR)/%__s.o: %.s Makefile | $$(BUILD_DIR)
	$$(AS) -c $$(CFLAGS) $$< -o $$@

$$(BUILD_DIR)/$$(TARGET).elf:: $$(OBJECTS) Makefile
	$$(CC) $$(OBJECTS) $$(LDFLAGS) -o $$@
	$$(SZ) $$@

$$(BUILD_DIR)/%.hex: $$(BUILD_DIR)/%.elf | $$(BUILD_DIR)
	$$(HEX) $$< $$@

$$(BUILD_DIR)/%.bin: $$(BUILD_DIR)/%.elf | $$(BUILD_DIR)
	$$(BIN) $$< $$@

$$(BUILD_DIR):
	mkdir -p $$@

#######################################
# clean up
#######################################
clean:
	-rm -fR $$(CLEAN_DIRS)

#######################################
# dependencies
#######################################
-include $$(shell mkdir $$(DEP_DIR) 2>/dev/null) $$(wildcard $$(DEP_DIR)/*)

.PHONY: clean all

FORCE:

# *** EOF ***
