// tb.v
// Self-checking testbench for alu.v (1-bit-opcode ALU, add/sub).

module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  integer errors, total;
  reg [3:0] exp_result;

  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  // Task to apply one test vector, wait, and check
  task check;
    input [3:0] a_val, b_val;
    input       op_val;
    begin
      t_a  = a_val;
      t_b  = b_val;
      t_op = op_val;
      #5;

      // Expected value computed independently -- plain 4-bit arithmetic
      if (op_val == 1'b0)
        exp_result = a_val + b_val;
      else
        exp_result = a_val - b_val;

      total = total + 1;
      if (t_result !== exp_result) begin
        $display("FAIL at time %0t: a=%b b=%b op=%b  got result=%b  expected=%b",
                 $time, t_a, t_b, t_op, t_result, exp_result);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    errors = 0;
    total  = 0;

    // --- Same operand pair, toggle op (exposes sensitivity-list bug) ---
    check(4'd6, 4'd3, 1'b0);   // add
    check(4'd6, 4'd3, 1'b1);   // sub, same operands
    check(4'd6, 4'd3, 1'b0);   // add again, same operands

    // --- Subtraction across several different operand pairs ---
    check(4'd9, 4'd4, 1'b1);
    check(4'd2, 4'd7, 1'b1);
    check(4'd0, 4'd0, 1'b1);
    check(4'd15, 4'd1, 1'b1);
    check(4'd5, 4'd5, 1'b1);

    // --- Addition across several pairs, operands changing ---
    check(4'd1, 4'd1, 1'b0);
    check(4'd8, 4'd7, 1'b0);
    check(4'd15, 4'd15, 1'b0);

    // --- Interleaved op changes with changing operands ---
    check(4'd3, 4'd2, 1'b0);
    check(4'd3, 4'd2, 1'b1);
    check(4'd10, 4'd6, 1'b1);
    check(4'd10, 4'd6, 1'b0);

    $write("Summary: %0d / %0d passed", total - errors, total);
    if (errors == 0)
      $display(" -- ALL PASS");
    else
      $display(" -- %0d FAILED", errors);

    $finish;
  end

  initial
    $monitor($time, " a=%b b=%b op=%b | result=%b", t_a, t_b, t_op, t_result);

endmodule