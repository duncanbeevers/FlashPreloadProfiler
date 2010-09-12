package  
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.net.SharedObject;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author ...
	 */
	public class Options extends Sprite
	{
		private static const COLOR_MOUSE_OVER:int =		0xFFE877; 
		private static const COLOR_MOUSE_OUT:int =		0xCCCCCC; 
		private static const COLOR_SELECTED:int =		0xF2B705; 

		private var mSaveObj:SharedObject;
		
		private var mFoldOptions:Sprite;
		private var mMouseListenerButton:Sprite;
		private var mMinimizeButton:Sprite;
		private var mAutoStatButton:Sprite;
		private var mShowOverdraw:Sprite;
		private var mShowInstanciator:Sprite;
		private var mShowProfiler:Sprite;
		private var mShowInternalEvents:Sprite;
		private var mShowHelp:Sprite;
		private var iconOff:DisplayObject;

		[Embed(source='../art/IconHelp.png')]
		private var IconHelp:Class;		
		[Embed(source='../art/IconHelpOut.png')]
		private var IconHelpOut:Class;		
		
		[Embed(source='../art/IconProfiler.png')]
		private var IconProfiler:Class;		
		[Embed(source='../art/IconProfilerOut.png')]
		private var IconProfilerOut:Class;						
		
		
		[Embed(source='../art/IconOverdraw.png')]
		private var IconOverdraw:Class;		
		[Embed(source='../art/IconOverdrawOut.png')]
		private var IconOverdrawOut:Class;						
		
		
		[Embed(source='../art/IconLifecycle.png')]
		private var IconLifeCycle:Class;		
		[Embed(source='../art/IconLifecycleOut.png')]
		private var IconLifeCyclesOut:Class;						
		
		[Embed(source='../art/IconMouse.png')]
		private var IconMouse:Class;		
		[Embed(source='../art/IconMouseOut.png')]
		private var IconMouseOut:Class;				
		
		[Embed(source='../art/Percent.png')]
		private var IconPercent:Class;		
		[Embed(source='../art/PercentOut.png')]
		private var IconPercentOut:Class;			
		
		[Embed(source='../art/IconStats.png')]
		private var IconStats:Class;		
		[Embed(source='../art/IconStatsOut.png')]
		private var IconStatsOut:Class;				
		
		[Embed(source="../art/MonstersRoarIcon.png")]
		private var DebugerIcon:Class;		
		[Embed(source="../art/MonstersRoarIconGray.png")]
		private var DebugerIconDisable:Class;		
		
		
		[Embed(source='../art/ArrowDown.png')]
		private var IconArrowDown:Class;		
		[Embed(source='../art/ArrowDownOut.png')]
		private var IconArrowDownOut:Class;			
		
		[Embed(source='../art/ArrowUp.png')]
		private var IconArrowUp:Class;		
		[Embed(source='../art/ArrowUpOut.png')]
		private var IconArrowUpOut:Class;			
		
		[Embed(source='../art/clock.png')]
		private var Clock:Class;	
		
		[Embed(source='../art/gradient.png')]
		private var Gradient:Class;		
		
		[Embed(source='../art/Disk.png')]
		private var IconDisk:Class;		
		[Embed(source='../art/DiskOver.png')]
		private var IconDiskOver:Class;		
		[Embed(source='../art/DiskOut.png')]
		private var IconDiskOut:Class;				

		[Embed(source='../art/Trash.png')]
		private var IconTrash:Class;		
		[Embed(source='../art/TrashOut.png')]
		private var IconTrashOut:Class;		

		[Embed(source='../art/cam.png')]
		private var IconCam:Class;		
		[Embed(source='../art/camOut.png')]
		private var IconCamOut:Class;				

		[Embed(source='../art/minimize.png')]
		private var IconMinimize:Class;		
		[Embed(source='../art/minimizeOut.png')]
		private var IconMinimizeOut:Class;				
		
		private var mGradientDown:Bitmap;
		private var mGradientUp:Bitmap;
		private var mClockUp:Bitmap;
		private var mClockIcon:Bitmap;
		private var mClockDown:Bitmap;
		private var mDisk:Bitmap;
		private var mDiskOut:Bitmap;
		private var mDiskOver:Bitmap;
		private var mTrash:Bitmap;
		private var mCam:Bitmap;
		private var mCamOut:Bitmap;
		
		private var mMinimize:Bitmap;
		
		private var debuggerIcon:DisplayObject = null;

		private var mLastSelected:Sprite = null;
		
		private var mInfos:TextField;
		public var mRecordingTxt:TextField;
		private var mInterface:Sprite;
		
		public static var mCurrentGradient:int = 6;
		public static var mCurrentClock:int = 10;		
		public static var mIsCollectingData:Boolean = false;
		public static var mIsSaveEnabled:Boolean = false;
		public static var mIsClockEnabled:Boolean = false;
		public static var mIsCamEnabled:Boolean = false;
		private var mStage:Stage;
		
		
		
		public function Options(aStage:Stage = null ) 
		{
			mStage = aStage;
			Init();
		}
		
		public function Init() : void
		{			
			try
			{
				mSaveObj = SharedObject.getLocal("FlashPreloadProfilerOptions");	
			}
			catch (e:Error)
			{
				mSaveObj = new SharedObject();
			}
			
			if (stage) this.OnAddedToStage();
            else {  addEventListener(Event.ADDED_TO_STAGE, this.OnAddedToStage); }
		}
		
		private function OnAddedToStage(e:Event=null) : void
		{
			if (e.target == this)
			{
				removeEventListener(Event.ADDED_TO_STAGE, OnAddedToStage);
			}
			else
			{
				return;
			}
			var barWidth:int = 400;
			mStage = this.stage;
			this.graphics.beginFill(0x000000, 0.3);
			this.graphics.drawRect(0, 0, barWidth, 18);
			this.graphics.endFill();
			this.graphics.beginFill(0xCCCCCC, 0.6);
			this.graphics.drawRect(0, 17, barWidth, 1);
			this.graphics.endFill();
			this.graphics.beginFill(0xFFFFFF, 0.8);
			this.graphics.drawRect(0, 18, barWidth, 1);
			this.graphics.endFill();
			
			mMinimizeButton = new Sprite();
			mMinimizeButton.addChild(new IconMinimizeOut() as DisplayObject);
			mMinimizeButton.addChild(new IconMinimize() as DisplayObject);			
			mMinimizeButton.getChildAt(1).visible = false;
			mMinimizeButton.x = 2;
			mMinimizeButton.y = 3;
			
			mMinimizeButton.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mMinimizeButton, COLOR_MOUSE_OVER); } );
			mMinimizeButton.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mMinimizeButton.addEventListener(MouseEvent.CLICK, function():void 
			{ 
					mLastSelected = mMinimizeButton;
					mInfos.text = "FlashPreloadProfiler";
					ResetColors(mMinimizeButton); 
					dispatchEvent(new Event("toggleMinimize",true)); } );
			addChild(mMinimizeButton);
			
			
			mAutoStatButton = new Sprite();
			mAutoStatButton.addChild(new IconStatsOut() as DisplayObject);
			mAutoStatButton.addChild(new IconStats() as DisplayObject);			
			mAutoStatButton.getChildAt(1).visible = false;
			mAutoStatButton.x = mMinimizeButton.x + 16;
			mAutoStatButton.y = 3;
			//this.addEventListener(MouseEvent.MOUSE_MOVE, function():void { ResetColors(null , 0xFF0000); } );
			mAutoStatButton.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mAutoStatButton, COLOR_MOUSE_OVER); } );
			mAutoStatButton.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mAutoStatButton.addEventListener(MouseEvent.CLICK, function():void 
			{ 
					mLastSelected = mAutoStatButton;
					mInfos.text = "Runtime Statistics";
					ResetColors(mAutoStatButton); 
					dispatchEvent(new Event("toggleStats",true)); } );
			addChild(mAutoStatButton);
			
			mMouseListenerButton = new Sprite();
			mMouseListenerButton.addChild(new IconMouseOut() as DisplayObject);
			mMouseListenerButton.addChild(new IconMouse() as DisplayObject);			
			mMouseListenerButton.getChildAt(1).visible = false;				
			mMouseListenerButton.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mMouseListenerButton, COLOR_MOUSE_OVER); } );
			mMouseListenerButton.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mMouseListenerButton.x = mAutoStatButton.x + 16;
			mMouseListenerButton.y = 3;
			mMouseListenerButton.addEventListener(MouseEvent.CLICK, function():void { 
					mLastSelected = mMouseListenerButton;
					mInfos.text = "Mouse Listeners";
					ResetColors(mMouseListenerButton);
					dispatchEvent(new Event("toggleMouseListeners",true)); } );
			addChild(mMouseListenerButton);
			
			this.mShowOverdraw = new Sprite();
			mShowOverdraw.addChild(new IconOverdrawOut() as DisplayObject);
			mShowOverdraw.addChild(new IconOverdraw() as DisplayObject);			
			mShowOverdraw.getChildAt(1).visible = false;			
			mShowOverdraw.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mShowOverdraw, COLOR_MOUSE_OVER); } );
			mShowOverdraw.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mShowOverdraw.x = mMouseListenerButton.x + 16;
			mShowOverdraw.y = 3;
			mShowOverdraw.addEventListener(MouseEvent.CLICK, function():void { 
					mLastSelected = mShowOverdraw;
					mInfos.text = "Overdraw";
					ResetColors(mShowOverdraw);
					dispatchEvent(new Event("toggleOverdraw", true)); } );
			//mShowOverdraw.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mShowOverdraw, 0xFF0000); } );
			addChild(mShowOverdraw);
			
			mShowInstanciator = new Sprite();
			mShowInstanciator.addChild(new IconLifeCyclesOut() as DisplayObject);
			mShowInstanciator.addChild(new IconLifeCycle() as DisplayObject);			
			mShowInstanciator.getChildAt(1).visible = false;				
			mShowInstanciator.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mShowInstanciator, COLOR_MOUSE_OVER); } );
			mShowInstanciator.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mShowInstanciator.x = mShowOverdraw.x + 16;
			mShowInstanciator.y = 3;
			mShowInstanciator.addEventListener(MouseEvent.CLICK, function():void { 
					mLastSelected = mShowInstanciator;
					mInfos.text = "Instances Life Cycle";
					ResetColors(mShowInstanciator); 
					dispatchEvent(new Event("toggleInstancesLifeCycle", true)); } );
			addChild(mShowInstanciator);			

			mShowProfiler = new Sprite();
			mShowProfiler.addChild(new IconPercentOut() as DisplayObject);
			mShowProfiler.addChild(new IconPercent() as DisplayObject);			
			mShowProfiler.getChildAt(1).visible = false;				
			mShowProfiler.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mShowProfiler, COLOR_MOUSE_OVER); } );
			mShowProfiler.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mShowProfiler.x = mShowInstanciator.x + 16;
			mShowProfiler.y = 3;
			mShowProfiler.addEventListener(MouseEvent.CLICK, function():void { 
					mLastSelected = mShowProfiler;
					mInfos.text = "Objects Profiler";
					ResetColors(mShowProfiler); 
					dispatchEvent(new Event("toggleProfiler", true)); } );
			addChild(mShowProfiler);	
			
			mShowInternalEvents = new Sprite();
			mShowInternalEvents.addChild(new IconProfilerOut() as DisplayObject);
			mShowInternalEvents.addChild(new IconProfiler() as DisplayObject);			
			mShowInternalEvents.getChildAt(1).visible = false;				
			mShowInternalEvents.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mShowInternalEvents, COLOR_MOUSE_OVER); } );
			mShowInternalEvents.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mShowInternalEvents.x = mShowProfiler.x + 16;
			mShowInternalEvents.y = 3;
			mShowInternalEvents.addEventListener(MouseEvent.CLICK, function():void { 
					mLastSelected = mShowInternalEvents;
					mInfos.text = "Internal Events Profiler";
					ResetColors(mShowInternalEvents); 
					dispatchEvent(new Event("toggleInternalEvents", true)); } );
			addChild(mShowInternalEvents);					
						
			
			mShowHelp = new Sprite();
			mShowHelp.addChild(new IconHelpOut() as DisplayObject);
			mShowHelp.addChild(new IconHelp() as DisplayObject);			
			mShowHelp.getChildAt(1).visible = false;				
			mShowHelp.addEventListener(MouseEvent.MOUSE_OVER, function():void { ResetColors(mShowHelp, COLOR_MOUSE_OVER); } );
			mShowHelp.addEventListener(MouseEvent.MOUSE_OUT, function():void { ResetColors(null); });
			mShowHelp.x = mShowInternalEvents.x + 16;
			mShowHelp.y = 3;
			mShowHelp.addEventListener(MouseEvent.CLICK, function():void { 
					mLastSelected = mShowHelp;
					mInfos.text = "Help / About";
					ResetColors(mShowHelp); 
					dispatchEvent(new Event("toggleHelp", true)); } );
			addChild(mShowHelp);				
			
			debuggerIcon = new DebugerIcon();
			iconOff = new DebugerIconDisable();
			debuggerIcon.x = mShowHelp.x+16;
			debuggerIcon.y = 1;
			iconOff.x = mShowHelp.x + 16;
			iconOff.y = 1;
			addChild(iconOff);
			addChild(debuggerIcon);
			debuggerIcon.visible = false
			
			//MonsterDisabled bar
			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myformatRight:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false,null,null,null,null,TextFormatAlign.RIGHT);
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
			
			mInfos = new TextField();
			mInfos.autoSize = TextFieldAutoSize.LEFT;
			mInfos.defaultTextFormat = myformat;
			mInfos.selectable = false;
			mInfos.text = "FlashPreloadProfiler";
			mInfos.filters = [ myglow ];
			mInfos.x = debuggerIcon.x + 50;
			addChild( mInfos );
			
			this.stage.addEventListener(Event.RESIZE, OnResize);
			
			mInterface = new Sprite(); 
			
			mInterface.visible = false;
			//mInterface.x = barWidth+250
			mInterface.x = this.stage.stageWidth;
			var obj:Bitmap = null;
			obj = new IconArrowDownOut() as Bitmap;
			obj.y = 4;
			obj.x = - 12 * 9
			mInterface.addChild(obj);
			obj = new IconArrowDown() as Bitmap;			
			obj.y = 4;
			obj.x = - 12 * 9
			obj.visible = false;
			mInterface.addChild(obj);
			mGradientDown = obj;
			
			obj = new Gradient() as Bitmap;
			obj.y = 4;
			obj.x = - 12*8			
			mInterface.addChild(obj);
			
			obj = new IconArrowUpOut() as Bitmap;
			obj.y = 4;
			obj.x = - 12*7		
			mInterface.addChild(obj);
			obj = new IconArrowUp() as Bitmap;			
			obj.y = 4;
			obj.x = - 12 * 7
			obj.visible = false;	
			mInterface.addChild(obj);
			mGradientUp = obj;
			
			obj = new IconArrowDownOut() as Bitmap;
			obj.y = 4;
			obj.x = - 12*5		
			mInterface.addChild(obj);
			obj = new IconArrowDown() as Bitmap;			
			obj.y = 4;
			obj.x = - 12 * 5
			obj.visible = false;
			mInterface.addChild(obj);
			mClockDown = obj;
			
			obj = new Clock() as Bitmap;
			obj.y = 4;
			obj.x = - 12*4			
			mInterface.addChild(obj);
			mClockIcon = obj;
			
			obj = new IconArrowUpOut() as Bitmap;
			obj.y = 4;
			obj.x = - 12*3			
			mInterface.addChild(obj);
			obj = new IconArrowUp() as Bitmap;
			obj.y = 4;
			obj.x = - 12*3			
			mInterface.addChild(obj);
			obj.visible = false;		
			mClockUp = obj;			
			
			addChild(mInterface);
			
			obj = new IconTrashOut() as Bitmap;
			obj.y = 4;
			obj.x = - 12*11			
			mInterface.addChild(obj);
			
			obj = new IconTrash() as Bitmap;
			obj.y = 4;
			obj.x = - 12*11		
			mInterface.addChild(obj);
			obj.visible = false;		
			mTrash = obj;

			obj = new IconCamOut() as Bitmap;
			obj.y = 4;
			obj.x = - 12*13			
			mInterface.addChild(obj);
			mCamOut = obj;
			
			obj = new IconCam() as Bitmap;
			obj.y = 4;
			obj.x = - 12*13		
			mInterface.addChild(obj);
			obj.visible = false;		
			mCam = obj;
			
			
			obj = new IconDiskOut() as Bitmap;
			obj.y = 4;
			obj.x = - 12*15			
			mInterface.addChild(obj);
			mDiskOut = obj; 
			
			obj = new IconDiskOver() as Bitmap;
			obj.y = 4;
			obj.x = - 12*15		
			mInterface.addChild(obj);
			obj.visible = false;				
			mDiskOver = obj;
			
			obj = new IconDisk() as Bitmap;
			obj.y = 4;
			obj.x = - 12*15		
			mInterface.addChild(obj);
			obj.visible = false;		
			mDisk = obj;
			
			mRecordingTxt = new TextField();
			mRecordingTxt.autoSize = TextFieldAutoSize.RIGHT;
			mRecordingTxt.defaultTextFormat = myformatRight;
			
			mRecordingTxt.selectable = false;
			mRecordingTxt.text = "Save to Clipboard";
			mRecordingTxt.filters = [ myglow ];
			mRecordingTxt.x = obj.x-94
			
			mInterface.addChild( mRecordingTxt );			
			

			this.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
			this.addEventListener(MouseEvent.MOUSE_OUT, OnMouseMove);
			
			this.addEventListener(MouseEvent.CLICK, OnMouseClick);
			
			//if (mMainSprite.stage.hasEventListener(MouseEvent.MOUSE_MOVE)) mMainSprite.stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
			//if (mMainSprite.stage.hasEventListener(MouseEvent.CLICK)) mMainSprite.stage.removeEventListener(MouseEvent.CLICK, OnMouseClick);
			
			
			ResetColors();			
		}
		
		public function SetStage(aStage:Stage) : void
		{
			mStage = aStage;
			mInterface.x = mStage.stageWidth ;
		}
		private function OnResize(e:Event):void 
		{
			mInterface.x = mStage.stageWidth ;
			trace("OnResize", e);
		}

		public function ShowInterfaceCustomizer(enable:Boolean) : void
		{
			mInterface.visible = enable;
			mDiskOut.visible = mIsSaveEnabled;
			mRecordingTxt.visible = mIsSaveEnabled;
			//mClockDown.visible = mIsClockEnabled;
			//mClockUp.visible = mIsClockEnabled;
			//mClockIcon.visible = mIsClockEnabled;
			mCamOut.visible = mIsCamEnabled;
			
		}
		
		
		private function OnMouseClick(e:MouseEvent):void 
		{
			var isPaused:Boolean = SampleAnalyzer.GetInstance().IsSamplingPaused();
			SampleAnalyzer.GetInstance().PauseSampling();			
			if (mTrash.mouseX >=0 && mTrash.mouseX < 12 && mTrash.mouseY >=0 && mTrash.mouseY < 12)
			{
				SampleAnalyzer.GetInstance().ForceGC();
			}

			if (mIsCamEnabled)
			{
				if (mCam.mouseX >=0 && mCam.mouseX < 12 && mCam.mouseY >=0 && mCam.mouseY < 12)
				{
					trace("Cam clicked");
					var classList:Array = SampleAnalyzer.GetInstance().GetClassInstanciationStats();
					
					classList.sortOn("Cumul", Array.NUMERIC | Array.DESCENDING);
					
					var outCam:ByteArray = new ByteArray();
					
					for each (var holder:ClassTypeStatsHolder in classList)
					{
						outCam.writeUTFBytes(holder.TypeName);
						outCam.writeByte(0x09);
						outCam.writeUTFBytes(holder.Added.toString());
						outCam.writeByte(0x09);
						outCam.writeUTFBytes(holder.Removed.toString());
						outCam.writeByte(0x09);
						outCam.writeUTFBytes(holder.Current.toString());
						outCam.writeByte(0x09);
						outCam.writeUTFBytes(holder.Cumul.toString());
						outCam.writeByte(0x0D);
						outCam.writeByte(0x0A);
						outCam.position = 0;
						System.setClipboard(outCam.readUTFBytes(outCam.length));
					}
				}
			}
			
	
			if (mIsSaveEnabled)
			{
				if (mDisk.mouseX >=0 && mDisk.mouseX < 12 && mDisk.mouseY >=0 && mDisk.mouseY < 12)
				{
					if (mIsCollectingData)
					{
						var lastTime:Number = 0;
						var eventTime:Number = 0;
						//Now save
						var out:ByteArray = new ByteArray();
						var data:Array = SampleAnalyzer.GetInstance().GetFrameDataArray();
						var len:int = data.length / 2;
						lastTime = data[0];
						for (var i:int = 0; i < len; )
						{
							eventTime = data[i++];
							out.writeUTFBytes(lastTime.toString() );
							out.writeByte(0x09);
							out.writeUTFBytes((eventTime-lastTime).toString() );
							lastTime = eventTime;
							out.writeByte(0x09);
							out.writeUTFBytes(data[i++]);
							out.writeByte(0x0D);
							out.writeByte(0x0A);
						}
						out.position = 0;
						System.setClipboard(out.readUTFBytes(out.length));
						
						mRecordingTxt.text = "Saved!"
						
						mDisk.visible = false;
						mIsCollectingData = false;
					}
					else
					{
						mRecordingTxt.text = "Recording..."
						mDisk.visible = true;
						mIsCollectingData = true;
					}
				}			
			}
			
	
			OnMouseMove(e);
			if (mGradientUp.visible)
			{
				if (mCurrentGradient <= 9) mCurrentGradient++;
			}
			else if (mGradientDown.visible)
			{
				if (mCurrentGradient>=2) mCurrentGradient--;
			}
			
			if (mIsClockEnabled)
			{
				if (mClockUp.visible)
				{
					if (mCurrentClock>=2) mCurrentClock--;
				}
				else if (mClockDown.visible)
				{
					if (mCurrentClock<=100) mCurrentClock++;
				}			
			}
			if (!isPaused) SampleAnalyzer.GetInstance().ResumeSampling();
			
		}
		
		private function OnMouseMove(e:MouseEvent):void 
		{
			//trace("mouse move!")
			var stageMouseX:int = this.stage.mouseX;
			var stageMouseY:int = this.stage.mouseY;
			//Update icons
			
			if (mTrash.mouseX >=0 && mTrash.mouseX < 12 && mTrash.mouseY >=0 && mTrash.mouseY < 12)
			{
				mTrash.visible = true;
				
			}
			else
			{
				mTrash.visible = false;
			}
			
			if (mCam.mouseX >=0 && mCam.mouseX < 12 && mCam.mouseY >=0 && mCam.mouseY < 12)
			{
				mCam.visible = true;
				
			}
			else
			{
				mCam.visible = false;
			}			
			
			if (mDiskOver.mouseX >=0 && mDiskOver.mouseX < 12 && mDiskOver.mouseY >=0 && mDiskOver.mouseY < 12)
			{
				mDiskOver.visible = true;
				
			}
			else
			{
				mDiskOver.visible = false;
			}
			
			if (mGradientUp.mouseX >=0 && mGradientUp.mouseX < 12 && mGradientUp.mouseY >=0 && mGradientUp.mouseY < 12)
			{
				mGradientUp.visible = true;
				
			}
			else
			{
				mGradientUp.visible = false;
			}
			if (mGradientDown.mouseX >=0 && mGradientDown.mouseX < 12 && mGradientDown.mouseY >=0 && mGradientDown.mouseY < 12)
			{
				mGradientDown.visible = true;
			}
			else
			{
				mGradientDown.visible = false;
			}
			if (mClockDown.mouseX >=0 && mClockDown.mouseX < 12 && mClockDown.mouseY >=0 && mClockDown.mouseY < 12)
			{
				mClockDown.visible = true;
			}
			else
			{
				mClockDown.visible = false;
			}
			if (mClockUp.mouseX >=0 && mClockUp.mouseX < 12 && mClockUp.mouseY >=0 && mClockUp.mouseY < 12)
			{
				mClockUp.visible = true;
			}
			else
			{
				mClockUp.visible = false;
			}					
		}
		
		public function SetMonsterDisabled():void
		{
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0x0, 1);
			s.graphics.drawRect(iconOff.x - 2, 10, iconOff.width + 4, 1);
			s.graphics.endFill();
			s.graphics.beginFill(0xFFFFFF, 1);
			s.graphics.drawRect(iconOff.x - 2, 11, iconOff.width + 4, 2);
			s.graphics.endFill();
			s.graphics.beginFill(0x0, 1);
			s.graphics.drawRect(iconOff.x - 2, 13, iconOff.width + 4, 1);
			s.graphics.endFill();
			addChild(s);			
		}
		public function Dispose() : void
		{
			mGradientDown = null;
			mGradientUp = null;
			mClockUp = null;
			mClockDown = null;
		}
		
		private function ResetColors(obj:Sprite = null , color:uint=COLOR_SELECTED ) : void
		{
			if (mLastSelected != mShowInstanciator) mShowInstanciator.getChildAt(1).visible = false;
			if (mLastSelected != mMouseListenerButton) mMouseListenerButton.getChildAt(1).visible = false;
			if (mLastSelected != mAutoStatButton) mAutoStatButton.getChildAt(1).visible = false;
			if (mLastSelected != mShowOverdraw) mShowOverdraw.getChildAt(1).visible = false;
			if (mLastSelected != mShowProfiler) mShowProfiler.getChildAt(1).visible = false;
			if (mLastSelected != mShowInternalEvents) mShowInternalEvents.getChildAt(1).visible = false;
			if (mLastSelected != mShowHelp) mShowHelp.getChildAt(1).visible = false;
			if (mLastSelected != mMinimizeButton) mMinimizeButton.getChildAt(1).visible = false;
			
			if (obj!=null)
			{
				obj.getChildAt(1).visible = true;
			}
		}
		
		public function OnDebuggerConnect(e:Event) : void
		{
			if (debuggerIcon != null)
			{
				debuggerIcon.visible = true;
			}
		}
		public function OnDebuggerDisconnect(e:Event) : void
		{
			if (debuggerIcon != null)
			{
				debuggerIcon.visible = false;
			}
		}				
		
		public function set AutoStartMonsterDebugger(auto:Boolean) : void
		{
			mSaveObj.data.autoMonster = auto;
			mSaveObj.flush();
		}
		
		public function get AutoStartMonsterDebugger() : Boolean
		{
			return mSaveObj.data.autoMonster;
		}
		
		public function set AutoStartStatBar(auto:Boolean) : void
		{
			mSaveObj.data.autoStats = auto;
			mSaveObj.flush();
		}
		public function get AutoStartStatBar() : Boolean
		{
			return mSaveObj.data.autoStats;
		}
		

	}

}