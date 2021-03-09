#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

typedef struct {
  int line_number;
  char* instruction_bits;
  char* label;
  char* var;
  int value;
} instruction;

instruction* instructions;
int ins_len = 0;

void trim_new_line(char * input) {
  char* pos;
  if (input != NULL && (pos=strchr(input, '\n')) != NULL)
    *pos = '\0';
}

bool check_if_really_zero(int i, char* input) {
  char* buffer = malloc(4);
  sprintf(buffer, "%d", i);
  return !strcmp(buffer, input);
}

void generate_code(int linum, FILE* p1);

int get_sym_val(char* symbol) {
  int i = 0;
  for (; i < ins_len; ++i) {
    if (!strcmp(instructions[i].var, symbol)) {
      return instructions[i].value;
    }
  }
  return -1;
}

int main(int argc, char* argv[]) {

  int start_index = 1;
  bool resolve = true;

  // Check for '-o' option
  if (argc > 1 && !strcmp(argv[1], "-o")) {
    resolve = false;
    start_index = 2;
  }

  instructions = malloc(1000 * sizeof(instruction));
  FILE* result_fp = fopen("result.o", "w");
  char* line = NULL;
  size_t line_length;
  int number_of_files = argc - start_index;
  int i = 0, current_line = 0, line_offset = 0, result_file_line = 0;

  for (i = 0; i < number_of_files; ++i) {
    FILE* fp;
    fp = fopen(argv[start_index + i], "r");

    if (fp != NULL) {
      int line_no = 0;
      do {
        instruction ins;
        
        getline(&line, &line_length, fp);
        if (strlen(line) == 0) { break; }
        char* f_line = strdup(line);

        char * input = strtok(f_line, " ");
        trim_new_line(input);

        // Extract number if there is one
        char* first_val;
        int i = atoi(input);

        // If string and not number, atoi returns 0.
        // So check if the token is really a (int) 0 or a string.
        if (i == 0) {
          bool is_zero = check_if_really_zero(i, input);
          if (!is_zero) {
            i = -1;
            first_val = input;
          }
        }
        if (i != -1) {
          ins.line_number = i;

          input = strtok(NULL, " ");
          trim_new_line(input);
          ins.instruction_bits = input;

          input = strtok(NULL, " ");
          trim_new_line(input);
          ins.label = input;

          if (i != 4096) {
            if (ins.label != NULL) {
              fprintf(result_fp, "%d %s %s\n", ins.line_number + result_file_line, ins.instruction_bits, ins.label);
            } else {
              fprintf(result_fp, "%d %s\n", ins.line_number + result_file_line, ins.instruction_bits);
            }
            current_line = ins.line_number + 1;
          }

        } else {
          // Reading in the symtable, <variable, value> now .. NOT instruction bits.
          ins.var = first_val;

          input = strtok(NULL, " ");
          trim_new_line(input);
          ins.value = atoi(input) + result_file_line;
          instructions[ins_len] = ins;
          ins_len++;
        }
        ++line_no;

      } while (!feof(fp));

      line_offset = current_line;
      result_file_line += current_line;

    }
    fclose(fp);
  }

  if (!resolve) {
    fprintf(result_fp, "4096 x\n");

    for (i = 0; i < ins_len; ++i) {
      fprintf(result_fp, "%s \t %d\n", instructions[i].var, instructions[i].value);
    }
  }

  fclose(result_fp);

  if (resolve) {
    generate_code(false, result_fp); // Resolve variables a.k.a. do second pass
  } else {
    result_fp = fopen("result.o", "r"); // Print unresolved, consolidated object file
    while (!feof(result_fp)) {
      getline(&line, &line_length, result_fp);
      printf("%s", line);
    }
    fclose(result_fp);
  }

  return 0;
}

void generate_code(int linum, FILE* p1) {
  /****   FILE  *p1;   ****/
  char linbuf[10];
  char instruction[18];
  int  line_number;
  int  pc, mask, sym_val,i, j, old_pc, diff;
  char symbol[26];
  char cstr_12[13];

  line_number = old_pc = 0;
  p1 = fopen("result.o", "r");

	sprintf(linbuf,"%5d:  ", line_number);
	while (fscanf(p1, "%d %s", &pc, instruction) != EOF){
    if ((diff = pc - old_pc ) > 1) {
      for (j = 1; j < diff; j++){
        sprintf(linbuf,"%5d:  ", line_number++);
        printf("%s1111111111111111\n", (linum ? linbuf : "\0"));
      }
    }
    sprintf(linbuf, "%5d:  ", line_number++);
    old_pc = pc;

	  if (instruction[0] == 'U') {
	    fscanf(p1, "%s", symbol);
	    if ((sym_val = get_sym_val(symbol)) == -1){
		    fprintf(stderr, "no symbol in symbol table: %s\n", symbol);
		    exit(27);
	    }
	   	
      for (i = 0; i < 12; ++i){
	      cstr_12[i] = '0';
	    }
	    cstr_12[12] = '\0';
         
	    mask = 2048;
      for(i = 0; i < 12; ++i){
	      if(sym_val & mask) {
		      cstr_12[i] = '1';
        }
	      mask >>= 1;
	    }
	    for(i = 0; i < 12; ++i){
		    instruction[i+5] = cstr_12[i];
	    }
	    printf("%s%s\n", (linum ? linbuf : "\0"), &instruction[1]);
	  } else
	    printf("%s%s\n", (linum ? linbuf : "\0"), instruction);
	}
	fclose(p1);
}