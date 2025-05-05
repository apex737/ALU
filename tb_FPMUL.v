`timescale 1ns/1ps
module tb_FPMUL;

  reg  [15:0] opA_i, opB_i;
  wire [15:0] MUL_o;

  // DUT instance
  FPMUL uut (
    .opA_i(opA_i),
    .opB_i(opB_i),
    .MUL_o(MUL_o)
  );

  // Internal signal monitor
  wire signed [6:0] Exp     = uut.Exp;
  wire        [4:0] DNshamt = uut.DNshamt;

  initial begin
    $display("Case |           A           |           B           |  Exp  | DNshamt |   MUL_o   | Category");
    $display("-----+-----------------------+-----------------------+--------+---------+-----------+------------");

    // -------- Norm × Norm Cases --------
    // N1: OVF
    opA_i = 16'b0_10100_1110000000;
    opB_i = 16'b0_10011_1100000000;
    #5; $display(" N1  | %h | %h | %4d  |    %2d   | %h | Norm×Norm→OVF", opA_i, opB_i, Exp, DNshamt, MUL_o);

    // N2: Norm
    opA_i = 16'b0_10001_0000000000;
    opB_i = 16'b0_10000_0000000000;
    #5; $display(" N2  | %h | %h | %4d  |    %2d   | %h | Norm×Norm→Norm", opA_i, opB_i, Exp, DNshamt, MUL_o);

    // N3: Norm
    opA_i = 16'b0_10000_1000000000;
    opB_i = 16'b0_10001_0100000000;
    #5; $display(" N3  | %h | %h | %4d  |    %2d   | %h | Norm×Norm→Norm", opA_i, opB_i, Exp, DNshamt, MUL_o);

    // N4: Denorm
    opA_i = 16'b0_10000_1000000000;
    opB_i = 16'b0_01100_0000000000;
    #5; $display(" N4  | %h | %h | %4d  |    %2d   | %h | Norm×Norm→Denorm", opA_i, opB_i, Exp, DNshamt, MUL_o);

    // N5: UDF
    opA_i = 16'b0_10000_1000000000;
    opB_i = 16'b0_00000_0000000001;
    #5; $display(" N5  | %h | %h | %4d  |    %2d   | %h | Norm×Norm→UDF", opA_i, opB_i, Exp, DNshamt, MUL_o);

    // -------- Norm × Denorm Cases --------
    // D1: UDF
    opA_i = 16'b0_10000_1000000000;
    opB_i = 16'b0_00000_0000000001;
    #5; $display(" D1  | %h | %h | %4d  |    %2d   | %h | Norm×Denorm→UDF", opA_i, opB_i, Exp, DNshamt, MUL_o);

    // D2: Norm
    opA_i = 16'b0_10001_0000000000;
    opB_i = 16'b0_00000_0010000000;
    #5; $display(" D2  | %h | %h | %4d  |    %2d   | %h | Norm×Denorm→Norm", opA_i, opB_i, Exp, DNshamt, MUL_o);

    // D3: Norm
    opA_i = 16'b0_10000_1000000000;
    opB_i = 16'b0_00000_0100000000;
    #5; $display(" D3  | %h | %h | %4d  |    %2d   | %h | Norm×Denorm→Norm", opA_i, opB_i, Exp, DNshamt, MUL_o);

    // D4: Denorm
    opA_i = 16'b0_10000_1000000000;
    opB_i = 16'b0_00000_0000010000;
    #5; $display(" D4  | %h | %h | %4d  |    %2d   | %h | Norm×Denorm→Denorm", opA_i, opB_i, Exp, DNshamt, MUL_o);

    // D5: Denorm
    opA_i = 16'b0_10000_0100000000;
    opB_i = 16'b0_00000_0000001000;
    #5; $display(" D5  | %h | %h | %4d  |    %2d   | %h | Norm×Denorm→Denorm", opA_i, opB_i, Exp, DNshamt, MUL_o);

    $finish;
  end
endmodule

