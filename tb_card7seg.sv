module tb_card7seg();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").
    
    //signals in testbench
    logic [3:0] SW;
    logic [6:0] HEX0;

    //instantiate DUT
    card7seg DUT(
        //connecting ports of card7seg with signals in testbench
        .SW(SW),
        .HEX0(HEX0)
    );

    // Task to display the test result
    task display_result(input [3:0] sw, input [6:0] hex);
        $display("SW = %b, HEX0 = %b", sw, hex);
    endtask

    initial begin
        // Apply all possible inputs to the DUT
        for (int i = 0; i < 16; i++) begin
            SW = i;                // Set the input
            #10;                   // Wait for a short time to observe the result
            display_result(SW, HEX0); // Display the result
        end

        // Finish simulation
        $stop;
    end
						
endmodule

