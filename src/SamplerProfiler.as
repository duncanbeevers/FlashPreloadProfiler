package  
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
	import flash.geom.Matrix;
	import flash.geom.Point;
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
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author jpauclair
	 */
	
	//http://help.adobe.com/en_US/FlashPlatform/beta/reference/actionscript/3/flash/sampler/package.html

	public class SamplerProfiler extends Bitmap implements IDisposable
	{
		
		private static const COLOR_BACKGROUND:int =	0x444444;
		
		private var mMainSprite:Stage= null;
			
		private var mBitmapBackgroundData:BitmapData = null;
		private var mBitmapBackground:Bitmap = null;
		private var mGridLine:Rectangle = null;
		
		private var mClassPathColumnStartPos:int = 2
		private var mAddedColumnStartPos:int = 250;
		private var mDeletedColumnStartPos:int = 300;
		private var mCurrentColumnStartPos:int = 370;
		private var mCumulColumnStartPos:int = 430;
		private var mBlittingTextField:TextField;
		private var mBlittingTextFieldARight:TextField;
		private var mBlittingTextFieldMatrix:Matrix = null;
		
		private var frameCount:int = 0;		
		private var mLastTime:int = 0;
		
		public function SamplerProfiler(mainSprite:Stage) 
		{
			Init(mainSprite);
		}
		
		
		private function Init(mainSprite:Stage) : void
		{
			mMainSprite = mainSprite;
			mGridLine = new Rectangle();
			var numLines:int = 15;
			
			mBitmapBackgroundData = new BitmapData(mMainSprite.stageWidth, mMainSprite.stageHeight,true,0);
			
			mGridLine.width = mMainSprite.stageWidth;
			mGridLine.height = 1;
			this.bitmapData = mBitmapBackgroundData;
			
			mCumulColumnStartPos = mMainSprite.stageWidth - 110;
			mCurrentColumnStartPos = mCumulColumnStartPos - 80;
			mDeletedColumnStartPos = mCurrentColumnStartPos - 80;
			mAddedColumnStartPos = mDeletedColumnStartPos - 80;
			
			var barWidth:int = mMainSprite.stageWidth;

			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myformat2:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false ,null,null,null,null,TextFormatAlign.RIGHT);
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
			
			mBlittingTextField = new TextField();
			mBlittingTextField .autoSize = TextFieldAutoSize.LEFT;
			mBlittingTextField .defaultTextFormat = myformat;
			mBlittingTextField .selectable = false;
			mBlittingTextField .filters = [ myglow ];
			
			mBlittingTextFieldARight = new TextField();
			mBlittingTextFieldARight.autoSize = TextFieldAutoSize.RIGHT;
			mBlittingTextFieldARight.defaultTextFormat = myformat2;
			mBlittingTextFieldARight.selectable = false;
			mBlittingTextFieldARight.filters = [ myglow ];			
			
			mBlittingTextFieldMatrix = new Matrix();
			// Sampler
			
			if (mainSprite.loaderInfo.applicationDomain.hasDefinition("flash.sampler.setSamplerCallback"))
			{
				//setSamplerCallback(OnTimer);
			}

			mainSprite.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
			
			SampleAnalyzer.GetInstance().ResetStats();
			
			SampleAnalyzer.GetInstance().ObjectStatsEnabled = true;
			SampleAnalyzer.GetInstance().InternalEventStatsEnabled = false;			
			SampleAnalyzer.GetInstance().StartSampling();
			
		}
		
		private function OnEnterFrame(e:Event):void 
		{
			
			if (frameCount++ % Options.mCurrentClock != 0) return;
			var diff:int= getTimer()-mLastTime;
			mLastTime = getTimer();
			
			
			SampleAnalyzer.GetInstance().PauseSampling();
			SampleAnalyzer.GetInstance().ProcessSampling();
			
			mBitmapBackgroundData.fillRect(mBitmapBackgroundData.rect, 0xFF000000);
			
			var classList:Array = SampleAnalyzer.GetInstance().GetClassInstanciationStats();
			
			classList.sortOn("Cumul", Array.NUMERIC | Array.DESCENDING);
			
			var holder:ClassTypeStatsHolder = null;
			var len:int = classList.length;
			if (len > 20) len = 20;

			mBlittingTextFieldMatrix.identity();
			mBlittingTextFieldMatrix.ty = 22;

			
			//Column Name
			mBlittingTextFieldMatrix.tx = mClassPathColumnStartPos;
			mBlittingTextField.text = "[QName]";
			this.bitmapData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mAddedColumnStartPos;
			mBlittingTextFieldARight.text = "[Add]"
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			mBlittingTextFieldMatrix.tx = mDeletedColumnStartPos;
			mBlittingTextFieldARight.text = "[Del]"
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
			mBlittingTextFieldARight.text = "[Current]"
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			mBlittingTextFieldMatrix.tx = mCumulColumnStartPos;
			mBlittingTextFieldARight.text = "[Cumul]"
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
			
			mBlittingTextFieldMatrix.ty += 14;

			mGridLine.y = mBlittingTextFieldMatrix.ty+2;
			this.bitmapData.fillRect(mGridLine, 0xFFCCCCCC);
			
			
			for (var i:int = 0; i < len; i++)
			{
				holder = classList[i];
				mBlittingTextFieldMatrix.tx = mClassPathColumnStartPos;
				mBlittingTextField.text = holder.TypeName;
				this.bitmapData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

				mBlittingTextFieldMatrix.tx = mAddedColumnStartPos;
				mBlittingTextFieldARight.text = holder.Added.toString()
				this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


				mBlittingTextFieldMatrix.tx = mDeletedColumnStartPos;
				mBlittingTextFieldARight.text = holder.Removed.toString();
				this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


				mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
				mBlittingTextFieldARight.text = holder.Current.toString();
				this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


				mBlittingTextFieldMatrix.tx = mCumulColumnStartPos;
				mBlittingTextFieldARight.text = holder.Cumul.toString();
				this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
				
				holder.Added = 0;
				holder.Removed = 0;		
				mBlittingTextFieldMatrix.ty += 14;
				mGridLine.y = mBlittingTextFieldMatrix.ty+2;
				this.bitmapData.fillRect(mGridLine, 0xFFCCCCCC);
			}
			
			Render();
			
			SampleAnalyzer.GetInstance().ClearSamples();
			SampleAnalyzer.GetInstance().ResumeSampling();
		}
		

		

		private function Render() : void
		{
			this.alpha = Options.mCurrentGradient / 10;
		}
		

		
		public function Dispose() : void
		{
			SampleAnalyzer.GetInstance().StopSampling();
			SampleAnalyzer.GetInstance().ClearSamples();

			
			mGridLine = null;
			
			mBlittingTextField = null;
			mBlittingTextFieldARight = null;
			mBlittingTextFieldMatrix = null;

			mBitmapBackgroundData.dispose();
			mBitmapBackgroundData = null;
			mBitmapBackground = null;
			
			if (mMainSprite.hasEventListener(Event.ENTER_FRAME)) mMainSprite.removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
			
			if (mMainSprite != null && mMainSprite != null)
			{
				mMainSprite = null;
			}
		}
		
	}
}

