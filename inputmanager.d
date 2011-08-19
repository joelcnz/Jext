import base, letterbase, lettermanager, letter;

class InputManager {
public:
	this( LetterManager letterManager ) {
		this.letterManager = letterManager;
		foreach( l; letterManager.letters )
			write( l.letter );
		std.stdio.stdout.flush;
		
		pos = letterManager.letters.length - 1;
	}
	
	void setLetterBase( LetterBase letterBase ) {
		this.letterBase = letterBase;;
	}

	
	void doInput() {
		int c = 0;
		c = readkey();

		void directional() {
			poll_input();
			
			auto wait = false;

			if ( key[ ALLEGRO_KEY_LCTRL ] ) {
				wait = true;
				if ( key[ ALLEGRO_KEY_LEFT ] ) {
					int i = 0;
					for( i = pos - 1;
						i > -1 && letterManager.letters[ i ].letter != ' ' ; --i )
					{}
					if ( pos > -1 )
						pos = i;
				}
				if ( key[ ALLEGRO_KEY_RIGHT ] ) {
					int i = 0;
					for( i = pos + 1;
						i < letterManager.letters.length &&
						letterManager.letters[ i ].letter != ' ' ; ++i )
					{}
					if ( i < letterManager.letters.length )
						pos = i;
				}
			} else {
				if ( key[ ALLEGRO_KEY_LEFT ] ) {
					--pos;
					if ( pos == -2 )
						pos = -1;
				}

				if ( key[ ALLEGRO_KEY_RIGHT ] ) {
					++pos;
					if ( pos >= letterManager.letters.length  )
						--pos;
				}
				
				if ( key[ ALLEGRO_KEY_HOME ] )
					pos = -1;

				if ( key[ ALLEGRO_KEY_END ] )
					pos = letterManager.letters.length - 1;
			}
			
			if ( wait )
				poll_input_wait();
		}
		directional();

		if ( c ) {
			if ( ( c & 0xFF ) >= 32 || c >> 8 == ALLEGRO_KEY_ENTER ) {
				with( letterManager ) {
					//insert letter
					// abD (ab#d) press c -> abcD (abc#d)
					if ( c >> 8 == ALLEGRO_KEY_ENTER ) {
						letters = letters[ 0 .. pos + 1 ] ~
							new Letter( g_lf ) ~ letters[ pos + 1 .. $ ];
					} else {
						letters = letters[ 0 .. pos + 1 ] ~
							new Letter( c & 0xFF ) ~ letters[ pos + 1 .. $ ];
					}
					++pos;
					placeLetters();
				}
			}
			
//			mixin( trace( "pos" ) );
			
			if ( c >> 8 == ALLEGRO_KEY_BACKSPACE && pos > -1 ) {
				write( " \b" );
				with( letterManager )
					letters = letters[ 0 .. pos ] ~ letters[ pos + 1 .. $ ];
				--pos;
				letterManager.placeLetters();
			}
			write( cast(char)c ~ "#\b" ); std.stdio.stdout.flush;
		}
	}
	
	void draw() {
		double xpos;
		double ypos;
		if ( letterManager.letters.length > 0 && pos > -1 ) {
			xpos = letterManager[ pos ].xpos;
			ypos = letterManager[ pos ].ypos;
		} else {
			xpos = -g_width;
			ypos = 0;
		}
		if ( xpos + g_width >= 640 )
			xpos = -g_width,
			ypos += g_height;
		
		al_draw_filled_rectangle(
			letterManager.square.xpos + xpos + g_width + 1, letterManager.square.ypos + ypos,
			letterManager.square.xpos + xpos + g_width * 2 + 1, letterManager.square.ypos + ypos + g_height,
			al_map_rgba( 0, 0, 255, 128 ) );
	}
	
	@property ref auto letterBase() { return m_letterBase; }
	@property ref auto letterManager() { return m_letterManager; }
	@property ref auto pos() { return m_pos; }
private:
	int m_pos;
	LetterBase m_letterBase;
	LetterManager m_letterManager;
}
