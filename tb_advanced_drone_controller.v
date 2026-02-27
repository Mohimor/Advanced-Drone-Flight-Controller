`timescale 1ns/1ps

module tb_advanced_drone_controller;

  
  reg clk = 0;
  always #10 clk = ~clk;

  
  reg reset;
  reg [1:0] flight_command;
  reg [3:0] joystick_input;
  reg [7:0] altimeter_reading;
  reg low_battery_sensor;
  reg [1:0] motor_feedback;
  reg emergency_stop;

  
  wire [1:0] motor_status;
  wire [2:0] status_led;

 initial begin
        $dumpfile("output.vcd");
        $dumpvars(0,tb_advanced_drone_controller);           
       end      


  
 advanced_drone_controller dut (
    .clk(clk),
    .reset(reset),
    .flight_command(flight_command),
    .joystick_input(joystick_input),
    .altimeter_reading(altimeter_reading),
    .low_battery_sensor(low_battery_sensor),
    .motor_feedback(motor_feedback),
    .emergency_stop(emergency_stop),
    .motor_status(motor_status),
    .status_led(status_led)
  );

  
  
  reg follow_feedback = 1;

  always @(posedge clk) begin
    if (follow_feedback) begin
      motor_feedback <= motor_status;
    end  
  end
  
  task wait_cycles;
    input integer n;
    integer i;
    begin
      for (i = 0; i < n; i = i + 1) @(posedge clk);
    end
  endtask
  

  task disarm;
    begin
      flight_command = 2'b01; 
      wait_cycles(8); 
      flight_command = 2'b00; 
      wait_cycles(4);
    end
  endtask

   task arm;
    begin
      flight_command = 2'b01; 
      wait_cycles(8); 
      flight_command = 2'b00; 
      wait_cycles(4);
    end
  endtask


  task takeoff;
    begin
      flight_command = 2'b10; 
      wait_cycles(8); 
      flight_command = 2'b00; 
      wait_cycles(2);
    end
  endtask


  task land;
    begin
      flight_command = 2'b11; 
      wait_cycles(8); 
      flight_command = 2'b00; 
      wait_cycles(4);
    end
  endtask


  task joystick;
    input [3:0] val;
    input integer cyc;
    begin
      joystick_input = val; 
      wait_cycles(cyc); 
      joystick_input = 4'b0000; 
      wait_cycles(4);
    end
  endtask


  task increas_height;
    input integer limit;
    begin
      while (altimeter_reading < limit) begin
        altimeter_reading = altimeter_reading + 1; 
        wait_cycles(2);
      end
    end
  endtask

  
  task decreas_height;
    begin
      while (altimeter_reading > 0) begin
        altimeter_reading = altimeter_reading - 1; 
        wait_cycles(2);
      end
    end
  endtask

  
  task emergency;
    input integer c;
    begin
      emergency_stop = 1; 
      wait_cycles(c); 
      emergency_stop = 0; 
      wait_cycles(5);
    end
  endtask

  

 

  


  initial begin
   
      reset = 1;                    
      flight_command = 2'b00;      
      joystick_input = 4'b0000;     
      altimeter_reading = 8'd0;     
      low_battery_sensor = 0;       
      emergency_stop = 0;           
      motor_feedback = 2'b00;       

      wait_cycles(5);               
      reset = 0;                    
      wait_cycles(5);               

      
      arm();                        
      disarm();                     
      arm();                        

     
      takeoff();                

     
      joystick(4'b0001, 20);    
      joystick(4'b0010, 20);    
      joystick(4'b0100, 20);    
      joystick(4'b1000, 20);    
 
      wait_cycles(15);              

      
      low_battery_sensor = 1;       
      wait_cycles(4);
      land();                   
      decreas_height();            
      low_battery_sensor = 0;       
      wait_cycles(6);

      
      arm();
      takeoff();

      altimeter_reading = 8'd0; 
      wait_cycles(3);
      altimeter_reading = 8'd5; 
      wait_cycles(4);
      altimeter_reading = 8'd6; 
      wait_cycles(5);
      increas_height(10);                  

      
      land();
      wait_cycles(6);
      altimeter_reading = 8'd9; 
      wait_cycles(4);
      altimeter_reading = 8'd10; 
      wait_cycles(4);
      decreas_height();             

      
      arm();
      takeoff();
      altimeter_reading = 8'd0; 
      wait_cycles(2);
      altimeter_reading = 8'd3; 
      wait_cycles(2);
      emergency(3);             
      wait_cycles(10);
      reset = 1;                      
      wait_cycles(3); 
      reset = 0; 
      wait_cycles(5);

      
      arm();
      takeoff();
      increas_height(12);                   
      emergency(5);             
      wait_cycles(10);
      reset = 1;                      
      wait_cycles(3); 
      reset = 0; 
      wait_cycles(5);

      
      arm();
      takeoff();
      increas_height(9);                   
      follow_feedback = 0;            
      motor_feedback = 2'b01;         
      wait_cycles(120);              
      follow_feedback = 1;            
      wait_cycles(15); 
      
                 

      $finish; 
                            
  end
   


endmodule
