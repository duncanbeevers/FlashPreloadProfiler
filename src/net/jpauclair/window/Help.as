package net.jpauclair.window
{
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.sampler.getSize;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import net.jpauclair.IDisposable;
	import net.jpauclair.ui.button.MenuButton;
	/**
	 * ...
	 * @author jpauclair
	 */
	public class Help extends Sprite implements IDisposable
	{
		private static const COLOR_BACKGROUND:int =	0x444444;
		
		private var mMainSprite:Sprite = null;
	
		private var mInfos:TextField;
		
		[Embed(source='../../../../art/link.png')]
		private var IconLink:Class;		
		[Embed(source='../../../../art/linkOut.png')]
		private var IconLinkOut:Class;			
		private var mLinkButton:MenuButton;
		
		public function Help(mainSprite:Sprite) 
		{
			Init(mainSprite);
		}
		
		private function Init(mainSprite:Sprite) : void
		{
			mMainSprite = mainSprite;
			
			//this.mouseChildren = false;
			this.mouseEnabled = false;
			
			var barWidth:int = mMainSprite.stage.stageWidth;
			var bgSprite:Sprite = new Sprite();
			this.graphics.beginFill(0x000000, 0.3);
			this.graphics.drawRect(0, 18, barWidth, mMainSprite.stage.stageHeight-18);
			this.graphics.endFill();
			this.graphics.beginFill(0xCCCCCC, 0.6);
			this.graphics.drawRect(0, 19, barWidth, 1);
			this.graphics.endFill();
			this.graphics.beginFill(0xFFFFFF, 0.8);
			this.graphics.drawRect(0, 18, barWidth, 1);
			this.graphics.endFill();


			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
			
			mInfos = new TextField();
			mInfos.mouseEnabled = false;
			mInfos.autoSize = TextFieldAutoSize.LEFT;
			mInfos.defaultTextFormat = myformat;
			mInfos.selectable = false;
			mInfos.appendText("FlashPreloadProfiler is an open source multi-purpose profiler designed to help productivity and stability \nduring development by exposing “under the hood” representation of any flash scene.");
			mInfos.appendText("\nThe main goal is to help expose and diagnose problems before they get too big.");
			mInfos.appendText("\nIt enables developers, artists, designer or testers to see what sometimes “cannot be seen” such as:");
			mInfos.appendText("\n\t-What is the current FPS and memory statistics of a SWF");
			mInfos.appendText("\n\t-Where are all mouse event listeners object");
			mInfos.appendText("\n\t-What is the global scene overdraw");
			mInfos.appendText("\n\t-How many sprites are contained in the scene and may be one over the others");
			mInfos.appendText("\n\t-What is the life cycle of all the display objects on the stage");
			mInfos.appendText("\n\t-Memory profiling");
			mInfos.appendText("\n\t-Performance profiling");
			mInfos.appendText("\n\t-Internal Events profiling");

			mInfos.appendText("\n\nFor a full description, help or support:\nhttp://jpauclair.net/flashpreloadprofiler/\n");
			mInfos.filters = [ myglow ];
			mInfos.x = 2;
			mInfos.y = 22;
			addChild( mInfos );

			mLinkButton = new MenuButton(4, 250, IconLinkOut, IconLink, IconLinkOut,null, null, "Navigate to this link",true,"");
			addChild(mLinkButton);
			
		}
		
		public function Dispose() : void
		{
			this.graphics.clear();
			mInfos = null;
			
			if (mMainSprite != null && mMainSprite.stage != null)
			{
				mMainSprite = null;
			}
		}
		
		public function Update():void
		{
			if (mLinkButton.mIsSelected)
			{
				mLinkButton.mIsSelected = false;
				var req:URLRequest = new URLRequest("http://jpauclair.net/flashpreloadprofiler");
				navigateToURL(req, "_new");
			}
			
		}
		
	}
}