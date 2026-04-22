
	class write_driver;

		virtual fifo_interface.wr_drv_mp wr_drv_intf;
		mailbox #(fifo_xtn) gen_2_wr_drv_mbx;
		fifo_xtn xtn;

		function new(virtual fifo_interface.wr_drv_mp wr_drv_intf, mailbox #(fifo_xtn) gen_2_wr_drv_mbx);
			this.wr_drv_intf = wr_drv_intf;
			this.gen_2_wr_drv_mbx = gen_2_wr_drv_mbx;
		endfunction

		virtual task run();
			fork
				begin
				  wr_drv_intf.wr_drv_cb.rstn <= 1'b0;
					forever
						begin
							gen_2_wr_drv_mbx.get(xtn);
							drive();
						end
				end
			join_none
		endtask

		virtual task drive();
			@(wr_drv_intf.wr_drv_cb);
			xtn.print($sformatf("%t, WRITE_DRV: Write Driver about to drive the below packets", $time));
			wr_drv_intf.wr_drv_cb.rstn <= xtn.rstn;
			wr_drv_intf.wr_drv_cb.chip_sel <= xtn.chip_sel;
			wr_drv_intf.wr_drv_cb.reg_sel <= xtn.reg_sel;
			wr_drv_intf.wr_drv_cb.addr <= xtn.addr;
			wr_drv_intf.wr_drv_cb.data_in <= xtn.data_in;
			wr_drv_intf.wr_drv_cb.wr_enb <= xtn.wr_enb;
	
		endtask

	endclass

