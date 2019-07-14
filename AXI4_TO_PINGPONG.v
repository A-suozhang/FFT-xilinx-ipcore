`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/11 18:38:46
// Design Name: 
// Module Name: AXI4_TO_PINGPONG
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


module AXI4_TO_PINGPONG #(parameter ADDRBITS=7,DATABITS=16,MEMDEPTH=128,USETLAST=0)(
        input clk,
        input rst,
        output [ADDRBITS-1:0]addra,
        output wea,
        output [DATABITS-1:0]dina,
        output finisha,
        input readya,
        input [DATABITS-1:0]s_axis_data_tdata,
        output s_axis_data_tready,
        input s_axis_data_tvalid,
        input s_axis_data_tlast
    );
    
    reg [ADDRBITS-1:0]addra_r0;
    reg wea_r0;
    reg [DATABITS-1:0]dina_r0;
    reg finisha_r0;
    reg [3:0]pingpongwaitcnt=4'd0;
    reg first=1'd1;
    //reg s_axis_data_tready_r0;
    
    assign addra=addra_r0;
    assign wea=wea_r0;
    assign dina=dina_r0;
    assign finisha=finisha_r0;
    assign s_axis_data_tready=readya&&pingpongwaitcnt==4'd0;
    always@(posedge clk)begin
        if(rst)begin
            addra_r0<=0;
            wea_r0<=1'b0;
            dina_r0<=0;
            finisha_r0<=1'b0;
            pingpongwaitcnt<=4'd0;
            first<=1'd1;
            //s_axis_data_tready_r0<=1'b0;
        end else begin
            if(pingpongwaitcnt==4'd0)begin
                if(s_axis_data_tready)begin
                    if(s_axis_data_tvalid)begin
                        wea_r0<=1'b1;
                        dina_r0<=s_axis_data_tdata;
                        if(s_axis_data_tlast || addra_r0==(MEMDEPTH-2))begin
                            pingpongwaitcnt<=4'd5;
                            first<=1'd1;
                        end else begin
                            first<=1'd0;
                        end
                        if(first==1'd0)
                            addra_r0<=addra_r0+1;
                    end else begin
                        wea_r0<=1'b0;
                    end
                end else begin
                    wea_r0<=1'b0;
                end
                finisha_r0<=1'b0;
            end else begin  //waiting
                pingpongwaitcnt<=pingpongwaitcnt-4'd1;
                if(pingpongwaitcnt==4'd5)begin
                    wea_r0<=1'b1;
                end else begin
                    wea_r0<=1'b0;
                end
                
                if(pingpongwaitcnt==4'd2)begin
                    finisha_r0<=1'b1;
                end else begin
                    finisha_r0<=1'b0;
                end
            end
        end
    end
endmodule