//#this goes in the dmd arguments
//#exit
//#draw letter
//#to stop bouncing
//#need this, or crashes
//#Aaar, now this stopped it crashing (1 of 2 clears to stop the crashing) I dont think I memory stuff properly
//#ALLEGRO_PIXEL_FORMAT_ANY undefined
/**
 * This program uses:
 * 
 * DAllegro5:  https://github.com/SiegeLord/DAllegro5  
 * 
 * JECA: (thin DAllegro wrapper)  https://github.com/joelcnz/Jeca
 */

//version = Terminal; //#this goes in the dmd arguments
version = Maths;

version( Windows ) {
	pragma( lib, "liballegro5" );
	pragma( lib, "libdallegro5" );
	pragma( lib, "libjeca" );
}

import jeca.all;
import base, letterbase, lettermanager, inputmanager;

/**
 * Program entry point
 */
void main( string[] args ) {
	//Init( args ~ "-mode opengl -wxh 640 480".split() );
	Init( "-wxh 640 480".split() ~ args );
	scope( exit ) Deinit();

	auto fonts = "ddrolive.bmp ddrocr.bmp".split;
	int fontIndex = 1;
	auto lettersSource = Bmp.loadBitmap( fonts[ fontIndex ] );
	al_convert_mask_to_alpha( lettersSource, al_get_pixel( lettersSource, 1, 0 ) );
	if ( fontIndex == 1 )
		al_convert_mask_to_alpha( lettersSource, al_get_pixel( lettersSource, 17, 0 ) );
	g_bmpLetters = getLetters(
		lettersSource, null, g_width + 1);
	

	version( Maths ) {
		auto letterBaseMaths = new LetterBase(
			new LetterManager( Square( 0, 0, DISPLAY_W, DISPLAY_H ) ) );
		letterBaseMaths.text.setLetterBase( letterBaseMaths );
		letterBaseMaths.input.setLetterBase( letterBaseMaths );
		maths( letterBaseMaths );
		return;
	}
	
	auto letterBase = new LetterBase(
		new LetterManager( Square( 0, DISPLAY_H - g_height * 3, DISPLAY_W, DISPLAY_H ) ) );

	letterBase.text.setLetterBase( letterBase );
	letterBase.input.setLetterBase( letterBase );
	
	auto mainText = new LetterBase(
			new LetterManager( Square( 0, 0, DISPLAY_W, DISPLAY_H - g_height * 3 ) )
	);

	int dummy;
	mainText.text.setText( cast(string)std.file.read( "jecatext.txt" ), dummy );
	
	with( mainText )
		text.setLetterBase( mainText ),
		input.setLetterBase( mainText );
	return;

	scope( exit )
		std.file.write( "jecatext.txt", mainText.letterManager.getText() );
	
	Bmp stamp = new Bmp( DISPLAY_W, DISPLAY_H );

	while( ! exitHandler.doKeysAndCloseHandling ) {
		//#ALLEGRO_PIXEL_FORMAT_ANY undefined
		al_lock_bitmap( stamp.bitmap,
			al_get_bitmap_format( stamp.bitmap ),
			ALLEGRO_LOCK_WRITEONLY );
		al_set_target_bitmap( stamp.bitmap );
		al_clear_to_color( Colour.red );

		with( mainText )
			text.draw();

		with( letterBase )
			text.draw(),
			input.draw();
		
		al_set_target_backbuffer( DISPLAY );
		al_draw_bitmap( stamp.bitmap, 0, 0, 0 );
		al_unlock_bitmap( stamp.bitmap );

		al_flip_display();
		
		with( mainText )
			text.update();

		with( letterBase )
			input.doInput(),
			text.update();
		
		with( letterBase ) {
			if ( text.getText() == "Timothy" || 
				text.getText() == "Alan" || 
				text.getText() == "Hamish" ) {
				text.setText(
					"Oh, hello " ~ text.getText() ~ ", how are you?",
					input.pos );
			}
			//#exit
			if ( text.getText() == "exit" )
				break;

			if ( text.letters.length > 0 && text[ text.count - 1 ].letter == g_lf ) {
				mainText.text.setText(
					mainText.text.getText() ~ text.getText(), mainText.input.pos );
				text.setText( "", input.pos );
			}
		}
	}
	
	clear( stamp );
}

Bmp[256] getLetters( ALLEGRO_BITMAP* bmp, in string order, int step ) {
	Bmp[256] letters;
	foreach( i; 0 .. 256 ) {
		if ( i >= 33 && i < 128 ) {
			letters[ i ] = Bmp.getBmpSlice(
				bmp,
				(i - 33) * step, 1,
				step, g_height - 1,
				0, 0,
				0
			);

			al_set_target_backbuffer( DISPLAY );
			al_draw_bitmap( bmp, 0, 0, 0 );
			al_draw_bitmap( letters[ i ].bitmap, (i - 33) * step, 32, 0 );
		} else {
			letters[ i ] = new Bmp( step, step );
		}
	}
	al_flip_display();
	//poll_input_wait();
	
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
				input.doInput();
				if ( text.letters[ $ - 1 ].letter == g_lf ) {
					return false;
				}
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
					problem = text.getText() ~
					to!string( variables[0] ) ~ "+" ~ to!string( variables[1] ) ~ "=";
					text.setText( problem, letterBase.input.pos );
				}

				while( refresh() == true ) {
					if ( exitHandler.doKeysAndCloseHandling )
						goto quit;
				}
				with( letterBase )
					if ( problem.length < text.count() )
						user = text.getText()[ problem.length .. $ - 1 ];

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
						text.addTextln( "It is!" );
				}
				else {
					with( letterBase )
						text.addTextln( (guess > answer ? "Less than" : "Greater then" ) );
				}
			} while (guess!=answer);
		} //for
	quit:
		version( Terminal )
			writeln("Ok then, see you later, do call again! :-)");
		with( letterBase )
			text.setText( text.getText()[ 0 .. text.count - 1 ] ~ g_lf
			~ "Ok then, see you later, do call again! :-)", input.pos );
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
