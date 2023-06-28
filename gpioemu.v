/* verilator lint_off WIDTH */
/* verilator lint_off BLKSEQ */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSED */
/* verilator lint_off MULTIDRIVEN */

module gpioemu(n_reset, saddress[31:0], srd, swr, sdata_in[31:0], sdata_out[31:0], gpio_in[31:0], gpio_latch, gpio_out[31:0], gpio_in_s_insp[31:0], clk);

	input clk;
	input srd;
	input swr;
	input n_reset;

	input [31:0] saddress;

	input [31:0] sdata_in;
	output[31:0] sdata_out;
	
	input gpio_latch;
	input [31:0] gpio_in;
	output [31:0] gpio_out;
	output [31:0] gpio_in_s_insp;
	

	reg [31:0] sdata_out;
	reg [31:0] gpio_in_s;
	reg [31:0] gpio_out_s;


	reg [63:0] multiplier;
	reg [63:0] multiplicand;
	reg [63:0] product;	

	reg [31:0] ones;
	reg [31:0] ones_temp;
	reg [31:0] counter;

	reg [7:0] flags; 
	parameter OVERFLOW_FLAG = 0;
	parameter INPUT_READY_FLAG = 1;
	parameter MALFORMED_A1_INPUT_FLAG = 2;
	parameter MALFORMED_A2_INPUT_FLAG = 3;  
	parameter FINISH_FLAG = 4; 
	
	parameter MAX_INPUT = 'hFFFFFF;
	parameter MAX_OUTPUT = 'hFFFFFFFF;
	parameter SYKT_GPIO_ADDR_SPACE = 'h100000;
	parameter SYKT_GPIO_A1 = 'h2C8;
	parameter SYKT_GPIO_A2 = 'h2D0;
	parameter SYKT_GPIO_W = 'h2D8;
	parameter SYKT_GPIO_L = 'h2E0;
	parameter SYKT_GPIO_B = 'h2E8;

	initial begin
		multiplier = 0;
		multiplicand = 0;
		product = 0;
		ones = 0;
		ones_temp = 0;
		counter = 0;;
		flags = 0;
	end

	always@(posedge clk) 
	begin

		if((flags[INPUT_READY_FLAG]) && ~((flags[MALFORMED_A1_INPUT_FLAG]) || (flags[MALFORMED_A2_INPUT_FLAG]))) begin
			product = 0;
			while(multiplicand != 0) begin
				if(multiplicand & 1 == 1) begin
					product = product + multiplier;
				end
				multiplier = (multiplier << 1);
				multiplicand = (multiplicand >> 1);
			end
			if(product[63:32] > 0)
				flags[OVERFLOW_FLAG] = 1;

			ones = 0;
			ones_temp = product[31:0];
			while(ones_temp != 0) begin
				ones = ones + (ones_temp & 1);
				ones_temp = (ones_temp >> 1);
			end

			flags[INPUT_READY_FLAG] = 0;
			flags[FINISH_FLAG] = 1;
			counter = counter + 1;
			multiplicand = 0;
			multiplier = 0;
		end
	end

	always@(negedge n_reset)
	begin
		multiplicand = 0;
		multiplier = 0;
		product = 0;
		ones = 0;
		flags = 0;
		
		gpio_in_s = 0;
		gpio_out_s = 0;
		sdata_out = 0;
	end
		
	always@(posedge gpio_latch)
	begin
		gpio_in_s = gpio_in;
	end

	always@(posedge swr)
	begin
		case(saddress)
			SYKT_GPIO_A1:	begin
				if(sdata_in > MAX_INPUT) begin
					flags[MALFORMED_A1_INPUT_FLAG] = 1;
				end else begin
					multiplier = sdata_in;
					flags[MALFORMED_A1_INPUT_FLAG] = 0;
				end
				flags [FINISH_FLAG] = 0;
				flags [OVERFLOW_FLAG] = 0;
			end
			SYKT_GPIO_A2:	begin
				if(sdata_in > MAX_INPUT) begin
					flags[MALFORMED_A2_INPUT_FLAG] = 1;
				end else begin
					multiplicand = sdata_in;
					if(~flags[MALFORMED_A1_INPUT_FLAG])
						flags[INPUT_READY_FLAG] = 1;
					flags [MALFORMED_A2_INPUT_FLAG] = 0;
				end
				flags [FINISH_FLAG] = 0;
				flags [OVERFLOW_FLAG] = 0;
			end
			default:		gpio_out_s = sdata_in;
		endcase
	end

	always@(posedge srd)
	begin
		sdata_out = 0;
		case(saddress)
			SYKT_GPIO_W:	sdata_out = product[31:0];
			SYKT_GPIO_L:	sdata_out = ones;
			SYKT_GPIO_B:	sdata_out = flags;
			default:		sdata_out = 0;
		endcase
		gpio_in_s = {16'h0 , counter[15:0]};
	end

	assign gpio_in_s_insp = gpio_in_s;
	assign gpio_out = gpio_out_s;	

endmodule
