//#not work
//#maths
//#what's this! - the goto has got to go!
//#that is set lock all to true or false
//#what's this step thing (wrong sizes)
//#exit
//#ALLEGRO_PIXEL_FORMAT_ANY undefined
/**
 * This program uses:
 * 
 * The D Programming language - http://www.d-programming-language.org
 * 
 * Allegro 5.0 - http://alleg.sourceforge.net
 * 
 * DAllegro5 - https://github.com/SiegeLord/DAllegro5  
 * 
 * JECA: (thin DAllegro wrapper -  https://github.com/joelcnz/Jeca
 */
module jtexttest;

//version = Maths;
version = NotePad;
//version = NotePad2;

//version = FrameCounter;

version( Windows ) {
	pragma( lib, "liballegro5" );
	pragma( lib, "libdallegro5" );
	pragma( lib, "libjeca" );
}

import std.stdio;
import std.string;
import std.file;
import std.conv;
import std.datetime;
import std.algorithm: reduce, map;
import std.range: array;

import jeca.all;
import jext.all;

string fileName = "jecatext.txt";

/**
 * Program entry point
 */
void main( string[] args ) {
	// display printing characters
	version( Terminal ) {
		foreach( c; 32 .. 128 )
			write( cast(char)c );
		writeln();
	}

	Init( "-wxh 640 480".split() ~ args );
	scope( exit ) Deinit( "Hey! I was writing a book!" );
	
	FONT = al_load_ttf_font( toStringz( "DejaVuSans.ttf" ), 36, 0 );

	assert( FONT );

/+
	class FontSelect {
		enum {first, second, third, fourth, fifth};
		string[] fonts;
		int fontIndex;
		Bmp lettersSource;
		this( int fontIndex ) {
			fonts = "ddrolive ddrocr lemgreen epicpinjec jaltext".split;
			if ( fontIndex < 0 || fontIndex >= fonts.length ) {
				writeln( "Font defaulting" );
				fontIndex = first;
			}
		}

		void loadBitmap() {
			lettersSource = Bmp.loadBitmap( `fonts\` ~ fonts[ fontIndex ] ~ `.bmp` );
		}

		void setUp() {
			
		}
	}

	struct Font {
		string name;
		int width, height;
		struct Alpha {
			bool convertToAlpha;
			int offx, offy;
			Bmp[] bmpLetters;
		}
		Alpha alpha;
	}
	auto fonts = [Font("ddrolive", 16, 16, Alpha() ), ];
+/

/+
file 'ddrolive.txt' as follows:
ddrocr.bmp
16 25 # charater dimentions
17 # loading step size
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~⌂
+/
	int width, height;
	auto fonts = "ddrolive.bmp ddrocr.bmp jaltext.bmp".split;
	enum first = 0, second = 1, third = 2;
	//int fontIndex = first;
	int fontIndex = second;
	//int fontIndex = third;
	switch(fontIndex) {
		default:
		break;
		case third:
			width = 16;
			height = 16;
		break;
		case second:
			width = 16;
			height = 25;
		break;
	}
	
	auto lettersSource2 = Bmp.loadBitmap(fonts[second]);
	//al_convert_mask_to_alpha( lettersSource, al_get_pixel( lettersSource, 1, 0 ) );
	//if ( fontIndex == second )
	//	al_convert_mask_to_alpha( lettersSource, al_get_pixel( lettersSource, width + 1, 0 ) );
	
	//Do the maths version
	version( Maths ) {
		auto letterBaseMaths = new LetterManager(lettersSource, Square( 0, 0, DISPLAY_W, DISPLAY_H ),
			width, height);
		writeln("Made it this far!");
		maths( letterBaseMaths );
		return;
	} else { // do the note pad version
		width = 16;
		height = 25;
		auto mainText = new LetterManager(Bmp.loadBitmap(fonts[third]),
											Square(0, 0, DISPLAY_W,
											DISPLAY_H - 25 * 3),
											16, 16);
		width = 16;
		height = 16;
		auto letterBase = new LetterManager(Bmp.loadBitmap(fonts[second]),
											Square(0, DISPLAY_H - height * 3, DISPLAY_W, height * 3),
											16, 25);

		with( mainText ) {
			//alternate = true;
		}

		
		if ( args.length > 1 && exists( args[ 1 ] ) )
			mainText.setText( cast(string)std.file.read( fileName = args[ 1 ] ) );

		if ( mainText.getText().length ==0 && exists( fileName ) )
			mainText.setText( readText( fileName ) );
			//mainText.setText( cast(string)std.file.read( "jecatext.txt" ) );

		scope( exit )
			std.file.write( fileName, mainText.getText() );
		
		Bmp stamp = new Bmp( DISPLAY_W, DISPLAY_H );
		scope( exit )
			clear( stamp );
			
		StopWatch sw;
		sw.start;
		uint frameCounter = 0, fps = uint.max;

		while( ! exitHandler.doKeysAndCloseHandling ) {
			//#ALLEGRO_PIXEL_FORMAT_ANY undefined
//			al_lock_bitmap( stamp.bitmap,
//				al_get_bitmap_format( stamp.bitmap ),
//				ALLEGRO_LOCK_WRITEONLY );
			//al_set_target_bitmap( stamp.bitmap );
			al_clear_to_color( makecol( 0, 0, 64 ) );

			/+
			version( NotePad ) {
				with( mainText )
					draw( g_Draw.text );//,
					//draw( g_Draw.input );
			}
			+/
			version( NotePad2 ) {
				with( mainText )
					draw( g_Draw.text ),
					draw( g_Draw.input );
				with( letterBase )
					draw( g_Draw.text ); //,
					//draw( g_Draw.input );
			} else { //NotePad 1
				with( mainText )
					draw( g_Draw.text );
				with( letterBase )
					draw( g_Draw.text ),
					draw( g_Draw.input );
			}
			
//			with( letterBase )
//				draw( g_Draw.text );

			version( FrameCounter ) {
				++frameCounter;
				if ( sw.peek.msecs > 1_000 ) {
					fps = frameCounter;
					frameCounter = 0;
					sw.start;
				}
				al_draw_text(
					FONT,
					Colour.amber,
					0, DISPLAY_H / 2,
					/* flags: */ ALLEGRO_ALIGN_LEFT,
					toStringz( text( "FPS: ", fps, " frames: ", frameCounter, " hnsecs: ", sw.peek.hnsecs ) )
				);
			}
			
			al_set_target_backbuffer( DISPLAY );
			//al_draw_bitmap( stamp.bitmap, 0, 0, 0 );
//			al_unlock_bitmap( stamp.bitmap );

			al_flip_display();
			
			if ( mainText.wait == true )
				poll_input_wait;

			with( mainText )
				update();

			version( NotePad ) {
				with( mainText )
					update();
				with( letterBase )
					doInput();
			} 
			version( NotePad2 ) {
				/+
				with( letterBase )
					doInput(),
					update();
				+/
				with( mainText )
					doInput(),
					update();
				if ( letterBase.wait == true )
					poll_input_wait;
			}
			
			version( NotePad2 ) {
				with( letterBase ) {
					if ( getText() == "Timothy" || 
						getText() == "Alan" || 
						getText() == "Hamish" ) {
						setText(
							"Oh, hello " ~ getText() ~ ", how are you?" );
					}
					//#exit
					if ( getText() == "exit" )
						break;

					if ( letters.length > 0 && letters[ count - 1 ].letter == g_lf ) {
						mainText.setText(
							mainText.getText() ~ getText() );
						setText( "" );
					}
				}
			} // notepad2
		}
	} // math else
}

/+
//#what's this step thing (wrong sizes)
Bmp[256] getLetters( ALLEGRO_BITMAP* bmp, in string order, int step ) {
	Bmp[256] letters;
	foreach( i; 0 .. 256 ) {
		if ( i >= 33 && i < 128 ) {
			letters[ i ] = Bmp.getBmpSlice(
				bmp,
				1 + (i - 33) * step, 1,
				g_width, g_height - 1,
				0, 0,
				0
			);
		} else {
			letters[ i ] = new Bmp( g_width, g_height );
		}
	}
	
	return letters;
}
+/

//version = SomeKindOfWrap;
version( SomeKindOfWrap ) {
/+
		if ( l.letter != 32 && inword == false )
			startWordIndex = i, inword = true;
		else if ( x > xpos + width && l.letter == 32 && inword == true ) {
				//startNewLine( startWordIndex ), inword = false;
				x = xpos;
				y += al_get_font_ascent( FONT ) +  al_get_font_descent( FONT );
				inword = false;
			}
+/
}

//#maths
version( Maths ) {
	import std.random;

	void maths( LetterManager jext ) {
		Bmp stamp = new Bmp( DISPLAY_W, DISPLAY_H );

		bool refresh() {
			al_clear_to_color( makecol( 0, 0, 64 ) );
			with( jext ) {
				al_lock_bitmap( stamp.bitmap,
					al_get_bitmap_format( stamp.bitmap ),
					ALLEGRO_LOCK_WRITEONLY );
				al_set_target_bitmap( stamp.bitmap );
				
				with( g_Draw )
					draw(text), //#access violation
					draw(input);
				
				al_set_target_backbuffer( DISPLAY );
				al_draw_bitmap( stamp.bitmap, 0, 0, 0 );
				al_unlock_bitmap( stamp.bitmap );

				al_flip_display();
				
				if ( wait == true )
					poll_input_wait;

				
				if ( count != 0
					&& letters[$-1].lock == false
					&& letters[$-1].letter == g_lf ) {
					return false;
				}

				doInput();
				update();
			} // with jext
			
			return true;
		}

		int[2] variables;
		string user;
		with( jext )
			addTextln( "Enter 'quit' to exit" );
		writeln("Hey, I haven't been here for a while!");
		
		int rand() { return uniform(0, 100); }
		for (;;) {
			//alias map!(rand) doRand;
			//variables=map!"a = rand"(array(variables)); //#not work
			foreach (ref v; variables)
				v=rand;
			int answer, guess;
			answer=reduce!"a+b"(variables); //variables[0]+variables[1];
			string problem;
			do {
				with( jext ) {
					setLockAll( false ); //#that is set lock all to true or false
					problem = getText() ~
						to!string( variables[0] ) ~ "+" ~ to!string( variables[1] )
						~ "=";
					writeln('"', problem, '"');
					//problem = "";
					
					jext.setText( problem );
					jext.setLockAll( true );
				}

				while( refresh() == true ) {
					if ( exitHandler.doKeysAndCloseHandling ) {
						jext.addText( newline );
						goto quit;
					}
				}
				with( jext )
					if ( problem.length < count() )
						user = getText()[ problem.length .. $ ].stripRight; //#maybe $ - 2, or stripRight

				if (user!="" && user[0]=='q')
					goto quit;
				if (isAValidNumber(user)==false) {
					with( jext )
						addTextln( "That wont do." );
					continue;
				}
				guess=parse!int(user); // User input
				if (guess==answer) {
					with( jext )
						addTextln( "Good" );
				}
				else {
					with( jext )
						addTextln( (guess > answer ? "Less than" : "Greater than" ) );
				}
			} while (guess!=answer);
		} //for
	quit: //#what's this! - the goto has got to go!
		with( jext )
			addText( "Ok then, see you later, do call again! :-)" ),
			setLockAll( true );
		while( refresh() == true ) { }
	}

	bool isAValidNumber(string testNumber) {
		if (testNumber.length==0)
			return false;
		foreach (chr; testNumber)
			if (chr<'0' || chr>'9')
				return false;
		return true;
	}
} // version maths
