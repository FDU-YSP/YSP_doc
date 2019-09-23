#include<stdio.h>
#include<cuda_runtime.h>

bool init_cuda(){
	int count;
	cudaGetDeviceCount(&count);
	if(0 == count) {
		fprintf(stderr, "There is no device \n");
		return false;
	}

	int i;
	for(i = 0; i < count; i++) {
		cudaDeviceProp prop;
		if(cudaSuccess == cudaGetDeviceProperties(&prop, i)) {
			if(prop.major >= 1){
				break;
			}
		}
	}

	if(i == count){
		fprintf(stderr, "There is no device supporting CUDA 1.x.\n");
		return false;
	}

	cudaSetDevice(i);

	return true;
}

int main() {
	if(!init_cuda()) {
		return 0;
	}

	printf("CUDA initialize.\n");

	return 0;
}


