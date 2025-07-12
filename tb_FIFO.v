`timescale 1ns/1ps

module tb_FIFO;

  parameter WIDTH = 8;
  parameter DEPTH = 10;
  parameter A_FULL_EMPTY=3;

  reg I_CLK, I_RE, I_WE, I_RESETN;
  reg [WIDTH-1:0] I_DIN;
  wire [WIDTH-1:0] O_DOUT;
  wire O_FULL, O_EMPTY, O_AFULL, O_AEMPTY, O_HALF_FULL, O_HALF_EMPTY;

  FIFO #(WIDTH, DEPTH, A_FULL_EMPTY) dut (
    .I_RE(I_RE), .I_WE(I_WE), .I_CLK(I_CLK), .I_RESETN(I_RESETN),
    .I_DIN(I_DIN), .O_DOUT(O_DOUT),
    .O_FULL(O_FULL), .O_EMPTY(O_EMPTY),
    .O_AFULL(O_AFULL), .O_AEMPTY(O_AEMPTY),
    .O_HALF_FULL(O_HALF_FULL), .O_HALF_EMPTY(O_HALF_EMPTY)
  );

  initial I_CLK = 0;
  always #5 I_CLK = ~I_CLK;

  initial begin
    $dumpfile("fifo_tb.vcd");
    $dumpvars();
  end

  task reset;
    begin
      I_RESETN = 0; I_WE = 0; I_RE = 0; I_DIN = 0;
      @(posedge I_CLK);
      I_RESETN = 1;
      //@(posedge I_CLK);
    end
  endtask

     task write(input [WIDTH-1:0] data);
      begin
        I_WE = 1;
        I_DIN = data;
        @(posedge I_CLK);
        $display("[WRITE] Time: %0t | Data: 0x%0h | WR_P: %0d | FULL: %b", $time, data, dut.WR_P, dut.O_FULL);
        I_WE = 0;
      end
    endtask

    task read;
      begin
        I_RE = 1;
        @(posedge I_CLK);
        $display("[READ ] Time: %0t | Data: 0x%0h | RD_P: %0d | EMPTY: %b", $time, O_DOUT, dut.RD_P, dut.O_EMPTY);
        I_RE = 0;
      end
    endtask


  task basic_write_read;
    begin
      $display("\n===== TEST: Basic Write and Read =====");
      repeat (5) write($random);
      repeat (5) read;
      #10;
      $display("===== END TEST: Basic Write and Read =====");
    end
  endtask

  task wraparound_test;
    begin
      $display("\n===== TEST: Wraparound Pointers =====");
      repeat (DEPTH) write($random);      
      repeat (3) read;                    
      repeat (3) write($random);          
      repeat (DEPTH) read;               
      #10;
      $display("===== END TEST: Wraparound Pointers =====");
    end
  endtask

  task full_condition_test;
    begin
      $display("\n===== TEST: Full Condition =====");
      repeat (DEPTH) write($random);
      write(8'hAA);  
      #10;
      $display("===== END TEST: Full Condition =====");
    end
  endtask

  task empty_condition_test;
    begin
      $display("\n===== TEST: Empty Condition =====");
      repeat(DEPTH+1) read; 
      #10;
      $display("===== END TEST: Empty Condition =====");
    end
  endtask

  task simultaneous_rw;
    begin
      $display("\n===== TEST: Simultaneous Read and Write =====");
      write(8'h11);  
      I_WE = 1; I_RE = 1; I_DIN = 8'h22;
      //@(posedge I_CLK);
      read;
      read;
      I_WE = 0; I_RE = 0;
      #10;
      $display("===== END TEST: Simultaneous Read and Write =====");
    end
  endtask

  task status_flag_check;
    begin
      $display("\n===== TEST: Status Flags (AFULL, AEMPTY, HALF)=====");
      repeat (DEPTH - 2) write($random);  
      repeat (DEPTH - 6) read;            
      #10;
      $display("===== END TEST: Status Flags =====");
    end
  endtask

  task reset_behavior_test;
    begin
      $display("\n===== TEST: Reset Behavior =====");
      repeat (5) write($random);
      reset();             
      read;
      read;
      #10;
      $display("===== END TEST: Reset Behavior =====");
    end
  endtask

  task continuous_flow_test;
    begin
      $display("\n===== TEST: Continuous Read/Write Flow =====");
      repeat (DEPTH) write($random);     
      repeat (3) read;                   
      repeat (3) write($random);        
      repeat (10) begin
        I_WE = 1; I_RE = 1; I_DIN = $random;
        @(posedge I_CLK);
      end
      I_WE = 0; I_RE = 0;
      #10;
      $display("===== END TEST: Continuous Flow =====");
    end
  endtask
  
  task toggle_flags_check;
    begin
      $display("\n===== TEST: Toggle FULL and EMPTY Flags =====");

      // Fill the FIFO to trigger FULL
      repeat (DEPTH) begin
        write($random);
        if (O_FULL) $display("FULL flag asserted at WR_P: %0d", dut.WR_P);
      end

      // Empty the FIFO to trigger EMPTY
      repeat (DEPTH) begin
        read;
        if (O_EMPTY) $display("EMPTY flag asserted at RD_P: %0d", dut.RD_P);
      end

      // Write and Read again to ensure toggling
      repeat (3) write($random);
      repeat (3) read;

      // Check status
      $display("Final FULL: %b | EMPTY: %b", O_FULL, O_EMPTY);

      #10;
      $display("===== END TEST: Toggle FULL and EMPTY Flags =====");
    end
  endtask

  initial begin
    reset();
    if ($test$plusargs("basic_write_read"))      basic_write_read();
    if ($test$plusargs("wraparound_test"))       wraparound_test();
    if ($test$plusargs("full_condition_test"))   full_condition_test();
    if ($test$plusargs("empty_condition_test"))  empty_condition_test();
    if ($test$plusargs("simultaneous_rw"))       simultaneous_rw();
    if ($test$plusargs("status_flag_check"))     status_flag_check();
    if ($test$plusargs("reset_behavior_test"))   reset_behavior_test();
    if ($test$plusargs("continuous_flow_test"))  continuous_flow_test();
    if ($test$plusargs("toggle_flags_check"))    toggle_flags_check();

    $display("\n=== Simulation Complete ===");
    $finish;
  end

endmodule
