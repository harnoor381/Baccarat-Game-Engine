module tb_datapath();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").

    // Testbench signals
    logic slow_clock, fast_clock, resetb;
    logic load_pcard1, load_pcard2, load_pcard3;
    logic load_dcard1, load_dcard2, load_dcard3;
    logic [3:0] pcard3_out, pscore_out, dscore_out;
    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

    // Instantiate the DUT (Device Under Test)
    datapath DUT (
        .slow_clock(slow_clock),
        .fast_clock(fast_clock),
        .resetb(resetb),
        .load_pcard1(load_pcard1),
        .load_pcard2(load_pcard2),
        .load_pcard3(load_pcard3),
        .load_dcard1(load_dcard1),
        .load_dcard2(load_dcard2),
        .load_dcard3(load_dcard3),
        .pcard3_out(pcard3_out),
        .pscore_out(pscore_out),
        .dscore_out(dscore_out),
        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0)
    );

    // Clock generation for slow and fast clocks
    initial begin
        slow_clock = 0;
        forever #10 slow_clock = ~slow_clock; // 20ns period
    end

    initial begin
        fast_clock = 0;
        forever #5 fast_clock = ~fast_clock;  // 10ns period
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

    // Task to test different combinations of enable signals and input data
    task test_vDFFE(input logic en_p1, en_p2, en_p3, en_d1, en_d2, en_d3, logic [3:0] dealcard_val);
        begin
            // Set the enable signals
            load_pcard1 = en_p1;
            load_pcard2 = en_p2;
            load_pcard3 = en_p3;
            load_dcard1 = en_d1;
            load_dcard2 = en_d2;
            load_dcard3 = en_d3;

            // Set the dealcard value (controlled by the dealcard module)
            DUT.dealcard = dealcard_val;

            @(posedge slow_clock);  // Wait for a clock edge
            $display("load_pcard1: %b, load_pcard2: %b, load_pcard3: %b, load_dcard1: %b, load_dcard2: %b, load_dcard3: %b, dealcard: %b, pcard3_out: %b, pscore_out: %b, dscore_out: %b", 
                     load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3, dealcard_val, pcard3_out, pscore_out, dscore_out);
        end
    endtask

    // Task to test the card7seg modules through the pcard and dcard signals
    task test_card7seg(input logic [3:0] pcard_val, dcard_val);
        begin
            // Drive the pcard and dcard values which affect the card7seg modules
            DUT.pcard1 = pcard_val;
            DUT.pcard2 = pcard_val;
            DUT.pcard3 = pcard_val;
            DUT.dcard1 = dcard_val;
            DUT.dcard2 = dcard_val;
            DUT.dcard3 = dcard_val;

            #1; // Allow time for the combinational logic to settle
            $display("Testing card7seg: pcard = %b, dcard = %b, HEX0 = %b, HEX1 = %b, HEX2 = %b, HEX3 = %b, HEX4 = %b, HEX5 = %b",
                     pcard_val, dcard_val, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
        end
    endtask

    // Main test sequence to ensure full coverage of the datapath
    initial begin
        apply_reset();  // Apply reset at the start

        // Test various enable conditions with different dealcard values
        test_vDFFE(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b1010); // Enable p1, dealcard = 10
        test_vDFFE(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0101); // Enable p2, dealcard = 5
        test_vDFFE(1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 4'b1100); // Enable p3, dealcard = 12
        test_vDFFE(1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 4'b0001); // Enable d1, dealcard = 1
        test_vDFFE(1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 4'b0110); // Enable d2, dealcard = 6
        test_vDFFE(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 4'b0011); // Enable d3, dealcard = 3

        // Test combinations with various enable signals and different dealcard inputs
        test_vDFFE(1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 4'b1111); // Enable p1 and p2, dealcard = 15
        test_vDFFE(1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 4'b0000); // Enable d1 and d2, dealcard = 0

        // Test card7seg with all possible values from 0 to 13
        integer i;
        for (i = 0; i <= 13; i = i + 1) begin
            test_card7seg(i[3:0], i[3:0]);  // Test pcard and dcard with values 0 to 13
        end

        $finish;  // End the simulation
    end

    // Monitor key outputs for verification
    initial begin
        $monitor("Time: %0t | pcard3_out: %b | pscore_out: %b | dscore_out: %b | HEX0-5: %b %b %b %b %b %b",
                 $time, pcard3_out, pscore_out, dscore_out, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    end
endmodule