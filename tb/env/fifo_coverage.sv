class fifo_coverage extends uvm_subscriber #(fifo_xtn);

    `uvm_component_utils(fifo_coverage)

    fifo_reference_model model_h;

    bit         cov_rst_n;
    bit         cov_cs;
    bit         cov_reg_sel;
    bit         cov_wr_enb;
    bit         cov_rd_enb;
    bit [7:0]   cov_addr;
    bit         cov_full;
    bit         cov_empty;
    bit         cov_almost_full;
    bit         cov_almost_empty;
    bit         cov_overflow;
    bit         cov_underflow;
    int unsigned cov_pre_occ;
    int unsigned cov_post_occ;
    bit [3:0]   cov_af_level;
    bit [3:0]   cov_ae_level;

    covergroup fifo_cg;
        option.per_instance = 1;

        cp_post_occ: coverpoint cov_post_occ {
            bins zero    = {0};
            bins one     = {1};
            bins four    = {4};
            bins twelve  = {12};
            bins fifteen = {15};
            bins full    = {16};
            bins others  = default;
        }

        cp_cs: coverpoint cov_cs;
        cp_reg_sel: coverpoint cov_reg_sel;
        cp_wr_enb: coverpoint cov_wr_enb;
        cp_rd_enb: coverpoint cov_rd_enb;

        cp_addr: coverpoint cov_addr iff (cov_rst_n && cov_cs && cov_reg_sel && (cov_wr_enb || cov_rd_enb)) {
            bins ctrl    = {8'h00};
            bins status  = {8'h04};
            bins af      = {8'h08};
            bins ae      = {8'h0C};
            bins peek    = {8'h10};
            bins fill    = {8'h14};
            bins invalid = default;
        }

        cp_full: coverpoint cov_full;
        cp_empty: coverpoint cov_empty;
        cp_almost_full: coverpoint cov_almost_full;
        cp_almost_empty: coverpoint cov_almost_empty;
        cp_overflow: coverpoint cov_overflow;
        cp_underflow: coverpoint cov_underflow;

        cp_af_level: coverpoint cov_af_level {
            bins zero    = {0};
            bins one     = {1};
            bins twelve  = {12};
            bins fifteen = {15};
            bins others  = default;
        }

        cp_ae_level: coverpoint cov_ae_level {
            bins zero    = {0};
            bins one     = {1};
            bins four    = {4};
            bins fifteen = {15};
            bins others  = default;
        }

        cp_simul_occ: coverpoint cov_pre_occ iff (cov_rst_n && cov_cs && !cov_reg_sel && cov_wr_enb && cov_rd_enb) {
            bins empty  = {0};
            bins middle = {[1:15]};
            bins full   = {16};
        }

        x_mode_control: cross cp_cs, cp_reg_sel, cp_wr_enb, cp_rd_enb;
    endgroup

    function new(string name = "fifo_coverage", uvm_component parent = null);
        super.new(name, parent);
        fifo_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        model_h = fifo_reference_model::type_id::create("model_h");
    endfunction

    virtual function void write(fifo_xtn t);
        fifo_xtn dummy;

        cov_pre_occ = model_h.get_occupancy();
        dummy = model_h.predict(t);
        cov_post_occ     = model_h.get_occupancy();
        cov_af_level     = model_h.get_af_level();
        cov_ae_level     = model_h.get_ae_level();
        cov_rst_n        = t.rst_n;
        cov_cs           = t.cs;
        cov_reg_sel      = t.reg_sel;
        cov_wr_enb       = t.wr_enb;
        cov_rd_enb       = t.rd_enb;
        cov_addr         = t.addr;
        cov_full         = t.full;
        cov_empty        = t.empty;
        cov_almost_full  = t.almost_full;
        cov_almost_empty = t.almost_empty;
        cov_overflow     = t.overflow;
        cov_underflow    = t.underflow;
        fifo_cg.sample();
    endfunction

endclass
