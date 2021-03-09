#include <iostream>
#include <sstream>
#include <iomanip>
#include <cmath>
#include <stdio.h>

using namespace std;

union float_32 {
	float   floating_value_in_32_bits;
	int     floating_value_as_int;
	struct  sign_exp_mantissa {
		unsigned  mantissa:23;
		unsigned  exponent:8;
		unsigned      sign:1;
	} f_bits;
	struct single_bits {
		unsigned  b0 :1;
		unsigned  b1 :1;
		unsigned  b2 :1;
		unsigned  b3 :1;
		unsigned  b4 :1;
		unsigned  b5 :1;
		unsigned  b6 :1;
		unsigned  b7 :1;
		unsigned  b8 :1;
		unsigned  b9 :1;
		unsigned  b10:1;
		unsigned  b11:1;
		unsigned  b12:1;
		unsigned  b13:1;
		unsigned  b14:1;
		unsigned  b15:1;
		unsigned  b16:1;
		unsigned  b17:1;
		unsigned  b18:1;
		unsigned  b19:1;
		unsigned  b20:1;
		unsigned  b21:1;
		unsigned  b22:1;
		unsigned  b23:1;
		unsigned  b24:1;
		unsigned  b25:1;
		unsigned  b26:1;
		unsigned  b27:1;
		unsigned  b28:1;
		unsigned  b29:1;
		unsigned  b30:1;
		unsigned  b31:1;
	} bit;
};

void createBitString(char* bit_string, union float_32 float_32);
bool getBitAt(int arg, int n);
void setupCharArray(char* bit_string);

int main(int argc, char * argv[]) {

	while(true) {
		union float_32 float_1, float_2;
		char bit_string[43], bit_string_2[43], smaller[43], result[43];
		int i,j,k;

		setupCharArray(bit_string);
		setupCharArray(bit_string_2);
		setupCharArray(smaller);
		setupCharArray(result);
		
		// Provide user with information
		printf("Please enter two positive floating point values each with:\n");
		printf("\t- no more than 6 significant digits\n");
		printf("\t- a value between + 10**37 and 10**-37\n\n");
		
		// Read in two floating point values
		printf("Enter Float 1: ");
		scanf("%g", &float_1.floating_value_in_32_bits);
		printf("Enter Float 2: ");		
		scanf("%g", &float_2.floating_value_in_32_bits);
		
		// Create bit strings for each value
		createBitString(bit_string, float_1);
		createBitString(bit_string_2, float_2);

		// Find out which has smaller exponent.
		int exponent1 = float_1.f_bits.exponent, exponent2 = float_2.f_bits.exponent;
		int value1 = 0, value2 = 0;
		for(int i = 0; i < 8; ++i) {
			value1 += getBitAt(exponent1, i) * pow(2, i);
			value2 += getBitAt(exponent2, i) * pow(2, i);
		}

		// Store the difference in exponent value to know how many bits to shift lower mantissa
		int difference = (value1 < value2) ? value2 - value1 : value1 - value2;
		
		if (difference > 24) {
			difference = 24;
		}
		
		int mantissa1 = float_1.f_bits.mantissa, mantissa2 = float_2.f_bits.mantissa;
		
		// Add hidden bit
		if(exponent1) {
			mantissa1 |= (1 << 23);
		}
		if (exponent2) {
			mantissa2 |= (1 << 23);
		}

		int* smallerFloatMantissa = (value1 < value2) ? &mantissa1 : &mantissa2;
		
		// Shift mantissa of smaller number <difference> bits to the right
		*smallerFloatMantissa >>= difference;
		
		int result_mantissa = 0;
		bool carry_out = 0;

		for (int i = 0; i < 24; ++i ) {

			int bit = (carry_out + getBitAt(mantissa1,i) + getBitAt(mantissa2, i)) % 2;
			result_mantissa |= (bit << i);

			if (getBitAt(mantissa1,i) && getBitAt(mantissa2,i)) { // If both bits are 1, carry_out = 1 if 0, or carry_out = 2 if 1
				carry_out += 1;
			} else if (carry_out && (getBitAt(mantissa1,i) || getBitAt(mantissa2,i)) ) { // If carry_out = 1, and only one bit is 1 from either numbers
				carry_out = 1;
			} else {
				carry_out = 0;
			}
		}

		int result_exp = (value1 > value2) ? exponent1 : exponent2;

		if (carry_out) {
			result_mantissa >>= 1; // Shift mantissa bits over one
			result_exp++; // Increment exponent, both exponents should be the same as the larger one now.
		}

		union float_32 result_fp;
		result_fp.f_bits.mantissa = result_mantissa;
		result_fp.f_bits.exponent = result_exp;

		// If exponent is all 1's we overflowed. Set mantissa to 0 to get infinity and not NaN.
		if (result_fp.f_bits.exponent == 255) {
			result_fp.f_bits.mantissa = 0;
		}

		createBitString(result, result_fp);

		float hardwareResult = float_1.floating_value_in_32_bits + float_2.floating_value_in_32_bits;
				
		// Print original bit strings of the numbers and result
		printf("\nOriginal pattern of Float 1: %s", bit_string);		
		printf("\nOriginal pattern of Float 2: %s", bit_string_2);
		printf("\nBit pattern of result      : %s\n", result);
		printf("\nEMULATED FLOATING RESULT FROM PRINTF ==>>> %g", result_fp.floating_value_in_32_bits);
		printf("\nHARDWARE FLOATING RESULT FROM PRINTF ==>>> %g\n\n", hardwareResult);
	}
}

void setupCharArray(char* bit_string) {
	// Set up bit string with spaces
	for(unsigned int i = 0; i < 42; ++i){
		bit_string[i] = ' ';
	}
	// Null terminate bit string
	bit_string[42] = '\0';
}


void createBitString(char* bit_string, union float_32 float_32) {
	// Sign Bit
	bit_string[0] = float_32.bit.b31?'1':'0';

	// Exponent Bits
	bit_string[2] = float_32.bit.b30?'1':'0';
	bit_string[3] = float_32.bit.b29?'1':'0';
	bit_string[4] = float_32.bit.b28?'1':'0';
	bit_string[5] = float_32.bit.b27?'1':'0';

	bit_string[7] = float_32.bit.b26?'1':'0';
	bit_string[8] = float_32.bit.b25?'1':'0';
	bit_string[9] = float_32.bit.b24?'1':'0';
	bit_string[10] = float_32.bit.b23?'1':'0';

	// Mantissa Bits
	bit_string[12] = float_32.bit.b22?'1':'0';
	bit_string[13] = float_32.bit.b21?'1':'0';
	bit_string[14] = float_32.bit.b20?'1':'0';

	bit_string[16] = float_32.bit.b19?'1':'0';
	bit_string[17] = float_32.bit.b18?'1':'0';
	bit_string[18] = float_32.bit.b17?'1':'0';
	bit_string[19] = float_32.bit.b16?'1':'0';

	bit_string[21] = float_32.bit.b15?'1':'0';
	bit_string[22] = float_32.bit.b14?'1':'0';
	bit_string[23] = float_32.bit.b13?'1':'0';
	bit_string[24] = float_32.bit.b12?'1':'0';

	bit_string[26] = float_32.bit.b11?'1':'0';
	bit_string[27] = float_32.bit.b10?'1':'0';
	bit_string[28] = float_32.bit.b9?'1':'0';
	bit_string[29] = float_32.bit.b8?'1':'0';

	bit_string[31] = float_32.bit.b7?'1':'0';
	bit_string[32] = float_32.bit.b6?'1':'0';
	bit_string[33] = float_32.bit.b5?'1':'0';
	bit_string[34] = float_32.bit.b4?'1':'0';

	bit_string[36] = float_32.bit.b3?'1':'0';
	bit_string[37] = float_32.bit.b2?'1':'0';
	bit_string[38] = float_32.bit.b1?'1':'0';
	bit_string[39] = float_32.bit.b0?'1':'0';
}

bool getBitAt(int arg, int n) {
	return ((arg) >> (n)) & 1;
}