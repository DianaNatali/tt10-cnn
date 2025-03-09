# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
COCOTB_HDL_TIMEUNIT = "1ns"
COCOTB_HDL_TIMEPRECISION = "10ps"
BEHAV?=1
COCOTB_SIM = 1

PWD=$(shell pwd)

VERILOG_SOURCES += $(PWD)/../src/parameters.svh
VERILOG_SOURCES += $(PWD)/../src/conv_control.sv
VERILOG_SOURCES += $(PWD)/../src/conv_core.sv
VERILOG_SOURCES += $(PWD)/../src/conv_layer.sv

#TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = conv_layer

# MODULE is the basename of the Python test file
# MODULE = gray_sobel_TB
MODULE = cnn_TB
COMPILE_ARGS += -PUSE_POWER_PINS=1
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

clean_output:
	rm -rf  *.jpg *.txt *~


