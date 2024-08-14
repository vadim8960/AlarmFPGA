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

//// 1100 0011 0101 0000 (50`000)
//assign clk_1khz = systicks_[4] & systicks_[6] & 
//						systicks_[8] & systicks_[9] & 
//						systicks_[14] & systicks_[15];

//// 0010 1111 1010 1111 0000 1000 0000 (50`000`000)
//assign clk_1hz = systicks_[7] & systicks_[12] & 
//					  systicks_[13] & systicks_[14] & 
//					  systicks_[15] & systicks_[17] & 
//					  systicks_[19] & systicks_[20] & 
//					  systicks_[21] & systicks_[22] & 
//					  systicks_[23] & systicks_[25];				  
					  
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
				0: seg = 8'b00000011;
				1: seg = 8'b10011111;
				2: seg = 8'b00100101;
				3: seg = 8'b00001101;
				4: seg = 8'b10011001;
				5: seg = 8'b01001001;
				6: seg = 8'b01000001;
				7: seg = 8'b00011111;
				8: seg = 8'b00000001;
				9: seg = 8'b00001001;
				default: seg = 8'b11111111;
			endcase
			
		end
		
	end
end

//always @(posedge clk_1hz or negedge rst)
//begin
//	
//	if (!rst) begin
//		val_ed_ = 0;
//		val_des_ = 0;
//	end else begin
//		led_debug <= ~led_debug;
//
//		val_ed_ = val_ed_ + 1;
//		if (val_ed_ == 10) begin
//			val_ed_ = 0;
//			val_des_ = val_des_ + 1;
//		end
//		
//		if (val_des_ == 10) begin
//			val_des_ = 0;
//		end
//	end
//end

//always @(posedge clk_1khz)
//begin
//	case (dig)
//		4'b0111: begin
//			dig = 4'b1011;
//			val_checkable_ = val_des_;
//		end
//		4'b1011: begin 
//			dig = 4'b0111;
//			val_checkable_ = val_ed_;
//		end
//	endcase
//	
//	case(val_checkable_)
//		0: seg = 8'b00000011;
//		1: seg = 8'b10011111;
//		2: seg = 8'b00100101;
//		3: seg = 8'b00001101;
//		4: seg = 8'b10011001;
//		5: seg = 8'b01001001;
//		6: seg = 8'b01000001;
//		7: seg = 8'b00011111;
//		8: seg = 8'b00000001;
//		9: seg = 8'b00001001;
//		default: seg = 8'b11111111;
//	endcase
//end

endmodule
