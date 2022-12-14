// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;
   wire [1:0] in;
   wire out;
   

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;
	
    

    // IO
    assign io_out[35] = out;
    assign io_oeb = 0;
    assign clk = wb_clk_i;
    assign rst = wb_rst_i;
    assign in = io_in[35:34]; 
    

    // IRQ
    assign irq = 3'b000;	// Unused

   
    iiitb_ptvm instance (clk,rst,in,out);
    
    
endmodule

module iiitb_ptvm(
	input clk,
	input rst,
	input [1:0]in,
	output reg out
);

parameter s0 = 2'b00;
parameter s1 = 2'b01;
parameter s2 = 2'b10;

reg [1:0]c_state; reg [1:0]n_state;

always @(posedge clk)
	begin
	if(rst)
		begin
		c_state = 0;
		n_state = 0;
		end
	else
		begin
		c_state = n_state;
		case(c_state)
		s0: if(in == 0)
			begin
			n_state = s0;
			out = 0;
			end
		
		else if(in== 2'b01)
			begin
			n_state = s1;
			out = 0;
			end
			
		else if(in == 2'b10)
			begin
			n_state = s2;
			out = 0;
			end
			
		s1: if(in == 0)
			begin
			n_state = s0;
			out = 0;
			end
		
		else if(in== 2'b01)
			begin
			n_state = s2;
			out = 0;
			end
			
		else if(in == 2'b10)
			begin
			n_state = s0;
			out = 1;
			end
			
		s2: if(in == 0)
			begin
			n_state = s0;
			out = 0;
			end
		
		else if(in== 2'b01)
			begin
			n_state = s0;
			out = 1;
			end
			
		else if(in == 2'b10)
			begin
			n_state = s0;
			out = 1;
			end 
			
		endcase
		
		end
	end
	
endmodule

`default_nettype wire
