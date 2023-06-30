#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "sglib.h"
#include "codeFacilities.h"

#define INSTRUCTION_COMPARATOR(e1, e2) (e1->number - e2->number)

// There is a sinlge instruction table.
INSTRUCTION_TABLE_TYPE INTERCODE = NULL;
int current_instruction_number = 10;

int nextInstruction(){
    return current_instruction_number;
}

void addInstruction(char *instuction_text, int label)
{
  INSTRUCTION_TYPE *new_instruction;
  new_instruction = malloc(sizeof(INSTRUCTION_TYPE));
  new_instruction->number = current_instruction_number;
  new_instruction->text = strdup(instuction_text);
  new_instruction->label = label;
  current_instruction_number++;
	// SGLIB function that adds the new quad at the end of the linked list.
  SGLIB_LIST_ADD(NUM_ITEM_TYPE, INTERCODE, new_instruction, next_i);
}

void print_int_code(FILE *outputStream)
{
  INSTRUCTION_TYPE * instr;

  SGLIB_LIST_REVERSE(INSTRUCTION_TYPE, INTERCODE, next_i);
  SGLIB_LIST_MAP_ON_ELEMENTS(INSTRUCTION_TYPE, INTERCODE, instr, next_i, {
    fprintf(outputStream,"%s", instr->text);
    if (instr->label != 0) {fprintf(outputStream,"%d",instr->label);}
    fprintf(outputStream,"\n");
  });
}

// Creates a new List of instruction numbers
NUMBER_LIST_TYPE makelist(int instNumber)
{
   NUM_ITEM_TYPE * newEntry;
   NUMBER_LIST_TYPE newList;

   newList = NULL;
   newEntry = malloc(sizeof(NUM_ITEM_TYPE));
   newEntry->number = instNumber;
   SGLIB_LIST_ADD(NUM_ITEM_TYPE, newList, newEntry, next_n);
   return newList;
}

/* Merges two lists of instruction Numbers. */
NUMBER_LIST_TYPE mergelists(NUMBER_LIST_TYPE list1, NUMBER_LIST_TYPE list2)
{
   NUMBER_LIST_TYPE newList;
   newList = NULL;
   NUM_ITEM_TYPE * n;
   NUM_ITEM_TYPE * el;

   SGLIB_LIST_MAP_ON_ELEMENTS(NUM_ITEM_TYPE, list1, n, next_n,
	{
		el = malloc(sizeof(NUM_ITEM_TYPE));
	  el->number = n->number;
		SGLIB_LIST_ADD(NUM_ITEM_TYPE,newList,el,next_n);
		})

	SGLIB_LIST_MAP_ON_ELEMENTS(NUM_ITEM_TYPE, list2, n, next_n,
	{
		el = malloc(sizeof(NUM_ITEM_TYPE));
	  el->number = n->number;
		SGLIB_LIST_ADD(NUM_ITEM_TYPE,newList,el,next_n);
		})
   return newList;
}

/* Backpatching main function. Takes a list of instruction numbers
(ntflist) and a label Label (int) that is the label to be patched to,
and makes appropriate changes. */

void backpatch(NUMBER_LIST_TYPE ntflist, int Label)
{   INSTRUCTION_TYPE  * inst_elem, * jumpInst;
    NUM_ITEM_TYPE * n_item;

	//char QLabelString[20]; /* needed for int to string conversion (C!) */
  //sprintf(QLabelString,"%d",QLabel); // conver the Qlabel to string.

	inst_elem = malloc(sizeof(INSTRUCTION_TYPE));
	// For all elements of the list ntflist, get the label, find the quad in the
	// code table INETRCODE and replace the third argument with the temp
	SGLIB_LIST_MAP_ON_ELEMENTS(NUM_ITEM_TYPE, ntflist, n_item, next_n,
	{
    inst_elem->number = n_item->number;
	  SGLIB_LIST_FIND_MEMBER(INSTRUCTION_TYPE,INTERCODE,inst_elem,INSTRUCTION_COMPARATOR,next_i, jumpInst);
		if (jumpInst == NULL) {printf("Error Quad %d Not found in Code\n",n_item->number);exit(1);}
		printf("backpatch instruction %d with %d\n",inst_elem->number,Label);
		jumpInst->label = Label;
	});
  free(inst_elem);
}
