package net.jpauclair.window
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.net.LocalConnection;
	import flash.sampler.clearSamples;
	import flash.sampler.DeleteObjectSample;
	import flash.sampler.getSamples;
	import flash.sampler.getSize;
	import flash.sampler.NewObjectSample;
	import flash.sampler.pauseSampling;
	import flash.sampler.Sample;
	import flash.sampler.setSamplerCallback;
	import flash.sampler.StackFrame;
	import flash.sampler.startSampling;
	import flash.sampler.stopSampling;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import net.jpauclair.data.InternalEventsStatsHolder;
	import net.jpauclair.IDisposable;
	import net.jpauclair.Options;
	import net.jpauclair.SampleAnalyzer;
	import net.jpauclair.ui.button.MenuButton;
	/**
	 * ...
	 * @author jpauclair
	 */
	
	//http://help.adobe.com/en_US/FlashPlatform/beta/reference/actionscript/3/flash/sampler/package.html

	public class InternalEventsProfiler extends Bitmap implements IDisposable
	{
		
		private static const COLOR_BACKGROUND:int =	0x444444;
		
		private static const VERIFY_COLOR:uint = 		0xFF00FFFF;
		private static const REAP_COLOR:uint = 			0xFF663000;
		private static const MARK_COLOR:uint = 			0xFFFFEF24;
		private static const SWEEP_COLOR:uint = 		0xFFE80000;
		
		private static const ENTER_FRAME_COLOR:uint = 	0xFFADD9CE;
		private static const TIMERS_COLOR:uint = 		0xFF1B4B94;	
		private static const PRE_RENDER_COLOR:uint = 	0xFF7B52AB;
		private static const RENDER_COLOR:uint = 		0xFF00CD73;
		

		private static const AVM1_COLOR:uint = 			0xFF6E7A16;
		private static const IO_COLOR:uint = 			0xFF22DE00;
		private static const MOUSE_COLOR:uint = 		0xFFFF00D8;
		private static const EXECUTE_QUEUE_COLOR:uint =	0xFFFFFFFF;
		
		private static const FREE_COLOR:uint 		=	0xFFFFFFFF;
		
								// [abc-decode]() 561226135231 global$init(),[abc-decode]()
								// [enter-frame]()
								// [openEvent]() 561230207465 [verify]()
								// [swf]() 561230432373 [swf]()

															
		private var mMainSprite:Stage= null;
			
		private var mInternalEventsLabels:TextField;
		
		private var mFrameDivisionData:BitmapData = null;
		private var mFrameDivision:Bitmap = null;
		
		private var mInterface:Sprite = null;
		
		private var mBitmapBackgroundData:BitmapData = null;
		private var mBitmapBackground:Bitmap = null;
		
		
		private var frameCount:int = 0;		
		
		public function InternalEventsProfiler(mainSprite:Stage) 
		{
			Init(mainSprite);
		}
		
		 private function Init(mainSprite:Stage) : void
		{
			
			mMainSprite = mainSprite;
			mInterface = new Sprite();
			
			mBitmapBackgroundData = new BitmapData(mMainSprite.stageWidth, mMainSprite.stageHeight,true,0);
			
			this.bitmapData = mBitmapBackgroundData;
			
			
			var barWidth:int = mMainSprite.stageWidth;
			var bgSprite:Sprite = new Sprite();
			mInterface.graphics.beginFill(0x000000, 1);
			mInterface.graphics.drawRect(0, 18, barWidth, mMainSprite.stageHeight-18);
			mInterface.graphics.endFill();
			mInterface.graphics.beginFill(0xCCCCCC, 1);
			mInterface.graphics.drawRect(0, 19, barWidth, 1);
			mInterface.graphics.endFill();
			mInterface.graphics.beginFill(0xFFFFFF, 1);
			mInterface.graphics.drawRect(0, 18, barWidth, 1);
			mInterface.graphics.endFill();

			
			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myformat2:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false ,null,null,null,null,TextFormatAlign.RIGHT);
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
			var txtField:TextField
			var yPos:int = 22;
			
			mFrameDivisionData = new BitmapData( mainSprite.stageWidth, mainSprite.stageHeight-50-22, false, 0);
			mFrameDivision = new Bitmap(mFrameDivisionData);
			mInterface.addChild(mFrameDivision);
			mFrameDivision.x = 0;
			mFrameDivision.y =mainSprite.stageHeight- mFrameDivisionData.height;			
			
			var mEventsHeaderData:BitmapData = new BitmapData(mainSprite.stageWidth, 50, false, 0);
			var mEventsHeader:Bitmap = new Bitmap(mEventsHeaderData);
			mEventsHeader.y = 22;
			mInterface.addChild(mEventsHeader);
			var rect:Rectangle = new Rectangle();
			rect.width = rect.height = 10;

			mInternalEventsLabels = new TextField();
			mInternalEventsLabels.autoSize = TextFieldAutoSize.LEFT;
			mInternalEventsLabels.defaultTextFormat = myformat;
			mInternalEventsLabels.selectable = false;
			mInternalEventsLabels.filters = [ myglow ];
			var m:Matrix = new Matrix();
			m.identity();
			
			rect.x = 4; rect.y = 2; 
			mEventsHeaderData.fillRect(rect, VERIFY_COLOR);
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "VERIFY";
			mEventsHeaderData.draw(mInternalEventsLabels, m);
			
			rect.x = 4+1*100; rect.y = 2; 
			mEventsHeaderData.fillRect(rect, MARK_COLOR);
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "MARK";
			mEventsHeaderData.draw(mInternalEventsLabels, m);
			
			rect.x = 4+2*100; rect.y = 2; 
			mEventsHeaderData.fillRect(rect, REAP_COLOR);
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "REAP";
			mEventsHeaderData.draw(mInternalEventsLabels, m);
			
			rect.x = 4+3*100; rect.y = 2; 
			mEventsHeaderData.fillRect(rect, SWEEP_COLOR);
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "SWEEP";
			mEventsHeaderData.draw(mInternalEventsLabels, m);			
			
			rect.x = 4; rect.y = 2+1*14; 
			mEventsHeaderData.fillRect(rect, ENTER_FRAME_COLOR);
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "ENTER FRAME";
			mEventsHeaderData.draw(mInternalEventsLabels, m);			
			
			rect.x = 4+1*100; rect.y = 2+1*14; 
			mEventsHeaderData.fillRect(rect, TIMERS_COLOR);
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "TIMERS";
			mEventsHeaderData.draw(mInternalEventsLabels, m);			
			
			rect.x = 4+2*100; rect.y = 2+1*14; 
			mEventsHeaderData.fillRect(rect, PRE_RENDER_COLOR);
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "PRE-RENDER";
			mEventsHeaderData.draw(mInternalEventsLabels, m);			
			
			rect.x = 4+3*100; rect.y = 2+1*14; 
			mEventsHeaderData.fillRect(rect, RENDER_COLOR);			
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "RENDER";
			mEventsHeaderData.draw(mInternalEventsLabels, m);			
			
			rect.x = 4+0*100; rect.y = 2+2*14; 
			mEventsHeaderData.fillRect(rect, AVM1_COLOR);			
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "AVM1";
			mEventsHeaderData.draw(mInternalEventsLabels, m);						

			rect.x = 4+1*100; rect.y = 2+2*14; 
			mEventsHeaderData.fillRect(rect, IO_COLOR);			
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "IO";
			mEventsHeaderData.draw(mInternalEventsLabels, m);						

			rect.x = 4+2*100; rect.y = 2+2*14; 
			mEventsHeaderData.fillRect(rect, MOUSE_COLOR);			
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "MOUSE";
			mEventsHeaderData.draw(mInternalEventsLabels, m);						

			rect.x = 4+3*100; rect.y = 2+2*14; 
			mEventsHeaderData.fillRect(rect, EXECUTE_QUEUE_COLOR);			
			m.tx = rect.x + 12; m.ty = rect.y-4;
			mInternalEventsLabels.text = "FREE";
			mEventsHeaderData.draw(mInternalEventsLabels, m);						

			
			rect.x = 0; rect.y = mEventsHeaderData.height - 5; rect.width = mEventsHeaderData.width, rect.height = 3;
			mEventsHeaderData.fillRect(rect, 0xFF888888);
			rect.x = 0; rect.y = mEventsHeaderData.height - 4; rect.width = mEventsHeaderData.width, rect.height = 1;
			mEventsHeaderData.fillRect(rect, 0xFFFFFFFF);
			
			// Sampler
			if (mainSprite.loaderInfo.applicationDomain.hasDefinition("flash.sampler.setSamplerCallback"))
			{
				//setSamplerCallback(OnTimer);
			}

			//mainSprite.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
			SampleAnalyzer.GetInstance().ObjectStatsEnabled = false;
			SampleAnalyzer.GetInstance().InternalEventStatsEnabled = true;
			SampleAnalyzer.GetInstance().StartSampling();
		}
		
		private var mLastTime:int = 0;
		public function Update():void 
		{
			
			if (frameCount++ % Options.mCurrentClock != 0) return;
			var diff:int= getTimer()-mLastTime;
			mLastTime = getTimer();
			
			SampleAnalyzer.GetInstance().PauseSampling();
			SampleAnalyzer.GetInstance().ProcessSampling();
			
			var internalEvents:InternalEventsStatsHolder = SampleAnalyzer.GetInstance().GetInternalsEvents();
			var totalTime:Number = internalEvents.FrameTime//+selfTime;
			//Console.Trace("diff: "+ diff + " total: " + totalTime, 0xFFFFFFFF);
			//mClassPaths[0].text = "diff: "+ diff + " total: " + int(internalEvents.reapTime/1000)//int(totalTime/1000);
			var lastX:uint = 0;
			var ratio:uint = 0;
			mFrameDivisionData.scroll(0, 4);
			ratio = Math.ceil(internalEvents.mVerify.entryTime / totalTime * mFrameDivisionData.width);
			mFrameDivisionData.fillRect(new Rectangle(lastX, 0, ratio, 2), VERIFY_COLOR);
			lastX += ratio;
			
			ratio = Math.ceil(internalEvents.mMark.entryTime / totalTime * mFrameDivisionData.width);
			mFrameDivisionData.fillRect(new Rectangle(lastX, 0, ratio, 2), MARK_COLOR);
			lastX += ratio;		
			
			ratio = Math.ceil(internalEvents.mReap.entryTime / totalTime * mFrameDivisionData.width);
			mFrameDivisionData.fillRect(new Rectangle(lastX, 0, ratio, 2), REAP_COLOR);
			lastX += ratio;
			
			ratio = Math.ceil(internalEvents.mSweep.entryTime / totalTime * mFrameDivisionData.width);
			mFrameDivisionData.fillRect(new Rectangle(lastX, 0, ratio, 2), SWEEP_COLOR);
			lastX += ratio;
			
			ratio = Math.ceil(internalEvents.mEnterFrame.entryTime / totalTime * mFrameDivisionData.width);
			//mClassPaths[0].text = ratio;
			mFrameDivisionData.fillRect(new Rectangle(lastX, 0, ratio, 2), ENTER_FRAME_COLOR);
			lastX += ratio;
			
			ratio = Math.ceil(internalEvents.mTimers.entryTime / totalTime * mFrameDivisionData.width);
			//mClassPaths[0].text = ratio;
			mFrameDivisionData.fillRect(new Rectangle(lastX, 0, ratio, 2), TIMERS_COLOR);
			lastX += ratio;
			
			ratio = Math.ceil(internalEvents.mPreRender.entryTime / totalTime * mFrameDivisionData.width);
			mFrameDivisionData.fillRect(new Rectangle(lastX, 0, ratio, 2), PRE_RENDER_COLOR);
			lastX += ratio;
			
			ratio = Math.ceil(internalEvents.mRender.entryTime / totalTime * mFrameDivisionData.width);
			mFrameDivisionData.fillRect(new Rectangle(lastX, 0, ratio, 2), RENDER_COLOR);
			lastX += ratio;		

			ratio = Math.ceil(internalEvents.mFree.entryTime / totalTime * mFrameDivisionData.width);
			mFrameDivisionData.fillRect(new Rectangle(lastX, 0, ratio, 2), FREE_COLOR);
			lastX += ratio;
			
			ratio = Math.ceil(internalEvents.mFree.entryCount*33 / totalTime * mFrameDivisionData.width);
			mFrameDivisionData.fillRect(new Rectangle(lastX, 0, 1, 2), 0xFF000000);
			mFrameDivisionData.fillRect(new Rectangle(lastX+1, 0, 1, 2), 0xFFFFFFFF);
			mFrameDivisionData.fillRect(new Rectangle(lastX+2, 0, 1, 2), 0xFF000000);
			//ratio = Math.ceil(selfTime / totalTime * mFrameDivisionData.width);
			//mFrameDivisionData.fillRect(new Rectangle(lastX, 0, ratio, 2), 0xFF000000);
			//lastX += ratio;		
			
			internalEvents.ResetFrame();
			
			Render();
		}
		

		private function Render() : void
		{
			mBitmapBackgroundData.lock();
			mBitmapBackgroundData.floodFill(0, 0,0);
			mBitmapBackgroundData.draw(mInterface,null);
			mBitmapBackgroundData.unlock(mBitmapBackgroundData.rect);
			this.alpha = Options.mCurrentGradient / 10;
			this.cacheAsBitmap = true;
		}
		
		public function Dispose() : void
		{
			mInterface.graphics.clear();
			
			mInternalEventsLabels = null;
			
			mFrameDivisionData = null;
			mFrameDivision = null;
			
			mInterface = null;
			
			mBitmapBackgroundData = null;
			mBitmapBackground = null;
			
			//if (mMainSprite.hasEventListener(Event.ENTER_FRAME)) mMainSprite.removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
			
			if (mMainSprite != null && mMainSprite != null)
			{
				mMainSprite = null;
			}
		}
		
	}
}

