class fifo_scoreboard extends uvm_component;

    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_imp #(fifo_xtn, fifo_scoreboard) analysis_imp;
    fifo_reference_model model_h;
    int unsigned sample_count;
    int unsigned error_count;
    int unsigned pass_count;
    int unsigned fail_count;

    function new(string name = "fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        analysis_imp = new("analysis_imp", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        model_h = fifo_reference_model::type_id::create("model_h");
        model_h.configure_trace(1'b1, "FIFO_REF");
    endfunction

    function bit check_bit(string field_name, bit actual, bit expected, fifo_xtn obs);
        if (actual !== expected) begin
            error_count++;
            `uvm_error("FIFO_SB",
                $sformatf("%s mismatch: expected=%0b actual=%0b sample=%s",
                          field_name, expected, actual, obs.convert2string()))
            return 1'b0;
        end
        return 1'b1;
    endfunction

    function bit check_byte(string field_name, bit [7:0] actual, bit [7:0] expected, fifo_xtn obs);
        if (actual !== expected) begin
            error_count++;
            `uvm_error("FIFO_SB",
                $sformatf("%s mismatch: expected=0x%02h actual=0x%02h sample=%s",
                          field_name, expected, actual, obs.convert2string()))
            return 1'b0;
        end
        return 1'b1;
    endfunction

    virtual function void write(fifo_xtn obs);
        fifo_xtn exp;
        bit      txn_pass;
        string   txn_id;

        sample_count++;
        txn_id = $sformatf("%0d", sample_count);
        exp = model_h.predict(obs, txn_id);
        txn_pass = 1'b1;

        txn_pass &= check_bit("full",         obs.full,         exp.full,         obs);
        txn_pass &= check_bit("empty",        obs.empty,        exp.empty,        obs);
        txn_pass &= check_bit("almost_full",  obs.almost_full,  exp.almost_full,  obs);
        txn_pass &= check_bit("almost_empty", obs.almost_empty, exp.almost_empty, obs);
        txn_pass &= check_bit("overflow",     obs.overflow,     exp.overflow,     obs);
        txn_pass &= check_bit("underflow",    obs.underflow,    exp.underflow,    obs);
        txn_pass &= check_byte("data_out",    obs.data_out,     exp.data_out,     obs);
        txn_pass &= check_byte("reg_rdata",   obs.reg_rdata,    exp.reg_rdata,    obs);

        if (txn_pass) begin
            pass_count++;
        end
        else begin
            fail_count++;
        end

        `uvm_info("FIFO_SB_CMP",
            $sformatf("Scoreboard compare[%0d]\n%s\n%s\n%s\n%s\n%s\n%s\nResult: %s | pass_count=%0d fail_count=%0d",
                      sample_count,
                      fifo_xtn::table_rule(),
                      fifo_xtn::table_header(),
                      fifo_xtn::table_rule(),
                      obs.table_row("OBS", txn_id),
                      exp.table_row("EXP", txn_id),
                      fifo_xtn::table_rule(),
                      txn_pass ? "PASS" : "FAIL",
                      pass_count,
                      fail_count),
            UVM_MEDIUM)
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (error_count == 0) begin
            `uvm_info(get_type_name(),
                $sformatf("Scoreboard checked %0d samples with no mismatches. pass_count=%0d fail_count=%0d",
                          sample_count, pass_count, fail_count),
                UVM_LOW)
        end
        else begin
            `uvm_error(get_type_name(),
                $sformatf("Scoreboard found %0d mismatches across %0d samples. pass_count=%0d fail_count=%0d",
                          error_count, sample_count, pass_count, fail_count))
        end
    endfunction

endclass


      
