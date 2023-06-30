#ifndef _code_facilities_h
#define _code_facilities_h

typedef struct number_list {
	int number;
	struct number_list *next_n;
} NUM_ITEM_TYPE;

typedef NUM_ITEM_TYPE *NUMBER_LIST_TYPE;


//#define nextInstruction current_instruction_number

#define NO_LABEL 0
#define UNKNOWN 0 
/* Type definition for storing instructions.
   A quad has four elements op,adr1,adr2,adr3
   and an integer label representing an operation, e.g. +,x,y,z   z = x + y;
*/
typedef struct instruction {
	int number;
	char * text;
	int label;
	struct instruction *next_i; } INSTRUCTION_TYPE;

typedef INSTRUCTION_TYPE *INSTRUCTION_TABLE_TYPE;

void addInstruction(char *instuction_text, int label);
void print_int_code(FILE *outputStream);
int nextInstruction();
NUMBER_LIST_TYPE makelist(int instNumber);
NUMBER_LIST_TYPE mergelists(NUMBER_LIST_TYPE list1, NUMBER_LIST_TYPE list2);
void backpatch(NUMBER_LIST_TYPE ntflist, int Label);

#endif
