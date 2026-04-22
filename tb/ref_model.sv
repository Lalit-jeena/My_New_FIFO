class reference_model;

  mailbox #(fifo_xtn) wr_mon_2_rf_mbx;
  mailbox #(fifo_xtn) rd_mon_2_rf_mbx;
  mailbox #(fifo_xtn) ref_2_sb_mbx;

  fifo_xtn wr_xtn, rd_xtn, ref_xtn;

  byte fifo_ram[$];
  bit  clr_pulse;      
  bit  clr_pulse_d1;   

  bit [3:0] af_level = 4'hC;
  bit [3:0] ae_level = 4'h4;

  bit [7:0] status_reg;
	bit read_pending;
	bit write_pending;
	byte write_data_pending;

	bit reg_write_pending;
	byte reg_write_data;
	byte reg_write_addr;

  function new(mailbox #(fifo_xtn) wr_mbx, mailbox #(fifo_xtn) rd_mbx,
               mailbox #(fifo_xtn) sb_mbx);
    wr_mon_2_rf_mbx = wr_mbx;
    rd_mon_2_rf_mbx = rd_mbx;
    ref_2_sb_mbx    = sb_mbx;
    ref_xtn         = new();
  endfunction

  virtual task run();
    fork
      forever 
				begin
        	wr_mon_2_rf_mbx.get(wr_xtn);
        	rd_mon_2_rf_mbx.get(rd_xtn);

        	update_reference_model();

					ref_xtn.print("DEBUG: From Ref Model reference Transaction");
        	ref_2_sb_mbx.put(ref_xtn);
      	end
    join_none
  endtask

  virtual task update_reference_model();

		ref_xtn.rstn     = wr_xtn.rstn;
    ref_xtn.chip_sel = wr_xtn.chip_sel;
    ref_xtn.reg_sel  = wr_xtn.reg_sel;
    ref_xtn.addr     = wr_xtn.addr;
    ref_xtn.data_in  = wr_xtn.data_in;
    ref_xtn.wr_enb   = wr_xtn.wr_enb;
    ref_xtn.rd_enb   = rd_xtn.rd_enb;

    if (!wr_xtn.rstn) 
			begin
      	reset_all();
      return;
    end

		if(write_pending)
			begin
				if(!ref_xtn.full)
				fifo_ram.push_back(write_data_pending);
				write_pending =0;
			end

		if(read_pending)
			begin
				if(!ref_xtn.empty)
				ref_xtn.fifo_data_out = fifo_ram.pop_front();
				read_pending = 0;
			end

			$display("the clear pulse value is %0d", clr_pulse);
			if (clr_pulse) 
			begin
      	fifo_ram.delete();
      	clr_pulse = 0;
				$display("Clearing the fifo due to clear_pulse");
      	ref_xtn.fifo_data_out = 8'h00;
      	ref_xtn.reg_data_out  = 8'h00;
    	end

			if(reg_write_pending)
			begin
				case (reg_write_addr)
          			8'h00: clr_pulse = reg_write_data[1];     
          			8'h08: af_level  = reg_write_data[3:0];
          			8'h0C: ae_level  = reg_write_data[3:0];
        		endcase
				reg_write_pending =0;
			end


   	if (wr_xtn.chip_sel) 
			begin
				if (wr_xtn.reg_sel && wr_xtn.wr_enb) 
					begin
						reg_write_pending = 1;
						reg_write_addr = wr_xtn.addr;
						reg_write_data = wr_xtn.data_in;

        		    end



				if (!wr_xtn.reg_sel && wr_xtn.chip_sel) 
					begin
        		if (wr_xtn.wr_enb && !ref_xtn.full) 
          		begin
								write_pending = 1'b1;
								write_data_pending = wr_xtn.data_in;
							end

        		if (rd_xtn.rd_enb && !ref_xtn.empty) 
          		 read_pending = 1'b1;
        		
      		end

    	end

    update_flags();

    update_reg_read();



		  $display("=======================================================================================");
			$display("%t REFERENCE MODEL: The queue (fifo_ram) size is %0d", $time, fifo_ram.size());
			$display("The content of the queue are %0p",  fifo_ram);
			$display("The Register Values are :");
			$display("Control Register : %0b", clr_pulse); 
			$display("The Status Register are %0b", status_reg);
			$display("the almost_full level reg : %0b", af_level);
		 	$display("the almost empty level reg : %0b", ae_level);
			$display("Fifo Data Register are %0b", fifo_ram[0]);
			$display("The Fifo Count register are %0b", fifo_ram.size());
			$display("========================================================================================");
  endtask

  virtual task reset_all();
    fifo_ram.delete();
    clr_pulse      = 0;
    clr_pulse_d1   = 0;
    af_level       = 4'hC;
    ae_level       = 4'h4;

	read_pending = 0;
	write_pending = 0;
	reg_write_pending = 0;
    ref_xtn.full         = 0;
    ref_xtn.empty        = 1;
    ref_xtn.almost_full  = 0;
    ref_xtn.almost_empty = 1;
    ref_xtn.overflow     = 0;
    ref_xtn.underflow    = 0;
    ref_xtn.fifo_data_out = 8'h00;
    ref_xtn.reg_data_out  = 8'h00;
  endtask

  virtual task update_flags();
    int size = fifo_ram.size();

    ref_xtn.full         = (size == 16);
    ref_xtn.empty        = (size == 0);
    ref_xtn.almost_full  = (size >= af_level);
    ref_xtn.almost_empty = (size <= ae_level);

    ref_xtn.underflow = ref_xtn.empty && rd_xtn.rd_enb && wr_xtn.chip_sel && !wr_xtn.reg_sel;
    ref_xtn.overflow  = ref_xtn.full  && wr_xtn.wr_enb && wr_xtn.chip_sel && !wr_xtn.reg_sel;

    status_reg = {2'b00, ref_xtn.underflow, ref_xtn.overflow,
                  ref_xtn.almost_empty, ref_xtn.almost_full,
                  ref_xtn.empty, ref_xtn.full};
  endtask

  virtual task update_reg_read();
    if (!wr_xtn.rstn || clr_pulse) 
			begin
      	ref_xtn.reg_data_out = 8'h00;
    	end
    else if (wr_xtn.chip_sel && wr_xtn.reg_sel && rd_xtn.rd_enb) 
			begin
      	case (wr_xtn.addr)
        	8'h00: ref_xtn.reg_data_out = 8'h00;
        	8'h04: ref_xtn.reg_data_out = status_reg;
        	8'h08: ref_xtn.reg_data_out = {4'h0, af_level};
        	8'h0C: ref_xtn.reg_data_out = {4'h0, ae_level};
        	8'h10: ref_xtn.reg_data_out = ref_xtn.empty ? 8'h00 : fifo_ram[0];
        	8'h14: ref_xtn.reg_data_out = {3'b000, fifo_ram.size()};
        	default: ref_xtn.reg_data_out = 8'hDE;
      	endcase
    	end
    else 
			begin
      	ref_xtn.reg_data_out = 8'h00;
    	end
  endtask

endclass
