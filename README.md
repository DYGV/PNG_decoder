# img4d  
[![licence](https://img.shields.io/github/license/DYGV/img4d.svg)](https://img.shields.io/github/license/DYGV/img4d.svg) 
[![status](https://travis-ci.org/DYGV/img4d.svg?branch=master)](https://travis-ci.org/DYGV/img4d) 

PNG Decoder/Encoder/image processing with no dependencies.  
~~Please see current status on [commit page](https://github.com/DYGV/img4d/commits/master) or [dub page](https://code.dlang.org/packages/img4d)~~

**~~Please feel free to throw PRs or issues.~~**  

# Examples  
|original|grayscale|gamma correction|FT(power spectrum)|
|---|---|---|---|
|![lena](https://user-images.githubusercontent.com/8480644/65213958-208c2e80-dae3-11e9-9bb4-fc5b7b2618f3.png)|![gray_lena](https://user-images.githubusercontent.com/8480644/65214007-4285b100-dae3-11e9-95b8-d5863a2c0369.png)|![gamma_0.5](https://user-images.githubusercontent.com/8480644/65214075-7eb91180-dae3-11e9-950f-3d48cef34447.png)|![lena_psd](https://user-images.githubusercontent.com/8480644/65214083-8aa4d380-dae3-11e9-9fe8-b51dd6c7a582.png)|
## decode, convert to grayscale and encode
### import required modules
```D
import img4d;
```
### load(decode)
```D
Img4d img = new Img4d();
Pixel colorPix = img.load("png_img/lena.png");
```
### rgb to grayscale
```D
Pixel grayPix = img.rgbToGrayscale(colorPix);
```
### 
### save(encode)
```D
 bool encodedData = img.save(grayPix, "png_img/encoded_lena_1.png");
```    
# Package  
 [img4d](https://github.com/DYGV/img4d/blob/master/README.md#img4d)  
 
 [img4d_lib.decode](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libdecode)  
 
 [img4d_lib.encode](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libencode)  
  
 [img4d_lib.edge](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libedge)  
 
 [img4d_lib.fourier](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libfourier) 
 
 [img4d_lib.template_matching](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libtemplate_matching) 
   
[img4d_lib.quality_evaluation](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libquality_evaluation) 
   
## img4d
-  **ref auto load(string filename)**  
-  **ubyte[] save(ref Pixel pix, string filename)**  
-  **bool save(ref Pixel pix, string filename, ubyte[] ancillary_chunks)** 
-  **bool isGrayscale(int colorType)**
-  **auto canny(T)(T[][] actualData, int tMin, int tMax)**  
-  **ref auto rgbToGrayscale(T)(ref Pixel pix, bool fastMode=false)**  
-  **pure auto differ(T)(ref T[][] origin, ref T[][] target)**  
-  **pure auto mask(T)(ref T[][][] colorTarget, ref T[][] gray)**  
-  **Complex!(double)[][] dft(ubyte[][] data, Header hdr)** 
-  **Complex!(double)[][] lpf(Complex!(double)[][] dft_matrix, int radius = 50)** 
-  **Complex!(double)[][] hpf(Complex!(double)[][] dft_matrix, int radius = 50)** 
-  **Complex!(double)[][] bpf(Complex!(double)[][] dft_matrix, int radius_low = 20, int radius_high = 50)** 
-  **ubyte[][] psd(Complex!(double)[][] dft_matrix)** 
-  **int[ubyte] pixelHistgram(ubyte[][] data)** 
-  **ubyte[][] gammaCorrection(ubyte[][] data, double gamma)** 
-  **auto rectangle(ref ubyte[][] src, int[] pos, int[] size)** 
-  **auto templateMatching(Header templateHeader, Header inputHeader, ubyte[][] templateImage, ubyte[][] inputImage, int type)** 
-  **auto qualityEvaluation(ubyte[][] img_reference, ubyte[][] img_evaluation, QualityEvaluationType type)**  
  
## img4d_lib.decode  
-  **Header readIHDR(ubyte[] header)**  
Set Header struct and Return its struct  
   - ***Params:***  
ubyte[] header: Header byte-data  
  
- **int byteToInt(T)(T[] data)**  
Return ChunkData-length(Convert byte array to int)   
  
- **string byteToString(T)(T[] data)**  
Return Chunk Type(Convert byte array to string)   
  
- **ubyte[] readIDAT(ubyte[] data)**  
Calculate CRC and Return IDAT Chunk-Data  
   - ***Params:***  
ubyte[] data : IDAT array expect for Chunk-Data-Size  
  
- **void crcCheck(ubyte[] crc, in ubyte[] chunk)**  
The function of CRC calculation  
  - ***Params***  
ubyte[] crc : The CRC code at the end of the chunk  
ubyte[] chunk : Byte array to be CRC calculated  
  
- **int paethPredictor(int left, int upper, int upperLeft)**  
Calculate and Return Paeth-Predictor  
- **int normalizePixelValue(int value)**  
Return the value which are subtracted 256 if it exceeds 256  
- **auto ubyte[][] inverseFiltering(ref ubyte[][] data, bool gray = false)**  
- **ubyte[][] parse(ref Header info, string filename)**  
## img4d_lib.encode  

-  **void set32bitInt(ref ubyte[4] buf, uint data)** 
-  **void set32bitInt(ref ubyte[2] buf, uint data)** 
-  **uint read32bitInt(in ubyte[] buf)** 
-  **auto makeChunk(ubyte[] chunk_type, ubyte[] chunk_data)**
-  **ubyte[] makeIHDR()**  
Return IHDR which required for encoding  
- **ubyte[] makeIDAT()**  
Return IDAT which required for encoding  
- **auto makeAncillary(int chunk_length, ubyte[] chunk_type, ubyte[] chunk_data)**  
- **ubyte[] makeIEND()**  
Return IEND which required for encoding  
- **auto makeCrc(ubyte[] data)**  
Calculate and Return CRC value  

- **int[] sumScanline(ref ubyte[][] src)**  
Cast to int[] and Calculate sum every horizontal line  
- **ubyte[][] chooseFilterType()**  
Choose optimal filter and Return filtered pixel

## img4d_lib.filter  
- **pure ref auto inverseSub(ref ubyte[][] scanline)**  
- **pure ubyte[][] sub(ref ubyte[][] src)**  
Calculate and Return Sub filter(Difference from left pixel)
- **pure ubyte[][] up(ref ubyte[][] src)**  
- **ubyte[][] ave(string op, string variable)(ubyte[][] src)**  
- **ubyte[][] paeth(string op, string variable)(ubyte[][] src)**  
- **pure ref auto joinVertical(T)(ref T[][] src)**  
Make array vertical
   
## img4d_lib.edge  
- **auto differential(T)(T[][] array, T[][] filter)**  
- **auto gradient(T)(T[][] Gr, T[][] Gth)**  
- **auto hysteresis(T)(T[][] src, int t_min, int t_max)**  
 
## img4d_lib.fourier  
-  **Complex!(double)[] _dft(Complex!(double)[] data, int num)**  
-  **Complex!(double)[][] transpose(Complex!(double)[][] matrix, int h, int w)** 
-  **ubyte[][] shift(ubyte[][] data, int h, int w)**  
 
## img4d_lib.template_matching
-  **this(Header templateHeader, Header inputHeader, ubyte[][] templateImage, ubyte[][] inputImage)**  
-  **int[] SSD**  
Sum of Squared Difference
-  **int[] SAD**  
Sum of Absolute Difference
-  **int[] NCC**  
Normalized Cross Correlation
-  **int[] ZNCC**  
Zero means Normalized Cross Correlation

## img4d_lib.quality_evaluation
-  **this(Header hdr, ubyte[][] img_reference, ubyte[][] img_evaluation)**  
-  **double PixelSquare(ubyte[][] img)**  
calculate squared sum of each pixel
-  **double SE()**  
Squared Error
-  **double MSE()**  
Mean Squared Error
-  **double NormalizedMSE()**  
Normalized Squared Error
-  **double SNR()**  
Signal-to-Noise Ratio
-  **double PSNR()**  
Peak signal-to-noise ratio
-  **auto MSSIM()**  
Mean Structural SIMilarity
