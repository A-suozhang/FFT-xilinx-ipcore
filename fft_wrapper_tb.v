module fft_wrapper_tb();

reg clk, rst;

always begin
    # 5
    clk <= ~ clk;
end

initial begin
    rst <= 1;
    clk <= 0;
    # 20
    rst <= 0;
    
    $readmemh("C:/Users/A_suozhang/Code/EE/Matlab/sin_wave.txt",data_in,0,127); 
end

reg[9:0] cnt;

// Gnerating A Streaming Of Data (Read From Txt 10kHz Sin Wave)
reg signed[13:0] data_in[0:127]; 
reg signed[15:0] expanded_data_in;
reg[31:0] s_axis_data_tdata;
reg s_axis_data_tvalid, s_axis_data_tlast;
wire s_axis_data_tready_o;


always @(posedge clk) begin
    if (rst) begin
        cnt <= 0;
        s_axis_data_tdata <= 0;
        expanded_data_in <= 0;
        s_axis_data_tlast <= 0;
        s_axis_data_tvalid <= 0;
    end

    else begin
        if (cnt == 0) begin
            s_axis_data_tvalid <= 1;
        end

        if (cnt == 126) begin
            s_axis_data_tlast <= 1;
        end

        if (cnt == 127) begin
            s_axis_data_tvalid <= 0;
            s_axis_data_tlast <= 0;
            cnt <= 0;
        end 

        if (s_axis_data_tready_o && s_axis_data_tvalid) begin
            cnt <= cnt + 1;
            expanded_data_in = {data_in[cnt][13], data_in[cnt][13], data_in[cnt]};  
            s_axis_data_tdata[31:16] = {data_in[cnt][13], data_in[cnt][13], data_in[cnt]};
        end
    end

end



wire signed[23:0] fft_re, fft_im;
wire[47:0] m_axis_data_tdata;
assign fft_re = m_axis_data_tdata[47:24];
assign fft_im = m_axis_data_tdata[23:0];
wire[63:0] fft_amp;
assign fft_amp = fft_re*fft_re + fft_im*fft_im;

integer fp;
reg[9:0] cnt1;

always @(posedge clk) begin
    if(rst) begin
        cnt1 <= 0;
        fp = $fopen("C:/Users/A_suozhang/Code/EE/Verilog/Read_Text/test1.txt","w");
    end
    else if (m_axis_data_tvalid) begin
        cnt1 <= cnt1 + 1;
        $fdisplay(fp,"%h %h", fft_re,fft_im);
    end
    if (cnt1 == 127) begin
        $fclose(fp);
    end
end
// reg[23:0] signed fft_re,fft_im;

// always @(posedge clk) begin
//     if (rst) begin
//         fft_re <= 0;
//         fft_im <= 0;
//     end
//     else begin
//         if (m_axis_data_tvalid) begin
//             fft_re <= m_axis_data_tdata[47:24];
//             fft_im <= m_axis_data_tdata[23:0];
//         end
//     end
// end

wire m_axis_data_tready;
assign m_axis_data_tready = 1;


FFT_WRAPPER FFT_WRAPPER_0(
    .clk(clk),
    .rst(rst),
    .rst_done(rst_done),
    .s_axis_data_tdata(s_axis_data_tdata),          // High 16 Is Re
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tready_o(s_axis_data_tready_o),
    .s_axis_data_tlast(s_axis_data_tlast),

     .m_axis_data_tdata(m_axis_data_tdata),
     .m_axis_data_tvalid(m_axis_data_tvalid),
     .m_axis_data_tready(m_axis_data_tready),
     .m_axis_data_tlast(m_axis_data_tlast),

     .event_frame_started(event_frame_started),
     .event_tlast_unexpected(event_tlast_unexpected),
     .event_tlast_missing(event_tlast_missing),
     .event_status_channel_halt(event_status_channel_halt),
     .event_data_in_channel_halt(event_data_in_channel_halt),
     .event_data_out_channel_halt(event_data_out_channel_halt)

);


endmodule
