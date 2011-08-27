//#could be done better, I think
//#I think put in 'newline' instead of g_lf
//#I don't know if 'ref' does anything.
//#is this worth keeping?
//#not nice
/// Letter Manager
///
/// Handles printing and layout of letters
module jext.lettermanager;

import jext.all;

/// Letter Manager
class LetterManager {
public:
	@property ref auto letters() { return  m_letters; } /// get/set letters
	@property ref auto area() { return m_area; } /// get/set bounds
	@property ref auto square() { return m_square; } /// get/set square (text box)
	@property ref auto alternate() { return m_alternate; } /// get/set alternating colours on or off
	
	@property auto count() { return letters.length; } /// get number of letters (including white space)
	
	/// Get letter using passed index number
	//#is this worth keeping?
	Letter opIndex( int pos ) {
		assert( pos >= 0 && pos < count, "opIndex" );
		return letters[ pos ];
	}

	/// Constructor, setting area
	this( Square square ) {
		this.square = square;
		with( square )
			area = new Bmp( width, height );
		//m_offx = m_offy = 0;
	}
	
	/// lock/unlock all letters
	void setLockAll( bool lock0 ) {
		foreach( l; letters )
			l.lock = lock0;
	}
	
	/// For access to inputManager
	void setLetterBase( LetterBase letterBase ) {
		this.letterBase = letterBase;
	}
	
	/// Add text with new line added to the end
	string addTextln( string str ) {
		string result = getText() ~ str ~ g_lf; //#I think put in 'newline' instead of g_lf
		setText( result );

		return result;
	}
	
	/// Add text without new line being added to the end
	void addText( string str ) {
		//string result = getText() ~ str; //#could be done better, I think
		//setText( result );
		auto lettersStartLength = count;
		letters.length = lettersStartLength + str.length;
		foreach( index, l; str )
			letters[ lettersStartLength + index ] = new Letter( l );
		with( letterBase )
			input.pos = count - 1;
		placeLetters();
	}

	/// apply text from string - also places text
	void setText( in string stringLetters ) {
		letters.length = 0; // clear letter array
		letters.length = stringLetters.length;
		foreach( index, l; stringLetters ) {
			letters[ index ] = new Letter( l );
		}
		with( letterBase )
			input.pos = cast(int)letters.length - 1;
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
	
	/// Eg. bouncing letters
	void update() {
		foreach( ref l; letters ) //#I don't think 'ref' does anything.
			l.update();
	}
	
	/// Draw stuff in square area
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

	@property ref auto letterBase() { return m_letterBase; } /// access m_letterBase (LetterBase)
	@property ref auto copiedText() { return m_copiedText; } /// access copiedText (string)
private:
	LetterBase m_letterBase;
	Bmp m_area;
	Letter[] m_letters;
	bool m_alternate;
	Square m_square;
	string m_copiedText;
}

