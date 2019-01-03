module Hazard_Detection_Unit
(
    Op_i,
    ID_EX_MemRead_i,
    IF_ID_RS1addr_i,
    IF_ID_RS2addr_i,
    ID_EX_RDaddr_i,
    PCWrite_o,
    IF_ID_Write_o,
    ID_Flush_lwstall_o
);

// Interface
input   [6:0]   Op_i;
input   ID_EX_MemRead_i;
input   [4:0]   IF_ID_RS1addr_i;
input   [4:0]   IF_ID_RS2addr_i;
input   [4:0]   ID_EX_RDaddr_i;
output reg  PCWrite_o;
output reg  IF_ID_Write_o;
output reg  ID_Flush_lwstall_o;

// Detection unit
wire    equal_Rs1;
wire    equal_Rs2;
assign equal_Rs1 = (ID_EX_RDaddr_i == IF_ID_RS1addr_i) ? 1 : 0;
assign equal_Rs2 = (ID_EX_RDaddr_i == IF_ID_RS2addr_i) ? 1 : 0;

always@(ID_EX_MemRead_i or equal_Rs1 or equal_Rs2) begin
    // Stall the pipeline and flush instruction in ID stage
    if (ID_EX_MemRead_i && (equal_Rs1 | equal_Rs2) && Op_i == 7'b0110011) begin
        PCWrite_o <= 0;
        IF_ID_Write_o <= 0;
        ID_Flush_lwstall_o <= 1;
    end else begin
        PCWrite_o <= 1;
        IF_ID_Write_o <= 1;
        ID_Flush_lwstall_o <= 0;
    end
end

endmodule