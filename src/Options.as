package  
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author ...
	 */
	public class Options extends Sprite
	{
		private static const COLOR_MOUSE_OVER:int =		0xFFE877; 
		private static const COLOR_MOUSE_OUT:int =		0xCCCCCC; 
		private static const COLOR_SELECTED:int =		0xF2B705; 

		private var mSaveObj:SharedObject;
		
		private var mFoldOptions:Sprite;
		private var mAutoMonsterButton:Sprite;
		private var mAutoStatButton:Sprite;
		private var mShowOverdraw:Sprite;
		private var mShowInstanciator:Sprite;
		private var iconOff:DisplayObject;
		[Embed(source="MonstersRoarIcon.png")]
		private var DebugerIcon:Class;		
		
		[Embed(source="MonstersRoarIconGray.png")]
		private var DebugerIconDisable:Class;		
		
		private var debuggerIcon:DisplayObject = null;

		private var mLastSelected:Sprite = null;
		
		private var mInfos:TextField;
		
		public function Options() 
		{
			Init();
		}
		
		public function Init() : void
		{			
			try
			{
				mSaveObj = SharedObject.getLocal("FlashPreloadProfilerOptions");	
			}
			catch (e:Error)
			{
				mSaveObj = new SharedObject();
			}
			
			
			var barWidth:int = 350;
						
			this.graphics.beginFill(0x000000, 0.3);
			this.graphics.drawRect(0, 0, barWidth, 18);
			this.graphics.endFill();
			this.graphics.beginFill(0xCCCCCC, 0.6);
			this.graphics.drawRect(0, 17, barWidth, 1);
			this.graphics.endFill();
			this.graphics.beginFill(0xFFFFFF, 0.8);
			this.graphics.drawRect(0, 18, barWidth, 1);
			this.graphics.endFill();
			
			mAutoStatButton = new Sprite();
			mAutoStatButton.x = 2;
			mAutoStatButton.y = 3;
			//this.addEventListener(MouseEvent.MOUSE_MOVE, function():void { ResetColors(null , 0xFF0000); } );
			mAutoStatButton.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mAutoStatButton, COLOR_MOUSE_OVER); } );
			mAutoStatButton.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mAutoStatButton.addEventListener(MouseEvent.CLICK, function():void { 
					mLastSelected = mAutoStatButton;
					mInfos.text = "FlashPreloadProfiler : Runtime Statistics";
					ResetColors(mAutoStatButton); 
					dispatchEvent(new Event("toggleStats",true)); } );
			addChild(mAutoStatButton);
			
			mAutoMonsterButton = new Sprite();
			mAutoMonsterButton.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mAutoMonsterButton, COLOR_MOUSE_OVER); } );
			mAutoMonsterButton.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mAutoMonsterButton.x = mAutoStatButton.x + 16;
			mAutoMonsterButton.y = 3;
			mAutoMonsterButton.addEventListener(MouseEvent.CLICK, function():void { 
					mLastSelected = mAutoMonsterButton;
					mInfos.text = "FlashPreloadProfiler : Mouse Listeners";
					ResetColors(mAutoMonsterButton);
					dispatchEvent(new Event("toggleMouseListeners",true)); } );
			addChild(mAutoMonsterButton);
			
			this.mShowOverdraw = new Sprite();
			mShowOverdraw.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mShowOverdraw, COLOR_MOUSE_OVER); } );
			mShowOverdraw.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mShowOverdraw.x = mAutoMonsterButton.x + 16;
			mShowOverdraw.y = 3;
			mShowOverdraw.addEventListener(MouseEvent.CLICK, function():void { 
					mLastSelected = mShowOverdraw;
					mInfos.text = "FlashPreloadProfiler : Overdraw";
					ResetColors(mShowOverdraw);
					dispatchEvent(new Event("toggleOverdraw", true)); } );
			//mShowOverdraw.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mShowOverdraw, 0xFF0000); } );
			addChild(mShowOverdraw);
			
			mShowInstanciator = new Sprite();
			mShowInstanciator.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mShowInstanciator, COLOR_MOUSE_OVER); } );
			mShowInstanciator.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mShowInstanciator.x = mShowOverdraw.x + 16;
			mShowInstanciator.y = 3;
			mShowInstanciator.addEventListener(MouseEvent.CLICK, function():void { 
					mLastSelected = mShowInstanciator;
					mInfos.text = "FlashPreloadProfiler : Instances Life Cycle";
					ResetColors(mShowInstanciator); 
					dispatchEvent(new Event("toggleInstancesLifeCycle", true)); } );
			addChild(mShowInstanciator);			

						
			debuggerIcon = new DebugerIcon();
			iconOff = new DebugerIconDisable();
			debuggerIcon.x = mShowInstanciator.x+16;
			debuggerIcon.y = 1;
			iconOff.x = mShowInstanciator.x + 16;
			iconOff.y = 1;
			addChild(iconOff);
			addChild(debuggerIcon);
			debuggerIcon.visible = false
			
			//MonsterDisabled bar
			
			
			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
			
			mInfos = new TextField();
			mInfos.autoSize = TextFieldAutoSize.LEFT;
			mInfos.defaultTextFormat = myformat;
			mInfos.selectable = false;
			mInfos.text = "FlashPreloadProfiler";
			mInfos.filters = [ myglow ];
			mInfos.x = debuggerIcon.x + 50;
			//mInfos.y = -1;
			addChild( mInfos );
			
			
			ResetColors();
			
			
		}

		final public function SetMonsterDisabled():void
		{
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0x0, 1);
			s.graphics.drawRect(iconOff.x - 2, 10, iconOff.width + 4, 1);
			s.graphics.endFill();
			s.graphics.beginFill(0xFFFFFF, 1);
			s.graphics.drawRect(iconOff.x - 2, 11, iconOff.width + 4, 2);
			s.graphics.endFill();
			s.graphics.beginFill(0x0, 1);
			s.graphics.drawRect(iconOff.x - 2, 13, iconOff.width + 4, 1);
			s.graphics.endFill();
			addChild(s);			
		}
		final public function Dispose() : void
		{
			
		}
		
		final private function ResetColors(obj:Sprite = null , color:uint=COLOR_SELECTED ) : void
		{
			
			if (mLastSelected!=mShowInstanciator) { DrawButton(mShowInstanciator, COLOR_MOUSE_OUT); }
			if (mLastSelected!=mAutoMonsterButton) { DrawButton(mAutoMonsterButton, COLOR_MOUSE_OUT); }
			if (mLastSelected!=mAutoStatButton) { DrawButton(mAutoStatButton, COLOR_MOUSE_OUT); }
			if (mLastSelected!=mShowOverdraw) { DrawButton(mShowOverdraw, COLOR_MOUSE_OUT); }

			
			if (obj != null)
			{
				DrawButton(obj, color);
			}
			else if (mLastSelected != null)
			{
				DrawButton(mLastSelected, color);
			}
			
			
		}
		
		final private function DrawButton(obj:Sprite, color:uint) : void
		{
			obj.graphics.clear();
			obj.graphics.beginFill(color, 0.8);
			obj.graphics.drawRect(0, 0, 12, 12);
			obj.graphics.endFill();			
		}
		
		public function OnDebuggerConnect(e:Event) : void
		{
			if (debuggerIcon != null)
			{
				debuggerIcon.visible = true;
			}
		}
		public function OnDebuggerDisconnect(e:Event) : void
		{
			if (debuggerIcon != null)
			{
				debuggerIcon.visible = false;
			}
		}				
		
		public function set AutoStartMonsterDebugger(auto:Boolean) : void
		{
			mSaveObj.data.autoMonster = auto;
			mSaveObj.flush();
		}
		public function get AutoStartMonsterDebugger() : Boolean
		{
			return mSaveObj.data.autoMonster;
		}
		
		public function set AutoStartStatBar(auto:Boolean) : void
		{
			mSaveObj.data.autoStats = auto;
			mSaveObj.flush();
		}
		public function get AutoStartStatBar() : Boolean
		{
			return mSaveObj.data.autoStats;
		}
		
	}

}