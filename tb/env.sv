
	class environment;
		
		virtual fifo_interface.wr_drv_mp wr_drv_intf;
		virtual fifo_interface.wr_mon_mp wr_mon_intf;
		virtual fifo_interface.rd_drv_mp rd_drv_intf;
		virtual fifo_interface.rd_mon_mp rd_mon_intf;
		
		fifo_xtn_generator xtn_gen;
		reference_model ref_mod;
		scoreboard sb_h;

		read_driver rd_drvh;
		read_monitor rd_monh;

		write_driver wr_drvh;
		write_monitor wr_monh;

		
		mailbox #(fifo_xtn) gen_2_rd_drv_mbx;
		mailbox #(fifo_xtn) gen_2_wr_drv_mbx;

		mailbox #(fifo_xtn) wr_mon_2_rf_mbx;
		mailbox #(fifo_xtn) rd_mon_2_rf_mbx;
		mailbox #(fifo_xtn) ref_2_sb_mbx;

		mailbox #(fifo_xtn) rd_mon_2_sb_mbx;	
		mailbox #(fifo_xtn) wr_mon_2_sb_mbx;

		function new(virtual fifo_interface.wr_drv_mp wr_drv_intf,
								 virtual fifo_interface.wr_mon_mp wr_mon_intf,
								 virtual fifo_interface.rd_drv_mp rd_drv_intf,
								 virtual fifo_interface.rd_mon_mp rd_mon_intf);
			this.wr_drv_intf = wr_drv_intf;
			this.wr_mon_intf = wr_mon_intf;
			this.rd_drv_intf = rd_drv_intf;
			this.rd_mon_intf = rd_mon_intf;
		endfunction

		function void build();
	
			gen_2_rd_drv_mbx = new();
			gen_2_wr_drv_mbx= new();

			wr_mon_2_rf_mbx = new();
			rd_mon_2_rf_mbx = new();
			ref_2_sb_mbx = new();

			rd_mon_2_sb_mbx = new();	
			wr_mon_2_sb_mbx =new();


			xtn_gen = new(gen_2_rd_drv_mbx, gen_2_wr_drv_mbx);
			ref_mod = new(wr_mon_2_rf_mbx, rd_mon_2_rf_mbx, ref_2_sb_mbx);
			sb_h = new(rd_mon_2_sb_mbx, ref_2_sb_mbx, wr_mon_2_sb_mbx);

			rd_drvh = new(rd_drv_intf, gen_2_rd_drv_mbx);
			rd_monh = new(rd_mon_intf, rd_mon_2_sb_mbx, rd_mon_2_rf_mbx);

			wr_drvh = new(wr_drv_intf, gen_2_wr_drv_mbx);
			wr_monh = new(wr_mon_intf, wr_mon_2_sb_mbx, wr_mon_2_rf_mbx);
		endfunction


		virtual task run();
			xtn_gen.run();
			ref_mod.run();
			sb_h.run();

			rd_drvh.run();
			rd_monh.run();

			wr_drvh.run();
			wr_monh.run();

			stop();
		endtask

		task stop();
			wait(sb_h.DONE.triggered);
			sb_h.report();
		endtask


	endclass
