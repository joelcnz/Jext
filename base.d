private import std.conv, std.ascii;

public import std.stdio, std.string, std.conv, std.file;
public import jeca.all;

char g_lf = newline[1];

Bmp[] g_bmpLetters;
int g_width = 16,
	g_height = 25;

struct Square {
	int xpos, ypos, width, height;
}
