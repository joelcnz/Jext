//#is this worth keeping?
//#not nice
module jext.lettermanager;

import jext.all;

class LetterManager {
public:
	@property ref auto letters() { return  m_letters; }
	@property ref auto area() { return m_area; }
	@property ref auto square() { return m_square; }
	@property ref auto alternate() { return m_alternate; }
	
	auto count() { return letters.length; }
	
	//#is this worth keeping?
	Letter opIndex( int pos ) {
		assert( pos >= 0 && pos < count, "opIndex" );
		return letters[ pos ];
	}

	this( Square square ) {
		this.square = square;
		with( square )
			area = new Bmp( width, height );
		//m_offx = m_offy = 0;
	}
	
	void setLockAll( bool lock0 ) {
		foreach( l; letters )
			l.lock = lock0;
	}
	
	void setLetterBase( LetterBase letterBase ) {
		this.letterBase = letterBase;
	}
	
	string addTextln( string str ) {
		string result = getText() ~ str ~ g_lf;
		setText( result );

		return result;
	}
	
	string addText( string str ) {
		string result = getText() ~ str;
		setText( result );

		return result;
	}

	void setText( in string stringLetters ) {
		letters.length = 0; // clear letter array
		double bar = stringLetters.length;
		auto countDown = 10;
		auto udtimes = 1;
		foreach( i, ref l; stringLetters ) {
			letters ~= new Letter( l );
		}
		with( letterBase )
			input.pos = cast(int)bar - 1;
		placeLetters();
	}

	string getText() {
		char[] str;
		foreach( l; letters ) {
			str ~= cast(char)l.letter;
		}

		return str.idup;
	}
	
	void placeLetters() {
		with( square ) {
			auto inword = false;
			auto startWordIndex = -1;
			ALLEGRO_COLOR[] altcols = [Colour.amber, Colour.red];
			auto altcolcyc = 0;
			int x = 0, y = 0;
			foreach( i, ref l; letters ) {
				auto let = cast(char)l.letter;// jtoCharPtr( l.letter );
				// if do new line
				if ( x + g_width > xpos + width || let == g_lf ) {
					x = ( let == g_lf ? -g_width : 0 );
					y += g_height;
					if ( alternate == true ) {
						altcolcyc = ( altcolcyc == 0 ? 1 : 0 );
					}
					if ( y + g_height > ypos + height) {
						foreach( l2; letters )
							l2.ypos -= g_height;
						y -= g_height;
					}
				}
				l.setPostion( x, y );
				if ( alternate == true ) {
					l.alternate = true; //#not nice
					l.altColour = altcols[ altcolcyc ];
				}
				x += g_width;
			}
		}
	}
	
	void update() {
		foreach( l; letters )
			l.update();
	}
	
	void draw() {
		auto bmp = al_get_target_bitmap();
		al_set_target_bitmap( area.bitmap );
		al_clear_to_color( Colour.black );
		/+
		al_draw_rectangle( 0.5, 0.5,
			al_get_bitmap_width( m_area.bitmap ), al_get_bitmap_height( m_area.bitmap ),
			Colour.white, 1 );
		+/
		if ( count > 0 )
			foreach( l; letters )
				l.draw();
		al_set_target_bitmap( bmp );
		with( square )
			al_draw_bitmap( area.bitmap, xpos, ypos, 0 );
	}

	@property ref auto letterBase() { return m_letterBase; }
	@property ref auto copiedText() { return m_copiedText; }
private:
	LetterBase m_letterBase;
	Bmp m_area;
	Letter[] m_letters;
	bool m_alternate;
	Square m_square;
	string m_copiedText;
}

