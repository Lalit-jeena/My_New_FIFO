
class write_monitor;

	virtual fifo_interface.wr_mon_mp wr_mon_intf;
	mailbox #(fifo_xtn) wr_mon_2_sb_mbx;
	mailbox #(fifo_xtn) wr_mon_2_rf_mbx;
	fifo_xtn wrmon_xtn;
	fifo_xtn wrmon2sb_xtn;
	fifo_xtn wrmon2rf_xtn;

	function new(virtual fifo_interface.wr_mon_mp wr_mon_intf, mailbox #(fifo_xtn) wr_mon_2_sb_mbx, mailbox #(fifo_xtn) wr_mon_2_rf_mbx);
		this.wr_mon_intf = wr_mon_intf;
		this.wr_mon_2_sb_mbx = wr_mon_2_sb_mbx;
		this.wr_mon_2_rf_mbx = wr_mon_2_rf_mbx;
		wrmon_xtn = new();
	endfunction

	virtual task run();
		fork
			begin
				@(wr_mon_intf.wr_mon_cb);
				forever
					begin
						collect_data();
						wrmon_xtn.print($sformatf("%t, WRITE_MON: Write Monitor Collected the below packet", $time));
						wrmon2sb_xtn = new wrmon_xtn;
						wrmon2rf_xtn = new wrmon_xtn;
						wr_mon_2_sb_mbx.put(wrmon2sb_xtn);
						wr_mon_2_rf_mbx.put(wrmon2rf_xtn);
				end
			end
		join_none
	endtask

	virtual task collect_data();
		@(wr_mon_intf.wr_mon_cb);
			wrmon_xtn.rstn = wr_mon_intf.wr_mon_cb.rstn;
			wrmon_xtn.chip_sel = wr_mon_intf.wr_mon_cb.chip_sel;
			wrmon_xtn.reg_sel = wr_mon_intf.wr_mon_cb.reg_sel;
			wrmon_xtn.addr = wr_mon_intf.wr_mon_cb.addr;
			wrmon_xtn.data_in = wr_mon_intf.wr_mon_cb.data_in;
			wrmon_xtn.wr_enb = wr_mon_intf.wr_mon_cb.wr_enb;
	endtask

endclass

