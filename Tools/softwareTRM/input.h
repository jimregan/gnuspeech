#ifndef __INPUT_H
#define __INPUT_H

#include "structs.h" // For TRMParameters

/*  VARIABLES FOR INPUT TABLES  */
typedef struct _INPUT {
    struct _INPUT *previous;
    struct _INPUT *next;

    TRMParameters parameters;
} INPUT;

extern INPUT *inputHead;

int parseInputFile(const char *inputFile);

double glotPitchAt(INPUT *ptr);
double glotVolAt(INPUT *ptr);
double *radiiAt(INPUT *ptr);
double radiusAtRegion(INPUT *ptr, int region);
double velumAt(INPUT *ptr);
double aspVolAt(INPUT *ptr);
double fricVolAt(INPUT *ptr);
double fricPosAt(INPUT *ptr);
double fricCFAt(INPUT *ptr);
double fricBWAt(INPUT *ptr);

void printControlRateInputTable(void);

#endif