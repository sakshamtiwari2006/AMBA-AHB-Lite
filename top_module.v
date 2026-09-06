`timescale 1ns / 1ps

module top_module (
    input HCLK,
    input HRESETn,
    
    // Control inputs for Master 0
    input        m0_henable,
    input [31:0] m0_start_addr,
    input [31:0] m0_write_data,
    input        m0_write,
    input [2:0]  m0_size,
    input [2:0]  m0_burst,
    input        m0_hbusreq,
    input        m0_hlock,

    // Control inputs for Master 1
    input        m1_henable,
    input [31:0] m1_start_addr,
    input [31:0] m1_write_data,
    input        m1_write,
    input [2:0]  m1_size,
    input [2:0]  m1_burst,
    input        m1_hbusreq,
    input        m1_hlock,

    // Control inputs for Master 2
    input        m2_henable,
    input [31:0] m2_start_addr,
    input [31:0] m2_write_data,
    input        m2_write,
    input [2:0]  m2_size,
    input [2:0]  m2_burst,
    input        m2_hbusreq,
    input        m2_hlock,

    // Control inputs for Master 3
    input        m3_henable,
    input [31:0] m3_start_addr,
    input [31:0] m3_write_data,
    input        m3_write,
    input [2:0]  m3_size,
    input [2:0]  m3_burst,
    input        m3_hbusreq,
    input        m3_hlock,

    // Bus outputs for observation
    output [31:0] HWDATA,
    output [31:0] HADDR,
    output        HWRITE,
    output [2:0]  HSIZE,
    output [1:0]  HTRANS,
    output [2:0]  HBURST,
    output [3:0]  HWSTRB,
    output [31:0] HRDATA,
    output        HRESP,
    output        HREADY,
    output [1:0]  HMASTER,
    output        HMASTLOCK
);

    // Arbiter / Grant Signals
    wire [3:0] hbusreq = {m3_hbusreq, m2_hbusreq, m1_hbusreq, m0_hbusreq};
    wire [3:0] hlock   = {m3_hlock,   m2_hlock,   m1_hlock,   m0_hlock};
    wire [3:0] hgrant;

    // Master 0 Signals
    wire [31:0] m0_haddr, m0_hwdata;
    wire [1:0]  m0_htrans;
    wire [2:0]  m0_hsize_out, m0_hburst_out;
    wire        m0_hwrite;
    wire [3:0]  m0_hwstrb;

    // Master 1 Signals
    wire [31:0] m1_haddr, m1_hwdata;
    wire [1:0]  m1_htrans;
    wire [2:0]  m1_hsize_out, m1_hburst_out;
    wire        m1_hwrite;
    wire [3:0]  m1_hwstrb;

    // Master 2 Signals
    wire [31:0] m2_haddr, m2_hwdata;
    wire [1:0]  m2_htrans;
    wire [2:0]  m2_hsize_out, m2_hburst_out;
    wire        m2_hwrite;
    wire [3:0]  m2_hwstrb;

    // Master 3 Signals
    wire [31:0] m3_haddr, m3_hwdata;
    wire [1:0]  m3_htrans;
    wire [2:0]  m3_hsize_out, m3_hburst_out;
    wire        m3_hwrite;
    wire [3:0]  m3_hwstrb;

    // Decoder Signals
    wire HSEL1, HSEL2, HSEL3, HSEL4, HSEL_DEFAULT;
    wire [3:0] HSELx = {HSEL4, HSEL3, HSEL2, HSEL1};

    // Slave Response Signals
    wire [31:0] hrdata1, hrdata2, hrdata3, hrdata4, hrdata_def;
    wire        hresp1,  hresp2,  hresp3,  hresp4,  hresp_def;
    wire        hready1, hready2, hready3, hready4, hready_def;

    // =========================================================================
    // Arbiter Instantiation
    // =========================================================================
    arbiter arb (
        .HCLK      (HCLK),
        .HRESETn   (HRESETn),
        .HREADY    (HREADY),
        .HBUSREQ   (hbusreq),
        .HLOCK     (hlock),
        .HGRANT    (hgrant),
        .HMASTER   (HMASTER),
        .HMASTLOCK (HMASTLOCK)
    );

    // =========================================================================
    // Master Instantiations
    // =========================================================================
    master m0 (
        .HCLK(HCLK), .HRESETn(HRESETn), .HENABLE(m0_henable),
        .start_addr(m0_start_addr), .write_data(m0_write_data),
        .write(m0_write), .size(m0_size), .burst(m0_burst),
        .HRDATA(HRDATA), .HRESP(HRESP), .HREADY(HREADY),
        .HWDATA(m0_hwdata), .HADDR(m0_haddr), .HSIZE(m0_hsize_out),
        .HWSTRB(m0_hwstrb), .HWRITE(m0_hwrite), .HTRANS(m0_htrans), .HBURST(m0_hburst_out)
    );

    master m1 (
        .HCLK(HCLK), .HRESETn(HRESETn), .HENABLE(m1_henable),
        .start_addr(m1_start_addr), .write_data(m1_write_data),
        .write(m1_write), .size(m1_size), .burst(m1_burst),
        .HRDATA(HRDATA), .HRESP(HRESP), .HREADY(HREADY),
        .HWDATA(m1_hwdata), .HADDR(m1_haddr), .HSIZE(m1_hsize_out),
        .HWSTRB(m1_hwstrb), .HWRITE(m1_hwrite), .HTRANS(m1_htrans), .HBURST(m1_hburst_out)
    );

    master m2 (
        .HCLK(HCLK), .HRESETn(HRESETn), .HENABLE(m2_henable),
        .start_addr(m2_start_addr), .write_data(m2_write_data),
        .write(m2_write), .size(m2_size), .burst(m2_burst),
        .HRDATA(HRDATA), .HRESP(HRESP), .HREADY(HREADY),
        .HWDATA(m2_hwdata), .HADDR(m2_haddr), .HSIZE(m2_hsize_out),
        .HWSTRB(m2_hwstrb), .HWRITE(m2_hwrite), .HTRANS(m2_htrans), .HBURST(m2_hburst_out)
    );

    master m3 (
        .HCLK(HCLK), .HRESETn(HRESETn), .HENABLE(m3_henable),
        .start_addr(m3_start_addr), .write_data(m3_write_data),
        .write(m3_write), .size(m3_size), .burst(m3_burst),
        .HRDATA(HRDATA), .HRESP(HRESP), .HREADY(HREADY),
        .HWDATA(m3_hwdata), .HADDR(m3_haddr), .HSIZE(m3_hsize_out),
        .HWSTRB(m3_hwstrb), .HWRITE(m3_hwrite), .HTRANS(m3_htrans), .HBURST(m3_hburst_out)
    );

    // =========================================================================
    // Master Multiplexer Instantiation
    // =========================================================================
    master_mux master_multiplexer (
        .HMASTER   (HMASTER),

        .M0_HADDR  (m0_haddr),  .M0_HTRANS (m0_htrans),
        .M0_HWRITE (m0_hwrite), .M0_HSIZE  (m0_hsize_out),
        .M0_HBURST (m0_hburst_out), .M0_HWSTRB (m0_hwstrb), .M0_HWDATA (m0_hwdata),

        .M1_HADDR  (m1_haddr),  .M1_HTRANS (m1_htrans),
        .M1_HWRITE (m1_hwrite), .M1_HSIZE  (m1_hsize_out),
        .M1_HBURST (m1_hburst_out), .M1_HWSTRB (m1_hwstrb), .M1_HWDATA (m1_hwdata),

        .M2_HADDR  (m2_haddr),  .M2_HTRANS (m2_htrans),
        .M2_HWRITE (m2_hwrite), .M2_HSIZE  (m2_hsize_out),
        .M2_HBURST (m2_hburst_out), .M2_HWSTRB (m2_hwstrb), .M2_HWDATA (m2_hwdata),

        .M3_HADDR  (m3_haddr),  .M3_HTRANS (m3_htrans),
        .M3_HWRITE (m3_hwrite), .M3_HSIZE  (m3_hsize_out),
        .M3_HBURST (m3_hburst_out), .M3_HWSTRB (m3_hwstrb), .M3_HWDATA (m3_hwdata),

        .HADDR     (HADDR),     .HTRANS    (HTRANS),
        .HWRITE    (HWRITE),    .HSIZE     (HSIZE),
        .HBURST    (HBURST),    .HWSTRB    (HWSTRB),
        .HWDATA    (HWDATA)
    );

    // =========================================================================
    // Decoder Instantiation
    // =========================================================================
    decoder d (
        .HADDR        (HADDR),
        .HSEL1        (HSEL1),
        .HSEL2        (HSEL2),
        .HSEL3        (HSEL3),
        .HSEL4        (HSEL4),
        .HSEL_DEFAULT (HSEL_DEFAULT)
    );

    // =========================================================================
    // Slave Instantiations
    // =========================================================================
    slave s1 (
        .HCLK(HCLK), .HRESETn(HRESETn), .HENABLE(1'b1), .HADDR(HADDR),
        .HWDATA(HWDATA), .HWRITE(HWRITE), .HSIZE(HSIZE), .HWSTRB(HWSTRB),
        .HBURST(HBURST), .HTRANS(HTRANS), .HSELx(HSEL1),
        .HRDATA(hrdata1), .HRESP(hresp1), .HREADYOUT(hready1)
    );

    slave s2 (
        .HCLK(HCLK), .HRESETn(HRESETn), .HENABLE(1'b1), .HADDR(HADDR),
        .HWDATA(HWDATA), .HWRITE(HWRITE), .HSIZE(HSIZE), .HWSTRB(HWSTRB),
        .HBURST(HBURST), .HTRANS(HTRANS), .HSELx(HSEL2),
        .HRDATA(hrdata2), .HRESP(hresp2), .HREADYOUT(hready2)
    );

    slave s3 (
        .HCLK(HCLK), .HRESETn(HRESETn), .HENABLE(1'b1), .HADDR(HADDR),
        .HWDATA(HWDATA), .HWRITE(HWRITE), .HSIZE(HSIZE), .HWSTRB(HWSTRB),
        .HBURST(HBURST), .HTRANS(HTRANS), .HSELx(HSEL3),
        .HRDATA(hrdata3), .HRESP(hresp3), .HREADYOUT(hready3)
    );

    slave s4 (
        .HCLK(HCLK), .HRESETn(HRESETn), .HENABLE(1'b1), .HADDR(HADDR),
        .HWDATA(HWDATA), .HWRITE(HWRITE), .HSIZE(HSIZE), .HWSTRB(HWSTRB),
        .HBURST(HBURST), .HTRANS(HTRANS), .HSELx(HSEL4),
        .HRDATA(hrdata4), .HRESP(hresp4), .HREADYOUT(hready4)
    );

    slave s_default (
        .HCLK(HCLK), .HRESETn(HRESETn), .HENABLE(1'b1), .HADDR(HADDR),
        .HWDATA(HWDATA), .HWRITE(HWRITE), .HSIZE(HSIZE), .HWSTRB(HWSTRB),
        .HBURST(HBURST), .HTRANS(HTRANS), .HSELx(HSEL_DEFAULT),
        .HRDATA(hrdata_def), .HRESP(hresp_def), .HREADYOUT(hready_def)
    );

    // =========================================================================
    // Slave Mux Instantiation
    // =========================================================================
    slave_mux mux (
        .HCLK          (HCLK),
        .HRESETn       (HRESETn),
        .HSELx         (HSELx),
        .HSEL_DEFAULT  (HSEL_DEFAULT),

        .S0_HRDATA    (hrdata1),    .S1_HRDATA    (hrdata2),
        .S2_HRDATA    (hrdata3),    .S3_HRDATA    (hrdata4),
        .SDEF_HRDATA  (hrdata_def),

        .S0_HRESP     (hresp1),     .S1_HRESP     (hresp2),
        .S2_HRESP     (hresp3),     .S3_HRESP     (hresp4),
        .SDEF_HRESP   (hresp_def),

        .S0_HREADY    (hready1),    .S1_HREADY    (hready2),
        .S2_HREADY    (hready3),    .S3_HREADY    (hready4),
        .SDEF_HREADY  (hready_def),

        .HRDATA       (HRDATA),
        .HRESP        (HRESP),
        .HREADY       (HREADY)
    );

endmodule