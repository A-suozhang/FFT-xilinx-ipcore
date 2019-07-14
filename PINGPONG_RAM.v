`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/12 17:27:51
// Design Name: 
// Module Name: PINGPONG_RAM
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

module PINGPONG_RAM(
        input clka,     //clock A
        input rsta,     //reset A
        input [6:0]addra,   //address A
        input wea,      //write enable A
        input [15:0]dina,    //data input A
        input finisha,  //finished A
        output readya,
        input clkb,     //clock B
        input rstb,
        input [6:0]addrb,   //address B
        output [15:0]doutb,  //dout B
        input finishb,  //finished B
        output readyb   //data ready B
    );
    reg sectora=1'b0;
    reg sectoraflop=1'b0;
    reg sectorb=1'b0;
    reg sectorbflop=1'b0;
    reg readya_r=1'b1;
    reg readyb_r=1'b0;
    assign readya=readya_r;
    assign readyb=readyb_r;
    
    always @(posedge clka) begin
        if(rsta)begin
            sectora<=1'b0;
            readya_r<=1'b1;
            sectorbflop<=1'b0;
        end else begin
            sectorbflop<=sectorb;
            if(finisha)begin
                readya_r<=1'b0;
                sectora<=~sectora;
            end else begin
                sectora<=sectora;
                if((!readya)&&(sectora!=sectorbflop))begin
                    readya_r<=1'b1;
                end else begin
                    readya_r<=readya_r;
                end
            end
        end
    end
    
    always @(posedge clkb) begin
        if(rstb)begin
            sectorb<=1'b0;
            readyb_r<=1'b0;
            sectoraflop<=1'b0;
        end else begin
            sectoraflop<=sectora;
            if(finishb)begin
                readyb_r<=1'b0;
                sectorb<=~sectorb;
            end else begin
                sectorb<=sectorb;
                if((!readyb)&&(sectorb!=sectoraflop))begin
                    readyb_r<=1'b1;
                end else begin
                    readyb_r<=readyb_r;
                end
            end
        end
    end
    
    //always enabled, simple dual port RAM
    blk_mem_gen_0 mem_inst(
        .clka(clka),
        .wea(wea),
        .addra({sectora,addra}),
        .dina(dina),
        .clkb(clkb),
        .addrb({sectorb,addrb}),
        .doutb(doutb)
    );
endmodule
