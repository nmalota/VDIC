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
class driver extends uvm_component;
    `uvm_component_utils(driver)

    virtual alu_bfm bfm;
    uvm_get_port #(random_command) command_port;
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
        command_port = new("command_port",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// run_phase
//------------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
	    random_command command;
        ALU_in_t ALU_in;
        shortint result;

        forever begin : command_loop
            command_port.get(command);
	        ALU_in.A = command.A;
	        ALU_in.B = command.B;
	        ALU_in.A_len = command.A_len;
	        ALU_in.B_len = command.B_len;
	        ALU_in.op_set = command.op_set;
	        ALU_in.CRC_in = command.CRC_in;
            bfm.send_op(ALU_in);
        end : command_loop
    endtask : run_phase



endclass : driver

