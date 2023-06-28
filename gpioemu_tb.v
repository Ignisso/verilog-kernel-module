module GpioEmu_tb;

reg         n_reset    = 0;

reg  [31:0] saddress   = 0;

reg         srd        = 0;
reg         swr        = 0;

reg  [31:0] sdata_in   = 0;

reg  [31:0] gpio_in    = 0;
reg         gpio_latch = 0;
reg         clk        = 0;

reg [31:0] a;
reg [31:0] b;
reg [31:0] i;
reg [63:0] res;
wire [31:0] gpio_out;
wire [31:0] sdata_out;
wire [31:0] gpio_in_s_insp;

reg [3:0] test = 0;
reg [31:0] expected_res = 0;
reg [31:0] expected_ones = 0;
reg [7:0] expected_flag = 0;

reg [31:0] res_val = 0;
reg [31:0] ones_val = 0;
reg [7:0] flag_val = 0;

reg [15:0] test_number = 0;

initial begin
	$dumpfile("GpioEmu.vcd");
	$dumpvars(0, GpioEmu_tb);
end
initial begin
	// BEGIN
	#1 n_reset = 1;

	/* TEST #1 - NORMAL 1-digit MULTIPLICATION */
	test_number = test_number + 1;
	expected_res = 'h00000006;
	expected_ones = 'h00000002;
	expected_flag = 'b00010000;
	#1 sdata_in = 'h00000002;
	#1 saddress = 'h2C8;
	#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;
	#1 sdata_in = 'h00000003;
	#1 saddress = 'h2D0;
	#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;
		#1 saddress = 'h2D8;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		res_val = sdata_out;
		if(res_val == expected_res) test[0] = 1;
		#1 saddress = 'h2E0;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		ones_val = sdata_out;
		if(ones_val == expected_ones) test[1] = 1;
		#1 saddress = 'h2E8;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		flag_val = sdata_out;
		if(flag_val == expected_flag) test[2] = 1;

		if(test == 'b111) begin
			$display("\033[32mTest #%0d OK\033[0m", test_number);
		end else begin
			$display("\033[31mTest #%0d FAIL\033[0m", test_number);
			if(test[0] == 0) begin
				$display("\033[31mError: Wrong product value, got %0h, expected %0h\033[0m", res_val, expected_res);
			end
			if(test[1] == 0) begin
				$display("\033[31mError: Wrong ones value, got %0h, expected %0h\033[0m", ones_val, expected_ones);
			end
			if(test[2] == 0) begin
				$display("\033[31mError: Wrong flag value, got %0h, expected %0h\033[0m", flag_val, expected_flag);
			end
		end
		test = 0;

	#1 n_reset = 1;
	/* TEST #2 - OVERFLOW MULTIPLICATION */
	test_number = test_number + 1;
	expected_res = 'h00800000;
	expected_ones = 'h00000001;
	expected_flag = 'b00010001;
	#1 sdata_in = 'h00800000;
	#1 saddress = 'h2C8;
	#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;
	#1 sdata_in = 'h00800001;
	#1 saddress = 'h2D0;
	#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;
		#1 saddress = 'h2D8;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		res_val = sdata_out;
		if(res_val == expected_res) test[0] = 1;
		#1 saddress = 'h2E0;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		ones_val = sdata_out;
		if(ones_val == expected_ones) test[1] = 1;
		#1 saddress = 'h2E8;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		flag_val = sdata_out;
		if(flag_val == expected_flag) test[2] = 1;

		if(test == 'b111) begin
			$display("\033[32mTest #%0d OK\033[0m", test_number);
		end else begin
			$display("\033[31mTest #%0d FAIL\033[0m", test_number);
			if(test[0] == 0) begin
				$display("\033[31mError: Wrong product value, got %0h, expected %0h\033[0m", res_val, expected_res);
			end
			if(test[1] == 0) begin
				$display("\033[31mError: Wrong ones value, got %0h, expected %0h\033[0m", ones_val, expected_ones);
			end
			if(test[2] == 0) begin
				$display("\033[31mError: Wrong flag value, got %0h, expected %0h\033[0m", flag_val, expected_flag);
			end
		end
		test = 0;

	/* TEST #3 - REGISTER A1 ARG TOO BIG */
	test_number = test_number + 1;
	expected_flag = 'b00000100;
	#1 sdata_in = 'h01000000;
	#1 saddress = 'h2C8;
	#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;
		#1 saddress = 'h2E8;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		flag_val = sdata_out;
		if(flag_val == expected_flag) test[2] = 1;

		if(test == 'b100) begin
			$display("\033[32mTest #%0d OK\033[0m", test_number);
		end else begin
			$display("\033[31mTest #%0d FAIL\033[0m", test_number);
			if(test[2] == 0) begin
				$display("\033[31mError: Wrong flag value, got %0h, expected %0h\033[0m", flag_val, expected_flag);
			end
		end
		test = 0;
	// RESET FLAG FROM PREVIOUS TEST
	#1 sdata_in = 'h00000000;
	#1 saddress = 'h2C8;
	#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;

	/* TEST #4 - REGISTER A2 ARG TOO BIG */
	test_number = test_number + 1;
	expected_flag = 'b00001000;
	#1 sdata_in = 'h01000000;
	#1 saddress = 'h2D0;
	#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;
		#1 saddress = 'h2E8;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		flag_val = sdata_out;
		if(flag_val == expected_flag) test[2] = 1;

		if(test == 'b100) begin
			$display("\033[32mTest #%0d OK\033[0m", test_number);
		end else begin
			$display("\033[31mTest #%0d FAIL\033[0m", test_number);
			if(test[2] == 0) begin
				$display("\033[31mError: Wrong flag value, got %0h, expected %0h\033[0m", flag_val, expected_flag);
			end
		end
		test = 0;

	/* TEST #5 - NORMAL 2-digit MULTIPLICATION */
	test_number = test_number + 1;
	expected_res = 'h0000006E;
	expected_ones = 'h00000005;
	expected_flag = 'b00010000;
	#1 sdata_in = 'h0000000A;
	#1 saddress = 'h2C8;
	#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;
	#1 sdata_in = 'h0000000B;
	#1 saddress = 'h2D0;
	#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;
		#1 saddress = 'h2D8;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		res_val = sdata_out;
		if(res_val == expected_res) test[0] = 1;
		#1 saddress = 'h2E0;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		ones_val = sdata_out;
		if(ones_val == expected_ones) test[1] = 1;
		#1 saddress = 'h2E8;
		#1 srd = 1; #1 srd = 0; saddress = 0;
		flag_val = sdata_out;
		if(flag_val == expected_flag) test[2] = 1;

		if(test == 'b111) begin
			$display("\033[32mTest #%0d OK\033[0m", test_number);
		end else begin
			$display("\033[31mTest #%0d FAIL\033[0m", test_number);
			if(test[0] == 0) begin
				$display("\033[31mError: Wrong product value, got %0h, expected %0h\033[0m", res_val, expected_res);
			end
			if(test[1] == 0) begin
				$display("\033[31mError: Wrong ones value, got %0h, expected %0h\033[0m", ones_val, expected_ones);
			end
			if(test[2] == 0) begin
				$display("\033[31mError: Wrong flag value, got %0h, expected %0h\033[0m", flag_val, expected_flag);
			end
		end
		test = 0;

	/* TEST #5-10000 - RANDOM TESTS */
	while(test_number < 10000) begin
		#1 n_reset = 1;
		test_number = test_number + 1;
		
		a = {$random} % 'hFFFFFF;
		b = {$random} % 'hFFFFFF;
		res = a * b;
		//$display("A1: %0h A2: %0h", a, b);

		expected_flag = 'b00010000;
		if(res[63:32] > 0)
			expected_flag[0] = 1;
		
		res = res[31:0];
		expected_res = res;

		expected_ones = 0;
		for(i = 0; i < 32; i++)
			expected_ones = expected_ones + res[i];

		#1 sdata_in = a;
		#1 saddress = 'h2C8;
		#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;
		#1 sdata_in = b;
		#1 saddress = 'h2D0;
		#1 swr = 1; #1 swr = 0; saddress = 0; sdata_in = 0;
			#1 saddress = 'h2D8;
			#1 srd = 1; #1 srd = 0; saddress = 0;
			res_val = sdata_out;
			if(res_val == expected_res) test[0] = 1;
			#1 saddress = 'h2E0;
			#1 srd = 1; #1 srd = 0; saddress = 0;
			ones_val = sdata_out;
			if(ones_val == expected_ones) test[1] = 1;
			#1 saddress = 'h2E8;
			#1 srd = 1; #1 srd = 0; saddress = 0;
			flag_val = sdata_out;
			if(flag_val == expected_flag) test[2] = 1;

		if(test == 'b111) begin
			$write("\033[32mTest #%0d OK\x0d\033[0m", test_number);
		end else begin
			$display("\033[31mTest #%0d FAIL\033[0m", test_number);
			if(test[0] == 0) begin
				$display("\033[31mError: Wrong product value, got %0h, expected %0h\033[0m", res_val, expected_res);
			end
			if(test[1] == 0) begin
				$display("\033[31mError: Wrong ones value, got %0h, expected %0h\033[0m", ones_val, expected_ones);
			end
			if(test[2] == 0) begin
				$display("\033[31mError: Wrong flag value, got %0h, expected %0h\033[0m", flag_val, expected_flag);
			end
		end
		test = 0;
	end
	$display();
	# 20 $finish;
end
// Clock
always begin
	#1 clk = ~clk;
end
gpioemu gpioemu(n_reset, saddress, srd, swr, sdata_in, sdata_out, gpio_in, gpio_latch, gpio_out, gpio_in_s_insp, clk);

endmodule
