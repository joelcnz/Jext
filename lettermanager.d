import base, letterbase, letter;

class LetterManager {
public:
	@property ref auto letters() { return  m_letters; }
	@property ref auto area() { return m_area; }
	@property ref auto square() { return m_square; }
	
	auto count() { return letters.length; }
	
	Letter opIndex( int pos ) {
		//if ( pos < 0 ) pos = letters.length + pos - 1;
		//writeln( pos );
		return letters[ pos ];
	}

	this( Square square, in string stringLetters ) {
		this.square = square;
		with( square )
			area = new Bmp( width, height );
		int dummy = 0;
		setText( stringLetters, dummy );
	}
	
	void setLetterBase( LetterBase letterBase ) {
		this.letterBase = letterBase;;
	}

	//void setInputManager( InputManager inputManager ) {
		//this.inputManager = inputManager;
	//}
	
	void setText( in string stringLetters, ref int postion ) {
		letters.length = 0;
		double bar = stringLetters.length;
		auto countDown = 10;
		auto udtimes = 1;
		foreach( i, char l; stringLetters ) {
			if ( --countDown == 0 )
				al_draw_filled_rectangle( 0, 0, i * ( 640 / bar ), 8, Colour.green ),
				countDown = 10,
				al_flip_display();
			letters ~= new Letter( l );
			foreach( upd; 0 .. udtimes )
				letters[ $ - 1 ].update();
			++udtimes;
			if ( udtimes == 5 )
				udtimes = 1;
		}
		postion = cast(int)bar - 1;
		placeLetters();
	}

	string getText() {
		char[] str;
		foreach( l; letters ) {
			str ~= cast(char)l.letter;
		}

		return str.idup;
	}
	
	void popBack() {
		//clear( letters[ $ - 1 ] ); //#Aaar, now this stopped it crashing (1 of 2 clears to stop the crashing) I dont think I memory stuff properly
		letters = letters[ 0 .. $ - 1 ];
	}
	
	void placeLetters() {
		with( square ) {
			auto inword = false;
			auto startWordIndex = -1;
			int x = 0, y = 0;
			foreach( i, ref l; letters ) {
				auto let = jtoCharPtr( l.letter );
				if ( x + g_width > xpos + width || let[0] == g_lf ) {
					x = ( let[0] == g_lf ? - g_width : 0);
					y += g_height;
					if ( y + g_height > ypos + height)
						break;
				}
				l.setPostion( x, y );
				l.update();
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
		al_clear_to_color( Colour.amber );
		al_draw_rectangle( 0.5, 0.5,
			al_get_bitmap_width( m_area.bitmap ), al_get_bitmap_height( m_area.bitmap ),
			Colour.white, 1 );
		if ( count > 0 )
			foreach( l; letters )
				l.draw();
		al_set_target_bitmap( bmp );
		with( square )
			al_draw_bitmap( area.bitmap, xpos, ypos, 0 );
	}
	@property ref auto letterBase() { return m_letterBase; }
private:
	Bmp m_area;
	LetterBase m_letterBase;
	Letter[] m_letters;
	Square m_square;
}

