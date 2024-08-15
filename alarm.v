
module alarm (
	input clk,
	input rst,

	input upbtn,
	input dnbtn,
	input startbtn,
	
	output reg buzz,
	
	output reg led_debug,
	
	output reg [7:0] seg,
	output reg [3:0] dig
);

parameter SET_TIME = 2'b00,
          CLOCK_DOWN = 2'b01,
          BEEP = 2'b10;

reg [2:0] global_state_ = SET_TIME;

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

wire clock_zero;

assign sec = div50000max & div1000max;
assign msec = div50000max;

assign clock_zero = (val_ed_ == 0) && (val_des_ == 0) && (val_sot_ == 0);

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

always @(posedge msec)
begin
	case (global_state_)
		SET_TIME: begin 
			if (startbtn) global_state_ = CLOCK_DOWN;
		end
		CLOCK_DOWN: begin
			if (clock_zero) global_state_ = BEEP;
		end
		BEEP: begin
			if (startbtn) global_state_ = SET_TIME;
		end
	endcase
end

always @(posedge msec)
begin
	if (global_state_ == SET_TIME) begin
		
	end
end

always @(posedge msec)
begin
	if (global_state_ == CLOCK_DOWN) begin
	
	end
end

always @(posedge msec)
begin
	if (global_state_ == BEEP) begin
		buzz = ~buzz;
	end
end

endmodule
