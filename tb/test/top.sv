`timescale 1ns/1ps

module top;

    import uvm_pkg::*;
    import fifo_pkg::*;

    localparam time CLK_PERIOD = 10ns;

    bit clk;
    fifo_interface fifo_if(clk);

    fifo_top dut (
        .clk          (clk),
        .rst_n        (fifo_if.rst_n),
        .cs           (fifo_if.cs),
        .reg_sel      (fifo_if.reg_sel),
        .addr         (fifo_if.addr),
        .data_in      (fifo_if.data_in),
        .wr_enb       (fifo_if.wr_enb),
        .rd_enb       (fifo_if.rd_enb),
        .full         (fifo_if.full),
        .empty        (fifo_if.empty),
        .almost_full  (fifo_if.almost_full),
        .almost_empty (fifo_if.almost_empty),
        .overflow     (fifo_if.overflow),
        .underflow    (fifo_if.underflow),
        .data_out     (fifo_if.data_out),
        .reg_rdata    (fifo_if.reg_rdata)
    );

    initial begin
        clk            = 1'b0;
        fifo_if.rst_n  = 1'b1;
        fifo_if.wr_enb = 1'b0;
        fifo_if.rd_enb = 1'b0;
        fifo_if.cs     = 1'b0;
        fifo_if.reg_sel = 1'b0;
        fifo_if.addr   = 8'h00;
        fifo_if.data_in = 8'h00;
    end

    initial begin
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        uvm_config_db#(virtual fifo_interface)::set(null, "*", "vif", fifo_if);
        run_test("fifo_regression_test");
    end

endmodule
