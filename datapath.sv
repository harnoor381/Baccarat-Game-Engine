module datapath(input logic slow_clock, input logic fast_clock, input logic resetb,
                input logic load_pcard1, input logic load_pcard2, input logic load_pcard3,
                input logic load_dcard1, input logic load_dcard2, input logic load_dcard3,
                output logic [3:0] pcard3_out,
                output logic [3:0] pscore_out, output logic [3:0] dscore_out,
                output logic [6:0] HEX5, output logic [6:0] HEX4, output logic [6:0] HEX3,
                output logic [6:0] HEX2, output logic [6:0] HEX1, output logic [6:0] HEX0);

// The code describing your datapath will go here.  Your datapath 
// will hierarchically instantiate six card7seg blocks, two scorehand
// blocks, and a dealcard block.  The registers may either be instatiated
// or included as sequential always blocks directly in this file.
//
// Follow the block diagram in the Lab 1 handout closely as you write this code.
    logic [3:0] pcard1;
    logic [3:0] pcard2;
    logic [3:0] pcard3;
    logic [3:0] dcard1;
    logic [3:0] dcard2;
    logic [3:0] dcard3;
    logic [3:0] dealcard;
    logic [3:0] pscore;
    logic [3:0] dscore;

    dealcard dc(fast_clock, resetb, dealcard);

    vDFFE #(4) p1(slow_clock, load_pcard1, resetb, dealcard, pcard1);
    vDFFE #(4) p2(slow_clock, load_pcard2, resetb, dealcard, pcard2);
    vDFFE #(4) p3(slow_clock, load_pcard3, resetb, dealcard, pcard3);
    vDFFE #(4) d1(slow_clock, load_dcard1, resetb, dealcard, dcard1);
    vDFFE #(4) d2(slow_clock, load_dcard2, resetb, dealcard, dcard2);
    vDFFE #(4) d3(slow_clock, load_dcard3, resetb, dealcard, dcard3);

    card7seg c1(.card(pcard1), .seg7(HEX0));
    card7seg c2(.card(pcard2), .seg7(HEX1));
    card7seg c3(.card(pcard3), .seg7(HEX2));
    card7seg c4(.card(dcard1), .seg7(HEX3));
    card7seg c5(.card(dcard2), .seg7(HEX4));
    card7seg c6(.card(dcard3), .seg7(HEX5));

    scorehand shp(.card1(pcard1), .card2(pcard2), .card3(pcard3), .total(pscore));
    scorehand shd(.card1(dcard1), .card2(dcard2), .card3(dcard3), .total(dscore));

    always_comb begin 
        pcard3_out = pcard3;
        pscore_out = pscore;
        dscore_out = dscore;
    end

endmodule

module vDFFE (clk, en, resetb, in, out);
	parameter n = 1;
	input clk, en, resetb;
	input [n-1:0] in;
	output logic [n-1:0] out;
	
	always_ff @ (posedge clk) begin 
        if(!resetb)
            out <= {4{1'b0}};
        else
            out <= en ? in : out;
    end
endmodule