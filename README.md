# High-Capacity Reversible Data Hiding in Encrypted Images Based on Pixel Prediction and Zero-Subblock Pattern Coding

## Project Overview

This project implements a reversible data hiding algorithm for encrypted images. The algorithm combines pixel prediction, bit-plane rearrangement, data embedding and extraction, as well as image encryption and decryption.

## File Description

| Main Files
- `Main.m` - Main program entry point, demonstrating the complete algorithm workflow
- `Preprocess1.m` - Preprocessing Stage 1: bit-plane decomposition and rearrangement
- `Preprocess2.m` - Preprocessing Stage 2: determining embeddable regions and embedding
- `Encrypt_image.m` - mage encryption
- `Embed_data.m` - Data embedding in AZB regions
- `Embed_NUBdata.m` - Data embedding in NAZB regions using subblock pattern coding
- `Extract_UBdata.m` - Data extraction from AZB regions
- `Extract_NUBdata.m` - Data extraction from NAZB regions
- `decrypt_image.m` - Image decryption
- `Recover_image1.m` - Bit-plane recovery
- `Recover_image2.m` - Final image recovery

| Auxiliary Files
- `Binary_Decimalism.m` / `zf_Binary_Decimalism.m` - Binary-to-decimal conversion
- `Decimalism_Binary.m` / `zf_Decimalism_Binary.m` - Decimal-to-binary conversion
- `arith07.m` - Arithmetic coding
- `dec_transform_bin.m` - Decimal-to-binary stream conversion
- `eight_to_one.m` - Merging 8 bit-planes into one image
- `NUBjudge.m` - NUB region judgment
- `Datasets_ER.m` - Dataset embedding rate calculation

| Test Images
- `Testimages/` - Contains six standard test images: Airplane, Baboon, Jetplane, Man, Peppers, and Tiffany

## Algorithm Workflow

1. **Image Preprocessing**
   -  Pixel prediction: using MED and SGAP predictors to calculate prediction errors
   - Bit-plane decomposition: decomposing the image into 8 bit-planes
   - Block classification: classifying blocks in each bit-plane into AZB, all-zero blocks, and NAZB, non-all-zero blocks
   - Bit-plane rearrangement: rearranging NAZB blocks and AZB blocks
   - Auxiliary information compression: using arithmetic coding to compress prediction flags and other information
2. **Image Encryption**
   - Using pseudo-random sequences to encrypt image bit-planes
   - Optionally encrypting NAZB regions and AZB regions

3. **Data Embedding**
   - Embedding auxiliary information and secret data in AZB regions
   - Embedding additional secret data in NAZB regions using a subblock pattern coding method

4. **Data Extraction and Image Recovery**
   - Extracting embedded data from the encrypted marked image
   - Decrypting the image
   - Completely recovering the original image losslessly

## Usage

Run Main.m in MATLAB:

```matlab
Main
```

The program will:
1. Read the test image
2. Execute the complete data hiding, encryption, embedding, extraction, and recovery workflow
3. Display the original image, encrypted image, marked encrypted image, and recovered image
4. Display the histograms of each image
5. Output verification information such as embedding rate, data extraction accuracy, and PSNR
6. Verify whether the image is recovered losslessly

## Main Parameters

| Parameter| Description | Default Value |
|------|------|--------|
| `block_size` | Block size | 4 |
| `Image_key` | Image encryption key | 1 |
| `Data_key` | Data encryption key | 2 |
| `num` | Number of data bits to embed | 4000000 |

## Output Results

After running the program, the following information will be output:

- Embedding rate, bpp
- Extraction accuracy of AZB data and NAZB data
- PSNR value of image recovery
- Auxiliary information analysis, including bit-count analysis of each part
- Capacity and overhead analysis
- Verification of whether lossless recovery is achieved

## Features

- **Reversibility**：The original image can be completely recovered
- **High Capacity**：Embedding capacity is improved by combining AZB and NAZB regions
- **Subblock Pattern Coding**：A subblock pattern coding method is used for data embedding in NAZB regions
- **Security**：The image is protected through encryption
- **Verification Functionality**：A complete verification workflow ensures the correctness of the algorithm
