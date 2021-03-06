module img4d.img4d_lib.edge;

import std.stdio, std.array, std.conv, std.algorithm, std.range, std.math;
import std.range.primitives;
import std.algorithm.mutation;

auto differential(T)(T[][] array, T[][] filter){
	uint image_h = array.length;
	uint image_w = array[0].length;
	int vicinity_h = 3;
	int vicinity_w = 3;
	int h = vicinity_h / 2;
	int w = vicinity_w / 2;

	auto output = minimallyInitializedArray!(typeof(array))(image_h, image_w);
	output.each!(a => fill(a, 0));
	foreach (i; h .. image_h - h){
		foreach (j; w .. image_w - w){
			double t = 0;
			foreach (m; 0 .. vicinity_h){
				foreach (n; 0 .. vicinity_w){
					t += array[i - h + m][j - w + n] * filter[m][n];
				}
			}
			output[i][j] = t;
		}
	}
	return output;
}

auto gradient(T)(T[][] Gr, T[][] Gth){
	uint image_h = Gr.length;
	uint image_w = Gr[0].length;
	int vicinity_h = 3;
	int vicinity_w = 3;
	int y = vicinity_h / 2;
	int x = vicinity_w / 2;

	auto output = Gr.dup;

	foreach (h; y .. image_h - y){
		foreach (w; x .. image_w - x){
			auto theta = Gth[h][w];

			if (theta >= -22.5 && theta < 22.5)
				theta = 0;
			if (theta >= 157.5 && theta < 180)
				theta = 0;
			if (theta >= -180 && theta < -157.5)
				theta = 0;
			if (theta >= 22.5 && theta < 67.5)
				theta = 45;
			if (theta >= -157.5 && theta < -112.5)
				theta = 45;
			if (theta >= 67.5 && theta < 112.5)
				theta = 90;
			if (theta >= -112.5 && theta < -67.5)
				theta = 90;
			if (theta >= 112.5 && theta < 157.5)
				theta = 135;
			if (theta >= -67.5 && theta < -22.5)
				theta = 135;

			if (theta == 0){
				if (Gr[h][w] < Gr[h][w + 1] || Gr[h][w] < Gr[h][w - 1]){
					output[h][w] = 0;
				}
			}
			else if (theta == 45){
				if (Gr[h][w] < Gr[h - 1][w + 1] || Gr[h][w] < Gr[h + 1][w - 1]){
					output[h][w] = 0;
				}
			}
			else if (theta == 90){
				if (Gr[h][w] < Gr[h + 1][w] || Gr[h][w] < Gr[h - 1][w]){
					output[h][w] = 0;
				}
			}
			else{
				if (Gr[h][w] < Gr[h + 1][w + 1] || Gr[h][w] < Gr[h - 1][w - 1]){
					output[h][w] = 0;
				}
			}
		}
	}
	return output;
}

auto hysteresis(T)(T[][] src, int t_min, int t_max){
	int image_h = src.length;
	int image_w = src[0].length;
	int vicinity_h = 3;
	int vicinity_w = 3;
	int h = vicinity_h / 2;
	int w = vicinity_w / 2;
	auto output = src.dup;

	foreach (i; h .. image_h - h){
		foreach (j; w .. image_w - w){
			if (src[i][j] >= t_max){
				output[i][j] = 255;
			}
			else if (src[i][j] < t_min){
				output[i][j] = 0;
			}
			else{
				T[] temp;
				foreach (m; 0 .. vicinity_h){
					foreach (n; 0 .. vicinity_w){
						temp ~= src[i - h + m][j - w + n];
					}
				}
				if (temp.sort.back >= t_max){
					output[i][j] = 255;
				}
				else{
					output[i][j] = 0;
				}
			}
		}
	}
	return output;
}
