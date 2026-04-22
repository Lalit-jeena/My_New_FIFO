class read_driver;
virtual fifo_interface.rd_drv_mp rd_drv_inf;
fifo_xtn stim_2_dut_pkt;
mailbox #(fifo_xtn) fifo_gen_2_rd_drv_mbx;

function new(virtual fifo_interface.rd_drv_mp rd_drv_inf, mailbox #(fifo_xtn) fifo_gen_2_rd_drv_mbx);
this.rd_drv_inf = rd_drv_inf;
this.fifo_gen_2_rd_drv_mbx = fifo_gen_2_rd_drv_mbx;
endfunction :new

virtual task drive();
@(rd_drv_inf.rd_drv_cb);
rd_drv_inf.rd_drv_cb.rd_enb <= stim_2_dut_pkt.rd_enb;
endtask :drive

virtual task run();
fork
    forever begin
        fifo_gen_2_rd_drv_mbx.get(stim_2_dut_pkt);
        drive();
    
    end
    
join_none 
    
endtask

endclass


