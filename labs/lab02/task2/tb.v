// tb.v
// Testbench for the parameterized lut module.

module tb;

  reg  [2:0] t_sel;
  wire [7:0] t_dout;

  integer i;
  integer errors;

  lut #(.WIDTH(8), .DEPTH(8)) DUT (
    .sel  (t_sel),
    .dout (t_dout)
  );

  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  initial begin
    errors = 0;
    for (i = 0; i < 8; i = i + 1) begin
      t_sel = i;
      #5;
      if (t_dout !== i * i) begin
        errors = errors + 1;
        $display("MISMATCH at sel=%0d: expected=%0d got=%0d", i, i*i, t_dout);
      end
    end
    #5;
    if (errors == 0)
      $display("All checks passed.");
    else
      $display("%0d mismatch(es) found.", errors);
    $finish;
  end

  initial
    $monitor($time, " sel=%0d dout=%0d", t_sel, t_dout);

endmodule