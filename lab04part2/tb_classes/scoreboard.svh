class scoreboard;
	
	virtual alu_bfm bfm;
	function new(virtual alu_bfm b);
		bfm = b;
	endfunction : new
	
	protected string test_result = "PASSED";
	protected bit expected_err_data;
	protected bit expected_err_op;
//------------------------------------------------------------------------------
	protected function bit [31:0] get_expected(
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
	protected function void get_expected_error(
			bit [31:0] A,
			bit [31:0] B,
			bit [2:0] A_len,
			bit [2:0] B_len,
			bit [3:0] CRC_in,
			operation_t op_set
		
		);
	
		expected_err_op=1'b0;
		expected_err_data=1'b0;
		bfm.expected_err_crc=1'b0;
	
		if((A_len != 3'd4) || (B_len != 3'd4))begin
			expected_err_data = 1'b1;
		end
		else if(CRC_in != nextCRC4_D68({B,A,1'b1,bfm.op},0))begin
			bfm.expected_err_crc = 1'b1;
		end
		else if(!op_set inside {3'b000, 3'b001, 3'b100, 3'b101}) begin
			expected_err_op = 1'b1;
		end	
	endfunction

	task execute();
	forever begin : scoreboard 
	@(negedge bfm.clk) 
    if(bfm.flag) begin:verify_result
	    if (!bfm.ERROR)
			begin
				automatic bit [31:0] expected = get_expected(bfm.A, bfm.B, bfm.op_set);
				CHK_VALUE : assert(bfm.C === expected) begin
						`ifdef DEBUG
					$display("Test passed for A=%0d B=%0d op_set=%0d", A, B, op);
						`endif
				end
				else begin
					$display("Test FAILED for A=%0d B=%0d op_set=%0d", bfm.A, bfm.B, bfm.op);
					$display("Expected: %d  received: %d", expected, bfm.C);
					test_result = "FAILED";
				end;
			end
	    else begin
		    get_expected_error(bfm.A, bfm.B, bfm.A_len, bfm.B_len, bfm.CRC_in, bfm.op_set);
		    if(expected_err_data)
			    CHK_ERR_DATA : assert(bfm.C[30:25] === 6'b100100)else begin
					$display("Test FAILED - expected ERR_DATA");
					$display("Received flags: %b", bfm.C[30:25]);
				    test_result = "FAILED";
				end
		    else if(bfm.expected_err_crc)
			    CHK_ERR_CRC : assert(bfm.C[30:25] === 6'b010010)else begin
					$display("Test FAILED - expected ERR_CRC");
					$display("Received flags: %b", bfm.C[30:25]);
				    test_result = "FAILED";
			    end
			else if(expected_err_op)
			    CHK_ERR_OP : assert(bfm.C[30:25] === 6'b001001)else begin
					$display("Test FAILED - expected ERR_OP");
					$display("Received flags: %b", bfm.C[30:25]);
				    test_result = "FAILED";
			    end
	    end
        bfm.flag = 1'b0;
    end 
	end : scoreboard
	endtask : execute
	// Temporary. The scoreboard data will be later used.
	//begin : finish_of_the_test
		//$display("Test %s.",test_result);
	//end
endclass : scoreboard	
	