interface fifo_interface(input logic clk);

logic rst_n;
logic wr_enb;
logic rd_enb;
logic cs;
logic reg_sel;
logic [7:0] addr;
logic [7:0] data_in;
logic full;
logic empty;
logic almost_full;
logic almost_empty;
logic overflow;
logic underflow;
logic [7:0] data_out;
logic [7:0] reg_rdata;

clocking drv_cb @(negedge clk);
    default input #1step output #0;
    output rst_n;
    output wr_enb;
    output rd_enb;
    output cs;
    output reg_sel;
    output addr;
    output data_in;
    input  full;
    input  empty;
    input  almost_full;
    input  almost_empty;
    input  overflow;
    input  underflow;
    input  data_out;
    input  reg_rdata;
endclocking

clocking mon_cb @(posedge clk);
    default input #0 output #0;
    input rst_n;
    input wr_enb;
    input rd_enb;
    input cs;
    input reg_sel;
    input addr;
    input data_in;
    input full;
    input empty;
    input almost_full;
    input almost_empty;
    input overflow;
    input underflow;
    input data_out;
    input reg_rdata;
endclocking

modport DRV(clocking drv_cb, input clk);
modport MON(clocking mon_cb, input clk);

property p_full_and_empty_exclusive;
    @(posedge clk) !(full && empty);
endproperty

a_full_and_empty_exclusive: assert property (p_full_and_empty_exclusive)
    else $error("FIFO flags full and empty asserted together");

endinterface
