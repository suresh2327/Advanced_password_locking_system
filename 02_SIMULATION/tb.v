module tb_password_lock_system;
    reg clk, reset;
    reg [15:0] passin, newpass;
    reg enter, chg_pass;
    wire access, alarm;
    wire [1:0] count;

    password_lock_system dut (
        .reset(reset), .clk(clk),
        .passin(passin), .newpass(newpass),
        .enter(enter), .chg_pass(chg_pass),
        .access(access), .alarm(alarm), .count(count)
    );

    reg [1:0] attempt_count;
    remaining_attempts_display disp(.count(attempt_count));

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 0;
        enter = 0;
        chg_pass = 0;
        passin = 16'h0000;
        newpass = 16'h0000;

        // Apply reset
        #10 reset = 1;

        // Test 1: Correct default password
        $display("\nFeature 1: Correct password");
        #10 passin = 16'h1234; enter = 1;
        #10 enter = 0;
        attempt_count = count;

        // Incorrect password attempts to trigger alarm
        $display("\nFeature 2: Alarm triggering condition");
        #10 passin = 16'h1516; enter = 1; #10 enter = 0; attempt_count = count;
        #10 passin = 16'h2127; enter = 1; #10 enter = 0; attempt_count = count;
        #10 passin = 16'h0348; enter = 1; #10 enter = 0; attempt_count = count;

        // Test 3: Change password
        $display("\nFeature 3: Change password");
        #10 passin = 16'h1234; newpass = 16'h4321; chg_pass = 1; enter = 1;
        #10 enter = 0; chg_pass = 0;

        // Test 4: Login with new password
        #10 passin = 16'h4321; enter = 1;
        #10 enter = 0;
        attempt_count = count;

        // Test 5: Invalid password change
        #10 passin = 16'h1234; enter = 1;
        #10 enter = 0; chg_pass = 0;
        attempt_count = count;

        // Test 6: Change using master password
        $display("\nFeature 4: Change with master password");
        #10 passin = 16'habcd; newpass = 16'h9866; chg_pass = 1; enter = 1;
        #10 enter = 0; chg_pass = 0;

        // Test 7: Login using master password
        #10 passin = 16'habcd; enter = 1;
        #10 enter = 0;
        attempt_count = count;

        // Test 8: Reset
        $display("\nFeature 5: Reset");
        #10 reset = 0; #10 reset = 1; #10 reset = 0;
        attempt_count = count;

        $display("\nSimulation Complete.");
        $finish;
    end
endmodule

// Display module (MUST be outside)
module remaining_attempts_display(input [1:0] count);
    always @(*) begin
        case (count)
            2'd0: $display("System unlocked successfully.");
            2'd1: $display("Incorrect password. You have 2 attempts left.");
            2'd2: $display("Incorrect password. You have 1 attempt left.");
            2'd3: $display("Limit reached! Alarm triggered.");
            default: $display("Invalid count value.");
        endcase
    end
endmodule

