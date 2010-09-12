package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author jpauclair
	 */
	public class Overdraw extends Sprite implements IDisposable
	{
		private static const COLOR_XRAY:int =		0xADBFD6; 
		private static const COLOR_XRAY_INVISIBLE:int =	 0xFF5600; 
		private static const COLOR_ALPHA:Number =	0.30;
		private static const COLOR_BACKGROUND:int =	0x000000;
		
		private var mMainSprite:Stage= null;		
	
		private var mRenderTargetData:BitmapData = null;
		private var mRenderTargetDataRect:Rectangle = null;		
		private var mRenderTarget:Bitmap = null;
		private var currentRenderTarget:Sprite = new Sprite();
		
		private var mInfos:TextField;
		
		private var mTimer:Timer;
		private var mDOTotal:int = 0;
		private var mMaxDepth:int = 0;
		
		
		public function Overdraw(mainSprite:Stage) 
		{			
			Init(mainSprite);
		}
		
		 private function Init(mainSprite:Stage) : void
		{
			mMainSprite = mainSprite;
			//This shouldn't influence mouse.
			this.mouseChildren = false;
			this.mouseEnabled = false;
						
			//Initialize render Target
			mRenderTargetData = new BitmapData(mMainSprite.stageWidth, mMainSprite.stageHeight, false, 0);
			mRenderTargetDataRect = mRenderTargetData.rect;
			mRenderTarget = new Bitmap();
			mRenderTarget.bitmapData = mRenderTargetData;
			
			//Add RenderTarget to stage.
			this.addChild(mRenderTarget);
			
			// Listen to Enter Frame events.
			mMainSprite.addEventListener(Event.ENTER_FRAME, Update);
			
			var barWidth:int = mMainSprite.stageWidth;
			var bgSprite:Sprite = new Sprite();
			bgSprite.graphics.beginFill(0x000000, 0.3);
			bgSprite.graphics.drawRect(0, 0, barWidth, 17);
			bgSprite.graphics.endFill();
			bgSprite.graphics.beginFill(0xCCCCCC, 0.6);
			bgSprite.graphics.drawRect(0, 1, barWidth, 1);
			bgSprite.graphics.endFill();
			bgSprite.graphics.beginFill(0xFFFFFF, 0.8);
			bgSprite.graphics.drawRect(0, 0, barWidth, 1);
			bgSprite.graphics.endFill();
			addChild(bgSprite);
			bgSprite.y = mMainSprite.stageHeight - bgSprite.height;

			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
			
			mInfos = new TextField();
			mInfos.autoSize = TextFieldAutoSize.LEFT;
			mInfos.defaultTextFormat = myformat;
			mInfos.selectable = false;
			mInfos.text = "FlashPreloadProfiler";
			mInfos.filters = [ myglow ];
			mInfos.x = 2;
			addChild( mInfos );
			mInfos.y = mMainSprite.stageHeight - bgSprite.height;

			mTimer = new Timer( 1000 );
			mTimer.addEventListener( TimerEvent.TIMER, OnTimerEvent,false,0,true);
			mTimer.start();
			
			trace("Overdraw initialized");
		}
		
		private function OnTimerEvent(e:TimerEvent):void 
		{
			var text:String = "DisplayObjectOnStage[ " 
							+ mDOTotal 
							+ " ]\tMaxDepth[ "
							+ mMaxDepth
							+ " ]";
							
			mInfos.text = text;
			
		}
		
		/**
		 * Dispose Everything. Free memory.
		 */
		public function Dispose():void
		{
			//trace("Dispose Overdraw");
			
			mInfos = null;
			
			if (mTimer != null)
			{
				mTimer.removeEventListener(TimerEvent.TIMER, OnTimerEvent);
			}
			mTimer = null;
			
			if (mMainSprite!= null && mMainSprite != null)
			{
				mMainSprite.removeEventListener(Event.ENTER_FRAME, Update);	
			}
			
			if (mRenderTarget != null)
			{
				mRenderTarget.bitmapData = null;
				mRenderTarget = null;
			}
			if (mRenderTargetData != null)
			{
				mRenderTargetData.dispose();
				mRenderTargetData = null;
			}
			mRenderTargetDataRect = null;
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
			mMainSprite = null;
			currentRenderTarget = null;
		}
				
		private function Update(e:Event):void 
		{
			//Clear the renderTarget
			
			mRenderTargetData.fillRect(mRenderTargetData.rect, COLOR_BACKGROUND);
			
			//Lock the renderTarget during Parsing/Drawing phase.
			mMaxDepth = 0;
			mDOTotal = 0;
			mRenderTargetData.lock();
				ParseStage(mMainSprite);
			mRenderTargetData.unlock();			
		}
		private function ParseStage(obj:DisplayObjectContainer, depth:int=1) : void
		{
			//trace("ParseStage", obj);
			//If obj is null, the object couln't be casted to container... slower but less validation and condition.
			if (obj == null || obj==FlashPreloadProfiler.MySprite) return; 
			
			if (mMaxDepth < depth) mMaxDepth = depth;
			for (var i:int = 0; i < obj.numChildren;i++)
			{
				mDOTotal++;
				var child:DisplayObject = obj.getChildAt(i);
				
				//If the child is null, just skip it. (it happens... don't know why yet)
				if (child == null) continue;
				
				//Get the rectangle around an object on the stage
				var rect:Rectangle = child.getRect(mMainSprite);
				
				//Don't use bad irrelevant data.
				rect = rect.intersection(mRenderTargetDataRect);
				
				//Create the rectangle in a graphics and draw in in bitmap
				currentRenderTarget.graphics.clear();
				
				if (child.visible == false || child.alpha == 0)
				{
					currentRenderTarget.graphics.beginFill(COLOR_XRAY_INVISIBLE, COLOR_ALPHA/6);
				}
				else
				{
					currentRenderTarget.graphics.beginFill(COLOR_XRAY, COLOR_ALPHA/6);
				}
				
				currentRenderTarget.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
				currentRenderTarget.graphics.endFill();
				mRenderTargetData.draw(currentRenderTarget);				

				//Parse all child objects
				ParseStage(child as DisplayObjectContainer, depth+1);
			}
		}
	}
}