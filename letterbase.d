//#not sure about these - and limited access being here
/// Letter Manager, and Letter Input bind
module jext.letterbase;

import jext.all;

/// For grouping letter and input managers
class LetterBase {
public:
	/// Setup managers
	this( LetterManager letterManager ) {
		this.letterManager = letterManager;
		inputManager = new InputManager( letterManager );
	}
	
	@property ref auto letterManager() { return m_letterManager; } /// access letter manager
	@property ref auto inputManager() { return m_inputManager; } /// access input manager
	
	//#not sure about these - and limited access being here
	alias letterManager text; /// letter manager nick name
	alias inputManager input; /// input manger nic name
private:
	LetterManager m_letterManager;
	InputManager m_inputManager;
}
