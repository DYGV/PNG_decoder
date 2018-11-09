import img4d;
import std.stdio,
       std.range,
       std.algorithm.iteration;
int main(){
    PNG_Header png;
    int[][][] actual_data;
    auto parsed_data = parse(png, "../png_img/lena.png");
    parsed_data.each!(n  => actual_data ~= n.chunks(length_per_pixel).array);
    
    writefln("Width  %8d\nHeight  %7d",
          png.width,
          png.height);
    writefln("Bit Depth  %4d\nColor Type  %3d",
          png.bit_depth, 
          png.color_type, 
          png.compression_method);
    

    // auto rgb_file = File("../png_img/rgb_lena.txt","w");
    // rgb_file.writeln(actual_data);

  /*
     covert to grayscale
   */
    auto gray = to_grayscale(actual_data);
    // auto gray_file = File("../png_img/gray_lena.txt","w");
    // gray_file.writeln(gray);

  /*
     convert to binary image by simple thresholding
   */
    auto bin = to_binary(gray);
    // auto bin_file = File("../png_img/bins_simple_lena.txt","w");
    // bin_file.writeln(bin);

  /*
     convert ot binary image by adaptive threshoding
   */
    auto bin_adaptive = to_binarize_elucidate(gray);
    // auto bin_adaptive_file = File("../png_img/bin_adaptive_lena.txt","w");
    // bin_adaptive.each!(a => bin_adaptive_file.writeln(a));
  

    auto median = to_binarize_elucidate(bin_adaptive, "median");
    auto median_filter_file = File("../png_img/median_filter_lena.txt","w");
    median.each!(a => median_filter_file.writeln(a));
    
    return 0;
}


