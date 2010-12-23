package net.jpauclair.event 
{
	import flash.events.Event;
	import net.jpauclair.ui.button.MenuButton;
	/**
	 * ...
	 * @author jpauclair
	 */
	public class ChangeToolEvent extends Event
	{
		public static const CHANGE_TOOL_EVENT:String = "ChangeToolEvent";
		public var mTool:Class
		public function ChangeToolEvent(newTool:Class)
		{
			mTool = newTool;
			super(CHANGE_TOOL_EVENT, true, false);
		}
		
	}

}