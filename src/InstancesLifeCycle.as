package  
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
	import flash.sampler.getSize;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author jpauclair
	 */
	public class InstancesLifeCycle extends Sprite implements IDisposable
	{
		private static const COLOR_CREATE:int =		0xF29F05; 
		private static const COLOR_RE_USE:int =		0xED1C43;
		private static const COLOR_REMOVED:int =	0x64A4F6;
		private static const COLOR_WAITING_GC:int =	0xB1FF91;
		private static const COLOR_ALPHA:Number =	0.30;
		private static const COLOR_BACKGROUND:int =	0x444444;
		
		private var mMainSprite:Sprite = null;
		private var mAssetsDict:Dictionary = new Dictionary(true);		
		
		private var renderTarget1:Shape = new Shape();
		private var renderTarget2:Shape = new Shape();
		private var currentRenderTarget:Shape = renderTarget2;
		
		private var mInfos:TextField;
		
		private var mTimer:Timer;
		
		private var mAddedLastSecond:int = 0;
		private var mRemovedLastSecond:int = 0;
		private var mDOTotal:int = 0;
		private var mDOToCollect:int = 0;
		
		public function InstancesLifeCycle(mainSprite:Sprite) 
		{
			Init(mainSprite);
		}
		
		final  private function Init(mainSprite:Sprite) : void
		{
			mMainSprite = mainSprite;
			
			this.addChild(renderTarget1);
			this.addChild(renderTarget2);
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			mMainSprite.stage.addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, true);
			mMainSprite.stage.addEventListener(Event.REMOVED_FROM_STAGE, OnRemovedToStage, true);
			mMainSprite.stage.addEventListener(Event.ENTER_FRAME, Update);
			this.swapChildren(renderTarget1, renderTarget2);
			
			var barWidth:int = mMainSprite.stage.stageWidth;
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
			bgSprite.y = mMainSprite.stage.stageHeight - bgSprite.height;

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
			mInfos.y = mMainSprite.stage.stageHeight - bgSprite.height;

			mTimer = new Timer( 1000 );
			mTimer.addEventListener( TimerEvent.TIMER, OnTimerEvent,false,0,true);
			mTimer.start();
		
			ParseStage(mMainSprite);
			trace("Instances life initialized");
			
			
		}
		
		final public function Dispose() : void
		{
			trace("Diposing Instances life");
			
			mInfos = null;
			
			if (mTimer != null)
			{
				mTimer.removeEventListener(TimerEvent.TIMER, OnTimerEvent);
			}
			mTimer = null;

			
			if (mMainSprite != null && mMainSprite.stage != null)
			{
				mMainSprite.stage.removeEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, true);
				mMainSprite.stage.removeEventListener(Event.REMOVED_FROM_STAGE, OnRemovedToStage, true);
				mMainSprite.stage.removeEventListener(Event.ENTER_FRAME, Update);
				mMainSprite = null;
			}
			mAssetsDict = null;
		
			renderTarget1 = null;
			renderTarget2 = null;
			currentRenderTarget = null;
			
		}
		
		private function OnTimerEvent(e:TimerEvent):void 
		{
			var text:String = "DisplayObjectOnStage[ " 
							+ mDOTotal 
							+ " ]\tAddedToStage[ "
							+ mAddedLastSecond 
							+ " ]\tRemovedFromStage[ "
							+ mRemovedLastSecond
							+ " ]\tWaitingGC[ "
							+ mDOToCollect
							+ " ]";
							
			mInfos.text = text;
			mDOTotal = mDOTotal + mAddedLastSecond - mRemovedLastSecond;
			mRemovedLastSecond = mAddedLastSecond = 0;
			
		}
		
		final private function SwapRenderTarget() : void
		{
			if (currentRenderTarget == renderTarget1)
			{
				currentRenderTarget = renderTarget2;
			}
			else
			{
				currentRenderTarget = renderTarget1;
			}
			this.swapChildren(renderTarget1, renderTarget2);
		}
		
		final private function Update(e:Event):void 
		{
			SwapRenderTarget();
		
			
			currentRenderTarget.graphics.clear();

			currentRenderTarget.graphics.beginFill(COLOR_BACKGROUND, COLOR_ALPHA/1);
			currentRenderTarget.graphics.drawRect(0,0,mMainSprite.stage.stageWidth,mMainSprite.stage.stageHeight);
			currentRenderTarget.graphics.endFill();
			
			var rect:Rectangle = null;
			mDOToCollect = 0;
			for (var obj3:Object in mAssetsDict)
			{
				if (obj3.stage != null && mAssetsDict[obj3] == false)
				{
					mDOToCollect++;
					rect = obj3.getRect(mMainSprite);
					currentRenderTarget.graphics.beginFill(COLOR_WAITING_GC, COLOR_ALPHA/4);
					currentRenderTarget.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
					currentRenderTarget.graphics.endFill();
					
				}
			}
		}
		
		private function OnAddedToStage(e:Event):void 
		{
			
			var obj : DisplayObject = e.target as DisplayObject;
			
			if (obj != mMainSprite)
			{
				
				
				var rect:Rectangle = obj.getRect(mMainSprite);
				var newObj:Boolean = true;
				if (mAssetsDict[obj] == true)
				{
					newObj = false;
				}
				if (newObj)
				{
					//trace("Added Create", e.currentTarget, e.target,rect);
					mAddedLastSecond++;
					currentRenderTarget.graphics.beginFill(COLOR_CREATE, 0.9);
					if (rect.width < 8 && rect.width < 8)
					{
						currentRenderTarget.graphics.drawCircle(rect.x, rect.y, 4);
					}
					else
					{
						currentRenderTarget.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
					}
					currentRenderTarget.graphics.endFill();

					mAssetsDict[obj] = true;
				}
				else
				{
					//trace("Added ReUSe", e.currentTarget, e.target);
					currentRenderTarget.graphics.beginFill(COLOR_RE_USE, 0.9);
					if (rect.width < 8 && rect.width < 8)
					{
						currentRenderTarget.graphics.drawCircle(rect.x, rect.y, 4);
					}
					else
					{
						currentRenderTarget.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
					}					
					
					currentRenderTarget.graphics.endFill();
				}
			}
		}

		private function OnRemovedToStage(e:Event):void 
		{
			//trace("Removed", e.currentTarget, e.target);
			var obj : DisplayObject = e.target as DisplayObject;
			
			
			if (obj != mMainSprite)
			{
				if (mAssetsDict[obj] == true)
				{
					mRemovedLastSecond++;
				}
				
				var rect:Rectangle = obj.getRect(mMainSprite);

				currentRenderTarget.graphics.beginFill(COLOR_REMOVED, 0.9);
				currentRenderTarget.graphics.drawRect(rect.x-2, rect.y-2, rect.width+4, rect.height+4);
				currentRenderTarget.graphics.endFill();
				
				mAssetsDict[obj] = false;
			}
		}
		
final private function ParseStage(obj:DisplayObjectContainer) : void
		{
			//trace("ParseStage", obj);
			//If obj is null, the object couln't be casted to container... slower but less validation and condition.
			if (obj == null) return; 
			for (var i:int = 0; i < obj.numChildren;i++)
			{
				mDOTotal++;
				ParseStage(obj.getChildAt(i) as DisplayObjectContainer);
			}
		}		
	}
}