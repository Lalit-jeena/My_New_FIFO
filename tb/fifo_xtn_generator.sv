
	class fifo_xtn_generator;
		fifo_xtn gen_xtn, rd_drv_xtn, wr_drv_xtn;
		mailbox #(fifo_xtn) gen_2_rd_drv_mbx;
		mailbox #(fifo_xtn) gen_2_wr_drv_mbx;

		function new(mailbox #(fifo_xtn) gen_2_rd_drv_mbx, mailbox #(fifo_xtn) gen_2_wr_drv_mbx );
			this.gen_2_rd_drv_mbx = gen_2_rd_drv_mbx;
			this.gen_2_wr_drv_mbx = gen_2_wr_drv_mbx;
			gen_xtn =  new();
		endfunction

		virtual task run();
			fork 
				for(int i=0; i<no_of_xtn;i++)
					begin
						assert(gen_xtn.randomize());
						gen_xtn.print("********FIFO TRANSACTION GENERATORr**********");
						rd_drv_xtn = new gen_xtn;
						wr_drv_xtn = new gen_xtn;
						gen_2_rd_drv_mbx.put(rd_drv_xtn);
						gen_2_wr_drv_mbx.put(wr_drv_xtn);
					end
			join_none
		endtask

	endclass
