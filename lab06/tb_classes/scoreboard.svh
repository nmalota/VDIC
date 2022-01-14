class scoreboard extends uvm_subscriber#(ALU_out_t);

	`uvm_component_utils(scoreboard)

	//virtual alu_bfm bfm;
	uvm_tlm_analysis_fifo #(ALU_in_t) cmd_f;

	protected string test_result = "PASSED";
	protected bit expected_err_data;
	protected bit expected_err_op;
	protected bit expected_err_crc;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    protected function void print_test_result (test_result r);
        if(tr == TEST_PASSED) begin
            set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
            $write ("-----------------------------------\n");
            $write ("----------- Test PASSED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
        else begin
            set_print_color(COLOR_BOLD_BLACK_ON_RED);
            $write ("-----------------------------------\n");
            $write ("----------- Test FAILED -----------\n");
            $write ("-----------------------------------");
            set_print_color(COLOR_DEFAULT);
            $write ("\n");
        end
    endfunction


	function void build_phase(uvm_phase phase);
		cmd_f = new ("cmd_f", this);
	endfunction : build_phase
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
		expected_err_crc=1'b0;

		if((A_len != 3'd4) || (B_len != 3'd4))begin
			expected_err_data = 1'b1;
		end
		else if(CRC_in != nextCRC4_D68({B,A,1'b1,op_set},0))begin
			expected_err_crc = 1'b1;
		end
		else if(!op_set inside {3'b000, 3'b001, 3'b100, 3'b101}) begin
			expected_err_op = 1'b1;
		end
	endfunction

	function void write(ALU_out_t t);

		ALU_in_t cmd;

		if (!cmd_f.try_get(cmd))
			$fatal(1, "Missing command in self checker");
		if (!t.ERROR)
		begin
			automatic bit [31:0] expected = get_expected(cmd.A, cmd.B, cmd.op_set);
			CHK_VALUE : assert(t.C === expected) begin
						`ifdef DEBUG
				$display("Test passed for A=%0d B=%0d op_set=%0d", A, B, op);
						`endif
			end
			else begin
				$display("Test FAILED for A=%0d B=%0d op_set=%0d", cmd.A, cmd.B, cmd.op_set);
				$display("Expected: %d  received: %d", expected, t.C);
				test_result = "FAILED";
			end;
		end
		else begin
			get_expected_error(cmd.A, cmd.B, cmd.A_len, cmd.B_len, cmd.CRC_in, cmd.op_set);
			if(expected_err_data)
				CHK_ERR_DATA : assert(t.C[30:25] === 6'b100100)else begin
					$display("Test FAILED - expected ERR_DATA");
					$display("Received flags: %b", t.C[30:25]);
					test_result = "FAILED";
				end
			else if(expected_err_crc)
				CHK_ERR_CRC : assert(t.C[30:25] === 6'b010010)else begin
					$display("Test FAILED - expected ERR_CRC");
					$display("Received flags: %b", t.C[30:25]);
					test_result = "FAILED";
				end
			else if(expected_err_op)
				CHK_ERR_OP : assert(t.C[30:25] === 6'b001001)else begin
					$display("Test FAILED - expected ERR_OP");
					$display("Received flags: %b", t.C[30:25]);
					test_result = "FAILED";
				end
		end
	endfunction : write

	function void report_phase(uvm_phase phase);
		if(test_result == "PASSED")begin
			$display("Test is PASSED");
		end else begin
			$display("Test is FAILED");
		end
	endfunction
endclass : scoreboard
