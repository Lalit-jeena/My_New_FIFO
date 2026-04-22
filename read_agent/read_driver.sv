
	class read_driver;

		virtual fifo_interface.rd_drv_mp rd_drv_intf;
		mailbox #(fifo_xtn) gen_2_rd_drv_mbx;
		fifo_xtn xtn;

		function new(virtual fifo_interface.rd_drv_mp rd_drv_intf, mailbox #(fifo_xtn) gen_2_rd_drv_mbx);
			this.rd_drv_intf = rd_drv_intf;
			this.gen_2_rd_drv_mbx = gen_2_rd_drv_mbx;
		endfunction

		virtual task run();
			fork
				forever
					begin
						gen_2_rd_drv_mbx.get(xtn);
						drive();
					end
			join_none
		endtask

		virtual task drive();
			@(rd_drv_intf.rd_drv_cb);
		  xtn.print($sformatf("%t, READ_DRV: Read driver is about to drive the below pkt", $time));
			rd_drv_intf.rd_drv_cb.rd_enb <= xtn.rd_enb;	
		endtask

	endclass
