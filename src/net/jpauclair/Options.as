package net.jpauclair
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.net.SharedObject;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import net.jpauclair.data.ClassTypeStatsHolder;
	import net.jpauclair.data.InternalEventEntry;
	import net.jpauclair.event.ChangeToolEvent;
	import net.jpauclair.ui.button.MenuButton;
	import net.jpauclair.ui.ToolTip;
	import net.jpauclair.window.FlashStats;
	import net.jpauclair.window.Help;
	import net.jpauclair.window.InstancesLifeCycle;
	import net.jpauclair.window.InternalEventsProfiler;
	import net.jpauclair.window.MouseListeners;
	import net.jpauclair.window.Overdraw;
	import net.jpauclair.window.PerformanceProfiler;
	import net.jpauclair.window.SamplerProfiler;
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
		
		private var mMouseListenerButton:Sprite;
		private var mMinimizeButton:Sprite;
		private var mAutoStatButton:Sprite;
		private var mShowOverdraw:Sprite;
		private var mShowInstanciator:Sprite;
		private var mShowProfiler:Sprite;
		private var mShowInternalEvents:Sprite;
		private var mShowHelp:Sprite;
		private var iconOff:DisplayObject;

		private var mFoldButton:MenuButton;
		private var mMouseListenersButton:MenuButton;
		private var mStatsButton:MenuButton;
		private var mOverdrawButton:MenuButton;
		private var mInstanciationButton:MenuButton;
		private var mMemoryProfilerButton:MenuButton;
		private var mInternalEventButton:MenuButton;
		private var mFunctionTimeButton:MenuButton;
		private var mHelpButton:MenuButton;
		
		private var mSaveDiskButton:MenuButton;
		private var mSaveSnapshotButton:MenuButton;
		private var mClearButton:MenuButton;
		private var mGCButton:MenuButton;
		
		[Embed(source='../../../art/IconHelp.png')]
		private var IconHelp:Class;		
		[Embed(source='../../../art/IconHelpOut.png')]
		private var IconHelpOut:Class;		
		
		[Embed(source='../../../art/IconProfiler.png')]
		private var IconProfiler:Class;		
		[Embed(source='../../../art/IconProfilerOut.png')]
		private var IconProfilerOut:Class;						
		
		
		[Embed(source='../../../art/IconOverdraw.png')]
		private var IconOverdraw:Class;		
		[Embed(source='../../../art/IconOverdrawOut.png')]
		private var IconOverdrawOut:Class;						
		
		
		[Embed(source='../../../art/IconLifecycle.png')]
		private var IconLifeCycle:Class;		
		[Embed(source='../../../art/IconLifecycleOut.png')]
		private var IconLifeCyclesOut:Class;						
		
		[Embed(source='../../../art/IconMouse.png')]
		private var IconMouse:Class;		
		[Embed(source='../../../art/IconMouseOut.png')]
		private var IconMouseOut:Class;				
		
		[Embed(source='../../../art/Percent.png')]
		private var IconPercent:Class;		
		[Embed(source='../../../art/PercentOut.png')]
		private var IconPercentOut:Class;			
		
		[Embed(source='../../../art/IconStats.png')]
		private var IconStats:Class;		
		[Embed(source='../../../art/IconStatsOut.png')]
		private var IconStatsOut:Class;				
		
		[Embed(source="../../../art/MonstersRoarIcon.png")]
		private var DebugerIcon:Class;		
		[Embed(source="../../../art/MonstersRoarIconGray.png")]
		private var DebugerIconDisable:Class;		
		
		
		[Embed(source='../../../art/ArrowDown.png')]
		private var IconArrowDown:Class;		
		[Embed(source='../../../art/ArrowDownOut.png')]
		private var IconArrowDownOut:Class;			
		
		[Embed(source='../../../art/ArrowUp.png')]
		private var IconArrowUp:Class;		
		[Embed(source='../../../art/ArrowUpOut.png')]
		private var IconArrowUpOut:Class;			
		
		[Embed(source='../../../art/clock.png')]
		private var IconClock:Class;	
		[Embed(source='../../../art/clockOut.png')]
		private var IconClockOut:Class;			
		
		[Embed(source='../../../art/gradient.png')]
		private var Gradient:Class;		
		
		[Embed(source='../../../art/Disk.png')]
		private var IconDisk:Class;		
		[Embed(source='../../../art/DiskOver.png')]
		private var IconDiskOver:Class;		
		[Embed(source='../../../art/DiskOut.png')]
		private var IconDiskOut:Class;				

		[Embed(source='../../../art/Trash.png')]
		private var IconTrash:Class;		
		[Embed(source='../../../art/TrashOut.png')]
		private var IconTrashOut:Class;		

		[Embed(source='../../../art/cam.png')]
		private var IconCam:Class;		
		[Embed(source='../../../art/camOut.png')]
		private var IconCamOut:Class;				

		[Embed(source='../../../art/minimize.png')]
		private var IconMinimize:Class;		
		[Embed(source='../../../art/minimizeOut.png')]
		private var IconMinimizeOut:Class;				
		
		[Embed(source='../../../art/Clear.png')]
		private var IconClear:Class;		
		[Embed(source='../../../art/ClearOut.png')]
		private var IconClearOut:Class;				
		
		private var mGradientDown:Bitmap;
		private var mGradientUp:Bitmap;
		private var mClockUpOut:Bitmap;
		private var mClockUp:Bitmap;
		private var mClockIcon:Bitmap;
		private var mClockDownOut:Bitmap;
		private var mClockDown:Bitmap;
		
		private var mMinimize:Bitmap;
		
		private var debuggerIcon:DisplayObject = null;

		private var mLastSelected:Sprite = null;
		
		private var mToolTip:ToolTip;
		private var mInterface:Sprite;
		
		public static var mCurrentGradient:int = 6;
		public static var mCurrentClock:int = 30;		
		public static var mIsCollectingData:Boolean = false;
		public static var mIsSaveEnabled:Boolean = false;
		public static var mIsPerformanceSnaptopEnabled:Boolean = false;
		public static var mIsClockEnabled:Boolean = false;
		public static var mIsCamEnabled:Boolean = false;
		private var mStage:Stage;
		private var mButtonDict:Dictionary = new Dictionary(true);
		
		
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
		
		public static const SAVE_RECORDING_EVENT:String = "SaveRecordingEvent";
		static public const SAVE_SNAPSHOT_EVENT:String = "saveSnapshotEvent";
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
			var barWidth:int = 300;
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

			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myformatRight:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false,null,null,null,null,TextFormatAlign.RIGHT);
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
			
			mToolTip = new ToolTip();
			
			var vButtonPosX:int = 4;
			var vButtonSpacing:int = 16;
			var vButtonPosY:int = 4;
			
			mFoldButton = new MenuButton(vButtonPosX, vButtonPosY, IconMinimizeOut, IconMinimize, IconMinimizeOut,
										"toggleMinimize", null,  "Minimize");
			addChild(mFoldButton);
			mButtonDict[mFoldButton] = mFoldButton;
			vButtonPosX += 16			
			
			mStatsButton = new MenuButton(vButtonPosX, vButtonPosY, IconStatsOut, IconStats, IconStatsOut,
										ChangeToolEvent.CHANGE_TOOL_EVENT, FlashStats, "Runtime Statistics");
			addChild(mStatsButton);
			mButtonDict[mStatsButton] = mStatsButton;
			vButtonPosX += 16			
			
			mMouseListenerButton = new MenuButton(vButtonPosX, vButtonPosY, IconMouseOut, IconMouse, IconMouseOut,
												ChangeToolEvent.CHANGE_TOOL_EVENT, MouseListeners, "Mouse Listeners");
			addChild(mMouseListenerButton);
			mButtonDict[mMouseListenerButton] = mMouseListenerButton;
			vButtonPosX += 16			
			
			mInstanciationButton = new MenuButton(vButtonPosX, vButtonPosY, IconOverdrawOut, IconOverdraw, IconOverdrawOut,
												ChangeToolEvent.CHANGE_TOOL_EVENT,Overdraw,  "Overdraw");
			addChild(mInstanciationButton);			
			mButtonDict[mInstanciationButton] = mInstanciationButton;
			vButtonPosX += 16			
			
			mInstanciationButton = new MenuButton(vButtonPosX, vButtonPosY, IconLifeCyclesOut, IconLifeCycle, IconLifeCyclesOut,
												ChangeToolEvent.CHANGE_TOOL_EVENT,InstancesLifeCycle,  "DisplayObjects Life Cycle");
			addChild(mInstanciationButton);			
			mButtonDict[mInstanciationButton] = mInstanciationButton;
			vButtonPosX += 16			
			
			mMemoryProfilerButton = new MenuButton(vButtonPosX, vButtonPosY, IconPercentOut, IconPercent, IconPercentOut,
												ChangeToolEvent.CHANGE_TOOL_EVENT,  SamplerProfiler, "Memory Profiler");
			addChild(mMemoryProfilerButton);			
			mButtonDict[mMemoryProfilerButton] = mMemoryProfilerButton;
			vButtonPosX += 16

			mInternalEventButton = new MenuButton(vButtonPosX, vButtonPosY, IconProfilerOut, IconProfiler, IconProfilerOut,
												ChangeToolEvent.CHANGE_TOOL_EVENT, InternalEventsProfiler, "Internal Events Profiler");
			addChild(mInternalEventButton);
			mButtonDict[mInternalEventButton] = mInternalEventButton;
			vButtonPosX += 16

			mFunctionTimeButton = new MenuButton(vButtonPosX, vButtonPosY, IconClockOut, IconClock, IconClockOut,
												ChangeToolEvent.CHANGE_TOOL_EVENT, PerformanceProfiler, "Performance Profiler");
			addChild(mFunctionTimeButton);
			mButtonDict[mFunctionTimeButton] = mFunctionTimeButton;
			vButtonPosX += 16
			
			
			mHelpButton = new MenuButton(vButtonPosX, vButtonPosY, IconHelpOut, IconHelp, IconHelpOut,
										ChangeToolEvent.CHANGE_TOOL_EVENT, Help, "Help");
			addChild(mHelpButton);
			mButtonDict[mHelpButton] = mHelpButton;
			vButtonPosX += 16

			debuggerIcon = new DebugerIcon();
			iconOff = new DebugerIconDisable();
			debuggerIcon.x = vButtonPosX;
			debuggerIcon.y = 1;
			iconOff.x = vButtonPosX;
			iconOff.y = 1;
			addChild(iconOff);
			addChild(debuggerIcon);
			debuggerIcon.visible = false

			vButtonPosX += 70
			
			mGCButton = new MenuButton(vButtonPosX, vButtonPosY, IconTrashOut, IconTrash, IconTrashOut,
										null, null, "Force (sync) Garbage Collector",true, "Done");
			addChild(mGCButton);
			//mButtonDict[mSaveDiskButton] = mHelpButton;
			vButtonPosX += 16		
			
			
			var saveText:String = "Save Samples in Clipboard" +
									"\nSamples include NewObject, DeletedObject, FunctionTime" + 
									"\nAll field are separated by Tabs, use a Grid editor" + 
									"\nfor a better view / sorting / analysis.";
			mSaveDiskButton = new MenuButton(vButtonPosX, vButtonPosY, IconDiskOut, IconDisk, IconDiskOut, SAVE_RECORDING_EVENT,
										null, "Start Recording Samples",true,saveText);
			addChild(mSaveDiskButton);
			addEventListener(SAVE_RECORDING_EVENT, OnSaveRecording);
			//mButtonDict[mSaveDiskButton] = mHelpButton;
			vButtonPosX += 16
			
			mSaveSnapshotButton = new MenuButton(vButtonPosX, vButtonPosY, IconCamOut, IconCam, IconCamOut, SAVE_SNAPSHOT_EVENT,
										null, "Save ALL Memory Allocation to Clipboard",true, "Saved");
			addChild(mSaveSnapshotButton);
			addEventListener(SAVE_SNAPSHOT_EVENT, OnSaveSnapshot);
			//mButtonDict[mSaveDiskButton] = mHelpButton;
			vButtonPosX += 16			
			
			
			mClearButton = new MenuButton(vButtonPosX, vButtonPosY, IconClearOut, IconClear, IconClearOut,
										null, null, "Clear Current Data",true, "Data cleared");
			addChild(mClearButton);
			//mButtonDict[mSaveDiskButton] = mHelpButton;
			vButtonPosX += 16						
			
			
	
			
			
			//MonsterDisabled bar
			
			this.stage.addEventListener(Event.RESIZE, OnResize);
			
			mInterface = new Sprite(); 
			
			mInterface.visible = false;
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
			mClockDownOut = obj;
			mInterface.addChild(obj);
			
			obj = new IconArrowDown() as Bitmap;			
			obj.y = 4;
			obj.x = - 12 * 5
			obj.visible = false;
			mInterface.addChild(obj);
			mClockDown = obj;
			
			obj = new IconClockOut() as Bitmap;
			obj.y = 4;
			obj.x = - 12*4			
			mInterface.addChild(obj);
			mClockIcon = obj;
			
			obj = new IconArrowUpOut() as Bitmap;
			obj.y = 4;
			obj.x = - 12*3			
			mClockUpOut = obj;			
			mInterface.addChild(obj);
			obj = new IconArrowUp() as Bitmap;
			obj.y = 4;
			obj.x = - 12*3			
			mInterface.addChild(obj);
			obj.visible = false;		
			mClockUp = obj;			

			addChild(mInterface);
			
			addChild( mToolTip );

			this.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
			this.addEventListener(MouseEvent.MOUSE_OUT, OnMouseMove);
			
			this.addEventListener(MouseEvent.CLICK, OnMouseClick);
			
			addEventListener(ChangeToolEvent.CHANGE_TOOL_EVENT, OnChangeTool);

			//if (mMainSprite.stage.hasEventListener(MouseEvent.MOUSE_MOVE)) mMainSprite.stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
			//if (mMainSprite.stage.hasEventListener(MouseEvent.CLICK)) mMainSprite.stage.removeEventListener(MouseEvent.CLICK, OnMouseClick);
			
			
			ResetColors();			
		}
		
		private function OnSaveSnapshot(e:Event):void 
		{
			if (mSaveSnapshotButton.mIsSelected)
			{
				if (mIsPerformanceSnaptopEnabled)
				{
					SavePerformanceSnapshot();
				}
				if (mIsCamEnabled)
				{
					SaveMemorySnapshot();
				}
				
				mSaveSnapshotButton.Reset();
			}			
		}
		
		private function OnSaveRecording(e:Event):void 
		{
			if (mIsCollectingData)
			{
				SaveCollectedData();
			}
		}
		
		private function OnChangeTool(e:ChangeToolEvent):void 
		{
			for each( var button:MenuButton in mButtonDict)
			{
				if (e.target != button)
				{
					button.Reset();
				}
			}
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

		public function Update() : void
		{
			//mSaveDiskButton.visible = Options.mIsSaveEnabled || mIsCollectingData
			//if (mIsCollectingData && !mSaveDiskButton.mIsSelected)
			//{
				//Time to save
				//SaveCollectedData();
			//}
			mIsCollectingData = mSaveDiskButton.mIsSelected;
			
			mSaveSnapshotButton.visible = mIsCamEnabled || mIsPerformanceSnaptopEnabled;
			mClearButton.visible = mIsCamEnabled || mIsPerformanceSnaptopEnabled;
			
			
			
			
			
			if (mClearButton.mIsSelected)
			{
				if (mIsPerformanceSnaptopEnabled)
				{
					ClearPerformanceData();
				}
				if (mIsCamEnabled)
				{
					ClearMemoryData();
				}
				
				mClearButton.Reset();
			}
			
			
			if (mGCButton.mIsSelected)
			{
				SampleAnalyzer.GetInstance().ForceGC();
				mGCButton.Reset();
			}
			
		}
		
		private function ClearMemoryData():void
		{
			SampleAnalyzer.GetInstance().ResetMemoryStats();
		}
		
		private function ClearPerformanceData():void
		{
			SampleAnalyzer.GetInstance().ResetPerformanceStats();
		}
		
		private static const ZERO_PERCENT:String = "0.00";
		private function SavePerformanceSnapshot():void
		{
			var vFunctionTimes:Array = SampleAnalyzer.GetInstance().GetFunctionTimes();
			vFunctionTimes.sortOn("entryTime", Array.NUMERIC | Array.DESCENDING);
			
			var outCam:ByteArray = new ByteArray();

			var len:int = vFunctionTimes.length;
			var holder:InternalEventEntry;
			var totalTime:int = 0;
			for each (holder in vFunctionTimes)
			{
				totalTime += holder.entryTime;
			}

			
			for each (holder in vFunctionTimes)
			{
				var percent:Number = int((holder.entryTime / totalTime) * 10000) / 100;
				if (percent == 0)
				{
					outCam.writeUTFBytes(ZERO_PERCENT);
				}
				else
				{
					outCam.writeUTFBytes(String(percent));
				}
				outCam.writeByte(0x09);

				
				outCam.writeUTFBytes(holder.entryTime.toString());
				outCam.writeByte(0x09);
				percent = int((holder.entryTimeTotal / totalTime) * 10000) / 100;
				if (percent == 0)
				{
					outCam.writeUTFBytes(ZERO_PERCENT);
				}
				else
				{
					outCam.writeUTFBytes(String(percent));
				}				
				outCam.writeByte(0x09);
				outCam.writeUTFBytes(holder.entryTimeTotal.toString());
				outCam.writeByte(0x09);
				outCam.writeUTFBytes(String(holder.mStackFrame));
				outCam.writeByte(0x0D);
				outCam.writeByte(0x0A);
				outCam.position = 0;
				System.setClipboard(outCam.readUTFBytes(outCam.length));
			}			
			
		}
		
		private function SaveMemorySnapshot():void
		{
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
		
		private function SaveCollectedData():void
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
		}
		
		public function ShowInterfaceCustomizer(enable:Boolean) : void
		{
			mInterface.visible = enable;
			mClockDownOut.visible = mIsClockEnabled;
			mClockUpOut.visible = mIsClockEnabled;
			mClockIcon.visible = mIsClockEnabled;
		}
		
		
		private function OnMouseClick(e:MouseEvent):void 
		{
			var isPaused:Boolean = SampleAnalyzer.GetInstance().IsSamplingPaused();
			SampleAnalyzer.GetInstance().PauseSampling();			
			
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
			
			if (mIsClockEnabled)
			{
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
		
		public function ResetMenu(aButton:MenuButton):void
		{
			for each( var button:MenuButton in mButtonDict)
			{
				if (aButton != button)
				{
					button.Reset();
				}
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