module CPU
(
	clk_i,
	rst_i,
	start_i,
   
	mem_data_i, 
	mem_ack_i, 	
	mem_data_o, 
	mem_addr_o, 	
	mem_enable_o, 
	mem_write_o
);

//input
input clk_i;
input rst_i;
input start_i;

//
// to Data Memory interface		
//
input	[256-1:0]	mem_data_i; 
input				mem_ack_i; 	
output	[256-1:0]	mem_data_o; 
output	[32-1:0]	mem_addr_o; 	
output				mem_enable_o; 
output				mem_write_o; 

//
// add your project1 here!
//

// Wire
// IF stage
wire	[31:0]	instr_addr, instr;
// ID stage
wire	[31:0]	RS1data, RS2data;
// Equal means if Branch succeed (RS1data == RS2data)
// Branch means the beq instruction in ID stage
wire    Equal, Branch;
wire    andGate_o;
// EX stage
wire	[31:0]	ALU_result;
wire	[31:0]	writeBack_data;

// --------------------- IF stage --------------------

MUX32 MUX_PCSrc(
    .data1_i    (Add_PC.data_o), // Branch not taken
    .data2_i    (Add_Imm.data_o), // Branch taken 
    .select_i   (andGate_o), // if andGate_o == 1, branch
    .data_o     (PC.pc_i)
);

PC PC(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.start_i(start_i),
	.stall_i(),
	.pcEnable_i(),
	.pc_i(MUX_PCSrc.data_o),
	.pc_o(instr_addr)
);

Adder Add_PC(
	.data1_i	(instr_addr),
	.data2_i	(32'd4),
	.data_o		(MUX_PCSrc.data1_i)
);

Instruction_Memory Instruction_Memory(
	.addr_i(instr_addr), 
	.instr_o(IF_ID.instr_i)
);

IF_ID IF_ID(
	.PC_i			(instr_addr),
	.PC_o			(Add_Imm.data1_i),
	.instr_i		(Instruction_Memory.instr_o),
	.instr_o		(instr),
	.IF_ID_Write_i	(Hazard_Detection_Unit.IF_ID_Write_o),
	.IF_Flush_i		(andGate_o),
	.clk_i			(clk_i),
	.rst_i			(rst_i)
);

// --------------------- ID stage --------------------

// And gate for branch
assign 	Equal = (RS1data == RS2data) ? 1 : 0;
assign  andGate_o = Branch && Equal; //to PCSrc and IF_Flush

Registers Registers(
	.clk_i(clk_i),
	.RS1addr_i(instr[19:15]),
	.RS2addr_i(instr[24:20]),
	.RDaddr_i(MEM_WB.RDaddr_o), 
	.RDdata_i(writeBack_data),
	.RegWrite_i(MEM_WB.RegWrite_o), 
	.RS1data_o(RS1data), 
	.RS2data_o(RS2data) 
);

Adder Add_Imm(
	.data1_i	(IF_ID.PC_o),
    .data2_i	(Sign_Extend.data_o<<1),
    .data_o		(MUX_PCSrc.data2_i)
);

Control Control(
    .Op_i		(instr[6:0]),
    // EX
    .ALUOp_o	(ID_EX.ALUOp_i),
    .ALUSrc_o	(ID_EX.ALUSrc_i),
    // MEM
    .Branch_o	(Branch),
    .MemRead_o	(ID_EX.MemRead_i),
    .MemWrite_o	(ID_EX.MemWrite_i),
    // WB
    .RegWrite_o	(ID_EX.RegWrite_i),
    .MemtoReg_o	(ID_EX.MemtoReg_i)
);

Sign_Extend Sign_Extend(
    .data_i     (instr),
    .data_o     (ID_EX.signExtend_i)
);

Hazard_Detection_Unit Hazard_Detection_Unit(
    .ID_EX_MemRead_i	(ID_EX.MemRead_o),
    .IF_ID_RS1addr_i	(instr[19:15]),
    .IF_ID_RS2addr_i	(instr[24:20]),
    .ID_EX_RDaddr_i		(ID_EX.RDaddr_o),
    .PCWrite_o			(PC.PCWrite_i),
    .IF_ID_Write_o		(IF_ID.IF_ID_Write_i),
    .ID_Flush_lwstall_o	(ID_EX.ID_Flush_lwstall_i)
);

ID_EX ID_EX(
	// Data content
	.RS1data_i			(RS1data),
	.RS2data_i			(RS2data),
	.signExtend_i		(Sign_Extend.data_o),
	.RS1data_o			(ALU_input1.data1_i),
	.RS2data_o			(ALU_input2.data1_i),
	.signExtend_o		(ALU_input2.data2_i),
	// Register content
	.RS1addr_i			(instr[19:15]),
	.RS2addr_i			(instr[24:20]),
	.RDaddr_i			(instr[11:7]),
	.RS1addr_o			(Forwarding_Unit.ID_EX_RS1addr_i),
	.RS2addr_o			(Forwarding_Unit.ID_EX_RS2addr_i),
	.RDaddr_o			(EX_MEM.RDaddr_i),
	// Function code to ALU control
	.funct3_i			(instr[14:12]),
	.funct7_i			(instr[31:25]),
	.funct3_o			(ALU_Control.funct3_i),
	.funct7_o			(ALU_Control.funct7_i),
	// Control signal
	.ID_Flush_lwstall_i	(Hazard_Detection_Unit.ID_Flush_lwstall_o),
    // EX
	.ALUSrc_i			(Control.ALUSrc_o),
	.ALUOp_i			(Control.ALUOp_o),
	.ALUSrc_o			(ALU_input.select_i),
	.ALUOp_o			(ALU_Control.ALUOp_i),
    // MEM
	.MemRead_i			(Control.MemRead_o),
	.MemWrite_i			(Control.MemWrite_o),
	.MemRead_o			(EX_MEM.MemRead_i),
	.MemWrite_o			(EX_MEM.MemWrite_i),
    // WB
	.RegWrite_i			(Control.RegWrite_o),
	.MemtoReg_i			(Control.MemtoReg_o),
	.RegWrite_o			(EX_MEM.RegWrite_i),
	.MemtoReg_o			(EX_MEM.MemtoReg_i),
	.clk_i				(clk_i),
	.rst_i				(rst_i)
);

// --------------------- EX stage --------------------

MUX32_3to1 ALU_input1(
    .data1_i	(ID_EX.RS1data_o), // from Register
    .data2_i	(writeBack_data), // from WB MUX
    .data3_i	(ALU_result), // ALU result
	.select_i	(Forwarding_Unit.forwardA_o),
	.data_o		(ALU.data1_i)
);

MUX32_3to1 ALU_input2(
	.data1_i	(ID_EX.RS2data_o), // from Register
	.data2_i	(writeBack_data), // from WB MUX
	.data3_i	(ALU_result), // from ALU result
	.select_i	(Forwarding_Unit.forwardB_o),
	.data_o		(ALU_input.data1_i)
);

MUX32 ALU_input(
    .data1_i    (ALU_input2.data_o),
	.data2_i    (ID_EX.signExtend_o),
    .select_i   (ID_EX.ALUSrc_o),
    .data_o     (ALU.data2_i)
);

ALU_Control ALU_Control(
	.funct3_i	(ID_EX.funct3_o),
	.funct7_i	(ID_EX.funct7_o),
	.ALUOp_i	(ID_EX.ALUOp_o),
	.ALUCtrl_o	(ALU.ALUCtrl_i)
);

ALU ALU(
    .data1_i	(ALU_input1.data_o),
    .data2_i	(ALU_input.data_o),
    .ALUCtrl_i	(ALU_Control.ALUCtrl_o),
    .data_o		(EX_MEM.ALU_result_i)
);

Forwarding_Unit Forwarding_Unit(
    .ID_EX_RS1addr_i		(ID_EX.RS1addr_o),
    .ID_EX_RS2addr_i		(ID_EX.RS2addr_o),
	.EX_MEM_RDaddr_i		(EX_MEM.RDaddr_o),
	.EX_MEM_RegWrite_i		(EX_MEM.RegWrite_o),
    .MEM_WB_RDaddr_i		(MEM_WB.RDaddr_o),
	.MEM_WB_RegWrite_i 		(MEM_WB.RegWrite_o),
    .forwardA_o				(ALU_input1.select_i),
	.forwardB_o				(ALU_input2.select_i)
);

EX_MEM EX_MEM(
	// Data content
	.ALU_result_i		(ALU.data_o),
	.RS2data_i			(ALU_input2.data_o),
	.ALU_result_o		(ALU_result),
	.RS2data_o			(dcache.p1_data_i), 
	// Register content
	.RDaddr_i			(ID_EX.RDaddr_o),
	.RDaddr_o			(MEM_WB.RDaddr_i),
	// Control signal
	// MEM
	.MemRead_i			(ID_EX.MemRead_o), 
	.MemWrite_i			(ID_EX.MemWrite_o),
	.MemRead_o			(dcache.p1_MemRead_i), 
	.MemWrite_o			(dcache.p1_MemWrite_i),
	// WB
	.RegWrite_i			(ID_EX.RegWrite_o), 
	.MemtoReg_i			(ID_EX.MemtoReg_o), 
	.RegWrite_o			(MEM_WB.RegWrite_i), 
	.MemtoReg_o			(MEM_WB.MemtoReg_i),
	.clk_i				(clk_i),
	.rst_i				(rst_i)
);

// --------------------- MEM stage --------------------

//data cache
dcache_top dcache
(
    // System clock, reset and stall
	.clk_i(clk_i), 
	.rst_i(rst_i),
	
	// to Data Memory interface		
	.mem_data_i(mem_data_i), 
	.mem_ack_i(mem_ack_i), 	
	.mem_data_o(mem_data_o), 
	.mem_addr_o(mem_addr_o), 	
	.mem_enable_o(mem_enable_o), 
	.mem_write_o(mem_write_o), 
	
	// to CPU interface	
	.p1_data_i(EX_MEM.RS2data_o), 
	.p1_addr_i(ALU_result), 	
	.p1_MemRead_i(EX_MEM.MemRead_o), 
	.p1_MemWrite_i(EX_MEM.MemWrite_o), 
	.p1_data_o(MEM_WB.dataMem_data_i), 
	.p1_stall_o()
);

Data_Memory Data_Memory
(
	.clk_i		(clk_i),
	.rst_i		(rst_i),
	.addr_i		(),
	.data_i		(),
	.enable_i	(),
	.write_i	(),
	.ack_o		(),
	.data_o		()
);

MEM_WB MEM_WB(
	.RegWrite_i			(EX_MEM.RegWrite_o),
	.MemtoReg_i			(EX_MEM.MemtoReg_o),
	.RegWrite_o			(Registers.RegWrite_i),
	.MemtoReg_o			(MUX_RegSrc.select_i),
	.dataMem_data_i		(dcache.p1_data_o),
	.ALU_result_i		(ALU_result),
	.dataMem_data_o		(MUX_RegSrc.data2_i),
	.ALU_result_o		(MUX_RegSrc.data1_i),
	.RDaddr_i			(EX_MEM.RDaddr_o),
	.RDaddr_o			(Registers.RDaddr_i),
	.clk_i				(clk_i),
	.rst_i				(rst_i)
);

// --------------------- WB stage --------------------

MUX32 MUX_RegSrc( // WB MUX
    .data1_i    (MEM_WB.ALU_result_o), // From ALU result
    .data2_i    (MEM_WB.dataMem_data_o), // From data memory
    .select_i   (MEM_WB.MemtoReg_o), // if MemtoReg == 1, from data memory, else from ALU result
    .data_o     (writeBack_data)
);

endmodule