class fifo_monitor extends uvm_component;

    `uvm_component_utils(fifo_monitor)

    virtual fifo_interface vif;
    uvm_analysis_port #(fifo_xtn) analysis_port;
    int unsigned                  monitor_count;

    function new(string name = "fifo_monitor", uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fifo_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "virtual interface handle not found for fifo_monitor")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        fifo_xtn tr;

        forever begin
            @(vif.mon_cb);
            tr = fifo_xtn::type_id::create("tr", this);
            tr.rst_n         = vif.mon_cb.rst_n;
            tr.wr_enb        = vif.mon_cb.wr_enb;
            tr.rd_enb        = vif.mon_cb.rd_enb;
            tr.cs            = vif.mon_cb.cs;
            tr.reg_sel       = vif.mon_cb.reg_sel;
            tr.addr          = vif.mon_cb.addr;
            tr.data_in       = vif.mon_cb.data_in;
            tr.full          = vif.mon_cb.full;
            tr.empty         = vif.mon_cb.empty;
            tr.almost_full   = vif.mon_cb.almost_full;
            tr.almost_empty  = vif.mon_cb.almost_empty;
            tr.overflow      = vif.mon_cb.overflow;
            tr.underflow     = vif.mon_cb.underflow;
            tr.data_out      = vif.mon_cb.data_out;
            tr.reg_rdata     = vif.mon_cb.reg_rdata;
            analysis_port.write(tr);
            monitor_count++;
            `uvm_info("FIFO_MON",
                $sformatf("Monitor transaction[%0d]\n%s\n%s\n%s\n%s\n%s",
                          monitor_count,
                          fifo_xtn::table_rule(),
                          fifo_xtn::table_header(),
                          fifo_xtn::table_rule(),
                          tr.table_row("MON", $sformatf("%0d", monitor_count)),
                          fifo_xtn::table_rule()),
                UVM_MEDIUM)
        end
    endtask

endclass



