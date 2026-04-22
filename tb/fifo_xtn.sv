
	class fifo_xtn;
		rand bit rstn;
		rand bit chip_sel;
		rand bit reg_sel;
		rand bit [7:0] addr;
		rand bit [7:0] data_in;
		rand bit wr_enb;
		rand bit rd_enb;

		bit full;
		bit empty;
		bit almost_full;
		bit almost_empty;
		bit overflow;
		bit underflow;
		bit [7:0] fifo_data_out;
		bit [7:0] reg_data_out;

		static int transaction_number;
		static int fifo_write_transaction_number;
		static int fifo_read_transaction_number;
		static int reg_write_transaction_number;
		static int reg_read_transaction_number;

		constraint reg_addr { addr inside {[8'h0: 8'h14]};
													addr[1:0] == 0;}
		constraint chip_sel_mode { chip_sel dist { 0:=25, 1:=75};}
		constraint write_read_enb { wr_enb dist {0:=30, 1:=70};
																rd_enb dist {0:=30, 1:=70};}


		function void print(input string message="");
			$display("=========================================================================");
			$display("%s", message);
			if(message == "********FIFO TRANSACTION GENERATORr**********")
				begin
					$display("The Transaction number is %0d", transaction_number);
					if(rstn && chip_sel && reg_sel)
						begin
							if(wr_enb)
								$display("Register type Write Transaction number is %0d", reg_write_transaction_number);
							if(rd_enb)
								$display("Register type Read Transaction number is %0d", reg_read_transaction_number);
						end
					if(rstn && chip_sel && !reg_sel)
						begin
							if(wr_enb)
								$display("Fifo type Write Transaction number is %0d", fifo_write_transaction_number);
							if(rd_enb)
								$display("Fifo type Read Transaction number is %0d", fifo_read_transaction_number);
						end
				end
			$display("Reset : %0b", rstn);
			$display("Chip Select : %0b", chip_sel);
			$display("Register Select : %0b", reg_sel);
			$display("Address of Regsister : %0b", addr);
			$display("Input Data : %0b", data_in);
			$display("Write Enable : %0b", wr_enb);
			$display("Read Enable : %0b", rd_enb);
			$display("Fifo Full : %0b", full);
			$display("Fifo Empty : %0b", empty);
			$display("Almost Full : %0b", almost_full);
			$display("Almost Empty : %0b", almost_empty);
			$display("Fifo Overflow : %0b", overflow);
			$display("Fifo Underflow : %0b", underflow);
			$display("Fifo Data out : %0b", fifo_data_out);
			$display("Register Data Out : %0b", reg_data_out);
			$display("==========================================================================");
		endfunction

		function bit compare(input fifo_xtn ref_mod_xtn, output string message);
			ref_mod_xtn.print(" from comparision logic --ref_mode xtn");
			if(! this.full == ref_mod_xtn.full)
				begin
					message="---------1, Full Comparision Failed----------------";
					return(0);
				end
			else if(!this.empty == ref_mod_xtn.empty)
				begin
					message="---------2, Empty Comparision Failed----------------";
					return(0);
				end
			else if(!this.almost_full == ref_mod_xtn.almost_full)
				begin
					message="---------3, Almost Full Comparision Failed----------------";
					return(0);
				end
			else if(!this.almost_empty == ref_mod_xtn.almost_empty)
				begin
					message="---------4, Almost Empty Comparision Failed----------------";
					return(0);
				end
			else if(!this.overflow == ref_mod_xtn.overflow)
				begin
					message="---------5, Overflow Comparision Failed----------------";
					return(0);
				end
			else if(!this.underflow == ref_mod_xtn.underflow)
				begin
					message="---------6, Underflow Comparision Failed----------------";
					return(0);
				end
			else if(!this.fifo_data_out == ref_mod_xtn.fifo_data_out)
				begin
					message="---------7, Fifo Data Comparision Failed----------------";
					return(0);
				end
			else if(!this.reg_data_out == ref_mod_xtn.reg_data_out)
				begin
					message="---------8, Reg Data Comparision Failed----------------";
					return(0);
				end
			else
				begin	
					message="---------------Peffect Match---------------------------";
					return(1);
				end
		endfunction

		function void post_randomize();
			if(rstn && chip_sel && reg_sel)
				begin
					if(wr_enb)
						reg_write_transaction_number++;
					if(rd_enb)
						reg_read_transaction_number++;
				end
			if(rstn && chip_sel && !reg_sel)
				begin
					if(wr_enb)
						fifo_write_transaction_number++;
					if(rd_enb)
						fifo_read_transaction_number++;
				end

				transaction_number ++;

		endfunction

	endclass
