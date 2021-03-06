`timescale 1ns / 1ps

module uart_tx_path(
	input clk_i,

	input [7:0] uart_tx_data_i,	         
	input uart_tx_en_i,			         
	
	output uart_tx_o
);

parameter BAUD_DIV     = 13'd5208;      //Chia xung clock cho viec nhan du lieu 9600bps??50Mhz/9600=5208
parameter BAUD_DIV_CAP = 13'd2604;      // Toc do lay ma

reg [12:0] baud_div=0;			         
reg baud_bps=0;				             
(* MARKDEBUG = "TRUE" *)reg [9:0] send_data=10'b1111111111;     //1 bit start, 8 bit data, 1 bit ket thuc
(* MARKDEBUG = "TRUE" *)reg [3:0] bit_num=0;	                //bo dem so luong du lieu da gui
reg uart_send_flag=0;	                // 
reg uart_tx_o_r=1;		                // Gui du lieu luon o muc cao

always@(posedge clk_i)
begin
	if(baud_div==BAUD_DIV_CAP)	        
		begin
			baud_bps<=1'b1;
			baud_div<=baud_div+1'b1;
		end
	else if(baud_div<BAUD_DIV && uart_send_flag)
		begin
			baud_div<=baud_div+1'b1;
			baud_bps<=0;	
		end
	else
		begin
			baud_bps<=0;
			baud_div<=0;
		end
end

always@(posedge clk_i)
begin
	if(uart_tx_en_i)	//Ket thuc vien truyen du lieu
		begin
			uart_send_flag<=1'b1;
			send_data<={1'b1,uart_tx_data_i,1'b0};//Truyen 1 start, 8 bit data, 1 the end
		end
	else if(bit_num==4'd10)	//Ket thuc qua trinh truyen
		begin
			uart_send_flag<=1'b0;
			send_data<=10'b1111_1111_11;
		end
end

always@(posedge clk_i)
begin
	if(uart_send_flag)	//Co bao gui hop le
		begin
			if(baud_bps)
				begin
					if(bit_num<=4'd9)
						begin
							uart_tx_o_r<=send_data[bit_num];	
							bit_num<=bit_num+1'b1;
						end
				end
			else if(bit_num==4'd10)
				bit_num<=4'd0;
		end
	else
		begin
			uart_tx_o_r<=1'b1;	
			bit_num<=0;
		end
end

assign uart_tx_o=uart_tx_o_r;

endmodule
