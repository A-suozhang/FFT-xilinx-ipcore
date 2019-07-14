module dds_test();

reg clk,rst;

always begin
    # 10
    clk <= ~clk;
end

initial begin
    clk <= 0;
    rst <= 1;
    # 50
    rst <= 0;
end


// ------------------------
wire signed [7:0] m_axis_data_tdata_dds;
wire[31:0] m_axis_phase_tdata_dds;
wire m_axis_data_tvalid_dds, m_axis_phase_tvalid_dds;


// ----------------- MARK TLAST ------------------
// Every 1024 nums We Raise The TLAST FLAG HIGH
reg[9:0] cnt_for_1024;
reg tlast_for_fft;

always@(posedge clk) begin
    if (rst) begin
        cnt_for_1024 <= 0;
        tlast_for_fft <= 0;
        tvalid_for_fft <= 0;
    end
    else begin
        if (s_axis_data_tready) begin

          if (cnt_for_1024 == 10'd1023) begin
              cnt_for_1024 <= 0;
              tlast_for_fft <= 1;
              tvalid_for_fft <= 0;
          end
          else begin
              cnt_for_1024 <= cnt_for_1024 + 1;
              s_axis_data_tdata_re <= m_axis_data_tdata_dds;
              tlast_for_fft <= 0;
              tvalid_for_fft <= 1;
          end
        end
        else begin
            cnt_for_1024 <= 0;
            tlast_for_fft <= 0;
        end
    end
end
 

dds_compiler_0 dds_0 (
  .aclk(clk),                                // input wire aclk
  .m_axis_data_tvalid(m_axis_data_tvalid_dds),    // output wire m_axis_data_tvalid
  .m_axis_data_tdata(m_axis_data_tdata_dds),      // output wire [7 : 0] m_axis_data_tdata
  .m_axis_phase_tvalid(m_axis_phase_tvalid_dds),  // output wire m_axis_phase_tvalid
  .m_axis_phase_tdata(m_axis_phase_tdata_dds)    // output wire [31 : 0] m_axis_phase_tdata
);

// --------------READ FFT's OUTPUT --------------------
reg[23:0] fft_output_re;
reg[23:0] fft_output_im;
reg ready_to_read_from_fft;
wire[63:0] fft_amp;

assign fft_amp = fft_output_re*fft_output_re + fft_output_im*fft_output_im;

always @(posedge clk) begin
    if (rst) begin
        ready_to_read_from_fft <= 0;
      
    end
    else begin
        ready_to_read_from_fft <= 1;
        if (m_axis_data_tvalid_fft) begin
            fft_output_re <= m_axis_data_tdata_re_fft;
            fft_output_im <= m_axis_data_tdata_im_fft;
        end   
    end
end

// -------------------------------------------------
wire signed [23:0] m_axis_data_tdata_re_fft, m_axis_data_tdata_im_fft;
wire m_axis_data_tlast_fft;
wire s_axis_data_tready;
reg[7:0] s_axis_data_tdata_re;
reg tvalid_for_fft;

fft_wrapper fft_wrapper_0( // The Config Word is 0000_0001 Denontes Forward FFT

  .clk_in(clk),
  .rst(rst),
  .s_axis_data_tdata_re(s_axis_data_tdata_re),
  .s_axis_data_tdata_im(8'b00000000),
  .s_axis_data_tvalid(tvalid_for_fft),
  .s_axis_data_tlast(tlast_for_fft),
  .s_axis_data_tready(s_axis_data_tready),
  .m_axis_data_tdata_re(m_axis_data_tdata_re_fft),
  .m_axis_data_tdata_im(m_axis_data_tdata_im_fft),
  .m_axis_data_tvalid(m_axis_data_tvalid_fft),
  .m_axis_data_tready(ready_to_read_from_fft),
  .m_axis_data_tlast(m_axis_data_tlast_fft),

  .event_frame_started(event_frame_started),
  .event_tlast_unexpected(event_tlast_unexpected),
  .event_tlast_missing(event_tlast_missing),
  .event_status_channel_halt(event_status_channel_halt),
  .event_data_in_channel_halt(event_data_in_channel_halt),
  .event_data_out_channel_halt(event_data_out_channel_halt)
);


endmodule
