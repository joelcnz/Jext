//#page up
//#I do not know how!
//#setTextClipboard
//#draw
//#need more than that (eg g_cr as well)
//#unused
//#unused
//#unused
//#character adder
//#not sure about this/these
//#I think put in 'newline' instead of g_lf
//#I don't know if 'ref' does anything.
//#is this worth keeping?
//#not nice
/// Letter Manager
///
/// Handles printing and layout of letters also input
module jext.lettermanager;

import std.stdio;
import std.range;

import jeca.all;
import jext.all;

version = AutoScroll;

/// Letter Manager
class LetterManager {
private:
	Bmp[256] m_bmpLetters; /// graphics for the letters
	int m_width, /// letter width
		m_height; /// letter height

	int m_pos;
	bool m_wait;
	//Bmp m_area;
	Letter[] m_letters;
	bool m_alternate;
	Square m_square;
	string m_copiedText;
public:
	enum TextType {block, line};
	TextType m_textType;
	@property ref auto letters() { return  m_letters; } /// get/set letters (Letter[])
	//@property ref auto area() { return m_area; } /// get/set bounds
	@property ref auto square() { return m_square; } /// get/set square (text box)
	@property ref auto alternate() { return m_alternate; } /// get/set alternating colours on or off
	@property auto count() { return letters.length; } /// get number of letters (including white space)
	@property ref auto pos() { return m_pos; } /// access cursor position
	@property ref auto wait() { return m_wait; } /// access cursor position
	@property ref auto copiedText() { return m_copiedText; } /// access copiedText (string)
	@property ref auto width() { return m_width; } /// letters width
	@property ref auto height() { return m_height; } /// letters height
	@property ref auto bmpLetters() { return m_bmpLetters; } /// letters height
	
	
	/// ctor, setting area
	//this(in string lettersFile, Square square, int width0, int height0) {
	//	bmpLetters = getLetters(Bmp.loadBitmap( fonts[ fontIndex ] ););
	this(ALLEGRO_BITMAP* lettersSource, Square square, int width0, int height0) {
		width = width0;
		height = height0;
		writeln(width, ' ', height);
		bmpLetters = getLetters(lettersSource, null, width + 1);
		//debug mixin(traceLine("bmpLetters[0].width"));
		//setText( "" );
		pos = -1;
		this.square = square;
		with( square ) {
			//al_set_new_bitmap_flags( ALLEGRO_VIDEO_BITMAP ); // is by default
			//area = new Bmp( width, height );
		}
		//m_offx = m_offy = 0;
	}
	
	/// copy letters to bmps
	Bmp[256] getLetters(ALLEGRO_BITMAP* bmp, in string order, int step) {
		Bmp[256] tletters;
		if (order is null) {
			debug writeln("no order");
			foreach(i; 0..256) {
				if (i >= 33 && i < 128)
					tletters[i] = Bmp.getBmpSlice(
						bmp,
						1 + (i - 33) * step, 1,
						width, height - 1,
						0, 0,
						0
					);
				else
					tletters[i] = new Bmp(width, height);
				/+
				al_set_target_backbuffer(DISPLAY);
				float x = cast(float)i*width;
				al_draw_bitmap(tletters[i].bitmap, x % DISPLAY_W, cast(int)x/DISPLAY_W*height, 0);
				al_draw_line(x, 0f, x, 25*4, getColour("orange"), 1); //orange"), 1);
				+/
			}
		} else {
			debug writeln("Order");
			foreach(i; 0..256)
				tletters[i]=new Bmp(width, height);
			foreach(i, c; order) {
				clear(tletters[c]);
				tletters[c] = Bmp.getBmpSlice(
					bmp,
					i * step, 1,
					width, height - 1,
					0, 0,
					0
				);
				debug
					mixin( traceLine( "i step c".split ) );
			}
		}
		al_set_target_backbuffer( DISPLAY );
		al_flip_display();
		//poll_input_wait();
		
		return tletters;
	}

	/// dtor Deal with C allocated memory
	~this() {
		//clear( area ); // Clear the area!
	}
	
	/// set type of text (block, line)
	void setTextType( TextType textType ) {
		m_textType = textType;
	}

	/// Get letter using passed index number
	//#is this worth keeping?
	Letter opIndex(int pos) {
		assert( pos >= 0 && pos < count, "opIndex" );
		return letters[pos];
	}
	
	/// lock/unlock all letters
	void setLockAll( bool lock0 ) {
		foreach( l; letters )
			l.lock = lock0;
	}
	
	/// Add text with new line added to the end
	string addTextln( string str ) {
		string result = getText() ~ str ~ g_lf; //#I think put in 'newline' instead of g_lf
		setText( result );

		return result;
	}
	
	/// Add text without new line being added to the end
	void addText( string str ) {
		auto lettersStartLength = count;
		letters.length = lettersStartLength + str.length;
		foreach( index, l; str )
			letters[ lettersStartLength + index ] = new Letter(this,l);
		pos = count - 1;
		placeLetters();
	}

	/// apply text from string - also places text
	void setText( in string stringLetters ) {
		letters.length = 0; // clear letter array
		letters.length = stringLetters.length;
		foreach(index, l; stringLetters)
			letters[index] = new Letter(this,l);
		pos = cast(int)letters.length - 1;
		placeLetters();
	}

	/// Get converted text (string format)
	string getText() {
		auto str = new char[]( letters.length );
		foreach( index, ref l; letters ) { // ref for more speed
			str[ index ] = cast(char)l.letter;
		}

		return str.idup;
	}
	
	/// Postion text for display
	void placeLetters() {
		auto inword = false;
		auto startWordIndex = -1;
		ALLEGRO_COLOR[] altcols = [Colour.amber, getColour( "red" ) ];
		auto altcolcyc = 0;
		int x = 0, y = 0;
		foreach( i, ref l; letters ) {
			auto let = cast(char)l.letter;// jtoCharPtr( l.letter );
			// if do new line
			if ( x + width > square.xpos + square.width || let == g_lf ) {
				x = ( let == g_lf ? -width : 0 );
				y += height;
				if ( alternate == true ) {
					altcolcyc |= 1; // or should it be altcolcyc ^= 1; //( altcolcyc == 0 ? 1 : 0 );
				}
				version( AutoScroll ) {
					if ( y + height > square.ypos + square.height) {
						foreach( l2; letters )
							l2.ypos -= height;
						y -= height;
					}
				}
			}
			l.setPostion( x, y );
			if ( alternate == true ) {
				l.alternate = true; //#not nice
				l.altColour = altcols[ altcolcyc ];
			}
			x += width;
		}
		
		//#I do not know how!
		/+
		if ( y < ypos )
			foreach( l2; letters )
				l2.ypos -= height;
		+/
	}
	
	/// Eg. bouncing letters
	void update() {
		foreach( ref l; letters ) //#I don't think 'ref' does anything.
			l.update();
	}
	
	// array, start pos, step, delegate
	//int search( Letter[] arr, int stpos, int step, bool delegate ( Letter ) let ) {
	/// Check each letter starting from a curtain postion, going a curtain direction and not past a curtain limit
	int searchForProperty( int stpos, int step, int limit, bool delegate ( int ) dg ) {
		foreach( i; iota( stpos, limit, step ) )
			if ( dg( i ) == true )
				return i;
		return -1;
	}

	/// Main function for recieving key presses
	dchar doInput() {
		int c = 0;
		c = readkey();

		wait = false;
		void directional() {
			poll_input();

			bool pLock( int a ) {
				return letters[ a ].lock;
			}

			if ( key[ ALLEGRO_KEY_LCTRL ]  || key[ ALLEGRO_KEY_RCTRL ] ) {
				wait = true;
				
				if ( key[ ALLEGRO_KEY_C ] && count > 1 ) {
					int lastLocked = searchForProperty( count() - 1, -1, -1, 
						&pLock //#not sure about this/these
					);
					auto copy = getText()[ lastLocked + 1.. $ ];
					copiedText = copy;
					//#setTextClipboard
					//setTextClipboard( copy );
				}

				if ( key[ ALLEGRO_KEY_V ] ) {
					int i = searchForProperty(
						/+ start: +/ count - 1,
						/+ end: +/ -1,
						/+ step: +/ -1,
						/+ rule(s): +/ &pLock
					);
					debug
						mixin( traceLine( "/+ paste: +/ i" ) );
					letters.length = i + 1;
					addText( copiedText );
					//foreach( l; copiedText )
					//	letters ~= new Letter( l );
					
					/+
					setText( getText()[ 0 .. i + 1 ]
						~ copiedText );
					foreach( index;
						0 .. count - copiedText.length )
						letters[ index ].lock = true;
					+/
					pos = count - 1;
				}
				
				if ( key[ ALLEGRO_KEY_LEFT ] ) {
					if ( pos > -1 && letters[ pos ].lock != true ) {
						int i = 0;
						for( i = pos - 1;
							i > -1 && letters[ i ].letter != ' '
							&& letters[ i ].lock == false; --i )
						{}
						if ( pos > -1 )
							pos = i;
					}
				}
				if ( key[ ALLEGRO_KEY_RIGHT ] ) {
					int i = 0;
					for( i = pos + 1;
						i < letters.length &&
						letters[ i ].letter != ' ' ; ++i )
					{}
					if ( i < letters.length )
						pos = i;
					else
						pos = letters.length - 1;
				}
				
				if ( key[ ALLEGRO_KEY_HOME ] ) {
					int i = pos;
					for( i = pos; i > -1 && letters[ i ].lock == false; --i )
					{}
					pos = i;
				}

				if ( key[ ALLEGRO_KEY_END ] )
					pos = count - 1;

				if ( key[ ALLEGRO_KEY_BACKSPACE ] ) {
					int i;
					for( i = count() - 1;
						i >= 0 && letters[ i ].lock == false; --i )
					{}
					letters.length = i + 1;
					pos = i;
				}
			} else { // not control down
				if ( key[ ALLEGRO_KEY_LEFT ] && count > 0 ) {
					if ( pos - 1 > -2 )
						--pos;
					if ( letters[ pos + 1 ].lock == true )
						++pos;
					wait = true;
				}

				if ( key[ ALLEGRO_KEY_RIGHT ] ) {
					++pos;
					if ( pos >= letters.length  )
						--pos;
					wait = true;
				}
				
				if ( key[ ALLEGRO_KEY_HOME ] && pos >= 0 ) {
					int i = pos;
					for( ; i > 0 && letters[ i ].lock == false
						&& cast(int)letters[ i ].xpos != 0; --i ) { }
					pos = i - 1;
					wait = true;
				}
				
				if ( key[ ALLEGRO_KEY_END ] && pos < count - 1 ) {
					int hght = cast(int)letters[ pos > -1 ? pos + 1 : 1 ].ypos;
					auto offTheEnd = true;
					foreach( i; iota( pos, count, 1 ) ) {
						if ( letters[ i ].ypos != hght ) {
							if ( letters[ i ].xpos + width * 2 > square.width )
								i -= 2;
							else
								--i;
							pos = i;
							offTheEnd = false;
							break;
						}
					}
					if ( offTheEnd == true )
						pos = count - 1;
					wait = true;
				}

				if ( key[ ALLEGRO_KEY_UP ] && count > 0 && pos != -1 ) {
						if ( count - 1 > pos &&  cast(int)letters[ pos + 1 ].ypos == height 
							&& cast(int)letters[ pos ].xpos == 0 ) {
							pos = -1;
							goto ncKeyUpExit;
						}
						int lastPos = pos;
						int xpos = cast(int)letters[ pos ].xpos,
							ypos = cast(int)letters[ pos ].ypos - height;
						//int last = ypos; //#unused
						auto bingo = false;
						foreach( i, l; letters[ 0 .. pos ] ) {
							if ( l.xpos == xpos && l.ypos == ypos ) {
								pos = i;
								bingo = true;
								break;
							}
						} // foreach
						if ( bingo == false ) {
							foreach( i; iota( pos, -1, -1 ) )
								if ( letters[ i ].letter == g_lf ) {
									pos = i;
									if ( pos != 0 )
										--pos;
									break;
								}
						}
						if ( count > 0 && letters[ pos + 1 ].lock == true )
							pos = lastPos;
ncKeyUpExit:
					wait = true;
				} // key up
				
				if ( key[ ALLEGRO_KEY_DOWN ] && count > 0 && pos != -1 ) {
						int xpos = cast(int)letters[ pos ].xpos,
							ypos = cast(int)letters[ pos ].ypos + height;
						//int last = ypos; //#unused
						auto bingo = false;
						foreach( i, l; letters[ pos .. $ ] ) {
							if ( l.xpos == xpos && l.ypos == ypos ) {
								pos = pos + i;
								bingo = true;
								break;
							}
						} // foreach
						if ( bingo == false ) {
							for( int i = pos; i < letters.length; ++i ) {
								if ( ( ypos + height == letters[i].ypos &&
									letters[i].letter == g_lf )
									|| i == letters.length - 1 ) {
									pos = i;
									if ( i != letters.length - 1 && pos - 1 > -1 )
										--pos;
									break;
								}
							}
						}
					wait = true;
				} // key down
				
				if ( key[ ALLEGRO_KEY_PGDN ] ) {
					foreach( l; letters )
						l.ypos -= square.height;
					wait = true;
				}
				
//#page up
				if ( key[ ALLEGRO_KEY_PGUP ] ) {
					foreach( l; letters )
						l.ypos += square.height;
					/+
					//Trying to move the cursor too
					foreach( lines; 0 .. square.height / height )
						foreach( i; iota( pos, -1, -1 ) )
							if ( letters[ i ].letter == g_lf ) {
								if ( i > -1 ) {
									pos = i - 1;
								}
								break;
							}
					+/
					wait = /+ might possibly be true on wednesdays - Hamish +/ true;
				}

			} // if not control pressed
			
		}
		directional();

		if ( c ) {
			auto doPut = false;
			
			//#character adder
			if ( chr( c ) >= 32 && ! tkey( c, ALLEGRO_KEY_DELETE ) ) {
				doPut = true;
				//insert letter
				// pos = -1
				// Bd press a -> aBc
				// #              #
				//mixin( traceLine( "pos letters.length".split ) );
				letters = letters[ 0 .. pos + 1 ] ~
					new Letter(this,chr(c)) ~ letters[pos + 1 .. $];
				++pos;
				placeLetters();
			}
			
			if ( tkey( c, ALLEGRO_KEY_ENTER ) || tkey( c, ALLEGRO_KEY_PAD_ENTER ) ) {
				final switch ( m_textType ) {
					case TextType.block:
						//letters = letters[ 0 .. pos + 1 ] ~	new Letter( g_cr ) ~ new Letter( g_lf ) ~ letters[ pos + 1 .. $ ];
						letters = letters[ 0 .. pos + 1 ]
							~ new Letter(this, g_cr ) ~ new Letter(this, g_lf ) //#need more than that (eg g_cr as well)
							~ letters[ pos + 1 .. $ ];
						pos += 2;
						placeLetters();
					break;
					case TextType.line:
						letters ~= new Letter(this, g_lf); // now this sets the input
					break;
				} // switch
			}
			
			if ( tkey( c, ALLEGRO_KEY_BACKSPACE ) && pos > -1
				&& letters[ pos ].lock == false ) {
				doPut = true;
				version( Terminal )
					write( " \b" );
				letters = letters[ 0 .. pos ] ~ letters[ pos + 1 .. $ ];
				--pos;
				placeLetters();
			}
			
			//Suck - it sucks (letters that is)
			if ( tkey( c, ALLEGRO_KEY_DELETE )
				&& pos != count - 1 ) {
				// pos = 0
				// aBc press del -> aC
				//  #                #
				letters = letters[ 0 .. pos + 1 ] ~ letters[ pos + 2 .. $ ],
				placeLetters();
			}

			version( Terminal ) {
				if ( doPut ) 
					write( cast(char)c ~ "#\b" );
				std.stdio.stdout.flush;
			}
		}

		// This is for direction keys
		/+
		if ( m_wait ) {
			draw;
			al_flip_display;
			poll_input_wait();
		}
		+/
		
		return chr( c ); //#unused
	}
	
	/// Draw cursor
	void draw( g_Draw drawType ) {
		switch( drawType ) {
			default:
			break;
			case g_Draw.text: //#draw
				//debug writeln("text draw started..");
				/// Draw letters etc stuff in square area
				//auto bmp = al_get_target_bitmap();
				//al_set_target_bitmap( area.bitmap );
				//al_clear_to_color( Colour.black );
				/+
				with( square )
					al_draw_filled_rectangle( xpos, ypos, xpos + width, ypos + height, Colour.black );
				+/				
				/+
				al_draw_rectangle( 0.5, 0.5,
					al_get_bitmap_width( m_area.bitmap ), al_get_bitmap_height( m_area.bitmap ),
					Colour.white, 1 );
				+/
				if ( count > 0 )
					foreach( l; letters )
						l.draw( square );
				//al_set_target_bitmap( bmp );
				//with( square )
				//	al_draw_bitmap( area.bitmap, xpos, ypos, 0 );
				//debug writeln("text draw done!");
			break;
			case g_Draw.input:
				double xpos;
				double ypos;
				if ( letters.length > 0 && pos > -1 ) {
					xpos = letters[ pos ].xpos;
					ypos = letters[ pos ].ypos;
				} else {
					xpos = -width;
					ypos = 0;
				}
				if ( xpos + width >= DISPLAY_W )
					xpos = -width,
					ypos += height;
				al_draw_filled_rectangle(
					square.xpos + xpos + width,     square.ypos + ypos,
					square.xpos + xpos + width * 2, square.ypos + ypos + height,
					al_map_rgba( 128, 128, 128, 128 ) );
			break;
		} // switch
	}
}
