import img4d;

int main(){
	Img4d img = new Img4d();
	Pixel original_pix = img.load("../../png_img/lena.png");
	Pixel transformed = original_pix;
	for(int i=20; i<120; i+=20){
		transformed = img.rotate(transformed, i);
		transformed = img.rotate(transformed, -i);
	}
	img.save(transformed, "../../png_img/affine_rotation.png");
	return 0;
}

