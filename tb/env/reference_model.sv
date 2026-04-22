class fifo_reference_model extends uvm_object;

    `uvm_object_utils(fifo_reference_model)

    protected byte unsigned fifo_q[$];
    protected bit [3:0]     af_level;
    protected bit [3:0]     ae_level;
    protected bit           clr_pulse;
    protected bit [4:0]     fill_level;
    protected byte unsigned data_out;
    protected bit           trace_enable;
    protected string        trace_id;

    function new(string name = "fifo_reference_model");
        super.new(name);
        reset_state();
    endfunction

    function void reset_state();
        fifo_q.delete();
        af_level   = 4'd12;
        ae_level   = 4'd4;
        clr_pulse  = 1'b0;
        fill_level = 5'd0;
        data_out   = 8'h00;
        trace_enable = 1'b0;
        trace_id     = "FIFO_REF";
    endfunction

    function int unsigned get_occupancy();
        return fifo_q.size();
    endfunction

    function bit [3:0] get_af_level();
        return af_level;
    endfunction

    function bit [3:0] get_ae_level();
        return ae_level;
    endfunction

    function bit [4:0] get_fill_level();
        return fill_level;
    endfunction

    function void configure_trace(bit enable, string id = "FIFO_REF");
        trace_enable = enable;
        trace_id     = id;
    endfunction

    function fifo_xtn predict(input fifo_xtn obs, input string trace_idx = "-");
        fifo_xtn         exp;
        byte unsigned    next_q[$];
        bit [3:0]        next_af_level;
        bit [3:0]        next_ae_level;
        bit              next_clr_pulse;
        bit [4:0]        next_fill_level;
        byte unsigned    next_data_out;
        int unsigned     old_occupancy;
        bit              old_full;
        bit              old_empty;
        int unsigned     new_occupancy;

        exp            = fifo_xtn::type_id::create("exp");
        next_q         = fifo_q;
        next_af_level  = af_level;
        next_ae_level  = ae_level;
        next_clr_pulse = clr_pulse;
        next_fill_level = fill_level;
        next_data_out  = data_out;

        old_occupancy = fifo_q.size();
        old_full      = (old_occupancy == 16);
        old_empty     = (old_occupancy == 0);

        if (!obs.rst_n) begin
            next_q.delete();
            next_af_level   = 4'd12;
            next_ae_level   = 4'd4;
            next_clr_pulse  = 1'b0;
            next_fill_level = 5'd0;
            next_data_out   = 8'h00;
        end
        else begin
            if (obs.cs) begin
                if (clr_pulse) begin
                    next_clr_pulse = 1'b0;
                end

                next_fill_level = old_occupancy[4:0];

                if (obs.reg_sel && obs.wr_enb) begin
                    case (obs.addr)
                        8'h00: if (obs.data_in[1]) next_clr_pulse = 1'b1;
                        8'h08: next_af_level = obs.data_in[3:0];
                        8'h0C: next_ae_level = obs.data_in[3:0];
                        default: ;
                    endcase
                end
            end

            if (obs.cs && !obs.reg_sel) begin
                if (clr_pulse) begin
                    next_q.delete();
                    next_data_out = 8'h00;
                end
                else begin
                    if (obs.wr_enb && !old_full) begin
                        next_q.push_back(obs.data_in);
                    end

                    if (obs.rd_enb && !old_empty) begin
                        next_data_out = fifo_q[0];
                        void'(next_q.pop_front());
                    end
                end
            end
        end

        fifo_q      = next_q;
        af_level    = next_af_level;
        ae_level    = next_ae_level;
        clr_pulse   = next_clr_pulse;
        fill_level  = next_fill_level;
        data_out    = next_data_out;

        new_occupancy     = fifo_q.size();
        exp.rst_n         = obs.rst_n;
        exp.wr_enb        = obs.wr_enb;
        exp.rd_enb        = obs.rd_enb;
        exp.cs            = obs.cs;
        exp.reg_sel       = obs.reg_sel;
        exp.addr          = obs.addr;
        exp.data_in       = obs.data_in;
        exp.full          = (new_occupancy == 16);
        exp.empty         = (new_occupancy == 0);
        exp.almost_full   = (new_occupancy >= af_level);
        exp.almost_empty  = (new_occupancy <= ae_level);
        exp.overflow      = exp.full  && obs.wr_enb && obs.cs && !obs.reg_sel;
        exp.underflow     = exp.empty && obs.rd_enb && obs.cs && !obs.reg_sel;
        exp.data_out      = data_out;
        exp.reg_rdata     = 8'h00;

        if (obs.cs && obs.reg_sel && obs.rd_enb) begin
            case (obs.addr)
                8'h00: exp.reg_rdata = 8'h00;
                8'h04: exp.reg_rdata = {2'b00, exp.underflow, exp.overflow,
                                        exp.almost_empty, exp.almost_full, exp.empty, exp.full};
                8'h08: exp.reg_rdata = {4'b0000, af_level};
                8'h0C: exp.reg_rdata = {4'b0000, ae_level};
                8'h10: exp.reg_rdata = exp.empty ? 8'h00 : fifo_q[0];
                8'h14: exp.reg_rdata = {3'b000, fill_level};
                default: exp.reg_rdata = 8'hDE;
            endcase
        end

        if (trace_enable) begin
            `uvm_info(trace_id,
                $sformatf("Reference model transaction[%s]\n%s\n%s\n%s\n%s\n%s\n%s\nState: old_occ=%0d new_occ=%0d af=%0d ae=%0d fill=%0d clr_pulse=%0b",
                          trace_idx,
                          fifo_xtn::table_rule(),
                          fifo_xtn::table_header(),
                          fifo_xtn::table_rule(),
                          obs.table_row("REF_IN", trace_idx),
                          exp.table_row("REF_OUT", trace_idx),
                          fifo_xtn::table_rule(),
                          old_occupancy, new_occupancy, af_level, ae_level, fill_level, clr_pulse),
                UVM_MEDIUM)
        end

        return exp;
    endfunction

endclass

