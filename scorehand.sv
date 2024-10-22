module scorehand(input logic [3:0] card1, input logic [3:0] card2, input logic [3:0] card3, output logic [3:0] total);

// The code describing scorehand will go here.  Remember this is a combinational
// block. The function is described in the handout. Be sure to review Verilog
// notes on bitwidth mismatches and signed/unsigned numbers.

    logic [4:0] score;
    logic [3:0] value1, value2, value3;

    always_comb begin
        value1 = (card1>4'b1001) ? 4'b0000 : card1; // greater than 9
        value2 = (card2>4'b1001) ? 4'b0000 : card2; // greater than 9
        value3 = (card3>4'b1001) ? 4'b0000 : card3; // greater than 9
        score = (value1 + value2 + value3) % 10;
    end
    assign total = score;
endmodule

