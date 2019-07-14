`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/12 21:54:15
// Design Name: 
// Module Name: FFT_WRAPPER
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FFT_WRAPPER(
        input clk,
        input rst,
        output rst_done,
        input [31:0]s_axis_data_tdata,
        input s_axis_data_tvalid,
        output s_axis_data_tready_o,
        input s_axis_data_tlast,
        output [47:0]m_axis_data_tdata,
        output m_axis_data_tvalid,
        input m_axis_data_tready,
        output m_axis_data_tlast,
        output event_frame_started,
        output event_tlast_unexpected,
        output event_tlast_missing,
        output event_status_channel_halt,
        output event_data_in_channel_halt,
        output event_data_out_channel_halt
    );
    
    reg [7:0]s_axis_config_tdata_r0=8'b0000_0001;
    reg s_axis_config_tvalid_r0=1'b0;
    wire s_axis_config_tready;
    wire s_axis_data_tready;
    reg rst_done_r0=1'b0;
    
    assign s_axis_data_tready_o=s_axis_data_tready&&(~rst)&&rst_done;
    assign rst_done=rst_done_r0;
    
    always@(posedge clk)begin
        if(rst)begin
            rst_done_r0<=1'b0;
            s_axis_config_tdata_r0<=8'd0;
            s_axis_config_tvalid_r0<=1'b0;
        end else begin
            if(~rst_done_r0)begin
                if(s_axis_config_tready)begin
                    s_axis_config_tvalid_r0<=1'b1;
                    s_axis_config_tdata_r0<=8'd0;
                    rst_done_r0<=1'b1;
                end
            end else begin
                s_axis_config_tvalid_r0<=1'b0;
            end
        end
    end
    
    xfft_0 fft_inst (
      .aclk(clk),                                                // input wire aclk
      .s_axis_config_tdata(s_axis_config_tdata_r0),                  // input wire [7 : 0] s_axis_config_tdata
      .s_axis_config_tvalid(s_axis_config_tvalid_r0),                // input wire s_axis_config_tvalid
      .s_axis_config_tready(s_axis_config_tready),                // output wire s_axis_config_tready
      .s_axis_data_tdata(s_axis_data_tdata),                      // input wire [31 : 0] s_axis_data_tdata
      .s_axis_data_tvalid(s_axis_data_tvalid),                    // input wire s_axis_data_tvalid
      .s_axis_data_tready(s_axis_data_tready),                    // output wire s_axis_data_tready
      .s_axis_data_tlast(s_axis_data_tlast),                      // input wire s_axis_data_tlast
      .m_axis_data_tdata(m_axis_data_tdata),                      // output wire [47 : 0] m_axis_data_tdata
      .m_axis_data_tvalid(m_axis_data_tvalid),                    // output wire m_axis_data_tvalid
      .m_axis_data_tready(m_axis_data_tready),                    // input wire m_axis_data_tready
      .m_axis_data_tlast(m_axis_data_tlast),                      // output wire m_axis_data_tlast
      .event_frame_started(event_frame_started),                  // output wire event_frame_started
      .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
      .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
      .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
      .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
      .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
    );
endmodule
