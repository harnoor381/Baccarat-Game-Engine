module tb_task5();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 100,000 ticks (equivalent to "initial #100000 $finish();").
    // Declare testbench signals
    logic slow_clock, fast_clock, resetb;
    logic [9:0] LEDR;
    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

    // Instantiate the DUT (task4 module)
    task5 DUT (
        .CLOCK_50(fast_clock),
        .KEY({resetb, 1'b0, slow_clock, 1'b0}),
        .LEDR(LEDR),
        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0)
    );

    // Clock generation
    initial begin
        fast_clock = 0;
        forever #5 fast_clock = ~fast_clock;  // 10ns period
    end

    initial begin
        slow_clock = 0;
        forever #20 slow_clock = ~slow_clock; // 40ns period
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

    initial begin 
        apply_reset();
        #30;
        apply_reset();
        #5;
        apply_reset();
        #40;
        apply_reset();
    end
endmodule
