# img4d  
[![licence](https://img.shields.io/github/license/DYGV/img4d.svg)](https://img.shields.io/github/license/DYGV/img4d.svg) 
[![status](https://travis-ci.org/DYGV/img4d.svg?branch=master)](https://travis-ci.org/DYGV/img4d) 

PNG images Decoder/Encoder for D language.  
Please see current status on [commit page](https://github.com/DYGV/img4d/commits/master) or [dub page](https://code.dlang.org/packages/img4d)  

**Please feel free to throw PRs or issues.**  

# Examples  
## decode, convert to grayscale and encode
### import some required modules
```D
import img4d;
import std.stdio,
       std.range,
       std.algorithm.iteration;
```
### load(decode)
```D
Header hdr;
Pixel colorPix = hdr.load("png_img/lena.png");
```
### rgb to grayscale
```D
Pixel grayPix = hdr.rgbToGrayscale(colorPix, true);
hdr.colorType = colorTypes.grayscale;
```
### 
### save(encode)
```D
bool encodedData = hdr.save(grayPix, "png_img/encoded_lena.png");
```    
# Package  
 [img4d](https://github.com/DYGV/img4d/blob/master/README.md#img4d)  
 
 [img4d_lib.decode](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libdecode)  
 
 [img4d_lib.encode](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libencode)  
 
 [img4d_lib.color_space](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libcolor_space)  
 
 [img4d_lib.edge](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libedge)  
 
 [img4d_lib.dft](https://github.com/DYGV/img4d/blob/master/README.md#img4d_libdft) 
   
## img4d
-  **ref auto load(ref Header header, string filename)**  
-  **ubyte[] save(ref Header header, ref Pixel pix, string filename)**  
-  **bool save(ref Header header, ref Pixel pix, string filename, ubyte[] ancillary_chunks)** 
-  **bool isGrayscale(int colorType)**
-  **bool isColorNoneAlpha(int colorType)**
-  **auto canny(T)(T[][] actualData, int tMin, int tMax)**  
-  **ref auto rgbToGrayscale(T)(ref Header header, ref Pixel pix, bool fastMode=false)**  
-  **pure auto toBinary(T)(ref T[][] gray, T threshold=127)**  
-  **pure auto toBinary(T)(T[][] array)**  
-  **pure auto differ(T)(ref T[][] origin, ref T[][] target)**  
-  **pure auto mask(T)(ref T[][][] colorTarget, ref T[][] gray)**  
- **ubyte[][] psd(ubyte[][] data, ref Header hdr)** 
-  **int[ubyte] pixelHistgram(ubyte[][] data)** 
-  **ubyte[][] gammaCorrection(Header hdr, ubyte[][] data, double gamma)** 
  
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
- **ref auto inverseSub(ref ubyte[][] scanline, bool gray)**
- **pure ubyte[][] sub(ref ubyte[][] src)**  
Calculate and Return Sub filter(Difference from left pixel)
- **pure ubyte[][] up(ref ubyte[][] src)**  
- **pure ubyte[][] neighborDifference(ubyte[][] src)**  
Calculate difference neighbor pixel
- **pure ref auto joinVertical(T)(ref T[][] src)**  
Make array vertical

- **auto inverseUp()**  
- **auto ave()**  
- **auto inverseAve()**  
- **auto paeth()**  
- **auto inversePaeth()**  
## img4d_lib.color_space  
- **ref auto toGrayscale(T)(ref T[][][] color)**  
Convert to grayscale by weighting  
## img4d_lib.edge  
- **auto differential(T)(T[][] array, T[][] filter)**  
- **auto gradient(T)(T[][] Gr, T[][] Gth)**  
- **auto hysteresis(T)(T[][] src, int t_min, int t_max)**  
 
## img4d_lib.dft
-  **Complex!(double)[] dft(Complex!(double)[] data, int num)**  
-  **Complex!(double)[][] transpose(Complex!(double)[][] matrix, int h, int w)** 
-  **ubyte[][] shift(ubyte[][] data, int h, int w)**
