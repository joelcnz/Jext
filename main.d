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
	Init( args ~ "-wxh 640 480".split() );
	scope( exit ) Deinit();

	auto fonts = "ddrolive.bmp ddrocr.bmp".split;
	int fontIndex = 1;
	auto lettersSource = Bmp.loadBitmap( fonts[ fontIndex ] );
	al_convert_mask_to_alpha( lettersSource, al_get_pixel( lettersSource, 1, 0 ) );
	if ( fontIndex == 1 )
		al_convert_mask_to_alpha( lettersSource, al_get_pixel( lettersSource, 17, 0 ) );
	g_bmpLetters = getLetters(
		lettersSource, null, g_width + 1);
	
	auto letterBase = new LetterBase(
		new LetterManager(
				Square( 0, 480 - g_height * 3, 640, 480 ),
				""
		)
	);

	letterBase.letterManager.setLetterBase( letterBase );
	letterBase.inputManager.setLetterBase( letterBase );
	
	auto mainText = new LetterBase(
		new LetterManager(
				Square( 0, 0, 640, 480 - g_height * 3 ),
				cast(string)std.file.read( "jecatext.txt" )
		)
	);
	
	with( mainText )
		text.setLetterBase( mainText ),
		input.setLetterBase( mainText );

	scope( exit )
		std.file.write( "jecatext.txt", mainText.letterManager.getText() );
	
	Bmp stamp = new Bmp( 640, 480 );

	while( ! exitHandler.doKeysAndCloseHandling ) {
		//#ALLEGRO_PIXEL_FORMAT_ANY undefined
		al_lock_bitmap( stamp.bitmap,
			al_get_bitmap_format( stamp.bitmap ),
			ALLEGRO_LOCK_WRITEONLY );
		al_clear_to_color( Colour.red );
		al_set_target_bitmap( stamp.bitmap );

		with( mainText )
			text.draw();

		with( letterBase )
			text.draw(),
			input.draw();
		
		al_set_target_bitmap( al_get_backbuffer( DISPLAY ) );
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
					"Oh, hello " ~ text.getText() ~ ", how are you? ",
					input.pos );
			}
			//#exit
			if ( text.getText() == "exit" )
				break;
			//writeln( "<"~text.getText()~">" );
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

/+
	with( text )
		setText( format( "%s+%s=%s", getText()[0 .. 1], getText()[2 .. 3],
			to!int( getText()[0 .. 1] ) + to!int( getText()[2 .. 3] )
		),
		input.pos
	);
+/
