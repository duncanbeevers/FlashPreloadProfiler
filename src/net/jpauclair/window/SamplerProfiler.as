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
	import net.jpauclair.data.ClassTypeStatsHolder;
	import net.jpauclair.IDisposable;
	import net.jpauclair.Options;
	import net.jpauclair.SampleAnalyzer;
	/**
	 * ...
	 * @author jpauclair
	 */
	
	//http://help.adobe.com/en_US/FlashPlatform/beta/reference/actionscript/3/flash/sampler/package.html

	public class SamplerProfiler extends Sprite implements IDisposable
	{
		
		private static const COLOR_BACKGROUND:int =	0x444444;
		
		private var mMainSprite:Stage= null;
			
		private var mBitmapBackgroundData:BitmapData = null;
		private var mBitmapLineData:BitmapData = null;
		private var mBitmapBackground:Bitmap = null;
		private var mBitmapLine:Bitmap = null;
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
			
			mBitmapBackgroundData = new BitmapData(mMainSprite.stageWidth, mMainSprite.stageHeight,true,0);
			mBitmapBackground = new Bitmap(mBitmapBackgroundData);
			
			mGridLine.width = mMainSprite.stageWidth;
			mGridLine.height = 1;
			
			
			mBitmapLineData = new BitmapData(mMainSprite.stageWidth, 13, true, 0x88FFD700);
			
			mBitmapLine = new Bitmap(mBitmapLineData);			
			mBitmapLine.y = -20;
			addChild(mBitmapBackground);
			addChild(mBitmapLine);

			
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

			//mainSprite.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
			
			//SampleAnalyzer.GetInstance().ResetStats();
			
			SampleAnalyzer.GetInstance().ObjectStatsEnabled = true;
			SampleAnalyzer.GetInstance().InternalEventStatsEnabled = false;			
			SampleAnalyzer.GetInstance().StartSampling();
			
		}
		private var mLastLen:int = 0
		public function Update():void 
		{
			
			if (mouseY >= 42 && mouseY < 42 + mLastLen*14)
			{
				mBitmapLine.y = mouseY - (mouseY % 14) - 3;
			}
			else 
			{
				mBitmapLine.y = -20;
			}			
			
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
			var maxLineCount:int = (stage.stageHeight - 25) / 16;
			if (len > maxLineCount) len = maxLineCount;
			//trace(len, maxLineCount);
			mBlittingTextFieldMatrix.identity();
			mBlittingTextFieldMatrix.ty = 22;

			mLastLen = len;
			
			//Column Name
			mBlittingTextFieldMatrix.tx = mClassPathColumnStartPos;
			mBlittingTextField.text = "[QName]";
			this.mBitmapBackgroundData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mAddedColumnStartPos;
			mBlittingTextFieldARight.text = "[Add]"
			this.mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			mBlittingTextFieldMatrix.tx = mDeletedColumnStartPos;
			mBlittingTextFieldARight.text = "[Del]"
			this.mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
			mBlittingTextFieldARight.text = "[Current]"
			this.mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			mBlittingTextFieldMatrix.tx = mCumulColumnStartPos;
			mBlittingTextFieldARight.text = "[Cumul]"
			this.mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
			
			mBlittingTextFieldMatrix.ty += 14;

			mGridLine.y = mBlittingTextFieldMatrix.ty+2;
			this.mBitmapBackgroundData.fillRect(mGridLine, 0xFFCCCCCC);
			
			
			for (var i:int = 0; i < len; i++)
			{
				holder = classList[i];
				mBlittingTextFieldMatrix.tx = mClassPathColumnStartPos;
				mBlittingTextField.text = holder.TypeName;
				this.mBitmapBackgroundData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

				mBlittingTextFieldMatrix.tx = mAddedColumnStartPos;
				mBlittingTextFieldARight.text = holder.Added.toString()
				this.mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


				mBlittingTextFieldMatrix.tx = mDeletedColumnStartPos;
				mBlittingTextFieldARight.text = holder.Removed.toString();
				this.mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


				mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
				mBlittingTextFieldARight.text = holder.Current.toString();
				this.mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


				mBlittingTextFieldMatrix.tx = mCumulColumnStartPos;
				mBlittingTextFieldARight.text = holder.Cumul.toString();
				this.mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
				
				holder.Added = 0;
				holder.Removed = 0;		
				mBlittingTextFieldMatrix.ty += 14;
				mGridLine.y = mBlittingTextFieldMatrix.ty+2;
				this.mBitmapBackgroundData.fillRect(mGridLine, 0xFFCCCCCC);
			}
			
			Render();
		}
		

		

		private function Render() : void
		{
			this.alpha = Options.mCurrentGradient / 10;
		}
		

		
		public function Dispose() : void
		{
			
			mGridLine = null;
			
			mBlittingTextField = null;
			mBlittingTextFieldARight = null;
			mBlittingTextFieldMatrix = null;

			mBitmapBackgroundData.dispose();
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

