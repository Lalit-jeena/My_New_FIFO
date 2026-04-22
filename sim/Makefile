# Makefile for FIFO - Regression Testing #
# Makefile for Questasim  
RTL= ../rtl/*.sv
work= work #library name
COVOP= -coveropt 3 +cover=bcft
SVTB1= ../tb/top.sv
INC = +incdir+../read_agent +incdir+../write_agent +incdir+../tb +incdir+../test
SVTB2 = ../test/fifo_pkg.sv
TEST = ../test/fifo_test.sv

VSIMOPT= -coverage  -vopt -voptargs=+acc -sva -sv_seed random work.top 
VSIMCOV= coverage save -onexit -assert -directive -cvg -codeAll mem_cov
VSIMBATCH= -c -do "$(VSIMCOV); run -all; exit"
VSIMBATCH1 = -c -do "log -r /* ;coverage save -onexit -assert -directive -cvg -codeAll fifo_cov1.ucdb;run -all;exit"
VSIMBATCH2 = -c -do "log -r /* ;coverage save -onexit -assert -directive -cvg -codeAll fifo_cov2.ucdb;run -all;exit"
VSIMBATCH3 = -c -do "log -r /* ;coverage save -onexit -assert -directive -cvg -codeAll fifo_cov3.ucdb;run -all;exit"
VSIMBATCH4 = -c -do "log -r /* ;coverage save -onexit -assert -directive -cvg -codeAll fifo_cov4.ucdb;run -all;exit"

help:
	@echo =============================================================================================================================
	@echo "! USAGE   						--  make target                  																								!"
	@echo "! clean   								=>  clean the earlier log and intermediate files.  													!"
	@echo "! compile    						=>  Create library and compile the code.           													!"
	@echo "! run_reset_test					=>  clean, compile & run the simulation for base test in batch mode.				!" 
	@echo "! run_reg_write_test			=>  clean, compile & run the simulation for wr_rd_test in batch mode.				!" 
	@echo "! run_fifo_wr_rd_test		=>  clean, compile & run the simulation for wr_rd_test in batch mode.				!" 
	@echo "! run_reg_read_test			=>  clean, compile & run the simulation for wr_rd_test in batch mode.				!" 
	@echo "! regress    						=>  clean, compile and run all testcases in batch mode.		    							!"
	@echo "! report     						=>  To merge coverage reports for all testcases and  convert to html format.!"
	@echo "! cov        						=>  To open merged coverage report in html format.													!"
	@echo =============================================================================================================================



compile:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL)  $(INC) $(SVTB2) $(TEST) $(SVTB1) 
	
run_reset_test:
	vsim  $(VSIMBATCH1) -cvgperinstance -coverage -vopt -voptargs=+acc -sva -sv_seed 431581410 -l test1_sim.log -wlf test1_wave.wlf work.top +TEST1
	vcover report -cvg -details  fifo_cov1.ucdb


run_reg_write_test:
	vsim  $(VSIMBATCH2) -cvgperinstance -coverage -vopt -voptargs=+acc -sva -sv_seed 2135035686 -l test2_sim.log -wlf test2_wave.wlf work.top +TEST2
	vcover report -cvg -details  fifo_cov2.ucdb


run_fifo_wr_rd_test:
	vsim  $(VSIMBATCH3) -cvgperinstance -coverage -vopt -voptargs=+acc -sva -sv_seed 2096639134 -l test3_sim.log -wlf test3_wave.wlf work.top +TEST3
	vcover report -cvg -details  fifo_cov3.ucdb

run_reg_read_test:
	vsim  $(VSIMBATCH4) -cvgperinstance -coverage -vopt -voptargs=+acc -sva -sv_seed 1063239334 -l test4_sim.log -wlf test4_wave.wlf work.top +TEST4
	vcover report -cvg -details  fifo_cov4.ucdb
	
report:
	vcover merge fifo_cov fifo_cov1.ucdb fifo_cov2.ucdb fifo_cov3.ucdb fifo_cov4.ucdb
	vcover report -cvg -details -html fifo_cov

cov:
	firefox covhtmlreport/index.html &


regress: clean compile run_reset_test run_reg_write_test run_fifo_wr_rd_test run_reg_read_test report cov

clean:
	del /Q modelsim.* *.ucdb transcript* vlog.* vsim.wlf fifo_cov* fcover* covhtml* vcover* *.log *.wlf
	rm -rf work covhtmlreport	
	clear

