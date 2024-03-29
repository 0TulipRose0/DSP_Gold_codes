//TulipRose/Dmitriy V.
module M_Sequence_gen1#(
    //Polynomials are specified without the first "1"
    parameter POLYNOME = 6'b000011,  //Polynomial M-sequence
    //Lenght of the code
    parameter N        = 63,
    //Polynom lenght
    parameter LENGTH   = $clog2(N),
    //Number of cycles of holding code at the out
    parameter HOLD     = 3
    )(
    input  logic              clkin,
    input  logic              rstn,
    
    input  logic              valid,
    output logic              out,
    
    //Shift value and ready signal
    input  logic [LENGTH-1:0] code_i,
    output logic              strobe_o,
    output logic              ready_o
    );
    
    ////////////////////////
    // Local declarations //
    ////////////////////////
    
    logic                  xor_op;

    logic [LENGTH-1:0]     phase;

    logic [LENGTH-1:0]     cnt;
    
    logic [HOLD-1:0]       hold_cnt;
    
    logic [LENGTH-1:0]     code;
    
    /////////////////
    // Main module //
    /////////////////
    
    always_comb begin
        xor_op = ^(POLYNOME & phase); 
//        code = code_i;         
    end
    
    always_ff @(posedge clkin) begin
        if(!rstn) begin
            ready_o  <= 1'b1;
            cnt <= N;
            hold_cnt <= HOLD - 1;           
            out <= 0;
            strobe_o <= 0;
                       
        end else if(valid || hold_cnt != 0) begin   
              
           if(valid && ready_o) code <= code_i;  
               
            if(valid) begin
            ready_o  <= 1'b0; 
            hold_cnt <= HOLD - 2; end          
            
                if(cnt == N && !ready_o) begin
                    //Phase should not be only zeros!
                    //generated from python script
                        case(code)
                        6'd0: phase <= 6'b101010;
                        endcase                                                     
                        if(hold_cnt != 0) begin
                            hold_cnt <= hold_cnt - 1;
                        end else begin
                        strobe_o <= 1;                        
                        out <= phase[0];                         
                        phase <= {xor_op, phase[LENGTH-1:1]};
                                                                   
                        cnt <= cnt - 1'b1;
                        hold_cnt <= HOLD - 1'b1;
                        end
                    end 
                
                if(cnt != 1 && cnt != N) begin
                
                   if(hold_cnt != 0) begin
                       hold_cnt <= hold_cnt - 1;
                   end else begin 
                       out <= phase[0];                          
                       phase <= {xor_op, phase[LENGTH-1:1]};
                       
                       hold_cnt <= HOLD - 1;                                                 
                       cnt <= cnt - 1;                       
                   end
                                      
                   end else if (cnt == 1) begin 
                       if(hold_cnt != 0) begin
                           hold_cnt <= hold_cnt - 1;
                       end else begin
                           ready_o <= 1'b1;
                           cnt <= N;                           
                           hold_cnt <= HOLD - 1;
                         
                           out <= phase[0];                         
                           phase <= {xor_op, phase[LENGTH-1:1]};                                                      
                       end
                 end  
         end else begin
            out <= 0;
            ready_o <= 1'b1;
            cnt <= N;                            
            if (cnt == 63 && ~valid) strobe_o <= 0;                        
         end
    end

endmodule