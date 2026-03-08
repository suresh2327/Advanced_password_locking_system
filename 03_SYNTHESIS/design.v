// Top module: password_lock_system
module password_lock_system(
    input reset,
    input clk,
    input [15:0] passin,
    input [15:0] newpass,
    input enter,
    input chg_pass,
    output access,
    output alarm,
    output [1:0] count
);
    reg [15:0] current_password;
    wire is_correct;
    wire [15:0] master_password = 16'habcd;

    initial begin
        current_password = 16'h1234;
    end

    assign is_correct = ((passin == current_password) || (passin == master_password));

    always @(posedge clk or negedge reset) begin
        if (!reset)
            current_password <= 16'h1234;
        else if (chg_pass && is_correct)
            current_password <= newpass;
    end

    password_attempt_counter counter (
        .clk(clk),
        .enter(enter),
        .correct(is_correct),
        .rstn(reset),
        .cnt(count),
        .access(access),
        .alarm(alarm)
    );
endmodule

// Password attempt counter module
module password_attempt_counter(
    input clk,
    input enter,
    input correct,
    input rstn,
    output reg [1:0] cnt,
    output reg access,
    output reg alarm
);
    parameter N = 4;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            cnt <= 0;
            access <= 1;
            alarm <= 0;
        end else if (enter) begin
            if (correct) begin
                cnt <= 0;
                access <= 1;
                alarm <= 0;
            end else if (cnt == N - 2) begin
                cnt <= cnt + 1;
                access <= 0;
                alarm <= 1;
            end else if (cnt == N - 1) begin
                access <= 0;
                alarm <= 1;
            end else begin
                cnt <= cnt + 1;
                access <= 0;
                alarm <= 0;
            end
        end
    end
endmodule

