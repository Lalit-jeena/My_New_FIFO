
	package fifo_pkg;
		int no_of_xtn =10;
		`include "fifo_xtn.sv"
		`include "read_driver.sv"
		`include "read_monitor.sv"
		`include "write_driver.sv"
		`include "write_monitor.sv"
		`include "ref_model.sv"
		`include "scoreboard.sv"
		`include "fifo_xtn_generator.sv"
		`include "env.sv"
		`include "fifo_test.sv"
	endpackage
