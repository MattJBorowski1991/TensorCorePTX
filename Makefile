NVCC ?= nvcc

NVCC_FLAGS = -O3 -lineinfo --std=c++17 -Xcompiler -Wall --use_fast_math

.DEFAULT_GOAL := all

MAXRREGCOUNT ?=
ifeq ($(MAXRREGCOUNT),)
	NVCC_REGCOUNT =
else
	NVCC_REGCOUNT = -maxrregcount=$(MAXRREGCOUNT)
endif

NVCC_ARCH ?= 89

NVCC_GENCODE = 	-gencode arch=compute_$(NVCC_ARCH),code=sm_$(NVCC_ARCH) \
				-gencode arch=compute_$(NVCC_ARCH),code=compute_$(NVCC_ARCH)

INCLUDE_FLAGS = -I.

SRC_DIR     = src
KERNELS_DIR = kernels
BIN_DIR     = bin

KERNEL ?= fp16_wmma

PROFILE_WARMUPS ?= 2
PROFILE_RUNS ?= 10

NCU ?= ncu
NCU_SET ?= full
NCU_FLAGS ?=

TARGET = $(BIN_DIR)/profile_$(KERNEL)

BASE_SRCS = $(SRC_DIR)/main.cu \
            $(SRC_DIR)/solver.cu \
            $(SRC_DIR)/data.cu

KERNEL_SRCS = $(KERNELS_DIR)/$(KERNEL).cu

SRC = $(BASE_SRCS) $(KERNEL_SRCS)

.PHONY: all run profile profile-ncu clean

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(TARGET): $(SRC) | $(BIN_DIR)
	$(NVCC) $(NVCC_FLAGS) $(NVCC_REGCOUNT) $(NVCC_GENCODE) $(INCLUDE_FLAGS) $(SRC) -o $(TARGET)

all: $(TARGET)

run: $(TARGET)
	./$(TARGET)

# ncu — full metric set, output to terminal
profile: $(TARGET)
	$(NCU) --set=$(NCU_SET) $(NCU_FLAGS) ./$(TARGET)

# ncu — same but explicit target alias for clarity
profile-ncu: $(TARGET)
	$(NCU) --set=$(NCU_SET) $(NCU_FLAGS) ./$(TARGET)

clean:
	rm -rf $(BIN_DIR)
	rm -f $(KERNELS_DIR)/*.o $(SRC_DIR)/*.o


