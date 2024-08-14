module alarm (
	input clk,
	input rst,
	
	output reg buzz,
	
	output reg led_debug,
	
	output reg [7:0] seg,
	output reg [3:0] dig
);

initial dig = 4'b0111;

reg [31:0] systicks1_;
reg [31:0] systicks2_;
reg [3:0] val_ed_;
reg [3:0] val_des_;
reg [3:0] val_checkable_;

wire clk_1khz;
wire clk_1hz;			  
					  
always @(posedge clk or negedge rst)
begin
	if (!rst) begin
		systicks1_ = 0;
		val_des_ = 0;
		val_ed_ = 0;
	end else begin
		systicks1_ = systicks1_ + 1'b1;
		if (systicks1_ > 50000000) begin
			systicks1_ = 0;
			
			led_debug <= ~led_debug;

			val_ed_ = val_ed_ + 1'b1;
			if (val_ed_ == 10) begin
				val_ed_ = 0;
				val_des_ = val_des_ + 1'b1;
			end
			
			if (val_des_ == 10) begin
				val_des_ = 0;
			end
			
		end
		
	end
end

always @(posedge clk or negedge rst)
begin
	if (!rst) begin
		systicks2_ = 0;
	end else begin
		systicks2_ = systicks2_ + 1'b1;
		
		if (systicks2_ > 500000) begin
			systicks2_ = 0;
			
			case (dig)
				4'b0111: begin
					dig = 4'b1011;
					val_checkable_ = val_des_;
				end
				4'b1011: begin 
					dig = 4'b0111;
					val_checkable_ = val_ed_;
				end
			endcase
			
			case(val_checkable_)
				4'd0: seg = 8'b00000011;
				4'd1: seg = 8'b10011111;
				4'd2: seg = 8'b00100101;
				4'd3: seg = 8'b00001101;
				4'd4: seg = 8'b10011001;
				4'd5: seg = 8'b01001001;
				4'd6: seg = 8'b01000001;
				4'd7: seg = 8'b00011111;
				4'd8: seg = 8'b00000001;
				4'd9: seg = 8'b00001001;
				default: seg = 8'b11111111;
			endcase
			
		end
		
	end
end

endmodule
