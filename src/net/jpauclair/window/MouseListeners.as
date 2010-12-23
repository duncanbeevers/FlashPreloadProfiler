package net.jpauclair.window
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import net.jpauclair.FlashPreloadProfiler;
	import net.jpauclair.IDisposable;
	/**
	 * ...
	 * @author jpauclair
	 */
	public class MouseListeners extends Sprite implements IDisposable
	{
		
		private static const COLOR_MOVE:int =		0xB1FF91; 
		private static const COLOR_CLICK:int =		0xF29F05; 
		private static const COLOR_XRAY:int =		0xADBFD6; 
		private static const COLOR_ALPHA:Number =	0.30;
		private static const COLOR_BACKGROUND:int =	0x000000;
		
		private var mMainSprite:Stage = null;
		
		private var mRenderTargetData:BitmapData = null;
		private var mRenderTarget:Bitmap = null;
		private var mRenderTargetDataRect:Rectangle = null;		
		private var currentRenderTarget:Sprite = new Sprite();
		
		public function MouseListeners(mainSprite:Stage) 
		{
			Init(mainSprite);
		}
		
		private function Init(mainSprite:Stage) : void
		{
			mMainSprite = mainSprite;
			
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			
			mRenderTargetData = new BitmapData(mMainSprite.stageWidth, mMainSprite.stageHeight, false, 0);
			mRenderTargetDataRect = mRenderTargetData.rect;
			mRenderTarget = new Bitmap();
			mRenderTarget.bitmapData = mRenderTargetData;
			this.addChild(mRenderTarget);
			
			//mMainSprite.stage.addEventListener(Event.ENTER_FRAME, Update);
			trace("MouseListeners initialized");
		}
		
		 public function Dispose() : void
		{
			//if (mMainSprite!= null && mMainSprite.stage != null)
			//{
				//mMainSprite.stage.removeEventListener(Event.ENTER_FRAME, Update);	
			//}
			
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
		
				
		public function Update():void 
		{
			mRenderTargetData.fillRect(mRenderTargetData.rect, COLOR_BACKGROUND);
			mRenderTargetData.lock();
			ParseStage(mMainSprite);
			mRenderTargetData.unlock();
			//mMainSprite.visible = false;
			
		}
		protected function ParseStage(obj:DisplayObjectContainer) : void
		{
			if (obj == null || obj==FlashPreloadProfiler.MySprite) return;
			
			if (obj.mouseChildren == false) return;
			
			for (var i:int = 0; i < obj.numChildren;i++)
			{
				var child:DisplayObject = obj.getChildAt(i);
				
				if (child == null) continue;
				
				var iobj:InteractiveObject = child as InteractiveObject;
				if (iobj == null || iobj.mouseEnabled == false) continue;
				
				var rect:Rectangle = child.getRect(mMainSprite);
				
				//Don't use bad irrelevant data.
				rect = rect.intersection(mRenderTargetDataRect);

				currentRenderTarget.graphics.clear();
				if (iobj.hasEventListener(MouseEvent.CLICK) || iobj.hasEventListener(MouseEvent.MOUSE_DOWN) || iobj.hasEventListener(MouseEvent.MOUSE_UP))
				{
					currentRenderTarget.graphics.beginFill(COLOR_CLICK, COLOR_ALPHA / 2);
				}
				else if (iobj.hasEventListener(MouseEvent.MOUSE_MOVE) || iobj.hasEventListener(MouseEvent.MOUSE_OVER) || iobj.hasEventListener(MouseEvent.MOUSE_OUT))
				{
					currentRenderTarget.graphics.beginFill(COLOR_MOVE, COLOR_ALPHA / 2);
				}
				else
				{
					currentRenderTarget.graphics.beginFill(COLOR_XRAY, COLOR_ALPHA / 2);	
				}
				
				currentRenderTarget.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
				currentRenderTarget.graphics.endFill();
				mRenderTargetData.draw(currentRenderTarget);				
				ParseStage(child as DisplayObjectContainer);
				//trace(obj);
			}
		}
		
	}
}