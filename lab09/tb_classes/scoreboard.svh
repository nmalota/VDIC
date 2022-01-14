class scoreboard extends uvm_subscriber #(result_transaction);
	`uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typedefs
//------------------------------------------------------------------------------

	typedef enum bit {
		TEST_PASSED,
		TEST_FAILED
	} test_result;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	uvm_tlm_analysis_fifo #(sequence_item) cmd_f;
	local test_result tr = TEST_PASSED; // the result of the current test
	protected bit expected_err_data;
	protected bit expected_err_op;
	protected bit expected_err_crc;
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
	local function void print_test_result (test_result r);
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

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
	function void build_phase(uvm_phase phase);
		cmd_f = new ("cmd_f", this);
	endfunction : build_phase
//------------------------------------------------------------------------------
	protected function result_transaction get_expected(sequence_item ALU_in);

		bit [31:0] ret;
		bit expected_err_op=1'b0;
		bit expected_err_data=1'b0;
		bit expected_err_crc=1'b0;
		result_transaction ALU_out;

		ALU_out = new("ALU_out");




		if((ALU_in.A_len != 3'd4) || (ALU_in.B_len != 3'd4))begin
			expected_err_data = 1'b1;
		end
		else if(ALU_in.CRC_in != nextCRC4_D68({ALU_in.B,ALU_in.A,1'b1,ALU_in.op_set},0))begin
			expected_err_crc = 1'b1;
		end
		else if(!(ALU_in.op_set inside {3'b000, 3'b001, 3'b100, 3'b101})) begin
			expected_err_op = 1'b1;
		end
		ALU_out.ERROR = expected_err_data || expected_err_crc || expected_err_op;
		if(ALU_out.ERROR == 0)begin
			case(ALU_in.op_set)
				and_op : ret = ALU_in.A & ALU_in.B;
				add_op : ret = ALU_in.A + ALU_in.B;
				sub_op : ret = ALU_in.B - ALU_in.A;
				or_op  : ret = ALU_in.A | ALU_in.B;
				default: begin
					$display("%0t INTERNAL ERROR. get_expected: unexpected case argument: %s", $time, ALU_in.op_set);
					tr = TEST_FAILED;
				end
			endcase
			ALU_out.C = ret;
		end
		else begin
			ALU_out.C = {1'b1,expected_err_data, expected_err_crc, expected_err_op, expected_err_data, expected_err_crc, expected_err_op, 1'b1, 24'h0};
		end
		return(ALU_out);
	endfunction

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------

	function void write(result_transaction t);
		string data_str;
		sequence_item cmd;
		result_transaction predicted;
		do 
		if (!cmd_f.try_get(cmd))
			$fatal(1, "Missing command in self checker");
		while(cmd.op_set == rst_op);

		predicted = get_expected(cmd);

		data_str  = { cmd.convert2string(),
			" ==>  Actual \n" , t.convert2string(),
			"/Predicted \n",predicted.convert2string()};

		if (!predicted.compare(t)) begin
			`uvm_error("SELF CHECKER", {"FAIL: ",data_str})
			tr = TEST_FAILED;
		end
		else
			`uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)

	endfunction : write

	function void report_phase(uvm_phase phase);
		print_test_result(tr);
	endfunction
endclass : scoreboard
