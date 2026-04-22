
class read_monitor;

	virtual fifo_interface.rd_mon_mp rd_mon_intf;
	mailbox #(fifo_xtn) rd_mon_2_sb_mbx;
	mailbox #(fifo_xtn) rd_mon_2_rf_mbx;
	fifo_xtn rdmon_xtn;
	fifo_xtn rdmon2sb_xtn;
	fifo_xtn rdmon2rf_xtn;

	function new(virtual fifo_interface.rd_mon_mp rd_mon_intf, mailbox #(fifo_xtn) rd_mon_2_sb_mbx, mailbox #(fifo_xtn) rd_mon_2_rf_mbx);
		this.rd_mon_intf = rd_mon_intf;
		this.rd_mon_2_sb_mbx = rd_mon_2_sb_mbx;
		this.rd_mon_2_rf_mbx = rd_mon_2_rf_mbx;
		rdmon_xtn = new();
	endfunction

	task run();
		fork
			begin
				@(rd_mon_intf.rd_mon_cb);
				forever
					begin
						collect_data();
						rdmon_xtn.print($sformatf("%t, READ_MON: Read Monitor Collected the below packet", $time));
						rdmon2sb_xtn = new rdmon_xtn;
						rdmon2rf_xtn = new rdmon_xtn;
						rd_mon_2_sb_mbx.put(rdmon2sb_xtn);
						rd_mon_2_rf_mbx.put(rdmon2rf_xtn);
					end
			end
		join_none
	endtask

	task collect_data();
			@(rd_mon_intf.rd_mon_cb);
			rdmon_xtn.rd_enb = rd_mon_intf.rd_mon_cb.rd_enb;
			rdmon_xtn.full = rd_mon_intf.rd_mon_cb.full;
			rdmon_xtn.empty = rd_mon_intf.rd_mon_cb.empty;
			rdmon_xtn.almost_full = rd_mon_intf.rd_mon_cb.almost_full;
			rdmon_xtn.almost_empty = rd_mon_intf.rd_mon_cb.almost_empty;
			rdmon_xtn.overflow = rd_mon_intf.rd_mon_cb.overflow;
			rdmon_xtn.underflow = rd_mon_intf.rd_mon_cb.underflow;
			rdmon_xtn.fifo_data_out = rd_mon_intf.rd_mon_cb.fifo_data_out;
			rdmon_xtn.reg_data_out = rd_mon_intf.rd_mon_cb.reg_data_out;

	endtask

endclass
