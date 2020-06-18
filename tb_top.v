module tb_top;

   parameter CYCLE = 10;
   reg clock;
   reg rstn;
   reg iValid;
   reg [7:0] A;
   reg [7:0] B;
   reg [1:0] ctrl;
   reg [15:0] gotC, outC;
   
   // DUT Initialization
   calc DUT(
            .inpA       (A),
            .inpB       (B),
            .inpOpType  (ctrl),
            .outC       (outC),
            .iValid     (iValid),
            .iStall     (),
            .oStall     (1'b0),
            .oValid     (oValid),
            .clk        (clock),
            .rstn       (rstn));

//----------------------------------------------------------------------------------
   // Clock generation
//----------------------------------------------------------------------------------

   initial begin 
      clock = 1'b0;
      forever 
      #(CYCLE/2) clock = ~clock;
   end

//----------------------------------------------------------------------------------
   // Body
//----------------------------------------------------------------------------------

   initial begin
      init_signals();
      reset_dut();
      calc_read_write(8'h5, 8'h5, 2'b00);
      calc_read_write(8'h8, 8'h5, 2'b01);
      calc_read_write(8'h7, 8'h11, 2'b10);
      calc_read_write(8'h16, 8'h2, 2'b11);
      $finish;
   end

//----------------------------------------------------------------------------------
   // Calci Read Write Method
//----------------------------------------------------------------------------------

   task calc_read_write;
      input [7:0] inpA;
      input [7:0] inpB;
      input [1:0] inpCtrl;
      
      reg [15:0]   expC;
      
      $display("Inside Calculator Read Write task...");
      $display("Inputs : A = %h B = %h ctrl = %b", inpA, inpB, inpCtrl);

      // Expected Output calculation
      case (inpCtrl)
	 2'b00: expC = inpA + inpB;
	 2'b01: expC = inpA - inpB;
	 2'b10: expC = inpA * inpB;
	 2'b11: if (inpB == 0) expC = 0;
	 else expC = inpA / inpB;
      endcase // case(inpCtrl)
      
      // Driving Inputs
      @(posedge clock);
      A = inpA;
      B = inpB;
      ctrl = inpCtrl;
      iValid = 'b1;
      
      // Sampling Outputs
      wait(oValid);
      @(posedge clock);
      gotC = outC; 
      iValid = 0;
      
      // Comparing Expected and Actual Output
      $display("Output : Expected = %h Actual = %h", expC, gotC);
      if (gotC == expC)
         $display("PASS: A = %h B = %h C = %h type = %b\n", inpA, inpB, gotC, inpCtrl);
      else
         $display("FAIL: A = %h B = %h C = %h type = %b\n", inpA, inpB, gotC, inpCtrl);
      
      wait(!oValid);
   endtask // calc_read_write

//----------------------------------------------------------------------------------
   // Initialize Input signals
//----------------------------------------------------------------------------------

   task init_signals;
      begin
         $display("Initializing Input signals...");
	 rstn = 'b1;
	 A = 'b0;
	 B = 'b0;
	 ctrl = 'b0;
	 iValid = 'b0;	 
      end
   endtask // init_signals

//----------------------------------------------------------------------------------
   // Reset DUT
//----------------------------------------------------------------------------------

   task reset_dut();
      begin
         #15 rstn = 'b0; 
         #15 rstn = 'b1; 
         $display("DUT is Reset...");
      end
   endtask // reset_dut

//----------------------------------------------------------------------------------
endmodule
