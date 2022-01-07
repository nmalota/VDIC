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
class command_monitor extends uvm_component;
	`uvm_component_utils(command_monitor)

	uvm_analysis_port #(random_command) ap;


//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

	function new (string name, uvm_component parent);
		super.new(name,parent);
	endfunction
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

	function void build_phase(uvm_phase phase);

		alu_agent_config alu_agent_config_h;

		// get the BFM
		if(!uvm_config_db #(alu_agent_config)::get(this, "","config", alu_agent_config_h))
			`uvm_fatal("COMMAND MONITOR", "Failed to get CONFIG");

		// pass the command_monitor handler to the BFM
		alu_agent_config_h.bfm.command_monitor_h = this;

		ap                                           = new("ap",this);
	endfunction : build_phase

//------------------------------------------------------------------------------
// access function for BMF
//------------------------------------------------------------------------------

	function void write_to_monitor(ALU_in_t ALU_in);
		random_command cmd;
		`uvm_info("COMMAND MONITOR",$sformatf("A: %8h B: %8h A_len: %h B_len: %h CRC: %h  op_mode: %s",
				ALU_in.A, ALU_in.B, ALU_in.A_len, ALU_in.B_len, ALU_in.CRC_in, ALU_in.op_set.name()), UVM_HIGH);

		cmd    = new("cmd");
		cmd.A  = ALU_in.A;
		cmd.B  = ALU_in.B;
		cmd.A_len = ALU_in.A_len;
		cmd.B_len = ALU_in.B_len;
		cmd.op_set = ALU_in.op_set;
		cmd.CRC_in = ALU_in.CRC_in;
		ap.write(cmd);

	endfunction : write_to_monitor

endclass : command_monitor

