//======================================================================

module fifo_top (
    input         clk,
    input         rst_n,
   
    input         cs,          // Global Enable
    input         reg_sel,     // 1 = Register Mode, 0 = FIFO Mode
   
    input [7:0]   addr,
    input [7:0]   data_in,
    input         wr_enb,
    input         rd_enb,
   
    output        full,
    output        empty,
    output        almost_full,
    output        almost_empty,
    output        overflow,
    output        underflow,
   
    output reg [7:0] data_out,
    output reg [7:0] reg_rdata
);

    reg [7:0] fifo_ram [0:15];
    reg [4:0] wr_ptr, rd_ptr;
    integer i;

    wire       iteration = wr_ptr[4] ^ rd_ptr[4];
    wire       ptr_equal = (wr_ptr[3:0] == rd_ptr[3:0]);

    assign full  = (iteration & ptr_equal);
    assign empty = (~iteration & ptr_equal);

    wire [4:0] fill_level_comb = iteration ? (5'd16 + wr_ptr[3:0] - rd_ptr[3:0]) :
                                             (wr_ptr[3:0] - rd_ptr[3:0]);

    reg  [4:0] fill_level;

    reg [3:0]  af_level;
    reg [3:0]  ae_level;
    reg        clr_pulse;

    assign almost_full  = (fill_level_comb >= {1'b0, af_level});
    assign almost_empty = (fill_level_comb <= {1'b0, ae_level});

    assign overflow  = full  && wr_enb && cs && (reg_sel == 0)&& rst_n;
    assign underflow = empty && rd_enb && cs && (reg_sel == 0) && rst_n;

    //==================================================================
    // Main Sequential Logic
    //==================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            af_level   <= 4'd12;
            ae_level   <= 4'd4;
            clr_pulse  <= 1'b0;
            fill_level <= 5'd0;
            wr_ptr     <= 5'b0;
            rd_ptr     <= 5'b0;
            data_out   <= 8'h00;
            for (i = 0; i < 16; i = i + 1)
                fifo_ram[i] <= 8'b0;
        end
        else if (cs) begin
            // Sample fill level for stable register read
            fill_level <= fill_level_comb;

            if (clr_pulse) begin
                clr_pulse <= 1'b0;
                wr_ptr    <= 5'b0;
                rd_ptr    <= 5'b0;
                data_out  <= 8'h00;
                for (i = 0; i < 16; i = i + 1)
                    fifo_ram[i] <= 8'b0;
            end
            else begin
                if (reg_sel && wr_enb) begin          // Register Write
                    case (addr)
                        8'h00: if (data_in[1]) clr_pulse <= 1'b1;
                        8'h08: af_level <= data_in[3:0];
                        8'h0C: ae_level <= data_in[3:0];
                        default: ;
                    endcase
                end

                // FIFO Data Path
                if (reg_sel == 0) begin
                    if (wr_enb && !full) begin
                        fifo_ram[wr_ptr[3:0]] <= data_in;
                        wr_ptr <= wr_ptr + 1'b1;
                    end

                    if (rd_enb && !empty) begin
                        data_out <= fifo_ram[rd_ptr[3:0]];
                        rd_ptr   <= rd_ptr + 1'b1;
                    end
                end
            end
        end
    end

    //==================================================================
    // Register Read Logic - Safe during reset and clr_pulse
    //==================================================================
    always @(*) begin
        reg_rdata = 8'h00;                    // Default safe value

        if (!rst_n || clr_pulse) begin
            reg_rdata = 8'h00;                // Safe value during reset or clear operation
        end
        else if (cs && reg_sel && rd_enb) begin
            case (addr)
                8'h00:   reg_rdata = 8'h00;                                 // CONTROL
                8'h04:   reg_rdata = {2'b00, underflow, overflow,
                                      almost_empty, almost_full,
                                      empty, full};
                8'h08:   reg_rdata = {4'b0000, af_level};
                8'h0C:   reg_rdata = {4'b0000, ae_level};
                8'h10:   reg_rdata = empty ? 8'h00 : fifo_ram[rd_ptr[3:0]];
                8'h14:   reg_rdata = {3'b000, fill_level};
                default: reg_rdata = 8'hDE;
            endcase
        end
    end
		
property write_pointer_calculation;
	@(posedge clk) disable iff(!rst_n)
		wr_enb && !full && !reg_sel && !clr_pulse |=>  (wr_ptr == $past(wr_ptr)+1);
endproperty

property read_pointer_calculation;
	@(posedge clk) disable iff(!rst_n)
	rd_enb && !empty && !reg_sel && cs && !clr_pulse |=> (rd_ptr == $past(rd_ptr) + 1);
endproperty

property reset_wr_rd_pointer;
	@(posedge clk) 
		(!rst_n || clr_pulse) |=> (wr_ptr == 0 && rd_ptr ==0);
endproperty

property underflow_calculation;
	@(posedge clk) disable iff(!rst_n)
	empty && rd_enb && cs && !reg_sel |-> underflow;
endproperty

property overflow_calculation;
	@(posedge clk) disable iff(!rst_n)
	full && wr_enb && cs && !reg_sel |-> overflow;
endproperty

WR_PTR_CALC : assert property (write_pointer_calculation);
RD_PTR_CALC	: assert property (read_pointer_calculation);
RST_WR_RD_PTR	:	assert property (reset_wr_rd_pointer);
UNDERFLOW	: assert property (underflow_calculation);
OVERFLOW	:	assert property (overflow_calculation);

endmodule


