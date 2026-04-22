
	import fifo_pkg::*;

	class reset_xtn extends fifo_xtn;
	
		constraint reset_gen { rstn dist { 0:= 70, 1:= 30};}
	endclass

	class write_read_xtn extends fifo_xtn;
		int x;
		constraint write_to_fifo {  if (x < 1)
																	rstn == 1'b0;
																else if(x<20)
																{ rstn == 1'b1;
																	chip_sel == 1'b1;
																	reg_sel == 1'b0;
																	rd_enb == 1'b0;
					 												wr_enb == 1'b1;}
																else if (x<50)
																		{
																		wr_enb dist { 0:= 85, 1:= 15};
																		rd_enb == 1'b1;
																		chip_sel == 1'b1;
																		reg_sel == 1'b0;
																		rstn == 1'b1;}
																else 
																	{
																		wr_enb dist {0:=50, 1:=50};
																		rd_enb dist {0:=50, 1:= 50};
																		chip_sel dist { 0:= 50, 1:=50};
																		reg_sel dist {0:= 70, 1:= 30};
																		rstn dist { 0:= 3, 1:=97}; } } 
		function void post_randomize();
			super.post_randomize();
			x++;
		endfunction
	endclass

	class reg_write_xtn extends fifo_xtn;
		int x;

		constraint write_to_registers { if (x<1)
																		rstn == 1'b0;
																		else {
																		rstn == 1'b1;
																		chip_sel dist { 0:=20, 1:= 80};
																		reg_sel dist { 0:=10, 1:=90};
																		wr_enb == 1'b1;}}
		function void post_randomize();
			super.post_randomize();
			$display("the Value of x is %0d", x);
			x++;
		endfunction

	endclass

	class reg_read_xtn extends fifo_xtn;
		int x;
		constraint read_to_registers {if (x<1)
																		rstn == 1'b0;
																		else {
																		 rstn == 1'b1;
																		chip_sel dist { 0:=20, 1:= 80};
																		reg_sel dist { 0:=10, 1:=90};
																		rd_enb == 1'b1;}}
		function void post_randomize();
			super.post_randomize();
			x++;
		endfunction

	endclass

	class fifo_test;

		environment env_h;

		reset_xtn rst_xtn;
		reg_write_xtn rg_wr_xtn;
		reg_read_xtn rg_rd_xtn;
		write_read_xtn wr_rd_xtn;
				


	  virtual fifo_interface.wr_drv_mp wr_drv_intf;
		virtual fifo_interface.wr_mon_mp wr_mon_intf;
		virtual fifo_interface.rd_drv_mp rd_drv_intf;
		virtual fifo_interface.rd_mon_mp rd_mon_intf;

		function new(virtual fifo_interface.wr_drv_mp wr_drv_intf,
								 virtual fifo_interface.wr_mon_mp wr_mon_intf,
								 virtual fifo_interface.rd_drv_mp rd_drv_intf,
								 virtual fifo_interface.rd_mon_mp rd_mon_intf);
			this.wr_drv_intf = wr_drv_intf;
			this.wr_mon_intf = wr_mon_intf;
			this.rd_drv_intf = rd_drv_intf;
			this.rd_mon_intf = rd_mon_intf;
		endfunction

		task build_and_run();
			
			env_h = new(wr_drv_intf, wr_mon_intf, rd_drv_intf, rd_mon_intf);

			if($test$plusargs("TEST1"))
			begin
				no_of_xtn = 50;
				rst_xtn = new();
				env_h.build();
				env_h.xtn_gen.gen_xtn = rst_xtn;
				env_h.run();
				$finish;
			end

		if($test$plusargs("TEST2"))
			begin
				rg_wr_xtn = new();
				no_of_xtn=50;
				env_h.build();
				env_h.xtn_gen.gen_xtn=rg_wr_xtn;
				env_h.run();
				$finish;
			end 

		if($test$plusargs("TEST3"))
			begin
					wr_rd_xtn=new;
					no_of_xtn=150;
					env_h.build();
					env_h.xtn_gen.gen_xtn=wr_rd_xtn;
					env_h.run();
					$finish;
			end 

					if($test$plusargs("TEST4"))
			begin
					rg_rd_xtn=new;
					no_of_xtn=50;
					env_h.build();
					env_h.xtn_gen.gen_xtn=rg_rd_xtn;
					env_h.run();
					$finish;
			end 

		endtask


	endclass
