`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/10 19:15:35
// Design Name: 
// Module Name: PINGPONG_TO_AXI4
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

module PINGPONG_TO_AXI4 #(parameter ADDRBITS=7,DATABITS=16,MEMDEPTH=128,USETLAST=0)(
        input clk,
        input rst,
        output [ADDRBITS-1:0]addrb,
        input [DATABITS-1:0]doutb,
        output finishb,
        input readyb,
        output [DATABITS-1:0]m_axis_data_tdata,
        input m_axis_data_tready,
        output m_axis_data_tvalid,
        output m_axis_data_tlast
    );
    //reg fifo_wr_en=0;
    reg fifo_wr_en=1'b0;
    reg fifo_wr_en_r1=1'b0;
    //reg fifo_rd_en=0;
    reg fifo_rd_en_r0=1'b0;
    reg [3:0]pprreadingcount=4'd0;
    reg [2:0]fiforeadingcount=4'd0;
    reg [ADDRBITS-1:0]addrb_r0=0;
    reg finishb_r0=1'b0;
    reg [3:0]waitcnt=4'd5;
    reg [3:0]pingpongwaitcnt=4'd0;
    wire fifo_full;
    wire fifo_almost_full;
    wire fifo_empty;
    wire fifo_almost_empty;
    wire [3:0]fifo_data_count;
    wire [DATABITS-1:0]fifo_dout;
    reg [DATABITS-1:0]fifo_dout_r1;
    
    assign addrb=addrb_r0;
    assign finishb=finishb_r0;
    
    reg m_axis_data_tvalid_r0=1'b0;
    reg m_axis_data_tvalid_r1=1'b0;
    reg m_axis_data_tlast_r0=1'b0;
    reg [DATABITS-1:0]transcount=0;
    assign m_axis_data_tvalid=(~(fiforeadingcount==4'd0));//&&(~fifo_empty);
    assign m_axis_data_tdata=(fiforeadingcount<4'd2)?fifo_dout:fifo_dout_r1;
    assign m_axis_data_tlast=m_axis_data_tlast_r0;
    
    always@(posedge clk)begin
        if(rst)begin
            fifo_wr_en<=1'b0;
            pprreadingcount<=4'd0;
            addrb_r0<=0;
            finishb_r0<=1'b0;
            waitcnt<=4'd5;
            m_axis_data_tvalid_r0<=1'b0;
            m_axis_data_tvalid_r1<=1'b0;
            m_axis_data_tlast_r0<=1'b0;
            fiforeadingcount<=4'd0;
            transcount<=0;
            fifo_dout_r1<=0;
        end else begin
            if(waitcnt>4'd0)begin
                waitcnt<=waitcnt-4'd1;
            end else begin
                //push fifo
                fifo_wr_en<=fifo_wr_en_r1;
                if(pingpongwaitcnt>4'd0)begin
                    pingpongwaitcnt<=pingpongwaitcnt-4'd1;
                    if(pingpongwaitcnt==4'd5)begin
                        finishb_r0<=1'b1;
                    end else begin
                        finishb_r0<=1'b0;
                    end
                    fifo_wr_en_r1<=1'b0;
                end else begin
                    finishb_r0<=1'b0;
                    if(readyb)begin
                        if(fifo_data_count<4'd11)begin   //was 5
                            if(addrb_r0<MEMDEPTH-1)begin
                                addrb_r0<=addrb_r0+1;
                            end else begin
                                addrb_r0<=0;
                                pingpongwaitcnt<=4'd7;// was 10
                            end
                            fifo_wr_en_r1<=1'b1;
                        end else begin
                            fifo_wr_en_r1<=1'b0;
                        end
                    end else begin
                        pingpongwaitcnt<=4'd1;
                        fifo_wr_en_r1<=1'b0;
                    end
                end
                //pop fifo
                //m_axis_data_tvalid_r0<=m_axis_data_tvalid_r1;
                if(~fifo_almost_empty)begin
                    fifo_rd_en_r0<=(m_axis_data_tready||fiforeadingcount==4'd0);
                    if(fiforeadingcount<4'd2)begin
                        fifo_dout_r1<=fifo_dout;
                    end
                end else begin
                    fifo_rd_en_r0<=1'd0;
                end
                //fifo count
                if((fifo_rd_en_r0==1'b1 && m_axis_data_tready==1'b0) || (fifo_rd_en_r0==1'b1 && m_axis_data_tvalid==1'b0))begin
                    fiforeadingcount<=fiforeadingcount+4'd1;
                end else begin
                    if(fifo_rd_en_r0==1'b0 && m_axis_data_tready==1'b1 && m_axis_data_tvalid==1'b1)begin
                        fiforeadingcount<=fiforeadingcount-4'd1;
                    end
                end
                if(m_axis_data_tready & m_axis_data_tvalid)begin
                    if(transcount<(MEMDEPTH-1))begin
                        transcount<=transcount+1;
                    end else begin
                        transcount<=0;
                    end
                    if(transcount==(MEMDEPTH-2))begin
                        m_axis_data_tlast_r0<=1'b1;
                    end else begin
                        m_axis_data_tlast_r0<=1'b0;
                    end
                end else begin
                    m_axis_data_tlast_r0<=1'b0;
                end
            end
        end
    end
    
    fifo_transbuf_0 fifo_transbuf (
      .clk(clk),                    // input wire clk
      .srst(rst),                  // input wire srst
      .din(doutb),                    // input wire [15 : 0] din
      .wr_en(fifo_wr_en),                // input wire wr_en
      .rd_en(fifo_rd_en_r0),                // input wire rd_en
      .dout(fifo_dout),                  // output wire [15 : 0] dout
      .full(fifo_full),                  // output wire full
      .almost_full(fifo_almost_full),    // output wire almost_full
      .empty(fifo_empty),                // output wire empty
      .almost_empty(fifo_almost_empty),  // output wire almost_empty
      .data_count(fifo_data_count)      // output wire [3 : 0] data_count
    );
    
endmodule
