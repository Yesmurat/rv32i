module imem (input logic [31:0] a,
            output logic [31:0] rd
    );

    (* rom_style="distributed" *) logic [31:0] ROM[63:0];
    
    initial begin
        $readmemh("C:/Users/Yesmurat Sagyndyk/Downloads/rv32i-main/rv32i-main/imem.txt", ROM);
    end

    assign rd = ROM[a[31:2]]; // word aligned

endmodule // Instruction memory