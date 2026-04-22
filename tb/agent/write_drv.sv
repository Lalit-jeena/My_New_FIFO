class fifo_driver extends uvm_driver #(fifo_xtn);

    `uvm_component_utils(fifo_driver)

    virtual fifo_interface vif;
    int unsigned           drive_count;

    function new(string name = "fifo_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fifo_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "virtual interface handle not found for fifo_driver")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        fifo_xtn req;

        forever begin
            seq_item_port.get_next_item(req);
            @(vif.drv_cb);
            vif.drv_cb.rst_n   <= req.rst_n;
            vif.drv_cb.cs      <= req.cs;
            vif.drv_cb.reg_sel <= req.reg_sel;
            vif.drv_cb.wr_enb  <= req.wr_enb;
            vif.drv_cb.rd_enb  <= req.rd_enb;
            vif.drv_cb.addr    <= req.addr;
            vif.drv_cb.data_in <= req.data_in;
            drive_count++;
            `uvm_info("FIFO_DRV",
                $sformatf("Driver transaction[%0d]\n%s\n%s\n%s\n%s\n%s",
                          drive_count,
                          fifo_xtn::table_rule(),
                          fifo_xtn::table_header(),
                          fifo_xtn::table_rule(),
                          req.table_row("DRV", $sformatf("%0d", drive_count)),
                          fifo_xtn::table_rule()),
                UVM_MEDIUM)
            seq_item_port.item_done();
        end
    endtask

endclass


