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
	import net.jpauclair.data.LoaderData;
	import net.jpauclair.IDisposable;
	import net.jpauclair.LoaderAnalyser;
	import net.jpauclair.Options;
	import net.jpauclair.SampleAnalyzer;
	import net.jpauclair.ui.button.MenuButton;
	/**
	 * ...
	 * @author jpauclair
	 */
	
	//http://help.adobe.com/en_US/FlashPlatform/beta/reference/actionscript/3/flash/sampler/package.html

	public class LoaderProfiler extends Sprite implements IDisposable
	{
		
		private static const COLOR_BACKGROUND:int =	0x444444;
		
		private var mMainSprite:Stage= null;
			
		private var mBitmapBackgroundData:BitmapData = null;
		private var mBitmapLineData:BitmapData = null;
		private var mBitmapBackground:Bitmap = null;
		private var mBitmapLine:Bitmap = null;
		private var mGridLine:Rectangle = null;
		
		private var mProgressCenterPosition:int = 2
		private var mAddedColumnStartPos:int = 250;
		private var mURLColPosition:int = 280;
		private var mSizeColPosition:int = 280;
		private var mCurrentColumnStartPos:int = 370;
		private var mHTTPStatusColPosition:int = 430;
		private var mBlittingTextField:TextField;
		private var mBlittingTextFieldCenter:TextField;
		private var mBlittingTextFieldARight:TextField;
		private var mBlittingTextFieldMatrix:Matrix = null;
		
		private var frameCount:int = 0;		
		private var mLastTime:int = 0;
		
		private var mStackButtonArray:Array/*MenuButton*/;		

		private var mLoaderDict:Dictionary;
		[Embed(source='../../../../art/IconClipboard.png')]
		private var IconStack:Class;		
		[Embed(source='../../../../art/IconClipboardOut.png')]
		private var IconStackOut:Class;		

		[Embed(source='../../../../art/ArrowDown.png')]
		private var IconArrowDown:Class;		
		[Embed(source='../../../../art/ArrowDownOut.png')]
		private var IconArrowDownOut:Class;			
		
		public function LoaderProfiler(mainSprite:Stage) 
		{
			Init(mainSprite);
		}
		
		
		private function Init(mainSprite:Stage) : void
		{
			mMainSprite = mainSprite;
			mGridLine = new Rectangle();
			var numLines:int = 15;
			
			mLoaderDict = new Dictionary(true);
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
			
			
			mProgressCenterPosition = 20;
			mHTTPStatusColPosition = 70
			
			mSizeColPosition = 130;
			mURLColPosition = 235;
			//mCurrentColumnStartPos = mHTTPStatusColPosition - 40;
			
			mAddedColumnStartPos = 100;
			
			var barWidth:int = mMainSprite.stageWidth;

			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myformat2:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false ,null,null,null,null,TextFormatAlign.RIGHT);
			var myformatCenter:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false ,null,null,null,null,TextFormatAlign.CENTER);
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

			mBlittingTextFieldCenter = new TextField();
			mBlittingTextFieldCenter.autoSize = TextFieldAutoSize.CENTER;
			mBlittingTextFieldCenter.defaultTextFormat = myformatCenter;
			mBlittingTextFieldCenter.selectable = false;
			mBlittingTextFieldCenter.filters = [ myglow ];
			
			mBlittingTextFieldMatrix = new Matrix();
			// Sampler
			
			if (mainSprite.loaderInfo.applicationDomain.hasDefinition("flash.sampler.setSamplerCallback"))
			{
				//setSamplerCallback(OnTimer);
			}

			//mainSprite.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
			
			//SampleAnalyzer.GetInstance().StartSampling();
			
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
			
				
			
			
		}
		
		private function OnSaveStack(e:Event):void 
		{
			//trace("OnSaveStack");
			var len:int = mStackButtonArray.length;
			for (var i:int = 0; i < len; i++)
			{
				var mbt:MenuButton = mStackButtonArray[i];
				if (mbt != null && mbt.mIsSelected)
				{
					//trace("OnSaveStack-valid mbt");
					if (mbt.mUrl != null && mbt.mUrl != "")
					{
						//trace("url");
						System.setClipboard(mbt.mUrl);
					}
					else if (mbt.mLD != null && mbt.mLD.mIOError)
					{
						//trace("io");
						System.setClipboard(mbt.mLD.mIOError.toString());
					}
					else if (mbt.mLD != null && mbt.mLD.mSecurityError)
					{
						//trace("security");
						System.setClipboard(mbt.mLD.mSecurityError.toString());
					}
					
				}
				if (mbt!= null)
				{
					mbt.Reset();
				}
			}			
		}
		
		public static const SAVE_FUNCTION_STACK_EVENT:String = "saveFunctionStackEvent";
		private static const ZERO_PERCENT:String = "0.00";
		private var mLastLen:int = 0;
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
			
			var len:int = mStackButtonArray.length;
			var i:int = 0;

			var vLoadersData:Array = LoaderAnalyser.GetInstance().GetLoadersData();
			vLoadersData.sortOn("mFirstEvent", Array.NUMERIC | Array.DESCENDING);
			var lCount:int = vLoadersData.length;

			len = vLoadersData.length;
			var maxLineCount:int = (stage.stageHeight - 25) / 16;
			if (len > maxLineCount) len = maxLineCount;

			
			mBlittingTextFieldMatrix.identity();
			mBlittingTextFieldMatrix.ty = 22;

			
			//Column Name
			mBlittingTextFieldMatrix.tx = mProgressCenterPosition;
			mBlittingTextFieldCenter.text = "Progress";
			mBitmapBackgroundData.draw(mBlittingTextFieldCenter, mBlittingTextFieldMatrix);

			mBlittingTextFieldMatrix.tx = mURLColPosition;
			mBlittingTextField.text = "Url"
			mBitmapBackgroundData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

			
			//mBlittingTextFieldMatrix.tx = mURLColPosition;
			//mBlittingTextFieldARight.text = "(%)"
			//mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			//mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
			//mBlittingTextFieldARight.text = "[Total] (µs)"
			//mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


			mBlittingTextFieldMatrix.tx = mHTTPStatusColPosition;
			mBlittingTextFieldARight.text ="Status"
			mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
			
			mBlittingTextFieldMatrix.tx = mSizeColPosition;
			mBlittingTextFieldARight.text ="Size"
			mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
			
			mBlittingTextFieldMatrix.ty += 14;

			mGridLine.y = mBlittingTextFieldMatrix.ty+2;
			mBitmapBackgroundData.fillRect(mGridLine, 0xFFCCCCCC);
			
			var ld:LoaderData = null;
			
			for (i = 0; i < len; i++)
			{
				
				
				
				
				ld = vLoadersData[i];
				if (ld.mFirstEvent == -1) continue;
				mStackButtonArray[i].visible = true;
				DrawProgress(vLoadersData[i], 40 + i * 14);
				if (mStackButtonArray[i].mUrl != ld.mUrl)
				{
					
					mStackButtonArray[i].SetToolTipText("// Click = Copy to Clipboard\n" + ld.mUrl);
					mStackButtonArray[i].mUrl = ld.mUrl;
					mStackButtonArray[i].mLD = ld;
				}
				else if (ld.mIOError)
				{
					mStackButtonArray[i].SetToolTipText("// Click = Copy to Clipboard\n" + ld.mIOError.text + "\n" + ld.mIOError);
				}
				else if (ld.mSecurityError)
				{
					mStackButtonArray[i].SetToolTipText("// Click = Copy to Clipboard\n" + ld.mSecurityError.text + "\n" + ld.mSecurityError);
				}
				

				
				mBlittingTextFieldMatrix.tx = mProgressCenterPosition;
				mBlittingTextFieldCenter.text = ld.mProgressText;
				mBitmapBackgroundData.draw(mBlittingTextFieldCenter, mBlittingTextFieldMatrix);

				mBlittingTextFieldMatrix.tx = mHTTPStatusColPosition;
				if (ld.mHTTPStatusText == null)
				{
					mBlittingTextFieldARight.text = LoaderData.LOADER_DEFAULT_HTTP_STATUS;
				}
				else
				{
					mBlittingTextFieldARight.text = ld.mHTTPStatusText; 
				}
				mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


				// SIZE
				mBlittingTextFieldMatrix.tx = mSizeColPosition;
				mBlittingTextFieldARight.text = ld.mLoadedBytesText; 
				mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
				
				
				
				mBlittingTextFieldMatrix.tx = mURLColPosition;
				if (ld.mUrl == null)
				{
					mBlittingTextField.text = LoaderData.LOADER_DEFAULT_URL;
				}
				else
				{
					mBlittingTextField.text = ld.mUrl; 
				}
				mBitmapBackgroundData.draw(mBlittingTextField, mBlittingTextFieldMatrix);

/*
				mBlittingTextFieldMatrix.tx = mAddedColumnStartPos;
				mBlittingTextFieldARight.text = holder.entryTime.toString();
				mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);


				mBlittingTextFieldMatrix.tx = mCurrentColumnStartPos;
				mBlittingTextFieldARight.text = holder.entryTimeTotal.toString();
				mBitmapBackgroundData.draw(mBlittingTextFieldARight, mBlittingTextFieldMatrix);
//
//
				mBlittingTextFieldMatrix.tx = mHTTPStatusColPosition;
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
				*/
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
		

		private var mProgressBarRect:Rectangle = new Rectangle(20, 0, 100, 11);
		private function DrawProgress(ld:LoaderData, positionY:int) : void
		{
			mProgressBarRect.y = positionY
			mProgressBarRect.width = 100;
			var color:uint = 0xFF77ad1b; //Green
			if (ld.mIOError != null || ld.mSecurityError != null)
			{
				color = 0xFFaf1e2d; //Red
			}
			else if (ld.mProgress == 0)
			{
				color = 0xFF444444;
			}
			else
			{
				if (ld.mType == LoaderData.DISPLAY_LOADER)
				{
					mProgressBarRect.width = 100 * ld.mProgress;
				}
				else if (ld.mType == LoaderData.URL_STREAM)
				{
					color = 0xFFD9A3B6; //light blue
				}
				else
				{
					color = 0xFFC4D7ED; //light blue
				}
			}
			mBitmapBackgroundData.fillRect(mProgressBarRect, color);
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

