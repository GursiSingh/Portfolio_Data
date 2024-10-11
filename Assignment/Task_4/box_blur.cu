//TASK 4

/*
-   Reading in an image file into a single or 2D array (5 marks)

-   Allocating the correct amount of memory on the GPU based on input data. Memory is freed once used (15 marks)

-   Applying Box filter on image in the kernel function (30 marks)

-   Return blurred image data from the GPU to the CPU (30 marks)

-   Outputting the correct image with Box Blur applied as a file (20 marks)

    Gursimran Singh - 2042387
*/

#include <stdio.h>
#include <stdlib.h>
#include "lodepng.h"


//Sum the given center pixel value (R,G,B,A) with all the valid pixels around  
__device__ int sumPixels (int pixel, unsigned char * inputImage, int width , int height){
    int sum = 0;
    int totalPixels =  (width * height * 4) -4;
    //Center

    sum += inputImage[pixel];
    // printf("\n---------------------------\n");
    // printf("CENTER = %d\n", inputImage[pixel]);

    //Top
    if(((pixel - (width*4)) < totalPixels) && ((pixel - (width*4)) >= 0)){
        sum += inputImage[pixel - (width*4)];
        // printf("Pixel = %d Top = %d\n",pixel - (width*4), inputImage[pixel - (width*4)]);
    }

    //Top-Right
    if(((pixel/ 4) +1) < (width*4) && ((((pixel/ 4) +1)% width) != 0)){
        if(((pixel - (width*4) +4) < totalPixels) && ((pixel - (width*4) +4) >= 0) ){
            sum += inputImage[pixel - (width*4) +4];
            
            // printf("Pixel = %d Top-Right = %d\n",(pixel - (width*4) +4), inputImage[pixel - (width*4) +4]);
        }

        //Right
        if(((pixel+4)< totalPixels) && ((pixel+4) > 0)){
            sum += inputImage[pixel+4];
            
            // printf("Pixel = %d Right = %d\n", (pixel+4), inputImage[pixel +4]);
            
        }
    }
    
    //check if is on the left margin
    if(((pixel/4)% width) != 0){
        //Top-Left
        if(((pixel - (width*4) -4) < totalPixels) && ((pixel - (width*4) -4) >= 0) ){
            sum += inputImage[pixel - (width*4) -4];
            
            // printf("Pixel = %d Top-Left = %d\n",(pixel - (width*4) -4), inputImage[pixel - (width*4) -4]);
        }
        //Left
        if(((pixel-4)< totalPixels) && ((pixel-4) >=     0)){
            
            sum += inputImage[pixel-4];
            // printf("Pixel = %d Left = %d\n", (pixel-4), inputImage[pixel -4]);
        }

        //Bottom-Left
        if((((pixel + (width*4)) -4 ) < totalPixels) && (((pixel + (width*4)) -4 ) >= 0) ){
            sum += inputImage[pixel + (width*4) -4];
            // printf("Pixel = %d Bottom-Left = %d\n", ((pixel + (width*4)) -4 ), inputImage[pixel + (width*4) -4]);

        }
        
    }

    //Bottom
    if(((pixel + (width*4))< totalPixels) && ((pixel + (width*4)) >= 0) ){
        sum += inputImage[pixel + (width*4)];
        
        // printf("Pixel = %d Bottom = %d\n", pixel + (width*4), inputImage[pixel + (width*4)]);
    }

    //Bottom-Right
    if(((((pixel/ 4) +1)% width) != 0)){
        if((((pixel + (width*4)) +4 ) < totalPixels) && (((pixel + (width*4)) +4 ) >= 0) ){
            sum += inputImage[pixel + (width*4) +4];
            // printf("Pixel = %d Bottom-Right = %d\n", ((pixel + (width*4)) +4 ), inputImage[pixel + (width*4) +4]);

        }
    }
    



    
    return sum;
}

//This function iterate though all the imagee pixels 4 by 4 if the centeer is foound  it blurs the pixels and return the new image data
__global__ void blurImage(unsigned char * inputImage,unsigned char * outputImage, int centerPixel, int width, int height, int blurredPixels){

    int threadID = blockDim.x * blockIdx.x + threadIdx.x;
    int pixel = threadID * 4;
    int sumR = 0;
    int sumG = 0;
    int sumB = 0;
    int sumA = 0;
    int totalPixels =  (width * height * 4) -4;

    //center
    if(pixel == centerPixel){
        sumR = sumPixels(centerPixel,inputImage, width, height) / blurredPixels;
        sumG = sumPixels(centerPixel+1,inputImage, width, height) / blurredPixels;
        sumB = sumPixels(centerPixel+2,inputImage, width, height) / blurredPixels;
        sumA = sumPixels(centerPixel+3,inputImage, width, height) / blurredPixels;
        
        //Center
        outputImage[pixel] = sumR;
        outputImage[pixel+1] = sumG;
        outputImage[pixel+2] = sumB;
        outputImage[pixel+3] = sumA;
        
        //Top
        if(((pixel - (width*4)) < totalPixels) && ((pixel - (width*4)) >= 0)){
            
            int top = pixel - (width*4);
            outputImage[top] = sumR;
            outputImage[top+1] = sumG;
            outputImage[top+2] = sumB;
            outputImage[top+3] = sumA;
        }


        //Check if is not right magin
        if(((pixel/ 4) +1) < (width*4) && ((((pixel/ 4) +1)% width) != 0)){

            //Top-Right
            if(((pixel - (width*4) +4) < totalPixels) && ((pixel - (width*4) +4) >= 0) ){
                
                if(((pixel/ 4) +1) < (width*4)){
                    
                    int topRight = pixel - (width*4) +4;
                    outputImage[topRight] = sumR;
                    outputImage[topRight+1] = sumG;
                    outputImage[topRight+2] = sumB;
                    outputImage[topRight+3] = sumA;
                }else{
                    int pix = pixel - (width*4) +4;
                    outputImage[pix] = inputImage[pix];
                    outputImage[pix+1] = inputImage[pix+1];
                    outputImage[pix+2] = inputImage[pix+2];
                    outputImage[pix+3] = inputImage[pix+3];

                }
                
            }

            //Right
            if(((pixel+4)< totalPixels) && ((pixel+4) >= 0)){
                
                int right = pixel+4;
                outputImage[right] = sumR;
                outputImage[right+1] = sumG;
                outputImage[right+2] = sumB;
                outputImage[right+3] = sumA;
            }

            //Bottom-Right
            if((((pixel + (width*4)) +4 ) < totalPixels) && (((pixel + (width*4)) +4 ) >= 0) ){
               
                int bottomRight = pixel + (width*4) +4;
                outputImage[bottomRight] = sumR;
                outputImage[bottomRight+1] = sumG;
                outputImage[bottomRight+2] = sumB;
                outputImage[bottomRight+3] = sumA;
            }
        }else{
            int pixA = pixel - (width*4) +4;
            outputImage[pixA] = inputImage[pixA];
            outputImage[pixA+1] = inputImage[pixA+1];
            outputImage[pixA+2] = inputImage[pixA+2];
            outputImage[pixA+3] = inputImage[pixA+3];

            int pixB =pixel+4;
            outputImage[pixB] = inputImage[pixB];
            outputImage[pixB+1] = inputImage[pixB+1];
            outputImage[pixB+2] = inputImage[pixB+2];
            outputImage[pixB+3] = inputImage[pixB+3];

            int pixC = pixel + (width*4) +4;
            outputImage[pixC] = inputImage[pixC];
            outputImage[pixC+1] = inputImage[pixC+1];
            outputImage[pixC+2] = inputImage[pixC+2];
            outputImage[pixC+3] = inputImage[pixC+3];
        }
        

        //Top-Left and not left margin
        if(((pixel - (width*4) -4) < totalPixels) && ((pixel - (width*4) -4) >= 0) && (((pixel/4)% width) != 0)){
            
            int topLeft = pixel - (width*4) -4;
            outputImage[topLeft] = sumR;
            outputImage[topLeft+1] = sumG;
            outputImage[topLeft+2] = sumB;
            outputImage[topLeft+3] = sumA;
    
        }else{
            int pix = pixel - (width*4) -4;
            outputImage[pix] = inputImage[pix];
            outputImage[pix+1] = inputImage[pix+1];
            outputImage[pix+2] = inputImage[pix+2];
            outputImage[pix+3] = inputImage[pix+3];
        }

        //Bottom
        if(((pixel + (width*4))<= totalPixels) && ((pixel + (width*4)) >= 0) ){
            
            int bottom = pixel + (width*4);
            outputImage[bottom] = sumR;
            outputImage[bottom+1] = sumG;
            outputImage[bottom+2] = sumB;
            outputImage[bottom+3] = sumA;
        }

        //Bottom-Left and not left margin
        if((((pixel + (width*4)) -4 ) < totalPixels) && (((pixel + (width*4)) -4 ) >= 0) && (((pixel/4)% width) != 0)){
            
            int bottomLeft = pixel + (width*4) -4;
            outputImage[bottomLeft] = sumR;
            outputImage[bottomLeft+1] = sumG;
            outputImage[bottomLeft+2] = sumB;
            outputImage[bottomLeft+3] = sumA;
        }else{
            int pix = pixel + (width*4) -4;
            outputImage[pix] = inputImage[pix];
            outputImage[pix+1] = inputImage[pix+1];
            outputImage[pix+2] = inputImage[pix+2];
            outputImage[pix+3] = inputImage[pix+3];
        }

        //Left and not left margin
        if(((pixel-4)< totalPixels) && ((pixel-4) >= 0) && (((pixel/4)% width) != 0)){
            
            int left = pixel-4;
            outputImage[left] = sumR;
            outputImage[left+1] = sumG;
            outputImage[left+2] = sumB;
            outputImage[left+3] = sumA;
            
        }else{
            int pix = pixel -4;
            outputImage[pix] = inputImage[pix];
            outputImage[pix+1] = inputImage[pix+1];
            outputImage[pix+2] = inputImage[pix+2];
            outputImage[pix+3] = inputImage[pix+3];
        }

        
    }

    //Left
    else if(pixel == centerPixel-4){

    }

    //Right
    else if(pixel == centerPixel+4){

    }

    //Top
    else if(pixel == (centerPixel - (width*4))){

    }
    
    //Top-Right
    else if(pixel == (centerPixel - (width*4) +4)){

    }

    //Top-Left
    else if(pixel == (centerPixel - (width*4) -4)){
    }

    //Bottom
    else if(pixel == (centerPixel + (width*4))){

    }


    //Bottom-Right
    else if(pixel == (centerPixel + (width*4) +4)){

    }

    //Bottom-Left
    else if(pixel == (centerPixel + (width*4) -4)){

    }else{
        //If is not the centers
        outputImage[pixel] = inputImage[pixel];
        outputImage[pixel+1] = inputImage[pixel+1];
        outputImage[pixel+2] = inputImage[pixel+2];
        outputImage[pixel+3] = inputImage[pixel+3];
    }
    __syncthreads();

    
}

//Print the image array in the console
void printImage(unsigned char** image2D, unsigned int width, unsigned int height){
    for(int row1=0; row1<height; row1++){
        for(int col1=0; col1<width*4; col1++){
            printf("%d ", image2D[row1][col1]);if((col1+1)%4 == 0);
            printf("| ");
        
        }
        printf("\n");
    }
}

//Return the number of pixels that can be blurred
int getBlurredNum(int width, int height, int row, int col){

    int totalBox = 1;
    
    //Right
    if(row+1 < width){
        totalBox++;
        //Top-Right
        if(col-1 < height && col-1 >= 0){
            totalBox++;
        }
        //Bottom-Right
        if(col+1 < height){
            totalBox++;
        }
    }


    //Bottom
    if(col+1 < height){
        totalBox++;
    }

    //Top
    if(col-1 < height && col-1 >= 0){
        totalBox++;
    }

    //Left
    if(row-1 < width && row-1 >= 0){
        totalBox++;

        //Top-Left
        if(col-1 < height && col-1 >= 0){
            totalBox++;
        }

        //Bottom-Left
        if(col+1 < height){
            totalBox++;
        }
    }
    
    return totalBox;
}

int main(int argc, char *argv[]){

    unsigned int error;
    unsigned char* image;
    unsigned char** image2D;
    unsigned int width;
    unsigned int height;
    const char* filename = argv[1];
    const char* newFilename = "output.png";

    //box filter center
    int centerRow = 3;
    int centerCol = 1;

    //Get image
    error = lodepng_decode32_file(&image, &width, &height, filename);

    if(error){
        printf("error %u: %s\n", error, lodepng_error_text(error));
    }

    //Array Size and memory
    int arraySize = width*height*4;
	int memorySize = arraySize * sizeof(unsigned char);

    unsigned char outputImage[arraySize];

    //Check how many pixeels will be blurred
    int blurredNum = getBlurredNum(width, height, centerRow, centerCol);
    int centerPixel = (width  * (centerCol + 1) - (width - (centerRow))) *4;

    
    //Allocate Memory for rows in the 2D array
    image2D = (unsigned char**)malloc(height * sizeof(unsigned char*));

    //Allocate Memory for cols
    for (int i = 0; i < height; ++i) {
        image2D[i] = (unsigned char*)malloc((width*4) * sizeof(unsigned int));
    }

    //Convert array to 2D in the 2D array
    for(int row=0; row<height; row++){
        for(int col=0; col<width*4; col=col+4){
            image2D[row][col]=image[(row*width*4)+col];
            image2D[row][col+1]=image[(row*width*4)+col+1];
            image2D[row][col+2]=image[(row*width*4)+col+2];
            image2D[row][col+3]=image[(row*width*4)+col+3];
        }
    }
    
    //Cuda Variables
    unsigned char* deviceOutputImage;
    unsigned char* deviceInputImage;

    //Cuda Malloc
	cudaMalloc( (void**) &deviceOutputImage, memorySize);
	cudaMalloc( (void**) &deviceInputImage, memorySize);

    //Send to device
	cudaMemcpy(deviceInputImage, image, memorySize, cudaMemcpyHostToDevice);

    //Dimensions
    dim3 nThreads(width, 1, 1);
    dim3 nBlocks(height, 1, 1);

    //Blur Image
    blurImage<<< nBlocks, nThreads >>>(deviceInputImage, deviceOutputImage, centerPixel, width, height, blurredNum);
	cudaDeviceSynchronize();

	//Get from Device
	cudaMemcpy(outputImage, deviceOutputImage, memorySize, cudaMemcpyDeviceToHost);
	
    //Output Image
    //printImage(image2D, width, height);
	lodepng_encode32_file(newFilename, outputImage, width, height);
    printf("\n##### Picture saved as output.png #####\n");   

    //Free memory		
    for (int i = 0; i < height; ++i) {
        free(image2D[i]);
    }
    free(image2D);
    cudaFree(deviceOutputImage);
    cudaFree(deviceInputImage);

    return 0;
}