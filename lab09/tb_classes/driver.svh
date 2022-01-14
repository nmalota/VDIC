/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
class driver extends uvm_driver #(sequence_item);
	`uvm_component_utils(driver)

	protected virtual alu_bfm bfm;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
			$fatal(1, "Failed to get BFM");
	endfunction : build_phase

//------------------------------------------------------------------------------
// run_phase
//------------------------------------------------------------------------------

	task run_phase(uvm_phase phase);
		sequence_item command;

		void'(begin_tr(command));

		forever begin : command_loop
			ALU_in_t ALU_in;
			shortint unsigned result;
			seq_item_port.get_next_item(command);

			ALU_in.A = command.A;
			ALU_in.B = command.B;
			ALU_in.A_len = command.A_len;
			ALU_in.B_len = command.B_len;
			ALU_in.op_set = command.op_set;
			ALU_in.CRC_in = command.CRC_in;
			bfm.send_op(ALU_in);
			seq_item_port.item_done();
		end : command_loop
		end_tr(command);
	endtask : run_phase



endclass : driver

