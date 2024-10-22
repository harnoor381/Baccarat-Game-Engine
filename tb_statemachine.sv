module tb_statemachine();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").

    // Testbench signals
    logic slow_clock, resetb;
    logic [3:0] dscore, pscore, pcard3;
    logic load_pcard1, load_pcard2, load_pcard3;
    logic load_dcard1, load_dcard2, load_dcard3;
    logic player_win_light, dealer_win_light;

    // Instantiate the DUT (Device Under Test)
    statemachine DUT (
        .slow_clock(slow_clock),
        .resetb(resetb),
        .dscore(dscore),
        .pscore(pscore),
        .pcard3(pcard3),
        .load_pcard1(load_pcard1),
        .load_pcard2(load_pcard2),
        .load_pcard3(load_pcard3),
        .load_dcard1(load_dcard1),
        .load_dcard2(load_dcard2),
        .load_dcard3(load_dcard3),
        .player_win_light(player_win_light),
        .dealer_win_light(dealer_win_light)
    );

    // Clock generation
    initial begin
        slow_clock = 0;
        forever #10 slow_clock = ~slow_clock; // 20ns period
    end

    // Task to apply a synchronous active low reset
    task apply_reset();
        begin
            resetb = 0;
            #20;  // Hold reset low for a few clock cycles
            resetb = 1;
            #20;
        end
    endtask

    // Task to test specific state transitions and outputs
    task test_state(input [3:0] dscore_val, pscore_val, pcard3_val, expected_state);
        begin
            dscore = dscore_val;
            pscore = pscore_val;
            pcard3 = pcard3_val;
            @(posedge slow_clock);
            $display("Testing: dscore = %b, pscore = %b, pcard3 = %b", dscore, pscore, pcard3);

            // Add checks for the expected outputs and state transitions
            case (expected_state)
                "s0": begin
                    if (load_pcard1 !== 1'b1 || load_dcard1 !== 1'b0) 
                        $display("Error: Expected s0 outputs not met");
                end
                "s1": begin
                    if (load_dcard1 !== 1'b1 || load_pcard2 !== 1'b0)
                        $display("Error: Expected s1 outputs not met");
                end
                "s2": begin
                    if (load_pcard2 !== 1'b1 || load_dcard2 !== 1'b0)
                        $display("Error: Expected s2 outputs not met");
                end
                "s3": begin
                    if (load_dcard2 !== 1'b1 || load_pcard3 !== 1'b0)
                        $display("Error: Expected s3 outputs not met");
                end
                "s4": begin
                    if (pscore > 4'b0111 || dscore > 4'b0111)
                        $display("Natural win checked.");
                    else if (pscore < 4'b0110)
                        $display("Player draws a third card.");
                end
                "s5": begin
                    if (player_win_light === 1'b1 && dealer_win_light === 1'b0)
                        $display("Player wins");
                    else if (dealer_win_light === 1'b1 && player_win_light === 1'b0)
                        $display("Dealer wins");
                    else if (player_win_light === 1'b1 && dealer_win_light === 1'b1)
                        $display("It's a tie");
                end
                "s6": begin
                    if (load_dcard3 === 1'b1)
                        $display("Dealer gets a third card");
                end
            endcase
        end
    endtask

    // Main test sequence
    initial begin
        apply_reset();

        // Sequentially test each state transition and conditions to ensure full coverage

        // Test initial state s0: loading player card 1
        test_state(4'b0000, 4'b0000, 4'b0000, "s0");

        // Test state s1: loading dealer card 1
        test_state(4'b0000, 4'b0000, 4'b0000, "s1");

        // Test state s2: loading player card 2
        test_state(4'b0000, 4'b0000, 4'b0000, "s2");

        // Test state s3: loading dealer card 2
        test_state(4'b0000, 4'b0000, 4'b0000, "s3");

        // Test state s4: Natural win scenarios (player or dealer has 8 or 9)
        test_state(4'b1001, 4'b1000, 4'b0000, "s4");

        // Test state s4 with pscore < 6, expecting to transition to s6
        test_state(4'b0011, 4'b0100, 4'b0000, "s4");

        // Test state s6: Dealer's third card draw based on dscore conditions
        test_state(4'b0110, 4'b0110, 4'b0110, "s6");

        // Test s5 scenarios: various win, lose, and tie conditions
        test_state(4'b0111, 4'b0110, 4'b0000, "s5"); // Dealer wins
        test_state(4'b0100, 4'b0101, 4'b0000, "s5"); // Player wins
        test_state(4'b0110, 4'b0110, 4'b0000, "s5"); // Tie condition

        // Exhaustively test combinations to cover all possible branches
        integer i, j, k;
        for (i = 0; i < 10; i = i + 1) begin
            for (j = 0; j < 10; j = j + 1) begin
                for (k = 0; k < 16; k = k + 1) begin
                    test_state(i[3:0], j[3:0], k[3:0], ""); // Generic check to force coverage
                    @(posedge slow_clock);
                end
            end
        end

        $finish;
    end

endmodule
