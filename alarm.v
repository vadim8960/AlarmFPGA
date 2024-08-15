
module alarm (
	input clk,
	input rst,
	
	output reg buzz,
	
	output reg led_debug,
	
	output reg [7:0] seg,
	output reg [3:0] dig
);

initial dig = 4'b0111;

reg [3:0] val_ed_;
reg [3:0] val_des_;
reg [3:0] val_sot_;
reg [3:0] val_checkable_;

reg [15:0] div50000;
reg [9:0] div1000;
reg div50000max;
reg div1000max;

wire sec;
wire msec;

assign sec = div50000max & div1000max;
assign msec = div50000max;

always @(posedge clk)
begin
	div50000max <= (div50000 == 16'd49999);
	if (div50000max) div50000 <= 16'd0;
	else div50000 <= div50000 + 1'b1;
end

always @(posedge clk)
begin
	div1000max <= (div1000 == 10'd999);
	if (div50000max & div1000max) div1000 <= 10'd0;
	else if (div50000max) div1000 <= div1000 + 1'b1;
end

always @(posedge sec)
begin
	led_debug = ~led_debug;

	val_ed_ = val_ed_ + 1'b1;	
	if (val_ed_ == 10) begin
		val_ed_ = 0;
		val_des_ = val_des_ + 1'b1;
	end
	
	if (val_des_ == 10) begin
		val_des_ = 0;
		val_sot_ = val_sot_ + 1'b1;
	end
	
	if (val_sot_ == 10) begin
		val_sot_ = 0;
	end
end

always @(posedge msec)
begin
	case (dig)
		4'b0111: begin
			dig = 4'b1011;
			val_checkable_ = val_des_;
		end
		4'b1011: begin 
			dig = 4'b1101;
			val_checkable_ = val_sot_;
		end
		4'b1101: begin
			dig = 4'b1110;
			val_checkable_ = 0;
		end
		4'b1110: begin 
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

endmodule
