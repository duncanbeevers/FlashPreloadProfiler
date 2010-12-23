package net.jpauclair.window
{
	import flash.desktop.Clipboard;
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
	import flash.sampler.getInvocationCount;
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
	import net.jpauclair.data.InternalEventEntry;
	import net.jpauclair.IDisposable;
	import net.jpauclair.Options;
	import net.jpauclair.SampleAnalyzer;
	import net.jpauclair.ui.button.MenuButton;
	/**
	 * ...
	 * @author jpauclair
	 */
	
	//http://help.adobe.com/en_US/FlashPlatform/beta/reference/actionscript/3/flash/sampler/package.html

	public class PerformanceProfiler extends Sprite implements IDisposable
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
		private var mDeletedColumnStartPos:int = 280;
		private var mCurrentColumnStartPos:int = 370;
		private var mCumulColumnStartPos:int = 430;
		private var mBlittingTextField:TextField;
		private var mBlittingTextFieldARight:TextField;
		private var mBlittingTextFieldMatrix:Matrix = null;
		
		private var frameCount:int = 0;		
		private var mLastTime:int = 0;
		
		private var mStackButtonArray:Array/*MenuButton*/;		

		[Embed(source='../../../../art/Stack.png')]
		private var IconStack:Class;		
		[Embed(source='../../../../art/StackOut.png')]
		private var IconStackOut:Class;		

		[Embed(source='../../../../art/ArrowDown.png')]
		private var IconArrowDown:Class;		
		[Embed(source='../../../../art/ArrowDownOut.png')]
		private var IconArrowDownOut:Class;			
		
		private var mSelfSortButton:MenuButton
		private var mTotalSortButton:MenuButton
		
		public function PerformanceProfiler(mainSprite:Stage) 
		{
			Init(mainSprite);
		}
		
		
		private function Init(mainSprite:Stage) : void
		{
			mMainSprite = mainSprite;
			mGridLine = new Rectangle();
			var numLines:int = 15;
			
			mBitmapBackgroundData = new BitmapData(mMainSprite.stageWidth, mMainSprite.stageHeight,true,0);
			mBitmapBackground = new Bitmap(mBitmapBackgroundData);
			
			mBitmapLineData = new BitmapData(mMainSprite.stageWidth, 13, true, 0x88FFD700);
			
			mBitmapLine = new Bitmap(mBitmapLineData);			
			mBitmapLine.y = -20;
			addChild(mBitmapBackground);
			addChild(mBitmapLine);
			//this.mouseChildren = false;
			this.mouseEnabled = false;
			
			mGridLine.width = mMainSprite.stageWidth;
			mGridLine.height = 1;
			//mBitmapBackground.bitmapData = mBitmapBackgroundData;
			
			mCumulColumnStartPos = mMainSprite.stageWidth - 110;
			mCurrentColumnStartPos = mCumulColumnStartPos - 40;
			mDeletedColumnStartPos = mCurrentColumnStartPos - 100;
			mAddedColumnStartPos = mDeletedColumnStartPos - 40;
			
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
			
			SampleAnalyzer.GetInstance().ObjectStatsEnabled = true;
			SampleAnalyzer.GetInstance().InternalEventStatsEnabled = false;			
			SampleAnalyzer.GetInstance().StartSampling();
			
			var maxLineCount:int = (mainSprite.stage.stageHeight - 25) / 16;
			mStackButtonArray = new Array();
			//addEventListener("copyStack", OnCopyStack,false,0,true);
			for (var i:int = 0; i < maxLineCount; i++)
			{
				var button:MenuButton = new MenuButton(3, 39 + i * 14, IconStackOut, IconStack, IconStackOut,SAVE_FUNCTION_STACK_EVENT, null, "",true,"Saved");
				mStackButtonArray.push(button);
				addChild(button);
				button.visible = false;
				
			}
			addEventListener(SAVE_FUNCTION_STACK_EVENT, OnSaveStack);
			
			mSelfSortButton = new MenuButton(mDeletedColumnStartPos-14, 25, IconArrowDownOut, IconArrowDown, IconArrowDownOut,null, null, "Sort by Self-Time",true,"");
			addChild(mSelfSortButton);
			
			mTotalSortButton= new MenuButton(mCumulColumnStartPos-14, 25, IconArrowDownOut, IconArrowDown, IconArrowDownOut,null, null, "Sort by Total-Time",true,"");
			addChild(mTotalSortButton);
				
			
			
		}
		
		private function OnSaveStack(e:Event):void 
		{
			var len:int = mStackButtonArray.length;
			for (var i:int = 0; i < len; i++)
			{
				var mbt:MenuButton = mStackButtonArray[i];
				if (mbt != null && mbt.mIsSelected)
				{
					
					var o:String = String(mbt.mInternalEvent.mStackFrame);
					while(o.indexOf(",") != -1)
					{
						o = o.replace(",", "\n");
					}
					System.setClipboard(o);
					
				}
				if (mbt!= null)
				{
					mbt.Reset();
				}
			}			
		}
		
		private function OnCopyStack(e:Event):void 
		{
			//trace("OnCopy", e.target, e.currentTarget);
			System.setClipboard(e.target.mInternalEvent.mStackFrame);
		}
		
		public static const SAVE_FUNCTION_STACK_EVENT:String = "saveFunctionStackEvent";
		private static const ZERO_PERCENT:String = "0.00";
		private var mLastLen:int = 0;
		private var mUseSelfSort:Boolean = true;
		public function Update():void 
		{
			if (mTotalSortButton.mIsSelected)
			{
				mUseSelfSort = false;
				mTotalSortButton.mIsSelected = false;
			}
			if (mSelfSortButton.mIsSelected)
			{
				mUseSelfSort = true;
				mSelfSortButton.mIsSelected = false;
			}
			
			
			
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
			
			var vFunctionTimes:Array = SampleAnalyzer.GetInstance().GetFunctionTimes();
			
			if (mUseSelfSort)
			{
				vFunctionTimes.sortOn("entryTime", Array.NUMERIC | Array.DESCENDING);
			}
			else
			{
				vFunctionTimes.sortOn("entryTimeTotal", Array.NUMERIC | Array.DESCENDING);
			}
			
			var len:int = mStackButtonArray.length;
			var i:int = 0;
			var holder:InternalEventEntry = null;
			len = vFunctionTimes.length;
			var totalTime:int = 0;
			
			mLastLen = len;
			
			for (i = 0; i < len; i++)
			{
				holder = vFunctionTimes[i];
				totalTime += holder.entryTime;
			}
			var maxLineCount:int = (stage.stageHeight - 25) / 16;
			if (len > maxLineCount) len = maxLineCount;
			//trace(len, maxLineCount);

			mBlittingTextFieldMatrix.identity();
			mBlittingTextFieldMatrix.ty = 22;

			
			//Column Name
			mBlittingTextFieldMatrix.tx = mClassPathColumnStartPos;
			mBlittingTextField.text = "[FunctionName]";
			mBitmapBackgroundData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mDeletedColumnStartPos;
			mBlittingTextFieldARight.text = "(%)"
			mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			mBlittingTextFieldMatrix.tx = mAddedColumnStartPos;
			mBlittingTextFieldARight.text = "[Self] (µs)"
			mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
			mBlittingTextFieldARight.text = "[Total] (µs)"
			mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			mBlittingTextFieldMatrix.tx = mCumulColumnStartPos;
			mBlittingTextFieldARight.text ="(%)"
			mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
			
			mBlittingTextFieldMatrix.ty += 14;

			mGridLine.y = mBlittingTextFieldMatrix.ty+2;
			mBitmapBackgroundData.fillRect(mGridLine, 0xFFCCCCCC);
			
			
			
			for (i = 0; i < len; i++)
			{
				mStackButtonArray[i].visible = true;
				
				holder = vFunctionTimes[i];
				if (mStackButtonArray[i].mInternalEvent != holder)
				{
					mStackButtonArray[i].SetToolTipText("// Click = Copy to Clipboard\n" + holder.mStack);
					mStackButtonArray[i].mInternalEvent = holder;
				}
				mBlittingTextFieldMatrix.tx = mClassPathColumnStartPos + 16;
				mBlittingTextField.text = holder.qName;
				//var name:QName = new QName(null, holder.qName);
				//trace(holder.qName, getInvocationCount(null, name));
				mBitmapBackgroundData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

				mBlittingTextFieldMatrix.tx = mDeletedColumnStartPos;
				var percent:Number = int((holder.entryTime / totalTime) * 10000) / 100;
				if (percent == 0)
				{
					mBlittingTextFieldARight.text = ZERO_PERCENT;
				}
				else
				{
					mBlittingTextFieldARight.text = String(percent)
				}
				
				mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


				mBlittingTextFieldMatrix.tx = mAddedColumnStartPos;
				mBlittingTextFieldARight.text = holder.entryTime.toString();
				mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


				mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
				mBlittingTextFieldARight.text = holder.entryTimeTotal.toString();
				mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
//
//
				mBlittingTextFieldMatrix.tx = mCumulColumnStartPos;
				percent = int((holder.entryTimeTotal / totalTime) * 10000) / 100;
				if (percent == 0)
				{
					mBlittingTextFieldARight.text = ZERO_PERCENT;
				}
				else
				{
					mBlittingTextFieldARight.text = String(percent)
				}
				mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
				
				//holder.Added = 0;
				//holder.Removed = 0;		
				mBlittingTextFieldMatrix.ty += 14;
				mGridLine.y = mBlittingTextFieldMatrix.ty+2;
				mBitmapBackgroundData.fillRect(mGridLine, 0xFFCCCCCC);
			}
			
			Render();
		}
		

		

		private function Render() : void
		{
			this.alpha = Options.mCurrentGradient / 10;
		}
		

		
		public function Dispose() : void
		{
			for each (var mb:MenuButton in mStackButtonArray)
			{
				mb.Dispose();
			}
			mStackButtonArray = null;
			
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

