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

version = Maths;
//version = NotePad;

version( Windows ) {
	pragma( lib, "liballegro5" );
	pragma( lib, "libdallegro5" );
	pragma( lib, "libjeca" );
}

import jeca.all;
import jext.all;

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
	scope( exit ) Deinit();

/+
file 'ddrolive.txt' as follows:
ddrocr.bmp
16 25 # charater dimentions
17 # loading step size
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~⌂
+/
	auto fonts = "ddrolive.bmp ddrocr.bmp".split;
	enum first = 0, second = 1;
	int fontIndex = second;
	auto lettersSource = Bmp.loadBitmap( fonts[ fontIndex ] );
	al_convert_mask_to_alpha( lettersSource, al_get_pixel( lettersSource, 1, 0 ) );
	if ( fontIndex == 1 )
		al_convert_mask_to_alpha( lettersSource, al_get_pixel( lettersSource, g_width + 1, 0 ) );
	g_bmpLetters = getLetters(
		lettersSource, null, g_width + 1);
	
	//Do the maths version
	version( Maths ) {
		auto letterBaseMaths = new LetterBase(
			new LetterManager( Square( 0, 0, DISPLAY_W, DISPLAY_H ) ) );
		letterBaseMaths.text.setLetterBase( letterBaseMaths );
		letterBaseMaths.input.setLetterBase( letterBaseMaths );
		maths( letterBaseMaths );
		return;
	} else { // do the note pad version
		auto letterBase = new LetterBase(
			new LetterManager( Square( 0, DISPLAY_H - g_height * 3, DISPLAY_W, DISPLAY_H ) ) );

		letterBase.text.setLetterBase( letterBase );
		letterBase.input.setLetterBase( letterBase );
		
		auto mainText = new LetterBase(
				new LetterManager( Square( 0, 0, DISPLAY_W, DISPLAY_H - g_height * 3 ) )
		);

		with( mainText ) {
			text.setLetterBase( mainText ),
			input.setLetterBase( mainText );
			text.alternate = true;
		}

		if ( exists( "jecatext.txt" ) )
			mainText.text.setText( cast(string)std.file.read( "jecatext.txt" ) );

		scope( exit )
			if ( exists( "jecatext.txt" ) )
				std.file.write( "jecatext.txt", mainText.letterManager.getText() );
		
		Bmp stamp = new Bmp( DISPLAY_W, DISPLAY_H );
		scope( exit )
			clear( stamp );

		while( ! exitHandler.doKeysAndCloseHandling ) {
			//#ALLEGRO_PIXEL_FORMAT_ANY undefined
			al_lock_bitmap( stamp.bitmap,
				al_get_bitmap_format( stamp.bitmap ),
				ALLEGRO_LOCK_WRITEONLY );
			al_set_target_bitmap( stamp.bitmap );
			al_clear_to_color( Colour.red );

			version( NotePad ) {
				with( mainText )
					text.draw(),
					input.draw();
			} else {
				with( mainText )
					text.draw();
				with( letterBase )
					input.draw();
			}
			
			with( letterBase )
				text.draw();
			
			al_set_target_backbuffer( DISPLAY );
			al_draw_bitmap( stamp.bitmap, 0, 0, 0 );
			al_unlock_bitmap( stamp.bitmap );

			al_flip_display();
			
			with( mainText )
				text.update();

			version( NotePad ) {
				with( letterBase )
					text.update();
				with( mainText )
					input.doInput();
			} else {
				with( letterBase )
					input.doInput(),
					text.update();
			}
			
			version( NotePad ) {
			} else {
				with( letterBase ) {
					if ( text.getText() == "Timothy" || 
						text.getText() == "Alan" || 
						text.getText() == "Hamish" ) {
						text.setText(
							"Oh, hello " ~ text.getText() ~ ", how are you?" );
					}
					//#exit
					if ( text.getText() == "exit" )
						break;

					if ( text.letters.length > 0 && text[ text.count - 1 ].letter == g_lf ) {
						mainText.text.setText(
							mainText.text.getText() ~ text.getText() );
						text.setText( "" );
					}
				}
			} // not notepad
		}
	} // math else
}

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

			al_set_target_backbuffer( DISPLAY );
			al_draw_bitmap( bmp, 0, 0, 0 );
			al_draw_bitmap( letters[ i ].bitmap, (i - 33) * step, 32, 0 );
		} else {
			letters[ i ] = new Bmp( g_width, g_height );
		}
	}
	al_flip_display();
	
	return letters;
}

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

version( Maths ) {
	import std.random;

	void maths( LetterBase letterBase ) {
		Bmp stamp = new Bmp( DISPLAY_W, DISPLAY_H );

		bool refresh() {
			al_lock_bitmap( stamp.bitmap,
				al_get_bitmap_format( stamp.bitmap ),
				ALLEGRO_LOCK_WRITEONLY );
			al_set_target_bitmap( stamp.bitmap );
			
			with( letterBase )
				text.draw(),
				input.draw();
			
			al_set_target_backbuffer( DISPLAY );
			al_draw_bitmap( stamp.bitmap, 0, 0, 0 );
			al_unlock_bitmap( stamp.bitmap );

			al_flip_display();
			
			with( letterBase ) {
				if ( text.count != 0
					&& text.letters[ $ - 1 ].lock == false
					&& text.letters[ $ - 1 ].letter == g_lf ) {
					return false;
				}
				input.doInput();
				text.update();
			}
			
			return true;
		}

		int[2] variables;
		string user;
		with( letterBase )
			text.addTextln( "Enter 'quit' to exit" );
		
		int rand() { return uniform(0, 100); }
		for (;;) {
			foreach (ref v; variables)
				v=rand;
			int answer, guess;
			answer=variables[0]+variables[1];
			string problem;
			do {
				with( letterBase ) {
					text.setLockAll( false ); //#that is set lock all to true or false
					problem = text.getText() ~
						to!string( variables[0] ) ~ "+" ~ to!string( variables[1] )
						~ "=";
					
					//problem = "";
					
					text.setText( problem );
					text.setLockAll( true );
				}

				while( refresh() == true ) {
					if ( exitHandler.doKeysAndCloseHandling )
						goto quit;
				}
				with( letterBase )
					if ( problem.length < text.count() )
						user = text.getText()[ problem.length .. $ - 1 ]; //#maybe $ - 2, or stripRight

				if (user!="" && user[0]=='q')
					goto quit;
				if (isAValidNumber(user)==false) {
					with( letterBase )
						text.addTextln( "That wont do." );
					continue;
				}
				guess=parse!int(user); // User input
				if (guess==answer) {
					with( letterBase )
						text.addTextln( "Good" );
				}
				else {
					with( letterBase )
						text.addTextln( (guess > answer ? "Less than" : "Greater than" ) );
				}
			} while (guess!=answer);
		} //for
	quit: //#what's this! - the goto has got to go!
		with( letterBase ) {
			text.addText( "Ok then, see you later, do call again! :-)" );
			text.setLockAll( true );
		}
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
