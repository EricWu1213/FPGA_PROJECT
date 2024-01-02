module sine_lut (input [7:0] address, output reg [13:0] data);
  always @ (*) begin
    case(address)
      8'd0: data = 14'b00000000000000;
      8'd1: data = 14'b00000000011001;
      8'd2: data = 14'b00000000110010;
      8'd3: data = 14'b00000001001011;
      8'd4: data = 14'b00000001100100;
      8'd5: data = 14'b00000001111101;
      8'd6: data = 14'b00000010010110;
      8'd7: data = 14'b00000010101111;
      8'd8: data = 14'b00000011001000;
      8'd9: data = 14'b00000011100000;
      8'd10: data = 14'b00000011111000;
      8'd11: data = 14'b00000100010001;
      8'd12: data = 14'b00000100101001;
      8'd13: data = 14'b00000101000001;
      8'd14: data = 14'b00000101011001;
      8'd15: data = 14'b00000101110001;
      8'd16: data = 14'b00000110001000;
      8'd17: data = 14'b00000110011111;
      8'd18: data = 14'b00000110110110;
      8'd19: data = 14'b00000111001100;
      8'd20: data = 14'b00000111100011;
      8'd21: data = 14'b00000111111001;
      8'd22: data = 14'b00001000001110;
      8'd23: data = 14'b00001000100100;
      8'd24: data = 14'b00001000111001;
      8'd25: data = 14'b00001001001110;
      8'd26: data = 14'b00001001100010;
      8'd27: data = 14'b00001001110110;
      8'd28: data = 14'b00001010001010;
      8'd29: data = 14'b00001010011101;
      8'd30: data = 14'b00001010110000;
      8'd31: data = 14'b00001011000010;
      8'd32: data = 14'b00001011010100;
      8'd33: data = 14'b00001011100110;
      8'd34: data = 14'b00001011110111;
      8'd35: data = 14'b00001100000111;
      8'd36: data = 14'b00001100011000;
      8'd37: data = 14'b00001100100111;
      8'd38: data = 14'b00001100110110;
      8'd39: data = 14'b00001101000101;
      8'd40: data = 14'b00001101010011;
      8'd41: data = 14'b00001101100001;
      8'd42: data = 14'b00001101101110;
      8'd43: data = 14'b00001101111011;
      8'd44: data = 14'b00001110000111;
      8'd45: data = 14'b00001110010011;
      8'd46: data = 14'b00001110011110;
      8'd47: data = 14'b00001110101000;
      8'd48: data = 14'b00001110110010;
      8'd49: data = 14'b00001110111011;
      8'd50: data = 14'b00001111000100;
      8'd51: data = 14'b00001111001100;
      8'd52: data = 14'b00001111010100;
      8'd53: data = 14'b00001111011011;
      8'd54: data = 14'b00001111100001;
      8'd55: data = 14'b00001111100111;
      8'd56: data = 14'b00001111101100;
      8'd57: data = 14'b00001111110001;
      8'd58: data = 14'b00001111110101;
      8'd59: data = 14'b00001111111000;
      8'd60: data = 14'b00001111111011;
      8'd61: data = 14'b00001111111101;
      8'd62: data = 14'b00001111111111;
      8'd63: data = 14'b00010000000000;
      8'd64: data = 14'b00010000000000;
      8'd65: data = 14'b00010000000000;
      8'd66: data = 14'b00001111111111;
      8'd67: data = 14'b00001111111101;
      8'd68: data = 14'b00001111111011;
      8'd69: data = 14'b00001111111000;
      8'd70: data = 14'b00001111110101;
      8'd71: data = 14'b00001111110001;
      8'd72: data = 14'b00001111101100;
      8'd73: data = 14'b00001111100111;
      8'd74: data = 14'b00001111100001;
      8'd75: data = 14'b00001111011011;
      8'd76: data = 14'b00001111010100;
      8'd77: data = 14'b00001111001100;
      8'd78: data = 14'b00001111000100;
      8'd79: data = 14'b00001110111011;
      8'd80: data = 14'b00001110110010;
      8'd81: data = 14'b00001110101000;
      8'd82: data = 14'b00001110011110;
      8'd83: data = 14'b00001110010011;
      8'd84: data = 14'b00001110000111;
      8'd85: data = 14'b00001101111011;
      8'd86: data = 14'b00001101101110;
      8'd87: data = 14'b00001101100001;
      8'd88: data = 14'b00001101010011;
      8'd89: data = 14'b00001101000101;
      8'd90: data = 14'b00001100110110;
      8'd91: data = 14'b00001100100111;
      8'd92: data = 14'b00001100011000;
      8'd93: data = 14'b00001100000111;
      8'd94: data = 14'b00001011110111;
      8'd95: data = 14'b00001011100110;
      8'd96: data = 14'b00001011010100;
      8'd97: data = 14'b00001011000010;
      8'd98: data = 14'b00001010110000;
      8'd99: data = 14'b00001010011101;
      8'd100: data = 14'b00001010001010;
      8'd101: data = 14'b00001001110110;
      8'd102: data = 14'b00001001100010;
      8'd103: data = 14'b00001001001110;
      8'd104: data = 14'b00001000111001;
      8'd105: data = 14'b00001000100100;
      8'd106: data = 14'b00001000001110;
      8'd107: data = 14'b00000111111001;
      8'd108: data = 14'b00000111100011;
      8'd109: data = 14'b00000111001100;
      8'd110: data = 14'b00000110110110;
      8'd111: data = 14'b00000110011111;
      8'd112: data = 14'b00000110001000;
      8'd113: data = 14'b00000101110001;
      8'd114: data = 14'b00000101011001;
      8'd115: data = 14'b00000101000001;
      8'd116: data = 14'b00000100101001;
      8'd117: data = 14'b00000100010001;
      8'd118: data = 14'b00000011111001;
      8'd119: data = 14'b00000011100000;
      8'd120: data = 14'b00000011001000;
      8'd121: data = 14'b00000010101111;
      8'd122: data = 14'b00000010010110;
      8'd123: data = 14'b00000001111101;
      8'd124: data = 14'b00000001100100;
      8'd125: data = 14'b00000001001011;
      8'd126: data = 14'b00000000110010;
      8'd127: data = 14'b00000000011001;
      8'd128: data = 14'b00000000000000;
      8'd129: data = 14'b11111111100111;
      8'd130: data = 14'b11111111001110;
      8'd131: data = 14'b11111110110101;
      8'd132: data = 14'b11111110011100;
      8'd133: data = 14'b11111110000011;
      8'd134: data = 14'b11111101101010;
      8'd135: data = 14'b11111101010001;
      8'd136: data = 14'b11111100111000;
      8'd137: data = 14'b11111100100000;
      8'd138: data = 14'b11111100000111;
      8'd139: data = 14'b11111011101111;
      8'd140: data = 14'b11111011010111;
      8'd141: data = 14'b11111010111111;
      8'd142: data = 14'b11111010100111;
      8'd143: data = 14'b11111010001111;
      8'd144: data = 14'b11111001111000;
      8'd145: data = 14'b11111001100001;
      8'd146: data = 14'b11111001001010;
      8'd147: data = 14'b11111000110100;
      8'd148: data = 14'b11111000011101;
      8'd149: data = 14'b11111000000111;
      8'd150: data = 14'b11110111110010;
      8'd151: data = 14'b11110111011100;
      8'd152: data = 14'b11110111000111;
      8'd153: data = 14'b11110110110010;
      8'd154: data = 14'b11110110011110;
      8'd155: data = 14'b11110110001010;
      8'd156: data = 14'b11110101110110;
      8'd157: data = 14'b11110101100011;
      8'd158: data = 14'b11110101010000;
      8'd159: data = 14'b11110100111110;
      8'd160: data = 14'b11110100101100;
      8'd161: data = 14'b11110100011010;
      8'd162: data = 14'b11110100001001;
      8'd163: data = 14'b11110011111001;
      8'd164: data = 14'b11110011101000;
      8'd165: data = 14'b11110011011001;
      8'd166: data = 14'b11110011001010;
      8'd167: data = 14'b11110010111011;
      8'd168: data = 14'b11110010101101;
      8'd169: data = 14'b11110010011111;
      8'd170: data = 14'b11110010010010;
      8'd171: data = 14'b11110010000101;
      8'd172: data = 14'b11110001111001;
      8'd173: data = 14'b11110001101101;
      8'd174: data = 14'b11110001100010;
      8'd175: data = 14'b11110001011000;
      8'd176: data = 14'b11110001001110;
      8'd177: data = 14'b11110001000101;
      8'd178: data = 14'b11110000111100;
      8'd179: data = 14'b11110000110100;
      8'd180: data = 14'b11110000101100;
      8'd181: data = 14'b11110000100101;
      8'd182: data = 14'b11110000011111;
      8'd183: data = 14'b11110000011001;
      8'd184: data = 14'b11110000010100;
      8'd185: data = 14'b11110000001111;
      8'd186: data = 14'b11110000001011;
      8'd187: data = 14'b11110000001000;
      8'd188: data = 14'b11110000000101;
      8'd189: data = 14'b11110000000011;
      8'd190: data = 14'b11110000000001;
      8'd191: data = 14'b11110000000000;
      8'd192: data = 14'b11110000000000;
      8'd193: data = 14'b11110000000000;
      8'd194: data = 14'b11110000000001;
      8'd195: data = 14'b11110000000011;
      8'd196: data = 14'b11110000000101;
      8'd197: data = 14'b11110000001000;
      8'd198: data = 14'b11110000001011;
      8'd199: data = 14'b11110000001111;
      8'd200: data = 14'b11110000010100;
      8'd201: data = 14'b11110000011001;
      8'd202: data = 14'b11110000011111;
      8'd203: data = 14'b11110000100101;
      8'd204: data = 14'b11110000101100;
      8'd205: data = 14'b11110000110100;
      8'd206: data = 14'b11110000111100;
      8'd207: data = 14'b11110001000101;
      8'd208: data = 14'b11110001001110;
      8'd209: data = 14'b11110001011000;
      8'd210: data = 14'b11110001100010;
      8'd211: data = 14'b11110001101101;
      8'd212: data = 14'b11110001111001;
      8'd213: data = 14'b11110010000101;
      8'd214: data = 14'b11110010010010;
      8'd215: data = 14'b11110010011111;
      8'd216: data = 14'b11110010101101;
      8'd217: data = 14'b11110010111011;
      8'd218: data = 14'b11110011001010;
      8'd219: data = 14'b11110011011001;
      8'd220: data = 14'b11110011101000;
      8'd221: data = 14'b11110011111001;
      8'd222: data = 14'b11110100001001;
      8'd223: data = 14'b11110100011010;
      8'd224: data = 14'b11110100101100;
      8'd225: data = 14'b11110100111110;
      8'd226: data = 14'b11110101010000;
      8'd227: data = 14'b11110101100011;
      8'd228: data = 14'b11110101110110;
      8'd229: data = 14'b11110110001010;
      8'd230: data = 14'b11110110011110;
      8'd231: data = 14'b11110110110010;
      8'd232: data = 14'b11110111000111;
      8'd233: data = 14'b11110111011100;
      8'd234: data = 14'b11110111110010;
      8'd235: data = 14'b11111000000111;
      8'd236: data = 14'b11111000011101;
      8'd237: data = 14'b11111000110100;
      8'd238: data = 14'b11111001001010;
      8'd239: data = 14'b11111001100001;
      8'd240: data = 14'b11111001111000;
      8'd241: data = 14'b11111010001111;
      8'd242: data = 14'b11111010100111;
      8'd243: data = 14'b11111010111111;
      8'd244: data = 14'b11111011010111;
      8'd245: data = 14'b11111011101111;
      8'd246: data = 14'b11111100000111;
      8'd247: data = 14'b11111100100000;
      8'd248: data = 14'b11111100111000;
      8'd249: data = 14'b11111101010001;
      8'd250: data = 14'b11111101101010;
      8'd251: data = 14'b11111110000011;
      8'd252: data = 14'b11111110011100;
      8'd253: data = 14'b11111110110101;
      8'd254: data = 14'b11111111001110;
      8'd255: data = 14'b11111111100111;
    endcase
  end
endmodule
