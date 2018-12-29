module Forwarding_Unit
(
    ID_EX_RS1addr_i,
    ID_EX_RS2addr_i,
	EX_MEM_RDaddr_i,
	EX_MEM_RegWrite_i,
    MEM_WB_RDaddr_i,
	MEM_WB_RegWrite_i,
    forwardA_o,
	forwardB_o
);


input	[4:0]	ID_EX_RS1addr_i, ID_EX_RS2addr_i, EX_MEM_RDaddr_i, MEM_WB_RDaddr_i;
input	EX_MEM_RegWrite_i, MEM_WB_RegWrite_i;
output reg	[1:0]	forwardA_o, forwardB_o;

always @(*) begin
	if (EX_MEM_RegWrite_i == 1'b1 && EX_MEM_RDaddr_i != 5'b0 && EX_MEM_RDaddr_i == ID_EX_RS1addr_i)
		forwardA_o <= 2'b10;
	else if (MEM_WB_RegWrite_i == 1'b1 && MEM_WB_RDaddr_i != 5'b0 && MEM_WB_RDaddr_i == ID_EX_RS1addr_i)
		forwardA_o <= 2'b01;
	else
		forwardA_o <= 2'b00;	
	
	if (EX_MEM_RegWrite_i == 1'b1 && EX_MEM_RDaddr_i != 5'b0 && EX_MEM_RDaddr_i == ID_EX_RS2addr_i)  //forwardB_o
		forwardB_o <= 2'b10;
	else if (MEM_WB_RegWrite_i == 1'b1 && MEM_WB_RDaddr_i != 5'b0 && MEM_WB_RDaddr_i == ID_EX_RS2addr_i)
		forwardB_o <= 2'b01;
	else
		forwardB_o <= 2'b00;
end

endmodule
