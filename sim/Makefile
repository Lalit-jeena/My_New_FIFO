# Makefile for FIFO UVM verification on Questa

QUESTA_HOME ?= C:/questasim64_10.7c
UVM_HOME    ?= $(QUESTA_HOME)/verilog_src/uvm-1.2
UVM_LIB     ?= $(QUESTA_HOME)/uvm-1.2

WORK_LIB    = work
WORK_DIR    = build/work
LOG_DIR     = logs
WAVE_DIR    = waves
UCDB_DIR    = coverage/ucdb
HTML_COV_DIR = coverage/html
VLOG_COV   = -coveropt 3 +cover=bcft
UCDB_FLAGS = -assert -directive -cvg -codeAll
SMOKE_UCDB = $(UCDB_DIR)/smoke.ucdb
REGISTER_UCDB = $(UCDB_DIR)/register.ucdb
RANDOM_UCDB = $(UCDB_DIR)/random.ucdb
REGRESSION_UCDB = $(UCDB_DIR)/regression.ucdb

RTL        = ../tb/interface/fifo_interface.sv ../rtl/design/fifo_top.sv
TB_PKG     = ../tb/test/fifo_pkg.sv
TB_TOP     = ../tb/test/top.sv
INC        = +incdir+../tb/interface +incdir+../tb/transaction +incdir+../tb/sequence +incdir+../tb/agent +incdir+../tb/env +incdir+../tb/test +incdir+$(UVM_HOME)/src
VLOG       = vlog -work $(WORK_LIB) -sv -L $(UVM_LIB) $(VLOG_COV)
VSIM_BASE  = vsim -c -L $(UVM_LIB) -nodpiexports -wlf $(WAVE_DIR)/vsim.wlf $(WORK_LIB).top -coverage -vopt -voptargs=+acc -sva

cmp:
	if not exist "$(LOG_DIR)" mkdir "$(LOG_DIR)"
	if not exist "$(WAVE_DIR)" mkdir "$(WAVE_DIR)"
	if not exist "$(UCDB_DIR)" mkdir "$(UCDB_DIR)"
	if not exist "$(HTML_COV_DIR)" mkdir "$(HTML_COV_DIR)"
	if exist "$(WORK_DIR)" rmdir /s /q "$(WORK_DIR)"
	vlib $(WORK_DIR)
	vmap $(WORK_LIB) $(WORK_DIR)
	$(VLOG) $(INC) $(RTL) $(TB_PKG) $(TB_TOP)

run_regression: cmp
	$(VSIM_BASE) -l $(LOG_DIR)/regression_sim.log -do "coverage save -onexit $(UCDB_FLAGS) $(REGRESSION_UCDB); run -all; quit -f" +UVM_TESTNAME=fifo_regression_test

run_smoke: cmp
	$(VSIM_BASE) -l $(LOG_DIR)/smoke_sim.log -do "coverage save -onexit $(UCDB_FLAGS) $(SMOKE_UCDB); run -all; quit -f" +UVM_TESTNAME=fifo_smoke_test

run_register: cmp
	$(VSIM_BASE) -l $(LOG_DIR)/register_sim.log -do "coverage save -onexit $(UCDB_FLAGS) $(REGISTER_UCDB); run -all; quit -f" +UVM_TESTNAME=fifo_register_test

run_random: cmp
	$(VSIM_BASE) -l $(LOG_DIR)/random_sim.log -do "coverage save -onexit $(UCDB_FLAGS) $(RANDOM_UCDB); run -all; quit -f" +UVM_TESTNAME=fifo_random_test

html_smoke:
	vcover report -html -htmldir $(HTML_COV_DIR)/smoke $(SMOKE_UCDB)

html_register:
	vcover report -html -htmldir $(HTML_COV_DIR)/register $(REGISTER_UCDB)

html_random:
	vcover report -html -htmldir $(HTML_COV_DIR)/random $(RANDOM_UCDB)

html_regression:
	vcover report -html -htmldir $(HTML_COV_DIR)/regression $(REGRESSION_UCDB)

view_cov_smoke:
	vsim -viewcov $(SMOKE_UCDB)

view_cov_register:
	vsim -viewcov $(REGISTER_UCDB)

view_cov_random:
	vsim -viewcov $(RANDOM_UCDB)

view_cov_regression:
	vsim -viewcov $(REGRESSION_UCDB)
