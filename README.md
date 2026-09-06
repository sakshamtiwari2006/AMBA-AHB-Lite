# AMBA AHB 

A fully functional, synthesizable Verilog implementation of an **AMBA AHB-Lite** (Advanced High-performance Bus) interconnect system[cite: 1, 2, 3, 4, 6]. This project features a complete system architecture including an AHB-Lite Master with burst and transfer size support[cite: 2], a 1-of-N Decoder[cite: 1], a Slave Response Mux[cite: 3], 8 Slaves backed by external memory[cite: 4, 6], a Default Slave for error handling[cite: 4, 6], and a verification testbench.

---

##  Features & Key Capabilities

- **AHB-Lite Master (`master_ahb.v`)**:
  - Supports Single, Incrementing, and Wrapping Bursts (4-beat, 8-beat, 16-beat)[cite: 2].
  - Dynamic Transfer Sizes (Byte - 8-bit, Halfword - 16-bit, Word - 32-bit)[cite: 2].
  - Automatic transfer address calculation with boundary wrapping logic[cite: 2].
  - Standard transfer states: `IDLE`, `BUSY`, `NONSEQ`, and `SEQ`[cite: 2].

- **AHB Decoder (`decoder_ahb.v`)**:
  - Decode support for up to 8 primary slaves using address masking (`0xFF00_0000`)[cite: 1].
  - Default slave selection (`HSEL_DEFAULT`) for unmapped address spaces[cite: 1].

- **AHB Multiplexer (`mux_ahb.v`)**:
  - Multiplexes read data (`HRDATA`) and slave response signals (`HRESP`) from active slaves[cite: 3].
  - Combines individual slave ready signals (`HREADYOUT`) into system-wide `HREADY`[cite: 3, 4, 6].

- **AHB Slave Architecture (`slave_ahb.v`)**:
  - FSM-driven byte-by-byte access to 8-bit external memory (`external_mem`)[cite: 4].
  - Supports unaligned access handling and dynamic multi-cycle state machines for sub-word reads/writes[cite: 4].
  - **2-Cycle Error Response Handling**: Generates standard AHB `HRESP` error signals for unaligned access or unsupported transfer sizes[cite: 4].

- **System Interconnect (`top_module_ahb.v`)**:
  - Top-level integration wiring Master, Decoder, Mux, 8 AHB Slaves, and 1 Default Slave into a functional SoC bus interconnect[cite: 6].

---

##  System Architecture Block Diagram
                   +-----------------------+
                   |      AHB Master       |
                   +-----------+-----------+
                               |
            +------------------+------------------+
            | HADDR, HTRANS, HBURST, HSIZE, HWDATA|
            v                                     v
    +-----------------+                   +-----------------+
    |   AHB Decoder   |                   |    AHB Slaves   |
    +--------+--------+                   | (Slave 0 - 7 &  |
            |                             | Default Slave)  |
    HSEL_S0..7| HSEL_DEF                  +--------+--------+
            |                                     |
            +------------------+------------------+
                               | HRDATA, HRESP, HREADYOUT
                               v
                   +-----------------------+
                   |        AHB Mux        |
                   +-----------+-----------+
                               |
                    HRDATA, HRESP, HREADY
                               |
                               v
                         (To Master)
##  Address Map

The standard configuration maps 8 slaves based on the upper 8 bits of the 32-bit address space (`HADDR[31:24]`)[cite: 1]:

| Slave ID | Base Address Range | Mask | Description |
| :--- | :--- | :--- | :--- |
| **Slave 0** | `0x0000_0000 - 0x0FFF_FFFF` | `0xFF00_0000` | Target Memory / IP 0[cite: 1] |
| **Slave 1** | `0x1000_0000 - 0x1FFF_FFFF` | `0xFF00_0000` | Target Memory / IP 1[cite: 1] |
| **Slave 2** | `0x2000_0000 - 0x2FFF_FFFF` | `0xFF00_0000` | Target Memory / IP 2[cite: 1] |
| **Slave 3** | `0x3000_0000 - 0x3FFF_FFFF` | `0xFF00_0000` | Target Memory / IP 3[cite: 1] |
| **Slave 4** | `0x4000_0000 - 0x4FFF_FFFF` | `0xFF00_0000` | Target Memory / IP 4[cite: 1] |
| **Slave 5** | `0x5000_0000 - 0x5FFF_FFFF` | `0xFF00_0000` | Target Memory / IP 5[cite: 1] |
| **Slave 6** | `0x6000_0000 - 0x6FFF_FFFF` | `0xFF00_0000` | Target Memory / IP 6[cite: 1] |
| **Slave 7** | `0x7000_0000 - 0x7FFF_FFFF` | `0xFF00_0000` | Target Memory / IP 7[cite: 1] |
| **Default** | All unmapped addresses | — | Catches out-of-bounds requests[cite: 1] |

---

##  AHB Protocol Specifications Supported

### Burst Modes (`HBURST`)
- `3'b000`: Single transfer[cite: 2]
- `3'b001`: Unspecified length burst[cite: 2]
- `3'b010`: 4-beat wrapping burst[cite: 2]
- `3'b011`: 4-beat incrementing burst[cite: 2]
- `3'b100`: 8-beat wrapping burst[cite: 2]
- `3'b101`: 8-beat incrementing burst[cite: 2]
- `3'b110`: 16-beat wrapping burst[cite: 2]
- `3'b111`: 16-beat incrementing burst[cite: 2]

### Transfer Sizes (`HSIZE`)
- `3'b000`: Byte (8-bit)[cite: 2, 4]
- `3'b001`: Halfword (16-bit)[cite: 2, 4]
- `3'b010`: Word (32-bit)[cite: 2, 4]

---
