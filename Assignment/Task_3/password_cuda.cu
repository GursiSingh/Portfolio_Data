//TASK 3

/*
Generate encrypted password in the kernel function (using CudaCrypt function) to be 
compared to original encrypted password (25 marks)
Allocating the correct amount of memory on the GPU based on input data. Memory is freed 
once used (15 marks)
Program works with multiple blocks and threads – the number of blocks and threads will 
depend on your kernel function. You will not be penalised if your program only works with a 
set number of blocks and threads however, your program must use more than one block (axis 
is up to you) and more than one thread (axis is up to you) (40 marks)
Decrypted password sent back to the CPU and printed (20 marks)

    Gursimran Singh -  2042387    
*/

#include <stdio.h>
#include <stdlib.h>


//This function gets two striings and return 0 if they match
__device__ int comparePasswords(const char *str_a, const char *str_b, unsigned len =256){

    int match = 0;
    unsigned i = 0;
    unsigned done = 0;
    while ((i < len) && (match == 0) && !done){
    if ((str_a[i] == 0) || (str_b[i] == 0))
        done = 1;
    else if (str_a[i] != str_b[i]){
        match = i+1;
        if (((int)str_a[i] - (int)str_b[i]) < 0)
            match = 0 - (i + 1);
        }
        i++;
    }

    return match;
}

//This function encrypts the raw passsword and returns thee new encrypted password
__device__ char *cudaEncrypt(char *rawPassword,char *newPassword){
    
	newPassword[0] = rawPassword[0] + 2;
	newPassword[1] = rawPassword[0] - 2;
	newPassword[2] = rawPassword[0] + 1;
	newPassword[3] = rawPassword[1] + 3;
	newPassword[4] = rawPassword[1] - 3;
	newPassword[5] = rawPassword[1] - 1;
	newPassword[6] = rawPassword[2] + 2;
	newPassword[7] = rawPassword[2] - 2;
	newPassword[8] = rawPassword[3] + 4;
	newPassword[9] = rawPassword[3] - 4;
	newPassword[10] = '\0';

	for(int i =0; i<10; i++){
		if(i >= 0 && i < 6){ //checking all lower case letter limits
			if(newPassword[i] > 122){
				newPassword[i] = (newPassword[i] - 122) + 97;
			}else if(newPassword[i] < 97){
				newPassword[i] = (97 - newPassword[i]) + 97;
			}
		}else{ //checking number section
			if(newPassword[i] > 57){
				newPassword[i] = (newPassword[i] - 57) + 48;
			}else if(newPassword[i] < 48){
				newPassword[i] = (48 - newPassword[i]) + 48;
			}
		}
	}
	return newPassword;
}

//This function run over all the combinations of the password and rreturns the decrypted password
__global__ void cudaDecrypt(char* inputPassword, char *outputPassword, char* letterList, char* numList){

    char rawPassword[5];

    //Set current password
    rawPassword[0] = letterList[blockIdx.x];
    rawPassword[1] += letterList[blockIdx.y];
    rawPassword[2] += numList[threadIdx.x];
    rawPassword[3] += numList[threadIdx.y];
    rawPassword[4] += '\0';
    
    char rawEnc[11];
    //Set current ecrypted password
    char *rawEncrypted = cudaEncrypt(rawPassword, rawEnc);

    //Check if input and raw encrypted passwords match and return the output password
    if((comparePasswords(rawEncrypted, inputPassword) == 0)){
        outputPassword[0]= rawPassword[0];
        outputPassword[1]= rawPassword[1];
        outputPassword[2]= rawPassword[2];
        outputPassword[3]= rawPassword[3];
        outputPassword[4]= '\0';
    }
    
}

int main(){

    printf("Encryption Started\n");

    //Size
    int numSize = 10;
    int numSizeMemory = numSize * sizeof(int);

    int letterSize = 26;
    int letterSizeMemory = letterSize * sizeof(int);

    int encPasswordSize = 11;
    int encPasswordSizeMemory = encPasswordSize * sizeof(int);

    int decPasswordSize = 5;
    int decPasswordSizeMemory = decPasswordSize * sizeof(char *);

    //CPU - HOST Variables
    //df77
    char *inputPassword = "fbeice9523";
    char outputPassword[decPasswordSize];

    char numList[numSize];
    char letterList[letterSize];

    int counter = 0;
    
    //creating input values on the CPU
    for(char i = '0'; i <= '9'; i++){
        numList[counter] = i;
        counter++;
    }

    counter = 0;
    for(char i = 'a'; i <= 'z'; i++){
        letterList[counter] = i;
        counter++;
    }
    
    //create GPU variables
    char *deviceLetterList;
    char *deviceNumList;
    char *deviceInputPassword;
    char *deviceOutputPassword;
    
    //allocate memory on the GPU using cudaMalloc
    cudaMalloc( (void**) &deviceLetterList, letterSizeMemory);
    cudaMalloc( (void**) &deviceNumList, numSizeMemory);
    cudaMalloc( (void**) &deviceInputPassword, encPasswordSizeMemory);
    cudaMalloc( (void**) &deviceOutputPassword, decPasswordSizeMemory);
    
    //Send to device
    cudaMemcpy(deviceLetterList, letterList, letterSizeMemory, cudaMemcpyHostToDevice);
    cudaMemcpy(deviceNumList, numList, numSizeMemory, cudaMemcpyHostToDevice);
    cudaMemcpy(deviceInputPassword, inputPassword, encPasswordSizeMemory, cudaMemcpyHostToDevice);
    cudaMemcpy(deviceOutputPassword, outputPassword, decPasswordSizeMemory, cudaMemcpyHostToDevice);
    

    //Blocks and Threads
    dim3 nBlocks = dim3(letterSize, letterSize); 
    dim3 nThreads= dim3(numSize, numSize); 

    cudaDecrypt<<<nBlocks , nThreads>>>(deviceInputPassword, deviceOutputPassword, deviceLetterList, deviceNumList);
    // cudaThreadSynchronize();
    
    cudaDeviceSynchronize();
    
    //Get from Device
    cudaMemcpy(outputPassword, deviceOutputPassword, decPasswordSizeMemory, cudaMemcpyDeviceToHost);

    //Print Output
    printf("Encrypted: %s - > Decrypted: %s\n", inputPassword, outputPassword);

    //Free Cuda Memory
    cudaFree(deviceLetterList);
    cudaFree(deviceNumList);
    cudaFree(deviceInputPassword);
    cudaFree(deviceOutputPassword);

    return 0;
}
