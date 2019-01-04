module img4d.img4d;
import img4d_lib.decode,
       img4d_lib.encode,
       img4d_lib.filter,
       img4d_lib.color_space,
       img4d_lib.edge;

import std.stdio,
       std.array,
       std.bitmanip,
       std.conv,
       std.algorithm,
       std.range,
       std.math,
       std.range.primitives,
       std.algorithm.mutation,
       std.file : exists;

int lengthPerPixel;

enum filterTypes{
    None,
    Sub,
    Up,
    Average,
    Paeth
}

enum colorTypes{
    grayscale,
    trueColor = 2,
    indexColor,
    grayscaleA,
    trueColorA = 6,
}

struct Header {

    this(in int width, in int height, in int bitDepth, in int colorType,
        in int compressionMethod, in int filterMethod, in int interlaceMethod, ubyte[] crc){
        
        _width              = width;
        _height             = height;
        _bitDepth           = bitDepth;
        _colorType          = colorType;
        _compressionMethod  = compressionMethod;
        _filterMethod       = filterMethod;
        _interlaceMethod    = interlaceMethod;
        _crc                = crc; 
    }
    
    @property{
        void width(ref int width){ _width = width;}
        void height(ref int height){ _height = height; }
        void bitDepth(ref int bitDepth){ _bitDepth = bitDepth; }
        void colorType(int colorType){ _colorType = colorType; }
        void compressionMethod (ref int compressionMethod){ _compressionMethod = compressionMethod; }
        void filterMethod(ref int filterMethod){ _filterMethod = filterMethod; }
        void interlaceMethod(ref int interlaceMethod){ _interlaceMethod = interlaceMethod; }
        void crc(ref ubyte[] crc){_crc = crc;}

        int width(){ return _width; }
        int height(){ return _height; }
        int bitDepth(){ return  _bitDepth; }
        int colorType(){ return  _colorType; }
        int compressionMethod (){ return  _compressionMethod; }
        int filterMethod(){ return  _filterMethod; }
        int interlaceMethod(){ return  _interlaceMethod; }
        ubyte[] crc(){ return  _crc; }
    }

    private:
        int   _width,
              _height,
              _bitDepth,
              _colorType,
              _compressionMethod,
              _filterMethod,
              _interlaceMethod;
        ubyte[] _crc;
}

struct Pixel{
    this(ref ubyte[][] R, ref ubyte[][] G, ref ubyte[][] B){
        _R = R;
        _G = G;
        _B = B;
    }
    this(ref ubyte[][] R, ref ubyte[][] G, ref ubyte[][] B, ref ubyte[][] A){
        _R = R;
        _G = G;
        _B = B;
        _A = A;
    }

    this(ref ubyte[][] grayscale){
        _grayscale = grayscale;
    }

    @property{
        void R(ref ubyte[][] R){ _R = R; }
        void G(ref ubyte[][] G){ _G = G; }
        void B(ref ubyte[][] B){ _B = B; }
        void A(ref ubyte[][] A){ _A = A; }
        void grayscale(ref ubyte[][] grayscale){ _grayscale = grayscale; }

        ubyte[][] R(){ return _R; }
        ubyte[][] G(){ return _G; }
        ubyte[][] B(){ return _B; }
        ubyte[][] A(){ return _A; }

        ubyte[][] Pixel(){
            if(!_RGB.empty) return _RGB;
            
            if(A.empty){
                _R.each!((idx,a) => 
                      a.each!((edx,b) => 
                          _tmp ~= [_R[idx][edx], _G[idx][edx], _B[idx][edx]]
                              )
                        );
                _RGB = _tmp.chunks(_R[0].length*3).array;
            }else{
                _R.each!((idx,a) => 
                      a.each!((edx,b) => 
                          _tmp ~= [_R[idx][edx], _G[idx][edx], _B[idx][edx], _A[idx][edx]]
                              )
                        );
                _RGB = _tmp.chunks(_R[0].length*4).array;
            }
            return _RGB;
        }

        ubyte[][] grayscale(){ return _grayscale; }
    }

    private:
        ubyte[][] _R, _G, _B, _A, _RGB, _grayscale;
        ubyte[] _tmp;
}

Pixel decode(ref Header header, string filename){
    if(!exists(filename))
        throw new Exception("Not found the file.");
    ubyte[][][] rgb, joinRGB;
    auto data = parse(header, filename);
    
    Pixel pixel;
    if(header.colorType == colorTypes.grayscale || header.colorType == colorTypes.grayscaleA){
        alias grayscale = data;
        pixel = Pixel(grayscale);
        return pixel;
    }
    
    data.each!(a => rgb ~= [a.chunks(lengthPerPixel).array]);
    rgb.each!(a => joinRGB ~= a.front.walkLength.iota.map!(i => transversal(a, i).array).array);
    auto pix = joinRGB.transposed;
    ubyte[][] R = pix[0].array.to!(ubyte[][]);
    ubyte[][] G = pix[1].array.to!(ubyte[][]);
    ubyte[][] B = pix[2].array.to!(ubyte[][]);
    ubyte[][] A = pix[3].array.to!(ubyte[][]);
    
    if(header.colorType == colorTypes.trueColor || header.colorType == colorTypes.indexColor){
        pixel = Pixel(R, G, B);
    }else{
        pixel = Pixel(R, G, B, A);
    }
    return pixel;
}

ubyte[] encode(Header header, Pixel pix){
    auto data = header.makeIHDR ~ pix.makeIDAT(header) ~ makeIEND;
    return data;
}

// Canny Edge Detection (Defective)
auto canny(T)(T[][] actualData, int tMin, int tMax){
    double[][] gaussian = [[0.0625, 0.125, 0.0625],
                          [0.125, 0.25, 0.125],
                          [0.0625, 0.125, 0.0625]];
    double[][] sobelX = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]];
    double[][] sobelY = [[-1, -2, -1], [0, 0, 0],[1, 2, 1]];

    auto G  = actualData.differential(gaussian);
    auto Gx = G.differential(sobelX);
    auto Gy = G.differential(sobelY);
    double[][]  Gr = minimallyInitializedArray!(double[][])(Gx.length, Gx[0].length);
    double[][]  Gth= minimallyInitializedArray!(double[][])(Gx.length, Gx[0].length);

    foreach(idx; 0 .. Gx.length){
        foreach(edx; 0 .. Gx[0].length){
            Gr[idx][edx]  = sqrt(Gx[idx][edx].pow(2)+Gy[idx][edx].pow(2));
            Gth[idx][edx] = ((atan2(Gy[idx][edx], Gx[idx][edx]) * 180) / PI); 
        }
    }

    auto approximateG = Gr.gradient(Gth);
    auto edge = approximateG.hysteresis(tMin, tMax);

    return edge;
}

Pixel rgbToGrayscale(T)(T[][][] color){ return color.toGrayscale; }

auto toBinary(T)(ref T[][] gray, T threshold=127){
    // Simple thresholding 

    T[][] bin;
    gray.each!(a =>bin ~=  a.map!(b => b < threshold ? 0 : 255).array);
    return bin;
}

auto toBinarizeElucidate(T)(T[][] array, string process="binary"){
    uint imageH = array.length;
    uint imageW = array[0].length;
    int vicinityH = 3;
    int vicinityW = 3;
    int h = vicinityH / 2;
    int w = vicinityW / 2;
    
    auto output = minimallyInitializedArray!(typeof(array))(imageH, imageW);
    output.each!(a=> fill(a,0));
    
    foreach(i; h .. imageH-h){
        foreach(j;  w .. imageW-w){
            if (process=="binary"){
                int t = 0;
                foreach(m; 0 .. vicinityH){
                    foreach(n; 0 .. vicinityW){      
                        t += array[i-h+m][j-w+n];
                    }
                }
                if((t/(vicinityH*vicinityW)) < array[i][j]) output[i][j] = 255;
            }              
            else if(process == "median"){
                T[] t;
                foreach(m; 0 .. vicinityH){
                    foreach(n; 0 .. vicinityW){      
                        t ~= array[i-h+m][j-w+n].to!T;
                    }
                }    
                output[i][j] = t.sort[4];
            }  
        }
    }
    return output;
}

auto differ(T)(ref T[][] origin, ref T[][] target){
    T[][] diff;
    origin.each!((idx,a) => diff ~=  (target[idx][] -= a[]).map!(b => abs(b)).array);

    return diff;
}

auto mask(T)(ref T[][][] colorTarget, ref T[][] gray){
    T[][] masked;
    masked.length = gray.length;
    gray.each!((idx,a)=> a.each!((edx,b) => masked[idx] ~= b==255 ? colorTarget[idx][edx] : [0, 0, 0]));
  
    return masked;
}
