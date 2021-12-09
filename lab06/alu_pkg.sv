`timescale 1ns/1ps
package alu_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	typedef enum bit[2:0] {and_op  = 3'b000,
		or_op = 3'b001,
		bad_op1 = 3'b010,
		bad_op2 = 3'b011,
		bad_op3 = 3'b110,
		bad_op4 = 3'b111,
		add_op  = 3'b100,
		sub_op  = 3'b101} operation_t;
	
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

	typedef struct packed {
		bit [31:0] A;
		bit [31:0] B;
		bit [3:0] CRC_in;
		bit [2:0] A_len;
		bit [2:0] B_len;
		operation_t        op_set;
	} ALU_in_t;

	typedef struct packed {
		bit [31:0] C;
		bit [3:0] FLAGS;
		bit ERROR;
		bit expected_err_crc;
		bit [2:0] CRC;
	} ALU_out_t;

	`include "coverage.svh"
	`include "base_tester.svh"
	`include "random_tester.svh"
	`include "min_max_tester.svh"
	`include "scoreboard.svh"
	`include "driver.svh"
	`include "command_monitor.svh"
	`include "result_monitor.svh"
	`include "env.svh"
	`include "random_test.svh"
	`include "min_max_test.svh"

endpackage : alu_pkg




