/// For stuff with greater access
module jext.base;

private import std.conv, std.ascii;

public import std.stdio, std.string, std.conv, std.file;

public import jeca.all;

char g_cr = newline[0]; /// carrage(sp) return
char g_lf = newline[1]; /// line feed

Bmp[] g_bmpLetters; /// graphics for the letters
int g_width = 16, /// letter width
	g_height = 25; /// letter height

/// display box
struct Square {
	int xpos, /// x postion
		ypos, /// y postion
		width, /// width of square
		height; /// height of square
}
