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
class result_monitor extends uvm_component;
	`uvm_component_utils(result_monitor)
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	uvm_analysis_port #(result_transaction) ap;
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
		virtual alu_bfm bfm;
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
			$fatal(1, "Failed to get BFM");
		bfm.result_monitor_h = this;
		ap                   = new("ap",this);
	endfunction : build_phase

//------------------------------------------------------------------------------
// access function for BFM
//------------------------------------------------------------------------------

	function void write_to_monitor(ALU_out_t r);
		result_transaction result_t;
		result_t        = new("result_t");
		
		result_t.C 				  = r.C;
		result_t.CRC 			  = r.CRC;
		result_t.ERROR 			  = r.ERROR;
		result_t.expected_err_crc = r.expected_err_crc;
		result_t.FLAGS 			  = r.FLAGS;
		
		ap.write(result_t);
	endfunction : write_to_monitor

endclass : result_monitor






