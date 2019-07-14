module fft_wrapper
(
    // Control Signal
    input wire clk_in,
    input wire rst,

    // Data_IN
    input wire signed[7:0] s_axis_data_tdata_re,    // [!] Note That It's SIGNED
    input wire signed[7:0] s_axis_data_tdata_im,
    input wire s_axis_data_tvalid,  // The Former Module Denotes That Its OUtput Data Are Valid
    input wire s_axis_data_tlast,   // The Former Module Denotes That Its OUTPUT is Last OUTPUT (ONly Affects 2 Flags, Not Implemented)
    output wire s_axis_data_tready,  // Denote That FFT is ready To Take In Data (IDLE HIGH
    
    // OUTPUT
    output wire signed[23:0] m_axis_data_tdata_re,  // 
    output wire signed[23:0] m_axis_data_tdata_im,  // 
    output wire m_axis_data_tvalid,  // The FFT Module Denote OUTPUT DATA 
    input wire m_axis_data_tready,   // THe Latter Module is ready to accepet data
    output wire m_axis_data_tlast,   // Last Frame Of FFT OUTPUT

    // EVENTS 
    output wire event_frame_started,
    output wire event_tlast_unexpected,
    output wire event_tlast_missing,
    output wire event_status_channel_halt,
    output wire event_data_in_channel_halt,
    output wire event_data_out_channel_halt
);

wire[31:0] s_axis_data_tdata;
assign s_axis_data_tdata = {s_axis_data_tdata_re, s_axis_data_tdata_im};

wire[47:0] m_axis_data_tdata;
assign m_axis_data_tdata_im = m_axis_data_tdata[23:0];
assign m_axis_data_tdata_re = m_axis_data_tdata[47:24];

reg s_axis_config_tvalid;   
// Denote The Former Module is Ready To Config
// We Automatically Raise It HIgh For 1 cycle 
// After Rst Is Done
// To Initialize FFT


reg[7:0] s_axis_config_tdata;

assign s_axis_data_tready = s_axis_data_tready_0 & (!rst) & config_finish; // Ready For Accept_DATA && RST_DONE
reg[7:0] CONFIG = 8'b0000_0001;

/*
reg config_finish;
always @(posedge clk_in) begin

    if (rst) begin
        config_finish <= 0;
    end

    else begin
        if (!config_finish) begin
            if (s_axis_config_tready) begin
                if (s_axis_config_tvalid == 1) begin
                    config_finish <= 1;
                    s_axis_config_tdata <= CONFIG;
                end
                else begin
                    s_axis_config_tvalid <= 1;
                end    
            end
        end
        else begin
            s_axis_config_tvalid <= 0;
        end
    end
    
end
*/
reg config_finish;

always@(posedge clk_in) begin
    if (rst) begin
        s_axis_config_tvalid <= 0;
        config_finish <= 0;
    end
    else begin
        if (!config_finish) begin
            if (s_axis_config_tready) begin
                s_axis_config_tvalid <= 1;
                s_axis_config_tdata <= CONFIG;
                config_finish <= 1;
            end
        end
        else begin
            s_axis_config_tvalid <= 0;
        end
        
    end
end


// -------------------------------- The FFT IP CORE --------------------------------------------
xfft_0 fft_0 (
  .aclk(clk_in),                                                // input wire aclk
  .s_axis_config_tdata(s_axis_config_tdata),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(s_axis_config_tvalid),                // input wire s_axis_config_tvalid        || Formrt Module is Ready To Give CONFIG (WE give config Automatically)
  .s_axis_config_tready(s_axis_config_tready),                // output wire s_axis_config_tready       ||  FFT ready for Accept Config Data
  .s_axis_data_tdata(s_axis_data_tdata),                      // input wire [15 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(s_axis_data_tvalid),                    // input wire s_axis_data_tvalid          || Former Module Output Valid Data
  .s_axis_data_tready(s_axis_data_tready_0),                  // output wire s_axis_data_tready       || FFT is Ready To Accept Data From Former Module (MASTER)
  .s_axis_data_tlast(s_axis_data_tlast),                      // input wire s_axis_data_tlast           
  .m_axis_data_tdata(m_axis_data_tdata),                      // output wire [47 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(m_axis_data_tvalid),                    // output wire m_axis_data_tvalid         || FFT's OUTPUTis VALID 
  .m_axis_data_tready(m_axis_data_tready),                    // input wire m_axis_data_tready          || Latter Module(Slave) is ready to Accept Data
  .m_axis_data_tlast(m_axis_data_tlast),                      // output wire m_axis_data_tlast
  .event_frame_started(event_frame_started),                  // output wire event_frame_started
  .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
  .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
  .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
);

endmodule