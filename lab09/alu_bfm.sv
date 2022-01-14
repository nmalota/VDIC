`timescale 1ns/1ps
interface alu_bfm;
	import alu_pkg::*;


//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

	bit sin;
	wire sout;
	bit clk;
	bit rst_n = 1'b1;

	ALU_in_t ALU_input;
	ALU_out_t ALU_output;
	bit                flag;
//------------------------------------------------------------------------------
// local variables
//-----------------------------------------------------------------------------
	command_monitor command_monitor_h;
	result_monitor result_monitor_h;
//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

	initial begin : clk_gen
		sin = 1;
		clk = 0;
		forever begin : clk_frv
			#10;
			clk = ~clk;
		end
	end


//------------------------------------------------------------------------------
// sending tasks
//------------------------------------------------------------------------------
	task send1byte (input [7:0] data_tmp, input ctl);
		begin
			reg [10:0] data;
			data = {1'b0, ctl, data_tmp, 1'b1};
			for (int i=0; i<11; i++)
			begin
				@(negedge clk);
				sin = data[10-i];
			end
		end
	endtask
//------------------------------------------------------------------------------
	task send1data (input bit [31:0] A, input bit [31:0] B, input bit [2:0] OP, bit[2:0] A_len, bit[2:0] B_len, bit [3:0] CRC_in );
		begin
			for (int i=0; i<B_len; i++)
			begin
				send1byte(B[31-8*i -: 8], 1'b0);
			end
			for (int i=0; i<A_len; i++)
			begin
				send1byte(A[31-8*i -: 8], 1'b0);
			end
			send1byte({1'b0,OP,CRC_in}, 1'b1);
		end
	endtask
//------------------------------------------------------------------------------
// receiving tasks
//------------------------------------------------------------------------------
	task get1byte (output [7:0] data, output ctl);
		begin
			reg [10:0] dataout;
			@(negedge sout);
			for (int i=0; i<11; i++)
			begin
				@(negedge clk);
				dataout[10-i] = sout;
			end
			ctl = dataout[9];
			data = dataout[8:1];
		end
	endtask
//------------------------------------------------------------------------------
	task get1data (output bit [31:0] C,output bit [3:0] FLAGS, output bit [2:0] CRC);
		begin
			bit ctlout;
			bit [7:0] data;
			ALU_output.ERROR = 1'b0;
			get1byte(C[31:24],ctlout);
			if (ctlout==1'b0)
			begin
				for (int i=1; i<4; i++)
				begin
					get1byte(C[31-8*i -: 8], ctlout);
				end
				get1byte(data[7:0], ctlout);
				FLAGS = data[6:3];
				CRC = data[2:0];
			end
			else begin
				ALU_output.ERROR = 1'b1;
				C[23:0] = 24'h0;
			end
		end
	endtask
//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------
	task reset_alu();
	`ifdef DEBUG
		$display("%0t DEBUG: reset_alu", $time);
	`endif
		rst_n = 1'b0;
		sin=1'b0;
		#100;
		@(negedge clk);
		sin=1'b1;
		rst_n = 1'b1;
	endtask
//------------------------------------------------------------------------------
	task send_op(input ALU_in_t ALU_in);
		
		ALU_input = ALU_in;

		if (ALU_in.op_set == rst_op ) reset_alu();
		else begin
			send1data(ALU_in.A, ALU_in.B, ALU_in.op_set, ALU_in.A_len, ALU_in.B_len, ALU_in.CRC_in);
			get1data(ALU_output.C, ALU_output.CRC, ALU_output.FLAGS);
			flag = 1'b1;
		end
			@(negedge clk);
	endtask : send_op
//------------------------------------------------------------------------------


	initial begin
		
		forever begin : op_monitor
			@(posedge clk);
			if(flag) begin : s_r
				
					command_monitor_h.write_to_monitor(ALU_input);
			
			end : s_r
		end : op_monitor
	end

  initial begin : rst_monitor
      forever begin
          @(negedge rst_n)
          ALU_input.op_set = rst_op;
              if (command_monitor_h != null) //guard against VCS time 0 negedge
              begin
                  command_monitor_h.write_to_monitor(ALU_input);
              end
      end
  end : rst_monitor

	initial begin : result_monitor_thread
		forever begin
			@(posedge clk) ;
			if (flag) begin
				result_monitor_h.write_to_monitor(ALU_output);
			end
			flag = 1'b0;
		end
	end : result_monitor_thread

endinterface : alu_bfm







