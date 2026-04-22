	class scoreboard;
		mailbox #(fifo_xtn) rd_mon_2_sb_mbx;	
		mailbox #(fifo_xtn) ref_2_sb_mbx;
		mailbox #(fifo_xtn) wr_mon_2_sb_mbx;
		fifo_xtn rdmon_xtn;
		fifo_xtn refmod_xtn;
		fifo_xtn wrmon_xtn;

		fifo_xtn wr_cov_xtn, rd_cov_xtn;

		event DONE;
		string message;

		int total_no_of_comparisions;
		int no_of_successful_comparisions;
		int no_of_failed_comparisions;

		//need to write the covergroups
		covergroup write_covergroup;
			option.per_instance =1 ;
 
			reset_cp			: coverpoint wr_cov_xtn.rstn { bins ZERO = {0};
																							 bins ONE = {1};}
			trans_reset_cp : coverpoint wr_cov_xtn.rstn { option.at_least = 3; 
																								 bins ZEROTOONE = (0 => 1);
																								 bins ONETOZERO = (1 => 0); }
			chip_sel_cp : coverpoint wr_cov_xtn.chip_sel { bins ZERO = {0};
																									bins ONE = {1}; }
			trans_chip_sel_cp :	coverpoint wr_cov_xtn.chip_sel { bins ZEROTOONE = ( 0 => 1);
																								 bins ONETOZERO = ( 1 => 0);}
			reg_sel_cp : coverpoint wr_cov_xtn.reg_sel { bins FIFO_MODE = {0};
																								bins REG_MODE = {1}; }
			trans_reg_sel_cp	:	coverpoint wr_cov_xtn.reg_sel { bins FIFO_TO_REG = ( 0 => 1);
																									bins REG_TO_FIFO =  (1 => 0);}
			reg_addr_cp : coverpoint wr_cov_xtn.addr { bins CONTROL_REG = {0};
																							bins STATUS_REG = {4};
																							bins ALMOST_FULL_LVL_REG ={8};
																							bins ALMOST_EMPTY_LVL_REG = { 12};
																							bins FIFO_DATA_REG = { 16};
																							bins FIFO_COUNT_REG = {20};
																						 	//ignore_bins NO_REG = {[0:255]} with (! item inside {0, 4, 8, 12, 16, 20});	
																							}
			data_in_cp: coverpoint wr_cov_xtn.data_in { bins FIFO_LEVELS[4] = {[0:15]};
																							 bins CR_REG[] = {0, 2};
																							 bins FIFO_DATA[4] = default;}
			write_enb_cp	:	coverpoint wr_cov_xtn.wr_enb { bins WR_DSB = {0};
																								 bins WR_ENB = {1};}
			trans_write_enb_cp	:	coverpoint wr_cov_xtn.wr_enb { bins WR_DSB_TO_ENB =  (0 => 1);
																											 bins WR_ENB_TO_DSB = ( 1 => 0); }
			reg_mode_wr_enb_addr_cr : cross chip_sel_cp, reg_sel_cp, write_enb_cp, reg_addr_cp { 
																bins WRITE_TO_REG = binsof(chip_sel_cp.ONE) && binsof(reg_sel_cp.REG_MODE) && binsof(write_enb_cp.WR_ENB)&&binsof(reg_addr_cp);}
			reg_addr_data_in_cr : cross /*iff(wr_cov_xtn.rstn && wr_cov_xtn.chip_sel && wr_cov_xtn.reg_sel && wr_cov_xtn.wr_enb)*/ reg_addr_cp, data_in_cp {
														bins WR_CONTROL_REG = binsof(reg_addr_cp.CONTROL_REG) && binsof(data_in_cp.CR_REG);
															bins WR_FULL_LVL_REG	= binsof(reg_addr_cp.ALMOST_FULL_LVL_REG) && binsof(data_in_cp.FIFO_LEVELS);
															bins WR_EMPTY_LVL_REG = binsof(reg_addr_cp.ALMOST_EMPTY_LVL_REG) && binsof(data_in_cp.FIFO_LEVELS);}
			reg_mode_write_enb_cr :	cross reg_sel_cp, write_enb_cp;
			chip_sel_reg_mode_cr : cross reg_sel_cp, chip_sel_cp;
			

					
		endgroup

		covergroup read_covergroup;
			option.per_instance =1;

			read_enb_cp :	coverpoint rd_cov_xtn.rd_enb { bins RD_DSB = {0};
																								 bins RD_ENB = {1};}
			trans_read_enb_cp : coverpoint rd_cov_xtn.rd_enb { bins RD_DSB_TO_ENB = ( 0 => 1);
																										  bins RD_ENB_TO_DSB = (1 => 0);}
			full_cp : coverpoint rd_cov_xtn.full { bins NOT_FULL = {0};
																					bins FULL = {1};}
			trans_full_cp : coverpoint rd_cov_xtn.full {bins NOTFULL_TO_FULL =  (0 => 1);
																							 bins FULL_TO_NOTFULL = (1 => 0);}
			overflow_cp : coverpoint rd_cov_xtn.overflow { bins NOT_OVERFLOW = {0};
																									bins OVERFLOW = {1};}
			trans_overflow_cp : coverpoint rd_cov_xtn.overflow { bins NOTOVERFLOW_TO_OVERFLOW = ( 0 => 1);
																												bins OVERFLOW_TO_NOTOVERFLOW = (1 => 0); }
			almost_full_cp : coverpoint rd_cov_xtn.almost_full { bins NOT_FULL = {0};
																												bins ALMOST_FULL = {1};}
			trans_almost_full_cp : coverpoint rd_cov_xtn.almost_full { bins NOTFULL_TO_ALMOST_FULL = (0=> 1);
																															bins ALMOSTFULL_TO_NOTFULL = (1 => 0);}
			empty_cp : coverpoint rd_cov_xtn.empty { bins NOT_EMPTY = {0};
																						bins EMPTY = {1}; }
			trans_empty_cp : coverpoint rd_cov_xtn.empty { bins NOTEMPTY_TO_EMPTY =(0 => 1);
																									bins EMPTY_TO_NOTEMPTY = (1=> 0);}
			almost_empty_cp : coverpoint rd_cov_xtn.almost_empty { bins  NOT_EMPTY = {0};
																													bins ALMOSTEMPTY = { 1};}
			trans_almost_empty_cp : coverpoint rd_cov_xtn.almost_empty { bins NOTEMPTY_TO_ALMOST_EMPTY=  (0 => 1);
																																bins ALMOSTEMPTY_TO_NOTEMPTY= ( 1 => 0 ); }
			underflow_cp	:	coverpoint rd_cov_xtn.underflow { bins NOT_UNDERFLOW = {0};
																										bins UNDERFLOW = {1};}
			trans_underflow_cp	:	coverpoint rd_cov_xtn.underflow { bins NOTUNDERFLOW_TO_UNDERFLOW = ( 0=>1);
																													bins UNDERFLOW_TO_NOTUNDERFLOW = ( 1 => 0); }
			fifo_data_out_cp	:	coverpoint rd_cov_xtn.fifo_data_out { bins FIFO_DATA_OUT [4] = {[0:$]};}
			reg_data_out_cp	:	coverpoint rd_cov_xtn.reg_data_out { bins REG_DATA_OUT [4] = {[0:$]};} 

			empty_almost_empty_cr : cross empty_cp, almost_empty_cp {
															illegal_bins EMPTY_WO_ALMOSTEMPTY = binsof(empty_cp.EMPTY) && binsof(almost_empty_cp.NOT_EMPTY);}
		  empty_underflow	: cross empty_cp, underflow_cp {
														illegal_bins UNDERFLOW_WO_WMPTY = binsof(empty_cp.NOT_EMPTY) && binsof(underflow_cp.UNDERFLOW);}
			full_almost_full_cr :	cross full_cp , almost_full_cp {
															illegal_bins FULL_WO_ALMOSTFULL = binsof(full_cp.FULL) && binsof(almost_full_cp.NOT_FULL);}
			full_overflow_cr	: cross full_cp, overflow_cp { illegal_bins OVERFLOW_WO_FULL = binsof(overflow_cp.OVERFLOW) && binsof(full_cp.NOT_FULL);} 




		endgroup

		function new(mailbox #(fifo_xtn) rd_mon_2_sb_mbx, ref_2_sb_mbx, wr_mon_2_sb_mbx);
			this.rd_mon_2_sb_mbx = rd_mon_2_sb_mbx;
			this.ref_2_sb_mbx = ref_2_sb_mbx;
			this.wr_mon_2_sb_mbx = wr_mon_2_sb_mbx;

			write_covergroup = new();
			read_covergroup = new();
		endfunction

		virtual task run();
			fork
				forever
					begin
						fork
							begin
								wr_mon_2_sb_mbx.get(wrmon_xtn);
								wr_cov_xtn = new wrmon_xtn;
								write_covergroup.sample();
							end
							begin
								rd_mon_2_sb_mbx.get(rdmon_xtn);
								rd_cov_xtn = new rdmon_xtn;
								read_covergroup.sample();
							end
							begin
								ref_2_sb_mbx.get(refmod_xtn);	
							end
						join
						if(rdmon_xtn.compare(refmod_xtn, message))
							begin
								$display("*********** Comparision is successfull *******************");
								no_of_successful_comparisions++;
								rdmon_xtn.print(message);
							end
						else
							begin
								$display("#####******* Comparision is Failed **********#######");
								no_of_failed_comparisions++;
								rdmon_xtn.print(message);
							end
						total_no_of_comparisions++;
						$display("The Total no comparisions are %0d", total_no_of_comparisions);
						$display(" The Transaction number is %0d", wrmon_xtn.transaction_number);
						if(total_no_of_comparisions == wrmon_xtn.transaction_number)
						-> DONE;
					end
			join_none
		endtask

		function void report();
			$display("-------------------------- Scoreboard Report ---------------------------------");
			$display(" The Total no of transactions compared %0d", total_no_of_comparisions);
			$display(" The no of Successfull comparisions %0d", no_of_successful_comparisions);
			$display(" The no of Failed comparisions %0d", no_of_failed_comparisions);
			$display(" The Write Transaction coverage is %0d", write_covergroup.get_coverage());
			$display(" The Read Transaction coverage is %0d", read_covergroup.get_coverage());
			$display("---------------------------------------------------------------------------------");
		endfunction

	endclass
