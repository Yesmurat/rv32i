module maindec (
    
            input logic [6:0] op,
            output logic [1:0] ResultSrcD,
            output logic MemWriteD,
            output logic BranchD, ALUSrcD,
            output logic RegWriteD, JumpD,
            output logic [2:0] ImmSrcD,
            output logic [1:0] ALUOp,
            output logic SrcAsrcD,
            output logic jumpRegD
            
    );

    logic [13:0] controls;

    assign {RegWriteD, ImmSrcD, ALUSrcD, MemWriteD,
            ResultSrcD, BranchD, ALUOp, JumpD, SrcAsrcD, jumpRegD} = controls;

    always_comb begin
        unique case (op)

            // {RegWrite, ImmSrc[2:0], ALUSrc, MemWrite, ResultSrc[1:0], Branch, ALUOp[1:0], Jump, SrcAsrc, jumpReg}

            7'b0000011: controls = {1'b1, 3'b000, 1'b1, 1'b0, 2'b01, 1'b0, 2'b00, 1'b0, 1'b1, 1'b1}; // I-type (loads)
            7'b0100011: controls = {1'b0, 3'b001, 1'b1, 1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 1'b1, 1'b1}; // S-type
            7'b0110011: controls = {1'b1, 3'b000, 1'b0, 1'b0, 2'b00, 1'b0, 2'b10, 1'b0, 1'b1, 1'b1}; // R-type
            7'b0010011: controls = {1'b1, 3'b000, 1'b1, 1'b0, 2'b00, 1'b0, 2'b10, 1'b0, 1'b1, 1'b1}; // I-type
            7'b1100011: controls = {1'b0, 3'b010, 1'b0, 1'b0, 2'b00, 1'b1, 2'b01, 1'b0, 1'b1, 1'b1}; // B-type
            7'b0110111: controls = {1'b1, 3'b100, 1'b1, 1'b0, 2'b11, 1'b0, 2'b00, 1'b0, 1'b0, 1'b1}; // lui
            7'b0010111: controls = {1'b1, 3'b100, 1'b1, 1'b0, 2'b00, 1'b0, 2'b00, 1'b0, 1'b0, 1'b1}; // auipc
            7'b1101111: controls = {1'b1, 3'b011, 1'b0, 1'b0, 2'b10, 1'b0, 2'b00, 1'b1, 1'b1, 1'b1}; // jal
            7'b1100111: controls = {1'b1, 3'b000, 1'b0, 1'b0, 2'b10, 1'b0, 2'b00, 1'b1, 1'b1, 1'b0}; // jalr
            
            default: controls = 14'b0;

        endcase
    end
    
endmodule