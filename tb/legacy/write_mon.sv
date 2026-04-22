class wr_monitor;
virtual fifo_interface.wr_mon_mp wr_mon_inf ;
fifo_xtn wr_mon_pkt;

mailbox #(fifo_xtn) wr_mon_2_sb_mbx;
mailbox #(fifo_xtn) wr_mon_2_ref_mod_mbx;

function new(virtual fifo_interface.wr_mon_mp wr_mon_inf, mailbox #(fifo_xtn) wr_mon_2_ref_mod_mbx, mailbox #(fifo_xtn) wr_mon_2_sb_mbx);
 this.wr_mon_inf = wr_mon_inf;
 this.wr_mon_2_ref_mod_mbx = wr_mon_2_ref_mod_mbx;
 this.wr_mon_2_sb_mbx = wr_mon_2_sb_mbx;

endfunction :new

virtual task collect_data();
@(wr_mon_inf.wr_mon_cb);
wr_mon_pkt.data_in =  wr_mon_inf.wr_mon_cb.data_in;
wr_mon_pkt.rst_n = wr_mon_inf.wr_mon_cb.rst_n;
wr_mon_pkt.wr_enb = wr_mon_inf.wr_mon_cb.wr_enb;
wr_mon_pkt.cs = wr_mon_inf.wr_mon_cb.cs;
wr_mon_pkt.reg_sel= wr_mon_inf.wr_mon_cb.reg_sel;
wr_mon_pkt.addr= wr_mon_inf.wr_mon_cb.addr;
endtask

virtual task run();
fork
    begin
        @(wr_mon_inf.wr_mon_cb);
        forever begin
            this.wr_mon_pkt = new();
            collect_data();
            wr_mon_2_sb_mbx.put(wr_mon_pkt);
            wr_mon_2_ref_mod_mbx.put(wr_mon_pkt);
        end
    end
join_none
endtask:run

endclass
