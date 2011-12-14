//#maybe change to just 'char'
//#draw letter
/// Letter
module jext.letter;

import std.stdio, std.string;
import jeca.all, jext.all;

/**
 * The letters that make up the text
 * 
 * May have the text bounce up and down
 */
class Letter {
private:
	static int m_idCurrent = 0;
	int m_id;

	double m_xpos, m_ypos,
		m_xdir, m_ydir, m_width, m_height, m_roof, m_floor, m_xoff, m_yoff,
		abcol;
	dchar m_letter; //#maybe change to just 'char'
	ALLEGRO_COLOR m_colour, acol, bcol,
		m_altColour;
	bool m_alternate;
	ubyte m_shade;
	bool m_lock;
	
	LetterManager m_letterManager;
public:
	@property ref auto xpos() { return m_xpos; } /// x position
	@property ref auto ypos() { return m_ypos; } /// y position
	@property ref auto letter() { return m_letter; } /// letter
	@property ref auto lock() { return m_lock; } /// lock state
	@property ref auto alternate() { return m_alternate; } /// alterating colour on/off switch
	@property ref auto altColour() { return m_altColour; } /// second colour for the alterating colour being on
	@property ref auto letterManager() { return m_letterManager; } /// 
	
	void setPostion( double x, double y ) { xpos = x; ypos = y; } /// postion the letter
	
	/// ctor new letter
	this(LetterManager letterManager0, dchar letter) {
		letterManager = letterManager0;
		m_id = m_idCurrent;
		++m_idCurrent;
		m_colour = Colour.amber;
		alternate = false;
		this.letter = letter;
		m_xdir = 0;
		m_ydir = -1;
		m_roof = -999;
		m_floor = 0;
		m_height = 3;
		m_xoff = m_yoff = 0;
		m_shade = 0;
		acol = Colour.red, bcol = Colour.blue, abcol =  0.0;
		debug {
//			if (letterManager.letters.length > 0)
//				mixin( traceLine( //"letterManager.bmpLetters[0].width", "letterManager.bmpLetters[0].height",
//									"letter", "letter & 0xFF", "letterManager.bmpLetters.length" ) );
			//mixin(traceLine("letterManager.bmpLetters[0]"));
		}
	}
	
	/// dtor for any Allegro C created stuff
	~this() {
		//clear( bmp ); //#need this, or crashes
	}
	
	/**
	 * For the letter behaviour(sp)
	 * 
	 * May:
	 * 
	 * 1. Bounce the letter up and down
	 * 
	 * 2. Keep changing the colour of the letter
	 */
	void update() {
		if ( m_roof == -999 ) {
			m_roof = -3, m_floor = 0;
		} else {
			m_yoff += m_ydir;
			dub tmp = m_ydir;
			if ( m_yoff < m_roof )
				m_ydir = 1;

			if ( m_yoff > m_floor )
				m_ydir = -1;

			if ( tmp != m_ydir )
				 m_yoff -= m_ydir;
		}
		m_yoff = 0; //#to stop bouncing
		m_colour = makecol( m_shade, m_shade, m_shade );
		m_shade += 5;
		
		abcol += 256 / 100 * 3;
		if ( abcol > 100.0 )
			abcol = 0.0;
	}
	
	//#draw letter
	/**
	 * Draw the letter
	 * 
	 * Draws:
	 * 
	 * 1. Alternating
	 * 
	 * 2. Changing colour
	 */
	void draw( Square square ) {
		//debug mixin(traceLine("xpos ypos letter&0xFF letterManager.width letterManager.height square.width square.height".split));
		if ( (letter & 0xFF) >= 32
		  && xpos + letterManager.width >= 0
		  && xpos <= square.width
		  && ypos + letterManager.height >= 0
		  && ypos <= square.height ) {
			  debug {
			//	  writeln("Crash!");
			//	  mixin(traceLine("letter", "letter & 0xFF", "letterManager.bmpLetters[letter & 0xFF]"));
				}
			if ( ! alternate ) {
				al_draw_bitmap(letterManager.bmpLetters[letter & 0xFF].bitmap,
					square.xpos + xpos + m_xoff, square.ypos + ypos + m_yoff, 0 );
			 }
			else {
			/+
				al_draw_tinted_bitmap( g_bmpLetters[ letter & 0xFF ].bitmap,
					Colour.amber,
					xpos, ypos, 0 );
			+/
				al_draw_tinted_bitmap( letterManager.bmpLetters[ letter & 0xFF ].bitmap,
					altColour,
					square.xpos + xpos + m_xoff, square.ypos + ypos + m_yoff, 0 );
			/+
				al_draw_tinted_bitmap( g_bmpLetters[ letter & 0xFF ].bitmap,
					getBlend( acol, bcol, abcol ),
					xpos + m_xoff, ypos + m_yoff, 0 );
			+/
			}
		} // if letter
	}
}
