//#draw letter
module jext.letter;

import jext.all;

class Letter {
	@property ref auto xpos() { return m_xpos; } // ( 0<, 0 )
	@property ref auto ypos() { return m_ypos; } // ( 0 ,>0 )
	@property ref auto letter() { return m_letter; } // 'c' (dchar)
	@property ref auto lock() { return m_lock; }
	@property ref auto alternate() { return m_alternate; }
	@property ref auto altColour() { return m_altColour; }
	
	void setPostion( double x, double y ) { xpos = x; ypos = y; }
	
	this( dchar letter ) {
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
	}
	
	~this() {
		//clear( bmp ); //#need this, or crashes
	}
	
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
	void draw() {
		if ( (letter & 0xFF) >= 32 )
			if ( ! alternate )
				al_draw_bitmap( g_bmpLetters[ letter & 0xFF ].bitmap,
					xpos + m_xoff, ypos + m_yoff, 0 );
			else {
				al_draw_tinted_bitmap( g_bmpLetters[ letter & 0xFF ].bitmap,
					Colour.amber,
					xpos, ypos, 0 );
			/+
				al_draw_tinted_bitmap( g_bmpLetters[ letter & 0xFF ].bitmap,
					altColour,
					xpos + m_xoff, ypos + m_yoff, 0 );
			+/
			/+
				al_draw_tinted_bitmap( g_bmpLetters[ letter & 0xFF ].bitmap,
					getBlend( acol, bcol, abcol ),
					xpos + m_xoff, ypos + m_yoff, 0 );
			+/
			}
	}
private:
	static int m_idCurrent = 0;
	int m_id;

	double m_xpos, m_ypos,
		m_xdir, m_ydir, m_width, m_height, m_roof, m_floor, m_xoff, m_yoff,
		abcol;
	dchar m_letter;
	ALLEGRO_COLOR m_colour, acol, bcol,
		m_altColour;
	bool m_alternate;
	ubyte m_shade;
	bool m_lock;
}
