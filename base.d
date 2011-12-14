/+
 + //dmd myfile.d -L-Lpath/to/libs -L-lmylib 
 + dmd myfile.d -L+path/to/libs mylib.lib
 + 
 + D script is my handy tool - Andrej
 + 
 + rdmd {params for dmd and rdmd} main.d {params for main.exe}
 +/
/// For stuff with greater access
module jext.base;

private:
import std.stdio, std.string, std.conv, std.file, std.ascii;
import jeca.all;

public:
enum g_Draw {text, input}; /// switch for weather to draw text, or cursor

char g_cr = newline[0]; /// carrage(sp) return
char g_lf = newline[1]; /// line feed - main one

/+
Bmp[] g_bmpLetters; /// graphics for the letters
int g_width = 16, /// letter width
	g_height = 25; /// letter height
+/
	
/// display box
struct Square {
	int xpos, /// x postion
		ypos, /// y postion
		width, /// width of square
		height; /// height of square
}
