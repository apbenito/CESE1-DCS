#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// Define the number of cores you want to simulate with
// Hint: You can use this to test your code with different number of cores
#ifndef NUM_CORES
    #define NUM_CORES 1
#endif

// Do not change the number of bins and letters per bin
#define NUM_BINS 7
#define N_LETTERS_PER_BIN 4

// ************************* Test Arrays *************************
const char arr[] = "programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors programming massively parallel processors"; 
// Output Data:
// Bin[0]: 500
// Bin[1]: 500
// Bin[2]: 600
// Bin[3]: 1000
// Bin[4]: 1000
// Bin[5]: 100
// Bin[6]: 100

// const char arr[] = "programming massively parallel processors";
// Output Data:
// Bin[0]: 5
// Bin[1]: 5
// Bin[2]: 6
// Bin[3]: 10
// Bin[4]: 10
// Bin[5]: 1
// Bin[6]: 1
// ****************************************************************

// Define the Global memory shared between all the cores
uint32_t *global_mem = (uint32_t*)0x20000004;
uint32_t *sync = (uint32_t *)0x20000000;        // Sync used to indicate program end


// Read the Core_ID
uint32_t read_hart_id(void) {
    uint32_t hart_id;
    asm volatile ("csrr %0, mhartid" : "=r"(hart_id));
    return hart_id;
}

// Loop until all the cores have updated their global-memory element
void sync_cores(){
    int done = 0;
    while(!done){
        done = 1;
        for(int i = 0 ; i < NUM_CORES * NUM_BINS; i++){
            if(global_mem[i] == -1){
                done = 0;
            }
        }    
    }  
}

// Pause the core until Sync is updated
// Required in simulation since GVSoC stops simulation once core has executed the program.
void pause_core(){
    while(*sync != 0);
    exit(0);
}

int main()
{
    // Read the core_id of the core executing the code
    uint32_t core_id = read_hart_id();

    // Set the global_memory bins of unused cores to 0 and pause the unused cores.
    // Each core owns NUM_BINS consecutive words, so only clear this core's own
    // bins; global_mem[core_id] would land in a used core's bins.
    if (core_id >= NUM_CORES){
        for (int i = 0; i < NUM_BINS; i++) {
            global_mem[core_id * NUM_BINS + i] = 0;
        }
        pause_core();
    }

    // Slice the array into NUM_CORES contiguous sections, like a CUDA kernel
    // with one block per core: the slice size is rounded up so every character
    // is covered, and the last slices may be shorter or empty.
    int arr_size = sizeof(arr) / sizeof(arr[0]);
    int arr_size_per_core = (arr_size + NUM_CORES - 1) / NUM_CORES;
    int start_index = core_id * arr_size_per_core;
    int end_index = start_index + arr_size_per_core;
    int local_counter[7] = {0, 0, 0, 0, 0, 0, 0};

    int bin_index;
    for (int i = start_index; i < end_index; i++) {
        // Protection from illegal memory access
        if (i >= arr_size) {
            break;
        }
        char c = arr[i];
        if (c >= 'a' && c <= 'z') {
            bin_index = (c - 'a') / N_LETTERS_PER_BIN;
            local_counter[bin_index]++;
        }
    }

    // Update of the global variable
    for (int i = 0; i < NUM_BINS; i++) {
        global_mem[core_id * NUM_BINS + i] = local_counter[i];
    }

    // Pause all cores except Core 0
    if(core_id != 0){
        pause_core();
    }

    // Synchronize all the cores
    sync_cores();

    // Calculate the final value of each bin by adding up the partial
    // histograms of all the used cores
    int final_count[7] = {0, 0, 0, 0, 0, 0, 0};
    for (int i = 0; i < NUM_CORES; i++) {
        for (int j = 0; j < NUM_BINS; j++) {
            final_count[j] += global_mem[i * NUM_BINS + j];
        }
    }

    // Print Final Value
    printf("Output Data:\n");
    for (int i = 0; i < NUM_BINS; i++){
        printf("Bin[%d]: %d\n", i, final_count[i]);
    }

    // Release the paused cores so that all the cores can terminate
    *sync = 0;

    return 0;
}
