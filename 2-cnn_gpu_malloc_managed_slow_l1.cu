#include <stdio.h>
#include <iostream>
#include <math.h>
#include <string.h>
#include <fstream>
#include <sstream>
//#include <bits/stdc++.h>
//#include <stdlib.h>
//#include <time.h>
using namespace std;
/***DEFINING THE DEFINES FOR THE ARRAY INDICES****************************/
//#define N 128
#define C 3
#define H 227
#define W 227
#define R 11
#define S 11
#define M 96
#define E 55
#define F 55
#define U 4
__global__
void ew_gpu_mmul(float* d_o, float* d_i, float* d_w, int width, int height, int stride, int ip_height, int wt_width, int num_wt,int num_img, int num_ch)
{
int row = threadIdx.y; int col = threadIdx.x;
{
for(int x=0;x<2;x++){
for(int y=0;y<2;y++){
for (int i=0; i<wt_width; i++){
  for (int j=0; j<wt_width; j++){
   for(int k=0; k<num_ch; k++){
//    float ip = d_i[blockIdx.x*num_ch*ip_height*ip_height+k*ip_height*ip_height+(stride*(2*row+y)+i)*ip_height+(stride*(2*col+x)+j)];
  //      float wt = d_w[blockIdx.y*num_ch*wt_width*wt_width+k*wt_width*wt_width+(i*wt_width+j)];
    //    float  prod = ip*wt;
        if((2*row+y<height)&&(2*col+x<width))
         d_o[blockIdx.x*num_wt*height*width+blockIdx.y*width*height+(2*row+y)*width+(2*col+x)] +=d_i[blockIdx.x*num_ch*ip_height*ip_height+k*ip_height*ip_height+(stride*(2*row+y)+i)*ip_height+(stride*(2*col+x)+j)]*d_w[blockIdx.y*num_ch*wt_width*wt_width+k*wt_width*wt_width+(i*wt_width+j)] ;

}
}
}
//if(d_o[blockIdx.x*num_wt*height*width+blockIdx.y*width*height+(2*row+y)*width+(2*col+x)]<0)
//d_o[blockIdx.x*num_wt*height*width+blockIdx.y*width*height+(2*row+y)*width+(2*col+x)] =0;
}
}
}
}

 

void element_wise_mmul(float* output, float* input, float* weight, int batch_size)
{
int x,y,i,j,m,n,k;
for(n=0; n<batch_size; n++){
for (m=0 ; m<M; m++){
 for (x=0; x<F; x++){
         for(y=0; y<E; y++){
            //    OP[x][y] = 0; // adding bias to output
                 for (i=0; i<R; i++){
                         for (j=0; j<S; j++){
				for(k=0; k<C; k++){
				float ip = input[n*C*H*W+k*H*W+(U*x+i)*H+(U*y+j)];
				float wt = weight[m*C*R*S+k*R*S+i*S+j];

				float prod = ip*wt;
				if(prod >=0)
				output[n*E*F*M+m*E*F+x*E+y] += prod;
                                 //OP[x][y] += IP[U*x+i][U*y+j]*WT[i][j];
                                                         }}
                                                 }
                                        }
                                         }
 

}
}
}
int main(int argc, char* argv[])
{
int batch_size = atoi(argv[1]);
/*************INITALIZING MATRICES*********************************/
float* IP;
//float *IP = (float*) malloc(batch_size*C*H*W*sizeof(float));
cudaMallocManaged(&IP,batch_size*C*H*W*sizeof(float));
//float IP[H][W];
float *OP = (float*) malloc(batch_size*M*F*E*sizeof(float));
//float OP[F][E];
float* OPG; 
//float *OPG = (float*) malloc(batch_size*M*F*E*sizeof(float));
cudaMallocManaged(&OPG,batch_size*M*F*E*sizeof(float));

float* WT;
//float *WT = (float*) malloc(M*C*R*S*sizeof(float));
cudaMallocManaged(&WT,M*R*C*S*sizeof(float));
//float WT[R][S];
//float* d_o;
//float* d_i;
//float* d_w;

//clock_t cpu_start, gpu_start, cpu_end, gpu_end;
//int a,b,c,d;
int c,d,m,n,k;
/*INITIALIZING WEIGHT MATRIX*/
for (m=0; m<M; m++){
for(k=0;k<C;k++){
for (c=0; c<R; c++){
	for(d=0; d<S; d++){
		//WT[c][d] = 2.0;
		WT[m*C*R*S+k*R*S+c*S+d] = (float)rand()/(RAND_MAX+1.0);
}
}	
}
}
/*INITIALIZING OUTPUT MATRIX*/
for (n=0; n<batch_size;n++){
for (m=0; m<M; m++){
for (c=0; c<F; c++){
	for(d=0; d<E; d++){
		//OP[c][d] = 0;
		OP[n*M*F*E+m*F*E+c*E+d] = 0;
}
}	
}
}
/*INITIALIZING INPUT MATRIX*/
for (n=0; n<batch_size; n++){
for(k=0;k<C;k++){
for (c=0; c<H; c++){
	for(d=0; d<W; d++){
	//	IP[c][d] = (a+b+c+d);
	//if ((c<=1) || (d<=1) || (c>=29) || (d>=29))
        //IP[n*C*H*W+k*H*W+c*W+d] = 0;
        //else
        IP[n*C*H*W+k*H*W+c*W+d] = (float)rand()/(RAND_MAX+1.0);

//		IP[n*C*H*W+k*H*W+c*W+d] = (c+d);
}
}	
}
}
//cudaMalloc((void**) &d_i,batch_size*C*H*W*sizeof(float));
//cudaMemcpy(d_i, IP, batch_size*C*H*W*sizeof(float), cudaMemcpyHostToDevice);
//cudaMalloc((void**) &d_w, M*C*R*S*sizeof(float));
//cudaMemcpy(d_w, WT, M*C*R*S*sizeof(float), cudaMemcpyHostToDevice);
//cudaMalloc((void**) &d_o, batch_size*M*E*F*sizeof(float));
clock_t start, end;
start = clock();
//element_wise_mmul(OP, IP, WT, batch_size);
end = clock();

dim3 dimGrid(batch_size,96,1);
dim3 dimBlock(28,28,1);
//gpu_start = clock();
ew_gpu_mmul<<<dimGrid, dimBlock>>>(OPG,IP,WT,55,55,4,227,11,96,batch_size,3);
cudaDeviceSynchronize();
//gpu_end = clock();
//cudaMemcpy(OPG,d_o, batch_size*M*E*F*sizeof(float), cudaMemcpyDeviceToHost);
/***NAIVE 7 LAYER LOOP IMPLEMENTATION***/
/*
int n,m,x,y,i,j,k;
for (x=0; x<F; x++){
	for(y=0; y<E; y++){
		OP[x][y] = 0; // adding bias to output
		for (i=0; i<R; i++){
			for (j=0; j<S; j++){
				OP[x][y] += IP[U*x+i][U*y+j]*WT[i][j];
							}
						}
					}
   					}
	
*/

/**print outputs**/
//int e,f,g,h;
int g,h,s,u;
float max_error=0;
string filename = "layer_1_"+to_string(batch_size);
ifstream fin(filename.c_str());
string line ;


for (u=0;u<batch_size;u++){
for (s=0;s<M;s++){
for (g=0; g<F; g++){
	for(h=0; h<E; h++){
	getline(fin,line);
        float error = abs(OPG[u*M*F*E+s*E*F+g*E+h]-atof(line.c_str()));
	//float error = abs(OPG[u*M*F*E+s*E*F+g*E+h]-OP[u*M*F*E+s*E*F+g*E+h]);
	if(error > max_error)
	max_error = error;
//	printf("inside loop\n");	
//       printf("the output is %f for index %d, %d,%d,%d.\n",OP[u*M*F*E+s*E*F+g*E+h],u,s,g,h);
  //     printf("diff CPU and GPU is %f for index %d,%d,%d,%d.\n", OPG[u*M*F*E+s*E*F+g*E+h]-OP[u*M*F*E+s*E*F+g*E+h],u,s,g,h);
    //   printf("the output from GPU  is %f for index %d,%d,%d,%d.\n",OPG[u*M*F*E+s*E*F+g*E+h],u,s,g,h);
}
}
}
}
fin.close();
printf("max error %f\n", max_error);
//cout<<"time taken by cpu call is "<<((double)(cpu_end-cpu_start))/CLOCKS_PER_SEC<<"secs"<<endl;
//cout<<"time taken by gpu call is "<<((double)(gpu_end-gpu_start))/CLOCKS_PER_SEC<<"secs"<<endl;

//cudaFree(d_o);
//cudaFree(d_i);
//cudaFree(d_w);
cudaFree(OPG);
cudaFree(IP);
cudaFree(WT);
cudaFree(OP);	
return 0;
}

