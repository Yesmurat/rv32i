// top module combines riscv with data and instruction memories

module top (input logic clk, clr,
            output logic [31:0] WriteDataM
    );

    logic [31:0] ALUResultM;
    logic [31:0] PCF;
    logic [31:0] RD_instr;
    logic [31:0] RD_data;
    logic MemWriteM;
    logic [3:0] byteEnable;

    riscv riscv(
        .clk(clk), .clr(clr),
        .RD_instr(RD_instr), .RD_data(RD_data),
        .PCF(PCF),
        .ALUResultM(ALUResultM), .WriteDataM(WriteDataM),
        .MemWriteM(MemWriteM),
        .byteEnable(byteEnable)
    );

    imem im(
        .a(PCF),
        .rd(RD_instr)
    );

    dmem dm(
        .clk(clk), .we(MemWriteM),
        .byteEnable(byteEnable),
        .a(ALUResultM), .wd(WriteDataM),
        .rd(RD_data)
    );
    
endmodule