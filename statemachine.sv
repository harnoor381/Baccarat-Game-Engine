module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

// The code describing your state machine will go here.  Remember that
// a state machine consists of next state logic, output logic, and the 
// registers that hold the state.  You will want to review your notes from
// CPEN 211 or equivalent if you have forgotten how to write a state machine.

    enum {s0, s1, s2, s3, s4, s5, s6} ps;
    
    always_ff @(posedge slow_clock) begin 
        if(!resetb) begin
            dealer_win_light <= 1'b0;
            player_win_light <= 1'b0;
            {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
            ps <= s0;
        end
        else begin 
            case(ps)
                s0 : begin //loading pc1
                    dealer_win_light <= 1'b0;
                    player_win_light <= 1'b0;
                    {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                    ps <= s1;
                end
                s1 : begin //loading dc1
                    {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0};
                    ps <= s2;
                end
                s2 : begin //loading pc2
                    {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0};
                    ps <= s3;
                end
                s3 : begin //loading dc2
                    {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0};
                    ps <= s4;
                end
                s4 : begin //checking natural and checking loading for pcard3
                    if(pscore > 4'b0111 || dscore > 4'b0111) begin //scores 8 or 9
                        {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                        ps <= s5;
                    end
                    else if(pscore < 4'b0110) begin //pscore less than 6 so load 3rd card
                        {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0};
                        ps <= s6;
                    end
                    else begin //pscore is 6 or 7 so no 3rd card
                        {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                        ps <= s6;
                    end
                end
                s5 : begin //display winner
                    if(dscore > pscore)
                        dealer_win_light <= 1'b1;
                    else if(dscore < pscore)
                        player_win_light <= 1'b1;
                    else begin 
                        dealer_win_light <= 1'b1;
                        player_win_light <= 1'b1;
                    end
                    {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                    ps <= s0;
                end
                s6 : begin //checking loading for dcard3
                    if(dscore > 4'b0110) begin //dscore greater than 6
                        {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                        ps <= s5;
                    end
                    //dealer gets 3rd card
                    else if(dscore == 4'b0110 && (pcard3 == 4'b0110 || pcard3 == 4'b0111)) begin //dscore is 6 and pcard3 is 6 or 7
                        {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
                        ps <= s5;
                    end
                    else if(dscore == 4'b0101 && (pcard3 > 4'b0011 && pcard3 < 4'b1000)) begin //dscore is 5 and pcard3 is 4 to 7
                        {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
                        ps <= s5;
                    end
                    else if(dscore == 4'b0100 && (pcard3 > 4'b0001 || pcard3 < 4'b1000)) begin //dscore is 4 and pcard3 is 2 to 7
                        {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
                        ps <= s5;
                    end
                    else if(dscore == 4'b0011 && pcard3 < 4'b1000) begin //dscore is 3 and pcard3 is less than 8
                        {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
                        ps <= s5;
                    end
                    else if(dscore < 4'b0011) begin //dscore is less than 3
                        {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
                        ps <= s5;
                    end
                    else begin //no dcard3 loaded
                        {load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3} <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                        ps <= s5;
                    end
                end
                default : ps <= s0;
            endcase
        end
    end
endmodule

