
	interface fifo_interface (input bit clk);
		logic rstn;

		logic chip_sel;
		logic reg_sel;

		logic [7:0] addr;
		logic [7:0] data_in;
		logic wr_enb;
		logic rd_enb;

		logic full;
		logic empty;
		logic almost_full;
		logic almost_empty;
		logic overflow;
		logic underflow;

		logic [7:0] fifo_data_out;
		logic [7:0] reg_data_out;

		// Write Driver clocking block
		clocking wr_drv_cb @(posedge clk);
			default input #1 output #1;
			output rstn;
			output chip_sel;
			output reg_sel;
			output addr;
			output data_in;
			output wr_enb;
		endclocking

		//Write Monitor clocking block
		clocking wr_mon_cb @(posedge clk);
			default input #1 output #1;
			input rstn;
			input chip_sel;
			input reg_sel;
			input addr;
			input data_in;
			input wr_enb;
		endclocking

		//Read Driver Clocking Block
		clocking rd_drv_cb @(posedge clk);
			default input #1 output #1;
			output rd_enb;
			input full;
			input empty;
			input almost_full;
			input almost_empty;
			input overflow;
			input underflow;
			input fifo_data_out;
			input reg_data_out;
		endclocking

		// Read Monitor Clokiong Block
		clocking rd_mon_cb @(posedge clk);
			default input #1 output #1;
			input rd_enb;
			input full;
			input empty;
			input almost_full;
			input almost_empty;
			input overflow;
			input underflow;
			input fifo_data_out;
			input reg_data_out;
		endclocking

		//modports
		modport wr_drv_mp (clocking wr_drv_cb);
		modport wr_mon_mp (clocking wr_mon_cb);
		modport rd_drv_mp (clocking rd_drv_cb);
		modport rd_mon_mp (clocking rd_mon_cb);

	endinterface
