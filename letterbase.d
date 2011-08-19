import base, lettermanager, inputmanager, letter;

class LetterBase {
public:
	this( LetterManager letterManager ) {
		this.letterManager = letterManager;
		inputManager = new InputManager( letterManager );
	}
	
	@property ref auto letterManager() { return m_letterManager; }
	@property ref auto inputManager() { return m_inputManager; }
	
	alias letterManager text;
	alias inputManager input;
private:
	LetterManager m_letterManager;
	InputManager m_inputManager;
}
