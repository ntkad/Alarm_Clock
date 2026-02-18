`timescale 1us/1ns

module alarm_clock_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg set_time;
    reg increment_hour;
    reg increment_minute;
    reg set_alarm_time;
    reg enable_alarm;
    reg alarm_off;

    // Outputs
    wire [4:0] time_hours;
    wire [5:0] time_minutes;
    wire [5:0] time_seconds;
    wire alarm;
    wire alarm_enabled;

    /*wire [7:0] clk_count;
    wire [4:0]  alarm_hours;
    wire [5:0]  alarm_minutes;
    wire [4:0]  hour_store;
    wire [5:0]  minute_store;*/

    // Instantiate DUT
    alarm_clock uut (
        .clk(clk),
        .rst_n(rst_n),
        .set_time(set_time),
        .increment_hour(increment_hour),
        .increment_minute(increment_minute),
        .set_alarm_time(set_alarm_time),
        .enable_alarm(enable_alarm),
        .alarm_off(alarm_off),
        .time_hours(time_hours),
        .time_minutes(time_minutes),
        .time_seconds(time_seconds),
        .alarm(alarm),
        .alarm_enabled(alarm_enabled)

        /*.time_seconds(time_seconds),
        .clk_count(clk_count),
	.alarm_hours(alarm_hours),
	.alarm_minutes(alarm_minutes),
	.hour_store(hour_store),
	.minute_store(minute_store)*/
    );

    // Clock generation: 50M Hz → 2 us period
    initial clk = 0;
    always #1 clk = ~clk;

    // Stimulus
    initial begin
        $dumpfile("alarm_clock.vcd");
        $dumpvars(0, alarm_clock_tb);

        $display("time(us)\t clk  hr  min  alarm en ");
        $monitor("%8t   %b   %02d  %02d   %b     %b    ",
                 $time, clk, time_hours, time_minutes, alarm, alarm_enabled);

        // Reset
        rst_n = 0;
        set_time = 0; increment_hour = 0; increment_minute = 0;
        set_alarm_time = 0; enable_alarm = 0; alarm_off = 0;
        #10; rst_n = 1;  // release reset

        // Requirement 5: Set time hour
        #1000; set_time = 1; 
	repeat (46) begin                                 //23 clk cycles, 2us per cycle
		#1 increment_hour = ~increment_hour; 
	end
	#2; increment_hour = 0; set_time = 0;

	// Requirement 6: Set time minute
        #1000; set_time = 1; 
	repeat (118) begin                                //59 clk cycles, 2us per cycle
		#1 increment_minute = ~increment_minute; 
	end 
	#2; increment_minute = 0; set_time = 0;

        // Requirement 7–9: Set alarm time
        #1000; set_alarm_time = 1;
	repeat (122) begin                                  //set alarm at 00:01
        	#1 increment_minute = ~increment_minute;
 	end
	repeat (48) begin
		#1 increment_hour = ~increment_hour;
	end
        #2; set_alarm_time = 0; increment_hour = 0; increment_minute = 0;

        // Requirement 10: Toggle alarm enable
        #1000; enable_alarm = 1;
	#2; enable_alarm = 0;
	#2; enable_alarm = 1;

        #60000;

        // Requirement 11: Turn alarm off
        #100; alarm_off = 1; 
	#10; alarm_off = 0;

        $finish;
    end

endmodule
