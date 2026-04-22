
	module top;
		reg clk;
		parameter CYCLE = 10;

		import fifo_pkg::*;

		fifo_interface fifo_intf(clk);
		fifo_test test_h;

		fifo_top dut(.clk				(clk),
								 .rst_n			(fifo_intf.rstn),
								 .cs				(fifo_intf.chip_sel),
								 .reg_sel		(fifo_intf.reg_sel),
								 .addr			(fifo_intf.addr),
								 .data_in		(fifo_intf.data_in),
								 .wr_enb		(fifo_intf.wr_enb),
								 .rd_enb		(fifo_intf.rd_enb),
								 .full			(fifo_intf.full),
								 .empty			(fifo_intf.empty),
								 .almost_full(fifo_intf.almost_full),
								 .almost_empty(fifo_intf.almost_empty),
								 .overflow	(fifo_intf.overflow),
								 .underflow	(fifo_intf.underflow),
								 .data_out	(fifo_intf.fifo_data_out),
								 .reg_rdata	(fifo_intf.reg_data_out));
		initial
			begin
				clk = 1'b0;
				forever 
					#(CYCLE/2) clk = ~ clk;
			end

		initial
			begin
				test_h = new(fifo_intf, fifo_intf, fifo_intf, fifo_intf);
				test_h.build_and_run();
			end


	endmodule
