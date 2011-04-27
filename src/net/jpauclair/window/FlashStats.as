package net.jpauclair.window
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import net.jpauclair.data.FrameStatistics;
	import net.jpauclair.IDisposable;
	import net.jpauclair.Options;
	
	
	public class FlashStats extends Bitmap implements IDisposable
	{
		
		private static const COLOR_BACKGROUND:int =	0x444444;
		
		private var mMainStage:Stage= null;
			
		private var mMemoryUseBitmapData:BitmapData = null;
		
		private var mBitmapBackgroundData:BitmapData = null;
		private var mBitmapBackground:Bitmap = null;
		private var mGridLine:Rectangle = null;
		
		private var mTypeColumnStartPos:int = 2
		private var mCurrentColumnStartPos:int = 80;
		private var mMinColumnStartPos:int = 130;
		private var mMaxColumnStartPos:int = 180;
		
		private var mBlittingTextField:TextField;
		private var mBlittingTextFieldARight:TextField;
		private var mBlittingTextFieldMatrix:Matrix = null;
		
		private var frameCount:int = 0;		
		private var mLastTime:int = 0;
		
		static public var stats:FrameStatistics = new FrameStatistics();
		private var statsLastFrame:FrameStatistics ;
		private var timer:int;
		private var ms_prev:int;
		private var fps:int=0;
		private var mDrawGraphics:Sprite;
		private var mDrawGraphicsMatrix:Matrix;
		private var mGraphPos:Point;

		private var mCurrentMaxMemGraph:int = 0;
		static public var mMemoryValues:Vector.<int> = null;
		static public var mMemoryMaxValues:Vector.<int> = null;
		static public var mSamplingCount:int = 300;
		static public var mSamplingStartIdx:int = 0;
		static public var IsStaticInitialized:Boolean = InitStatic();
		public function FlashStats(mainStage:Stage)
		{
			mProfilerWasActive = Configuration.PROFILE_MEMGRAPH;
			Configuration.PROFILE_MEMGRAPH = true;
			
			Init(mainStage);
		}
		
		private static function InitStatic() : Boolean
		{
			//mSamplingCount = int(mMainSprite.stageWidth / 5) + 1;
			mMemoryValues = new Vector.<int>(mSamplingCount);
			mMemoryMaxValues = new Vector.<int>(mSamplingCount);
			for (var i:int = 0; i < mSamplingCount; i++)
			{
				mMemoryValues[i] = -1;
				mMemoryMaxValues[i] = -1
			}
			return true;
		}
		private function Init(mainStage:Stage) : void
		{
			
			statsLastFrame = new FrameStatistics();
			mMainStage = mainStage;
			mGridLine = new Rectangle();
			var numLines:int = 15;
			
			for (var i:int = 0; i < mSamplingCount; i++)
			{
				if (!mProfilerWasActive)
				{
					mMemoryMaxValues[i] = -1;
					mMemoryValues[i] = -1;
				}
				if (mMemoryMaxValues[i] > stats.MemoryMax) stats.MemoryMax = mMemoryMaxValues[i];
			}
			mBitmapBackgroundData = new BitmapData(mMainStage.stageWidth, mMainStage.stageHeight,true,0);

			mMemoryUseBitmapData = new BitmapData(mMainStage.stageWidth, 150,false,0xFFFFFFFF);
			mGraphPos = new Point(0, mMainStage.stageHeight - 150);
			mDrawGraphics = new Sprite();
			mDrawGraphicsMatrix = new Matrix(1,0,0,1,mMainStage.stageWidth-5);
			mDrawGraphics.graphics.lineStyle(3, 0xFFFF0000);
			
			mGridLine.width = mMainStage.stageWidth;
			mGridLine.height = 1;
			this.bitmapData = mBitmapBackgroundData;
			
			
			var barWidth:int = mMainStage.stageWidth;

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
			
			fps = mainStage.frameRate;
			stats.MemoryFree = System.freeMemory / 1024;
			stats.MemoryPrivate = System.privateMemory / 1024;
			
			stats.MemoryCurrent = System.totalMemory / 1024;
			statsLastFrame.Copy(stats);
			mCurrentMaxMemGraph = stats.MemoryCurrent;
			
			
		}
		
		private var lastGraphHeight:int = 0;
		private var mProfilerWasActive:Boolean = false;
		public function Update():void 
		{
			timer = getTimer();

			if ( timer - 1000 < ms_prev ) { fps++; return;  }

			//mSamplingStartIdx--;
			//if (mSamplingStartIdx < 0) mSamplingStartIdx = mSamplingCount - 1;
			stats.FpsCurrent = fps;
			ms_prev = timer;
			
			
			mBitmapBackgroundData.fillRect(mBitmapBackgroundData.rect, 0xFF000000);

			//Update statistics
			stats.MemoryFree = System.freeMemory / 1024;
			stats.MemoryPrivate = System.privateMemory / 1024;
			
			stats.MemoryCurrent = System.totalMemory / 1024;
			if (stats.MemoryCurrent < stats.MemoryMin) stats.MemoryMin = stats.MemoryCurrent;
			if (stats.MemoryCurrent > stats.MemoryMax)
			{
				stats.MemoryMax = stats.MemoryCurrent;
				
			}

			
			
			if (stats.FpsCurrent < stats.FpsMin) stats.FpsMin = stats.FpsCurrent;
			if (stats.FpsCurrent > stats.FpsMax) stats.FpsMax = stats.FpsCurrent;
			
			
			mBlittingTextFieldMatrix.identity();
			mBlittingTextFieldMatrix.ty = 22;

			if (Configuration.PROFILE_MEMGRAPH)
			{
			
				// Draw current values
				mDrawGraphics.graphics.clear();
				
				var sliceWidth:Number = stage.stageWidth / mSamplingCount;
				var i:int = 0;
				var sampleVal:int = 0;
				var val:int = 0;
				
				mDrawGraphics.graphics.lineStyle(5, 0xFFFF0000);
				var it:int = mSamplingStartIdx;
				var currentX:int = mSamplingCount*sliceWidth;
				mDrawGraphics.graphics.moveTo(currentX, 150)
				for (i= 0; i<mSamplingCount; i++)
				{
					
					sampleVal = mMemoryMaxValues[it % mSamplingCount];
					it++;
					if (sampleVal == -1) continue;
					val = 150 - (sampleVal / stats.MemoryMax * 148);
					mDrawGraphics.graphics.lineTo(currentX, val);
					currentX -= sliceWidth;
				}

				mDrawGraphics.graphics.lineStyle(3, 0xFF0000FF);
				it = mSamplingStartIdx;
				currentX = mSamplingCount*sliceWidth;
				mDrawGraphics.graphics.moveTo(currentX, 150)
				for (i = 0; i<mSamplingCount; i++)
				{
					
					sampleVal = mMemoryValues[it % mSamplingCount];
					it++;
					if (sampleVal == -1) continue;
					val = 150 - (sampleVal / stats.MemoryMax * 148);
					mDrawGraphics.graphics.lineTo(currentX, val);
					currentX -= sliceWidth;
				}

				
				mMemoryUseBitmapData.fillRect(mMemoryUseBitmapData.rect, 0xFF888888);
				mMemoryUseBitmapData.draw(mDrawGraphics);
			}
			//lastGraphHeight = newCurrent;
			
			//mDrawGraphics.graphics.clear();
			mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
			mBlittingTextFieldARight.text = "Current";
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mMinColumnStartPos;
			mBlittingTextFieldARight.text = "Min";
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mMaxColumnStartPos;
			mBlittingTextFieldARight.text = "Max";
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
			
			mBlittingTextFieldMatrix.ty += 14;
			mGridLine.y = mBlittingTextFieldMatrix.ty + 2;
			this.bitmapData.fillRect(mGridLine, 0xFFCCCCCC);
			
			
			
			// FPS
			mBlittingTextFieldMatrix.tx = mTypeColumnStartPos;
			mBlittingTextField.text = "fps:";
			this.bitmapData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

			
			
			mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
			mBlittingTextFieldARight.text = stats.FpsCurrent.toString() + " / " + mMainStage.frameRate;
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mMinColumnStartPos;
			mBlittingTextFieldARight.text = stats.FpsMin.toString();
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mMaxColumnStartPos;
			mBlittingTextFieldARight.text = stats.FpsMax.toString();
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);			
			
			mBlittingTextFieldMatrix.ty += 14;
			mGridLine.y = mBlittingTextFieldMatrix.ty + 2;
			this.bitmapData.fillRect(mGridLine, 0xFFCCCCCC);
			
			// Memory
			mBlittingTextFieldMatrix.tx = mTypeColumnStartPos;
			mBlittingTextField.text = "total-memory (Ko):";
			this.bitmapData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
			mBlittingTextFieldARight.text = stats.MemoryCurrent.toString();
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mMinColumnStartPos;
			mBlittingTextFieldARight.text = stats.MemoryMin.toString();
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mMaxColumnStartPos;
			mBlittingTextFieldARight.text = stats.MemoryMax.toString();
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);			
			
			mBlittingTextFieldMatrix.ty += 14;
			mGridLine.y = mBlittingTextFieldMatrix.ty + 2;
			this.bitmapData.fillRect(mGridLine, 0xFFCCCCCC);			

			// Free-Memory
			mBlittingTextFieldMatrix.tx = mTypeColumnStartPos;
			mBlittingTextField.text = "free-memory (Ko):";
			this.bitmapData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
			mBlittingTextFieldARight.text = stats.MemoryFree.toString();
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
			
			mBlittingTextFieldMatrix.ty += 14;
			mGridLine.y = mBlittingTextFieldMatrix.ty + 2;
			this.bitmapData.fillRect(mGridLine, 0xFFCCCCCC);		
			
			// Private-Memory
			mBlittingTextFieldMatrix.tx = mTypeColumnStartPos;
			mBlittingTextField.text = "private-memory (Ko):";
			this.bitmapData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
			mBlittingTextFieldARight.text = stats.MemoryPrivate.toString();
			this.bitmapData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
			
			mBlittingTextFieldMatrix.ty += 14;
			mGridLine.y = mBlittingTextFieldMatrix.ty + 2;
			this.bitmapData.fillRect(mGridLine, 0xFFCCCCCC);					
			
			Render();
			
			statsLastFrame.Copy(stats);
			fps = 0;
			
		}
		

		

		private function Render() : void
		{
			
			this.bitmapData.copyPixels(mMemoryUseBitmapData, mMemoryUseBitmapData.rect, mGraphPos);
			this.alpha = Options.mCurrentGradient / 10;
		}
		

		
		public function Dispose() : void
		{
			
			Configuration.PROFILE_MEMGRAPH = mProfilerWasActive;
			

			
			mMemoryUseBitmapData.dispose();
			mMemoryUseBitmapData = null;
			mBitmapBackgroundData.dispose();
			mBitmapBackgroundData = null;
			mBitmapBackground = null;
			mGridLine = null;
			mBlittingTextField = null;
			mBlittingTextFieldARight = null;
			mBlittingTextFieldMatrix = null;
		
			//stats = null;
			statsLastFrame = null;
			mDrawGraphics = null;
			mDrawGraphicsMatrix = null;
			mGraphPos = null;
			
			//mMemoryValues = null;
			//mMemoryMaxValues = null;
			
			if (mMainStage != null && mMainStage != null)
			{
				mMainStage = null;
			}
		}
		
	}
}

