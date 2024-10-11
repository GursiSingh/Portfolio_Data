//TASK 2

/*
In this task, you will be asked to use the "crypt" library to decrypt a password using 
multithreading. You will be provided with two programs. The first program called 
"EncryptSHA512.c" which allows you to encrypt a password. For this assessment, you will be 
required to decrypt a 4-character password consisting of 2 capital letters, and 2 numbers. The 
format of the password should be "LetterLetterNumberNumber." For example, "HP93." Once 
you have generated your password, this should then be entered into your program to decrypt 
the password. The method of input for the encrypted password is up to you. The second 
program is a skeleton code to crack the password in regular C without any multithreading 
syntax. Your task is to use multithreading to split the workload over many threads and find the 
password. Once the password has been found, the program should finish meaning not all 
combinations of 2 letters and 2 numbers should be explored unless it`s ZZ99 and the last thread 
happens to finish last. You can use either POSIX Threads (Pthreads) or OpenMP threads for this 
task.

    Gursimran Singh - 2042387
*/




#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <crypt.h>
#include <unistd.h>
#include <omp.h>

/**
 Required by lack of standard function in C.   
*/
void substr(char *dest, char *src, int start, int length){
    memcpy(dest, src + start, length);
    *(dest + length) = '\0';
}

/**
 This function can crack the kind of password. All combinations
 that are tried and the correct one is displayed when the password is found,
*/

void crack(char *salt_and_encrypted, int threadNumber){
    // Loop counters
    int x, y, z;     
    // String used in hashing the password. Need space for \0 // incase you have modified the salt value, then should modifiy the number accordingly
    char salt[7];    
    // The combination of letters currently being checked // Please modifiy the number when you enlarge the encrypted password.
    char plain[7];   
    // Pointer to the encrypted password
    char *enc;       
    // String used to store the decrypted password
    char decr;
    //int used as boolean to find out if the password has been found
    int isDecrypted = 0; // false

    substr(salt, salt_and_encrypted, 0, 6);
    #pragma omp parallel for private(x,y,z,plain, enc) shared(isDecrypted, salt) num_threads(threadNumber) collapse(3)
    for(x='A'; x<='Z'; x++){
        for(y='A'; y<='Z'; y++){
            for(z=0; z<=99; z++){
                #pragma omp critical
                if(isDecrypted == 0){
                    sprintf(plain, "%c%c%02d", x, y, z);
                    enc = (char *) crypt(plain, salt);
                    if(strcmp(salt_and_encrypted, enc) == 0){
                        printf("Password is: %s\n",plain);
                        isDecrypted = 1;
                        x= 'Z';
                        y= 'Z';
                    }
                }
            }
        }
    }
    return;
}

int main(int argc, char *argv[]){

    //thread number entered by the user in the console
    int threadNumber = atoi(argv[1]);

    //AA55
    //crack("$6$AS$djb519tszEB0jiTssC84CtrlQhc0TsHj.qvrC74nYegybXek5oKIu3MqoUpTVaVi3HVqhg5h0xnL57JVJbwpA1", threadNumber);		
    //ZZ98
    //crack("$6$AS$tqp47C7ydQ1WfB2zeo/qyMwiUHeYQF8hgyYT7P5.bKJKl.Haz9t745829rp9IJRatjnpurYM2IP5zB2HqynYr/", threadNumber);
    //DE52
    crack("$6$AS$/WvuvbyOUGko5KMYHLvEfypw492zvphZw3ImhUVSEfim7PE4q/z0vt6qwX0evIcLuR4Rz3KpNjxskVoel/w1N1", threadNumber);
    return 0;
}
