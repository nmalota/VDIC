module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

	typedef enum bit[2:0] {
		and_op                  = 3'b000,
		or_op                   = 3'b001,
		bad_op1                 = 3'b010,
		bad_op2                 = 3'b011,
		bad_op3                 = 3'b110,
		bad_op4                 = 3'b111,
		add_op                  = 3'b100,
		sub_op                  = 3'b101
	} operation_t;
	
	bit         [31:0]  A;
	bit         [31:0]  B;
	bit                clk;
	bit                rst_n;
	bit				   flag;
	bit                expected_err_data;
	bit                expected_err_op;
	bit                expected_err_crc;
	bit [2:0] A_len;
	bit [2:0] B_len;
	wire        [2:0]  op;
	operation_t        op_set;

	assign op = op_set;

	string             test_result = "PASSED";

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

	bit sin;
	wire sout;
	bit [31:0] C;
	bit [3:0] FLAGS;
	bit ERROR;
	bit [2:0] CRC;
	bit [3:0] CRC_in;


	mtm_Alu u_mtm_Alu (
		.clk  (clk), //posedge active clock
		.rst_n(rst_n), //synchronous reset active low
		.sin  (sin), //serial data input
		.sout (sout) //serial data output
	);


covergroup op_cov;

    option.name = "cg_op_cov";
	
	A_alu_op : coverpoint op_set {
        // #A1 test all operations
        bins A1_valid_op[] = {and_op, or_op, add_op, sub_op};
		// #A2 test incorrect alu op code
        bins A2_invalid_op[] = {bad_op1, bad_op2, bad_op3, bad_op4};
	}
endgroup

covergroup zeros_or_ones_on_ops;

    option.name = "cg_zeros_or_ones_on_ops";

    all_ops : coverpoint op_set {
        bins all_op[] = {and_op, or_op, add_op, sub_op};
    }

    a_leg: coverpoint A {
        bins zeros = {'h0000_0000};
        bins others= {['h0000_0001:'hFFFF_FFFE]};
        bins ones  = {'hFFFF_FFFF};
    }

    b_leg: coverpoint B {
        bins zeros = {'h0000_0000};
        bins others= {['h0000_0001:'hFFFF_FFFE]};
        bins ones  = {'hFFFF_FFFF};
    }

    B_op_00_FF: cross a_leg, b_leg, all_ops {

        // #B1 simulate all zero input for all the operations
        bins B1_add_00          = binsof (all_ops) intersect {add_op} &&
        (binsof (a_leg.zeros) || binsof (b_leg.zeros));

        bins B1_and_00          = binsof (all_ops) intersect {and_op} &&
        (binsof (a_leg.zeros) || binsof (b_leg.zeros));

        bins B1_or_00         	= binsof (all_ops) intersect {or_op} &&
        (binsof (a_leg.zeros) || binsof (b_leg.zeros));

        bins B1_sub_00          = binsof (all_ops) intersect {sub_op} &&
        (binsof (a_leg.zeros) || binsof (b_leg.zeros));

        // #B2 simulate all one input for all the operations
        bins B2_add_FF          = binsof (all_ops) intersect {add_op} &&
        (binsof (a_leg.ones) || binsof (b_leg.ones));

        bins B2_and_FF          = binsof (all_ops) intersect {and_op} &&
        (binsof (a_leg.ones) || binsof (b_leg.ones));

        bins B2_or_FF          	= binsof (all_ops) intersect {or_op} &&
        (binsof (a_leg.ones) || binsof (b_leg.ones));

        bins B2_sub_FF          = binsof (all_ops) intersect {sub_op} &&
        (binsof (a_leg.ones) || binsof (b_leg.ones));

        ignore_bins others_only =
        binsof(a_leg.others) && binsof(b_leg.others);
    }

endgroup

covergroup err_cov;

    option.name = "cg_err_cov";
    
    // #A4 Test operations with incorrect CRC
    err_crc : coverpoint expected_err_crc {
	    bins C2_err_crc = {1'b1};
    }
    
    // #A3 Test operations with incorrect nr of data bits
    err_data_A : coverpoint A_len {
	    bins C3_inv_range_A[] = {[3'd0 : 3'd3]};
    }   
    err_data_B : coverpoint B_len {
	    bins C3_inv_range_B[] = {[3'd0 : 3'd3]};
    }

endgroup

op_cov                      oc;
zeros_or_ones_on_ops        c_00_FF;
err_cov						err_c;

initial begin : coverage
    oc      = new();
    c_00_FF = new();
	err_c	= new();
    forever begin : sample_cov
        @(posedge clk);
        if(flag || !rst_n) begin
            oc.sample();
            c_00_FF.sample();
	        err_c.sample();
        end
    end
end : coverage

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

	initial begin : clk_gen
		clk = 0;
		forever begin : clk_frv
			#10;
			clk = ~clk;
		end
	end
//------------------------------------------------------------------------------
// CRC
//------------------------------------------------------------------------------
	// polynomial: x^4 + x^1 + 1
	// data width: 68
	// convention: the first serial bit is D[67]
	function [3:0] nextCRC4_D68;

		input [67:0] Data;
		input [3:0] crc;
		reg [67:0] d;
		reg [3:0] c;
		reg [3:0] newcrc;
		begin
			d = Data;
			c = crc;

			newcrc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
			newcrc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
			newcrc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
			newcrc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
			nextCRC4_D68 = newcrc;
		end
	endfunction
//---------------------------------
// Random data generation functions
//---------------------------------
	function operation_t get_op();
		bit [2:0] op_choice;
		op_choice = 3'($random);
		case (op_choice)
			3'b000 : return and_op;
			3'b001 : return or_op;
			3'b010 : return bad_op1;
			3'b011 : return bad_op2;
			3'b100 : return add_op;
			3'b101 : return sub_op;
			3'b110 : return bad_op3;
			3'b111 : return bad_op4;
		endcase // case (op_choice)
	endfunction : get_op

//------------------------------------------------------------------
	function bit [31:0] get_data();
		bit [1:0] zero_ones;
		zero_ones = 2'($random);
		if (zero_ones == 2'b00)
			return 32'h00000000;
		else if (zero_ones == 2'b11)
			return 32'hFFFFFFFF;
		else
			return 32'($random);
	endfunction : get_data
	
	function bit [2:0] get_len();
		bit correct;
		correct = 1'($random);
		if (correct)
			return 3'd4;
		else
			return {1'b0, 2'($random)};
	endfunction : get_len
	
	function bit [3:0] get_crc();
		bit correct;
		correct = 1'($random);
		if (correct)
			return nextCRC4_D68({B,A,1'b1,op},0);
		else
			return 4'($random);
	endfunction : get_crc
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
			ERROR = 1'b0;
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
			else
				ERROR = 1'b1;
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
// Tester main

	initial begin : tester
		reset_alu();
		repeat (10000) begin : tester_main
			@(negedge clk);
			reset_alu();
			op_set = get_op();
			A      = get_data();
			B      = get_data();
			A_len  = get_len();
			B_len  = get_len();
			CRC_in = get_crc();
			
			send1data(A,B,op_set,A_len, B_len, CRC_in);
			get1data(C, FLAGS, CRC);
			flag = 1'b1;
//        	if($get_coverage() == 100) break;
		end
		$finish;
	end : tester
//------------------------------------------------------------------------------
	function bit [31:0] get_expected(
			bit [31:0] A,
			bit [31:0] B,
			operation_t op_set
		);
		bit [31:0] ret;
		
	`ifdef DEBUG
		$display("%0t DEBUG: get_expected(%0d,%0d,%0d)",$time, A, B, op_set);
	`endif
		case(op_set)
			and_op : ret = A & B;
			add_op : ret = A + B;
			sub_op : ret = B - A;
			or_op  : ret = A | B;
			default: begin
				$display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, op_set);
				test_result = "FAILED";
				return -1;
			end
		endcase
		return(ret);
	endfunction
//------------------------------------------------------
function void get_expected_error(
			bit [31:0] A,
			bit [31:0] B,
			bit [2:0] A_len,
			bit [2:0] B_len,
			bit [3:0] CRC_in,
			operation_t op_set
		
		);
	
		expected_err_op=1'b0;
		expected_err_data=1'b0;
		expected_err_crc=1'b0;
	
		if((A_len != 3'd4) || (B_len != 3'd4))begin
			expected_err_data = 1'b1;
		end
		else if(CRC_in != nextCRC4_D68({B,A,1'b1,op},0))begin
			expected_err_crc = 1'b1;
		end
		else if(!op_set inside {3'b000, 3'b001, 3'b100, 3'b101}) begin
			expected_err_op = 1'b1;
		end	
	endfunction
// Temporary. The scoreboard data will be later used.
	final begin : finish_of_the_test
		$display("Test %s.",test_result);
	end
//------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
initial 
	forever begin : scoreboard 
	@(negedge clk) 
    if(flag) begin:verify_result
	    if (!ERROR)
			begin
				automatic bit [31:0] expected = get_expected(A, B, op_set);
				CHK_VALUE : assert(C === expected) begin
						`ifdef DEBUG
					$display("Test passed for A=%0d B=%0d op_set=%0d", A, B, op);
						`endif
				end
				else begin
					$display("Test FAILED for A=%0d B=%0d op_set=%0d", A, B, op);
					$display("Expected: %d  received: %d", expected, C);
					test_result = "FAILED";
				end;
			end
	    else begin
		    get_expected_error(A, B, A_len, B_len, CRC_in, op_set);
		    if(expected_err_data)
			    CHK_ERR_DATA : assert(C[30:25] === 6'b100100)else begin
					$display("Test FAILED - expected ERR_DATA");
					$display("Received flags: %b", C[30:25]);
				    test_result = "FAILED";
				end
		    else if(expected_err_crc)
			    CHK_ERR_CRC : assert(C[30:25] === 6'b010010)else begin
					$display("Test FAILED - expected ERR_CRC");
					$display("Received flags: %b", C[30:25]);
				    test_result = "FAILED";
			    end
			else if(expected_err_op)
			    CHK_ERR_OP : assert(C[30:25] === 6'b001001)else begin
					$display("Test FAILED - expected ERR_OP");
					$display("Received flags: %b", C[30:25]);
				    test_result = "FAILED";
			    end
	    end
        flag = 1'b0;
    end
end : scoreboard



endmodule : top







