module alarm_clock (
    input  wire        clk,              
    input  wire        rst_n,            // active-low reset
    input  wire        set_time,         
    input  wire        increment_hour,   
    input  wire        increment_minute, 
    input  wire        set_alarm_time,   
    input  wire        enable_alarm,     
    input  wire        alarm_off,        
    output reg  [4:0]  time_hours,       // 0–23
    output reg  [5:0]  time_minutes,     // 0–59
    output reg  [5:0]  time_seconds,     // 0- 59
    output reg         alarm,            
    output reg         alarm_enabled  
	 
    /*output reg  [7:0]  clk_count,             //for testing       
    output reg  [4:0]  alarm_hours,      
    output reg  [5:0]  alarm_minutes,    
    output reg  [4:0]  hour_store,
    output reg  [5:0]  minute_store */
);
    
    reg  [7:0]  clk_count;               // 8-bit counter (0–255)
    reg  [4:0]  alarm_hours;             // 0-23
    reg  [5:0]  alarm_minutes;           // 0-59
    reg  [4:0]  hour_store;              // 0-23, saving current hour
    reg  [5:0]  minute_store;            // 0-59, saving current minute

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin                                             //-------------------------------------------
            clk_count     <= 0;                                       // Func.1 : When reset is released,
	    time_seconds  <= 0;	                                      //          the time shall be 00:00 and
            time_hours    <= 0;                                       //          the alarm shall be disabled.
            time_minutes  <= 0;                                       //
            alarm_hours   <= 0;                                       //
            alarm_minutes <= 0;                                       //
            alarm_enabled <= 0;                                       // 
            alarm         <= 0;                                       // 
        end else begin                                                //
            clk_count <= clk_count + 1;                               // 256 Hz clock signal -> 1 second
            if (clk_count == 255) begin                               //
                clk_count <= 0;                                       // 
		time_seconds <= time_seconds + 1;                     // Func.2 : time_minutes output shall 
		if (time_seconds == 59)begin                          //          increment every 60 seconds.
			time_seconds <= 0;                            //
                	if (!set_time && !set_alarm_time) begin       //
                    		time_minutes <= time_minutes + 1;     // 
                    		if (time_minutes == 59) begin         // Func.3 : time_hours output shall
                        		time_minutes <= 0;            //          increment every 60 minutes. 
                        		time_hours <= time_hours + 1; //  
                        		if (time_hours == 23)         //
                            			time_hours <= 0;      // Func.4 : valid range 00:00 to 23:59
                    		end                                   //
                	end                                           //
		end                                                   //  
            end                                                       //-------------------------------------------

            if (set_time) begin                                                   //-------------------------------
                if (increment_hour)                                               // Func.5,6 : when set_time is
                    time_hours <= (time_hours == 23) ? 0 : time_hours + 1;        //            active, pressing   
                if (increment_minute)                                             //            increment_hour and
                    time_minutes <= (time_minutes == 59) ? 0 : time_minutes + 1;  //            increment_minute
            end                                                                   //            will increment by
                                                                                  //            one every clk cycle      
    	                                                                          //-------------------------------
    	    
	    if (set_alarm_time) begin                            //------------------------------------------------             
                if (increment_hour)begin                         // Func.7,8,9 : When set_alarm_time is active,
		    if (alarm_hours == 23)                       //              the alarm time will be displayed
			alarm_hours <= 0;                        //              on the time_hours/minutes output,
		    else begin                                   //              and pressing increment_hour and
			alarm_hours <= alarm_hours + 1;          //              increment_minute will invrement 
		    end                                          //              the alarm hour/minute by one every
		end                                              //              clk cycle.
		time_hours <= alarm_hours;                       //
                                                                 //              When set_alarm_time is inactive,
                if (increment_minute)begin                       //              the time should be displayed.
                    if (alarm_minutes == 59)                     //
			alarm_minutes <= 0;                      // 
		    else begin                                   //
			alarm_minutes <= alarm_minutes + 1;      //
		    end                                          // 
		end                                              //
		time_minutes <= alarm_minutes;                   //
            end                                                  //------------------------------------------------ 

                                                                 //------------------------------------------------
            if (enable_alarm)                                    // Func.10 :  When enable_alarm is active,
                alarm_enabled <= ~alarm_enabled;                 //  	       alarm_enable should toggle state
                                                                 //------------------------------------------------        
                                                                 
            if (alarm_enabled &&                                 //------------------------------------------------
                time_hours == alarm_hours &&                     // Func.11 :  If the alarm is enabled, when
                time_minutes == alarm_minutes)                   //            current time is equal to alarm time,  
                alarm <= 1;                                      //            the alarm output shall go active
                                                                 //            until alarm_off goes active.
            if (alarm_off)                                       // 
                alarm <= 0;                                      //
        end                                                      //------------------------------------------------
    end                                                            

    always @ (posedge set_alarm_time) begin                      //------------------------------------------------
		hour_store <= time_hours;                        // Func.7 : store time_hours/minutes so alarm time
		minute_store <= time_minutes;                    //          can be displayed on time_hours/minutes 
	    end                                                  //          output.
                                                                 // 
    always @ (negedge set_alarm_time) begin                      //          when exiting alarm setting mode,
		time_hours <= hour_store;                        //          retrieve stored time back to  
		time_minutes <= minute_store;                    //          time_hours/minutes output, and clear
		hour_store <= 0;                                 //          stored value.
		minute_store <= 0;                               // 
	    end                                                  //------------------------------------------------ 

endmodule
