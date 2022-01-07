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
class result_transaction extends uvm_transaction;

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    	bit [31:0] C;
		bit [3:0] FLAGS;
		bit [2:0] CRC;
		bit ERROR;
		bit expected_err_crc;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "");
        super.new(name);
    endfunction : new
//------------------------------------------------------------------------------
// transaction functions: do_copy, do_compare, convert2string
//------------------------------------------------------------------------------

    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();

endclass : result_transaction

    function void result_transaction::do_copy(uvm_object rhs);
        result_transaction copied_transaction_h;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(copied_transaction_h,rhs)) else
            `uvm_fatal("RESULT TRANSACTION","Failed cast in do_copy");
        C 				 = copied_transaction_h.C;
        FLAGS 			 = copied_transaction_h.FLAGS;
        CRC 			 = copied_transaction_h.CRC;
        ERROR 			 = copied_transaction_h.ERROR;
        expected_err_crc = copied_transaction_h.expected_err_crc;
    endfunction : do_copy

    function string result_transaction::convert2string();
        string s;
        s = $sformatf("C: %8h, FLAGS: %h, CRC: %h, ERROR: %h, expected_err_crc: %h ", C, FLAGS, CRC,ERROR,expected_err_crc);
        return s;
    endfunction : convert2string

    function bit result_transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
        result_transaction RHS;
        bit same;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to compare null transaction");

        same = super.do_compare(rhs, comparer);

        $cast(RHS, rhs);
        same = (C  == RHS.C) && 
        (ERROR == RHS.ERROR) &&
//        (CRC == RHS.CRC) &&
//        (expected_err_crc == RHS.expected_err_crc) &&
//        (FLAGS == RHS.FLAGS) &&
        same;
        return same;
    endfunction : do_compare
