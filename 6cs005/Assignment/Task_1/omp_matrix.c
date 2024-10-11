//TASK 1

/*
    Read data from file appropriately (20 marks)
    Using dynamic memory (malloc) for matrix A and matrix B (10 marks)
    Creating an algorithm to multiply matrices correctly (20 marks)
    Using multithreading with equal computations (30 marks)
    Storing the correct output matrices in the correct format in a file  (20 marks)

    Gursimran Singh - 2042387
*/

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

/*

This function checks if the two matrix can be multiplied, by checking if the number of 
colums of the first matrix is equal to the number of rows of the second one.
it return a boolean true or false;
*/

int canBeMultiplied(int colA, int rowB){
    if(colA == rowB)
      return 1;
    return 0;
}

//function to save the result to a file
void writeResults(double** result, int rowsC, int colsC, FILE *fpOut){

  // printf("SAVING TO FILE");
  
  
  fprintf(fpOut,"%d,%d\n", rowsC, colsC);
  for (int i = 0; i < rowsC; ++i) {
    for (int j = 0; j < colsC; ++j) {
        fprintf(fpOut,"%lf,", result[i][j]);
        if (j == colsC - 1)
          fprintf(fpOut,"\n");
    }
  }
  fprintf(fpOut,"\n");
  
}

//function to display a matrix in the console
void display(double** matrix, int row, int column) {

  printf("\nOutput Matrix:\n");
  for (int i = 0; i < row; ++i) {
    for (int j = 0; j < column; ++j) {
        printf("%lf  ", matrix[i][j]);
        if (j == column - 1)
          printf("\n");
    }
  }
}


//function that multiplies the matrices
void multiplyMatrices(double** matrixA, double** matrixB, double** result, int colsA, int colsB, int rowsA, int rowsB, FILE *fpOut, int threadNumber){
  //if rowB = 2 colB 2  and rowB = 2 colB = 2
  //C11 = A11 * B11 + A12 * B21
  #pragma omp parallel for num_threads(threadNumber)
  for(int rowA = 0; rowA < rowsA; rowA++){
    for(int colB = 0; colB < colsB; colB++){
      for(int colA = 0; colA < colsA; colA++){
        result[rowA][colB] += matrixA[rowA][colA] * matrixB[colA][colB];
      }
      
      //printf("----> THREAD %d - MATRIXC= %f\n\n", omp_get_thread_num(), result[rowA][colB]);
    }

  }

  //write the result of the moltiplication to the output file
  writeResults(result, rowsA, colsB, fpOut);
}

void main(int argc, char *argv[])
{
  FILE *fp = NULL;
  FILE *fpOut;
  int row, col;
  int rowsA, colsA;
  int rowsB, colsB;
  int rowsC, colsC;

  double matval = 0.0;
  int counter = 0;
  char c;
  char* outputFile = "matrixresults2042387.txt";
  //thread number entered by the user in the console
  int threadNumber = atoi(argv[1]);
  //open file containing the matrices
  fp = fopen("2042387-matrices.txt", "r");
  //open file to write out the results of the matrices
  fpOut = fopen(outputFile, "a");
  
  //while loop to iterate between different lines of contained in the matrix files
  while(!feof(fp)){
    //counter to count the current matrix multiplication
    counter++;
    
    //initialize matrix A 2D Array
    //printf("\n----MATRIX A----\n");
    fscanf(fp,"%d,%d\n",&rowsA, &colsA);
    //printf("\nRows: %d, Cols: %d\n", rowsA, colsA);
    
    double** matrixA = malloc(sizeof(double*) * rowsA);
    for(int i = 0; i < rowsA; i++){
        matrixA[i] = malloc(sizeof(double*) * colsA);
    }

    
    //read and save matrix in the 2D matrix A arrays
    for(row = 0; row < rowsA; row++){
      for(col = 0; col < colsA -1; col++){
        fscanf(fp,"%lf,",&matval);
        matrixA[row][col] = matval;
      }
      fscanf(fp,"%lf\n",&matval);
      matrixA[row][colsA -1] = matval;
    }

    
    //initialize matrix B 2D Array
    fscanf(fp,"%d,%d\n",&rowsB, &colsB);
    

    double** matrixB = malloc(sizeof(double*) * rowsB);
    for(int i = 0; i < rowsB; i++){
        matrixB[i] = malloc(sizeof(double*) * colsB);
    }

    //read and save matrix in the 2D matrix B arrays
    // printf("\n----MATRIX B----\n");
    // printf("\nRows: %d, Cols: %d\n", rowsB, colsB);
    for(row = 0; row < rowsB; row++){
      for(col = 0; col < colsB -1; col++){
        fscanf(fp,"%lf,",&matval);
        matrixB[row][col] = matval; 
      }
      fscanf(fp,"%lf\n",&matval);
      matrixB[row][colsB -1] = matval;
    }

    //check if matrix a and b can be multiplied if so return 1 else 0
    int valid = canBeMultiplied(colsA, rowsB);

    if(valid == 1){
      //initialize matrix C 2D Array used to store the result
      //printf("\nMatrix A and B, Number %d can be multiplied.\n", counter);
      rowsC = rowsA;
      colsC = colsB;

      double** matrixC = malloc(sizeof(double*) * rowsC);

      for(int i = 0; i < rowsC; i++){
        matrixC[i] = malloc(sizeof(double*) * colsC);
      }
      //Multiply matrix A and B
      multiplyMatrices(matrixA, matrixB, matrixC, colsA, colsB, rowsA, rowsB, fpOut, threadNumber);

      //Free Matrix C
      for (int i = 0; i < rowsC; i++){
        matrixC[i] = NULL;
        free(matrixC[i]);
      }
      
      free(matrixC);
    }else{

      //print message if two matrices cannot be multiplied
      printf("Matric A[%d, %d] and B[%d, %d], cannot be multiplied.\n",rowsA, colsA, rowsB, colsB);    
    }
    
    //Free Matrix A
    //printf("\nFREE MEMORY: %d\n\n", counter);
    for (int i = 0; i < rowsA; i++){
      matrixA[i] = NULL;
      free(matrixA[i]);
    }

    free(matrixA);
    

    //Free Matrix B
    for (int i = 0; i < rowsB; i++){
      matrixB[i] = NULL;
      free(matrixB[i]);
    }
    
    free(matrixB);
  }

  printf("Matrix multiplication completed, results saved to %s.\n",outputFile);
  fclose(fp);
  fclose(fpOut);
}