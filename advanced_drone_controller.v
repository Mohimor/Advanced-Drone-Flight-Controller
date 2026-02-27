`timescale 1ns/1ps
module advanced_drone_controller (
    input clk,
    input reset,
    input [1:0] flight_command,
    input [3:0] joystick_input,
    input [7:0] altimeter_reading,
    input low_battery_sensor,
    input [1:0] motor_feedback,
    input emergency_stop,
    output reg [1:0] motor_status,
    output reg [2:0] status_led
);

    parameter S_LANDED = 4'b0000;
    parameter S_IDLE = 4'b0001;
    parameter S_TAKING_OFF = 4'b0010;
    parameter S_IN_FLIGHT = 4'b0011;
    parameter S_MANEUVERING = 4'b0100;
    parameter S_LANDING = 4'b0101;
    parameter S_EMERGENCY = 4'b0110;
    parameter S_FAULT = 4'b0111;

    reg [3:0] current_state;
    reg [3:0] next_state;

    reg [6:0] fault_counter;

    wire fault_detected;
    assign fault_detected = (fault_counter >= 7'd100);
 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fault_counter <= 7'd0;
        end else if (motor_status != motor_feedback) begin
            if (fault_counter < 7'd100)
                fault_counter <= fault_counter + 7'd1;
        end else begin
            fault_counter <= 7'd0;
        end
    end

    
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= S_LANDED;
        else
            current_state <= next_state;
    end

    
    always @(*) begin
        next_state = current_state;
         
        case (current_state)
            S_LANDED: begin
                if (flight_command == 2'b01) next_state = S_IDLE;
            end
            S_IDLE: begin
                if (flight_command == 2'b01)      next_state = S_LANDED;       
                else if (flight_command == 2'b10) next_state = S_TAKING_OFF;   
            end
            S_TAKING_OFF: begin
                if (altimeter_reading > 8'd5) next_state = S_IN_FLIGHT;
            end
            S_IN_FLIGHT: begin
                if (joystick_input != 4'b0000) next_state = S_MANEUVERING;
                else if (flight_command == 2'b11 || low_battery_sensor) next_state = S_LANDING;
            end
            S_MANEUVERING: begin
                if (joystick_input == 4'b0000) next_state = S_IN_FLIGHT;
                else if (flight_command == 2'b11 || low_battery_sensor) next_state = S_LANDING;
            end
            S_LANDING: begin
                if (altimeter_reading == 8'd0) next_state = S_LANDED;
            end
            S_EMERGENCY,
            S_FAULT: begin
                next_state = S_LANDING;  
            end
            default: next_state = S_LANDED;
        endcase

        
        if (emergency_stop)        next_state = S_EMERGENCY;
        else if (fault_detected)   next_state = S_FAULT;
    end

    
    always @(*) begin
        motor_status = 2'b00;
        status_led   = 3'b001;

        case (current_state)
            S_LANDED: begin
                motor_status = 2'b00;
                status_led   = 3'b001;
            end
            S_IDLE: begin
                motor_status = 2'b01;
                status_led   = 3'b010;
            end
            S_TAKING_OFF,
            S_IN_FLIGHT,
            S_MANEUVERING: begin
                motor_status = 2'b10;
                status_led   = 3'b100;
            end
            S_LANDING: begin
                motor_status = 2'b11;
                status_led   = 3'b101;
            end
            S_EMERGENCY,
            S_FAULT: begin
                motor_status = 2'b00;
                status_led   = 3'b111; 
            end
            default: begin
                motor_status = 2'b00;
                status_led   = 3'b001;
            end
        endcase
    end

endmodule
