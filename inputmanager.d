module jext.inputmanager;

//#unused
//#unused
//#character adder
import std.c.stdio;

import jext.all;

class InputManager {
public:
	this( LetterManager letterManager ) {
		this.letterManager = letterManager;

		pos = letterManager.letters.length - 1;
	}
	
	void setLetterBase( LetterBase letterBase ) {
		this.letterBase = letterBase;
	}
	
	dchar doInput() {
		int c = 0;
		c = readkey();

		void directional() {
			poll_input();
			
			auto wait = false;

			if ( key[ ALLEGRO_KEY_LCTRL ]  || key[ ALLEGRO_KEY_RCTRL ] ) {
				wait = true;
				
				if ( key[ ALLEGRO_KEY_C ] && letterManager.count > 0 ) {
					int i = 0;
					for( i = letterManager.count() - 1;
						i >= 0 && letterManager.letters[ i ].lock == false; --i )
					{}
					debug
						mixin( traceLine( "/+ copy: +/ i" ) );
					letterManager.copiedText = letterManager.getText()[ i + 1.. $ ];
				}

				if ( key[ ALLEGRO_KEY_V ] && letterManager.count > 0 ) {
					int i = 0;
					for( i = letterManager.count() - 1;
						i >= 0 && letterManager.letters[ i ].lock == false; --i )
					{}
					debug
						mixin( traceLine( "/+ paste: +/ i" ) );
					letterManager.setText( letterManager.getText()[ 0 .. i + 1 ]
						~ letterManager.copiedText );
					foreach( index;
						0 .. letterManager.count - letterManager.copiedText.length )
						letterManager[ index ].lock = true;
					pos = letterManager.count - 1;
				}
				
				if ( key[ ALLEGRO_KEY_LEFT ] ) {
					if ( letterManager.letters[ pos ].lock != true ) {
						int i = 0;
						for( i = pos - 1;
							i > -1 && letterManager.letters[ i ].letter != ' '
							&& letterManager.letters[ i ].lock == false; --i )
						{}
						if ( pos > -1 )
							pos = i;
					}
				}
				if ( key[ ALLEGRO_KEY_RIGHT ] ) {
					int i = 0;
					for( i = pos + 1;
						i < letterManager.letters.length &&
						letterManager.letters[ i ].letter != ' ' ; ++i )
					{}
					if ( i < letterManager.letters.length )
						pos = i;
					else
						pos = letterManager.letters.length - 1;
				}
				
				if ( key[ ALLEGRO_KEY_HOME ] ) {
					int i = pos;
					for( i = pos; i >= -1 && letterManager.letters[ i ].lock == false; --i )
					{}
					pos = i;
				}

				if ( key[ ALLEGRO_KEY_END ] )
					pos = letterManager.letters.length - 1;

			} else { // not control down
				if ( key[ ALLEGRO_KEY_LEFT ] && letterManager.count > 0 ) {
					--pos;
					if ( pos == -2 )
						pos = -1;
					if ( letterManager.letters[ pos + 1 ].lock == true )
						++pos;
					wait = true;
				}

				if ( key[ ALLEGRO_KEY_RIGHT ] ) {
					++pos;
					if ( pos >= letterManager.letters.length  )
						--pos;
					wait = true;
				}
				
				if ( key[ ALLEGRO_KEY_UP ] && letterManager.count > 0 ) {
					with( letterManager ) {
						int lastPos = pos;
						int xpos = cast(int)letters[ pos ].xpos,
							ypos = cast(int)letters[ pos ].ypos - g_height;
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
							for( int i = pos; i >= 0; --i )
								if ( letters[ i ].letter == g_lf ) {
									pos = i;
									if ( pos != 0 )
										--pos;
									break;
								}
						}
						if ( count > 0 && letters[ pos + 1 ].lock == true )
							pos = lastPos;
					} // with
					wait = true;
				} // key up
				
				if ( key[ ALLEGRO_KEY_DOWN ] && letterManager.count > 0 ) {
					with( letterManager ) {
						int xpos = cast(int)letters[ pos ].xpos,
							ypos = cast(int)letters[ pos ].ypos + g_height;
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
								if ( ( ypos + g_height == letters[i].ypos &&
									letters[i].letter == g_lf )
									|| i == letters.length - 1 ) {
									pos = i;
									if ( i != letters.length - 1 && pos - 1 > -1 )
										--pos;
									break;
								}
							}
						}
					} // with
					wait = true;
				} // key down
			} // if not control pressed
			
			if ( wait )
				poll_input_wait();
		}
		directional();

		if ( c ) {
			auto doPut = false;
			
			//#character adder
			if ( chr( c ) >= 32 && ! tkey( c, ALLEGRO_KEY_DELETE ) ) {
				doPut = true;
				with( letterManager ) {
					//insert letter
					// pos = -1
					// Bd press a -> aBc
					// #              #
					//mixin( traceLine( "pos letters.length".split ) );
					letters = letters[ 0 .. pos + 1 ] ~
						new Letter( chr( c ) ) ~ letters[ pos + 1 .. $ ];
					++pos;
					placeLetters();
				}
			}
			
			if ( tkey( c, ALLEGRO_KEY_ENTER ) || tkey( c, ALLEGRO_KEY_PAD_ENTER ) ) {
				with( letterManager ) {
					//letters = letters[ 0 .. pos + 1 ] ~	new Letter( g_cr ) ~ new Letter( g_lf ) ~ letters[ pos + 1 .. $ ];
					letters = letters[ 0 .. pos + 1 ] ~
						new Letter( g_lf ) ~
						letters[ pos + 1 .. $ ];
					pos += 1;
					placeLetters();
				}
			}
			
			if ( tkey( c, ALLEGRO_KEY_BACKSPACE ) && pos > -1
				&& letterManager.letters[ pos ].lock == false ) {
				doPut = true;
				version( Terminal )
					write( " \b" );
				with( letterManager )
					letters = letters[ 0 .. pos ] ~ letters[ pos + 1 .. $ ];
				--pos;
				letterManager.placeLetters();
			}
			
			//Suck - it sucks (letters that is)
			if ( tkey( c, ALLEGRO_KEY_DELETE )
				&& pos != letterManager.count - 1 ) {
				// pos = 0
				// a*Bc press del -> ac
				//   #                #
				with( letterManager )
					letters = letters[ 0 .. pos + 1 ] ~ letters[ pos + 2 .. $ ],
					placeLetters();
			}

			version( Terminal ) {
				if ( doPut ) 
					write( cast(char)c ~ "#\b" );
				std.stdio.stdout.flush;
			}
		}
		
		return chr( c ); //#unused
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
		if ( xpos + g_width >= DISPLAY_W )
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
