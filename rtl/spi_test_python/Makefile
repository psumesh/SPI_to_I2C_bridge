
TOPLEVEL_LANG ?= verilog

PWD=$(shell pwd)
VERILOG_SOURCES = $(PWD)/../spi_rtl/*.v
TOPLEVEL := spi_master
MODULE   := spi_master_


export PYTHONPATH := $(PWD)/model:$(PYTHONPATH)

include $(shell cocotb-config --makefiles)/Makefile.sim
