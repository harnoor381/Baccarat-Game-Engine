module tb_scorehand;
    // Testbench signals
    logic [3:0] card1, card2, card3;
    logic [3:0] total;

    // Instantiate the DUT
    scorehand DUT (
        .card1(card1),
        .card2(card2),
        .card3(card3),
        .total(total)
    );

    // Task to test a specific combination of cards and display results
    task test_combination(input logic [3:0] c1, c2, c3);
        logic [3:0] expected_value1, expected_value2, expected_value3;
        logic [4:0] expected_total;
        begin
            // Calculate expected values based on the if-else logic in the scorehand module
            expected_value1 = (c1 > 4'b1001) ? 4'b0000 : c1; // card1 handling
            expected_value2 = (c2 > 4'b1001) ? 4'b0000 : c2; // card2 handling
            expected_value3 = (c3 > 4'b1001) ? 4'b0000 : c3; // card3 handling
            expected_total = (expected_value1 + expected_value2 + expected_value3) % 10; // Calculate expected total

            // Assign inputs to the DUT
            card1 = c1;
            card2 = c2;
            card3 = c3;

            #1; // Small delay to allow combinational logic to settle

            // Display the test case and check the result
            $display("Test: card1 = %b (%0d), card2 = %b (%0d), card3 = %b (%0d) => total = %b (%0d) | Expected total = %b (%0d)",
                     card1, card1, card2, card2, card3, card3, total, total, expected_total[3:0], expected_total);

            // Check the output against the expected result
            if (total !== expected_total[3:0]) begin
                $display("ERROR: Mismatch for card1 = %b, card2 = %b, card3 = %b. Expected total = %b, but got %b", 
                         card1, card2, card3, expected_total[3:0], total);
            end else begin
                $display("PASS: Correct output for card1 = %b, card2 = %b, card3 = %b", card1, card2, card3);
            end
        end
    endtask

    // Main test sequence to ensure full coverage
    initial begin 
        // Test branches where card values are less than or equal to 9
        test_combination(4'b0000, 4'b0000, 4'b0000); // All zero
        test_combination(4'b0101, 4'b0011, 4'b1001); // Normal values within range

        // Test branches where some card values are greater than 9
        test_combination(4'b1010, 4'b0001, 4'b0010); // card1 > 9
        test_combination(4'b0010, 4'b1011, 4'b0011); // card2 > 9
        test_combination(4'b0011, 4'b0100, 4'b1100); // card3 > 9

        // Test cases where multiple cards are greater than 9
        test_combination(4'b1101, 4'b1010, 4'b1110); // All cards > 9
        test_combination(4'b0101, 4'b1111, 4'b1000); // Mixed values

        // Exhaustively loop through all valid combinations for completeness
        run_all_combinations();

        $finish; // End the simulation
    end

    // Task to run all test cases for full coverage
    task run_all_combinations();
        integer i, j, k;
        begin
            // Iterate through valid values (0 to 13) for card1, card2, and card3
            for (i = 0; i <= 13; i = i + 1) begin
                for (j = 0; j <= 13; j = j + 1) begin
                    for (k = 0; k <= 13; k = k + 1) begin
                        test_combination(i[3:0], j[3:0], k[3:0]);
                    end
                end
            end
        end
    endtask

endmodule
