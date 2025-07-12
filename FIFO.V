module FIFO #(
  parameter WIDTH = 8,
  parameter DEPTH = 10,
  parameter A_FULL_EMPTY=2
)(
  input I_RE, I_WE, I_CLK, I_RESETN,
  input [WIDTH-1:0] I_DIN,
  output O_FULL, O_EMPTY,
  output O_AFULL, O_AEMPTY, O_HALF_FULL, O_HALF_EMPTY,
  output reg [WIDTH-1:0] O_DOUT
);

  integer i;
  reg [WIDTH-1:0] FIFO[0:DEPTH-1];
  reg [$clog2(DEPTH)-1:0] WR_P = 0, RD_P = 0;
  reg [$clog2(DEPTH):0] COUNT = 0;  // One extra bit to go up to DEPTH

  always @(posedge I_CLK) begin
    if (!I_RESETN) begin
      WR_P <= 0;
      RD_P <= 0;
      COUNT <= 0;
      O_DOUT <= 0;
      for(i=0;i<DEPTH;i=i+1)
        begin
          FIFO[i]<=0;
        end
    end
  end
  always@(posedge I_CLK) begin
    if (I_WE && !O_FULL && I_RESETN) begin
        FIFO[WR_P] <= I_DIN;
        WR_P <= (WR_P + 1) % DEPTH;
        COUNT <= COUNT + 1;
      end
  end

  always@(posedge I_CLK)begin
    if (I_RE && !O_EMPTY && I_RESETN) begin
        O_DOUT <= FIFO[RD_P];
        RD_P <= (RD_P + 1) % DEPTH;
        COUNT <= COUNT - 1;
      end
    end

  assign O_FULL       = (COUNT == DEPTH);
  assign O_EMPTY      = (COUNT == 0);
  assign O_AFULL      = (COUNT > (DEPTH - A_FULL_EMPTY));
  assign O_AEMPTY     = (COUNT <= A_FULL_EMPTY);
  assign O_HALF_FULL  = (COUNT > (DEPTH/2)-1);
  assign O_HALF_EMPTY = (COUNT <= ((DEPTH/2)-1));

endmodule
