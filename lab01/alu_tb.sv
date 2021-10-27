module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

typedef enum bit[2:0] {
	and_op 					= 3'b000,
    or_op                   = 3'b001,
    add_op                  = 3'b100,
    sub_op					= 3'b101
    } operation_t;
bit         [31:0]  A;
bit         [31:0]  B;
bit                clk;
bit                rst_n;
wire        [2:0]  op;
bit                start;
wire               done;
wire        [31:0] result;
operation_t        op_set;

assign op = op_set;

string             test_result = "PASSED";

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

bit sin;
wire sout;
bit [7:0] dataout;
bit ctlout;
bit [31:0] C; 
bit [3:0] FLAGS;
bit ERROR;
bit [2:0] CRC;


mtm_Alu u_mtm_Alu (
	.clk  (clk), //posedge active clock
	.rst_n(rst_n), //synchronous reset active low
	.sin  (sin), //serial data input
	.sout (sout) //serial data output
);


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
    op_choice = $random;
    case (op_choice)
        3'b100 : return add_op;
        3'b000 : return and_op;
        3'b001 : return or_op;
        3'b101 : return sub_op;
    endcase // case (op_choice)
endfunction : get_op
//------------------------------------------------------------------
function byte get_data();
    bit [1:0] zero_ones;
    zero_ones = 2'($random);
    if (zero_ones == 2'b00)
        return 8'h00;
    else if (zero_ones == 2'b11)
        return 8'hFF;
    else
        return 8'($random);
endfunction : get_data
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
task send1data (input bit [31:0] A, input bit [31:0] B, input bit [2:0] OP);
	begin 
		for (int i=0; i<4; i++)
			begin
				send1byte(B[31-8*i -: 8], 1'b0);
			end
		for (int i=0; i<4; i++)
			begin
				send1byte(A[31-8*i -: 8], 1'b0);
			end
		send1byte({1'b0,OP,nextCRC4_D68({B,A,1'b1,OP},0)}, 1'b1);
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
task get1data (output bit [31:0] C, output bit ctlout,output bit [3:0] FLAGS,output bit ERROR,output bit [2:0] CRC);
	begin 
		bit [7:0] data;
		get1byte(C[31:24],ctlout);
		if (ctlout==0)
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
			ERROR = 1;
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
    @(negedge clk);
	sin=1'b1;
    rst_n = 1'b1;
endtask
//------------------------------------------------------------------------------
// Tester main

initial begin : tester
    reset_alu();
	send1data(32'b00000000000000000000000000001111,32'b00000000000000000000000000010100, 3'b111);
	get1data(C, ctlout,FLAGS, ERROR, CRC );
	$display("C %0b, ctlout %0b, FLAGS %0b, ERROR %0b, CRC %0b", C, ctlout, FLAGS, ERROR, CRC);
    $finish;
end : tester
//------------------------------------------------------------------------------



endmodule : top







