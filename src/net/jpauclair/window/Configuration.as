package net.jpauclair.window
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
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.sampler.getSize;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import net.jpauclair.event.ChangeToolEvent;
	import net.jpauclair.IDisposable;
	import net.jpauclair.Options;
	import net.jpauclair.ui.button.MenuButton;
	
	import flash.net.SharedObject;
	
	/**
	 * ...
	 * @author jpauclair
	 */
	public class Configuration extends Sprite implements IDisposable
	{
		private static const COLOR_BACKGROUND:int =	0x444444;
		
		public static const SETUP_MEMORY_PROFILING_ENABLED:String =	"SETUP_MEMORY_PROFILING_ENABLED";
		public static const SETUP_INTERNALEVENT_PROFILING_ENABLED:String =	"SETUP_INTERNALEVENT_PROFILING_ENABLED";
		public static const SETUP_FUNCTION_PROFILING_ENABLED:String =	"SETUP_FUNCTION_PROFILING_ENABLED";
		public static const SETUP_LOADERS_PROFILING_ENABLED:String =	"SETUP_LOADERS_PROFILING_ENABLED";
		public static const SETUP_SOCKETS_PROFILING_ENABLED:String =	"SETUP_SOCKETS_PROFILING_ENABLED";
		public static const SETUP_MEMGRAPH_PROFILING_ENABLED:String =	"SETUP_MEMGRAPH_PROFILING_ENABLED";
		public static const SETUP_MONSTER_DEBUGGER:String =	"SETUP_MONSTER_DEBUGGER";
		
		private static var _PROFILE_MEMORY:Boolean = false;
		private static var _PROFILE_FUNCTION:Boolean = false;
		private static var _PROFILE_INTERNAL_EVENTS:Boolean = false;
		private static var _PROFILE_LOADERS:Boolean = false;
		private static var _PROFILE_SOCKETS:Boolean = false;
		private static var _PROFILE_MEMGRAPH:Boolean = false;
		private static var _PROFILE_MONSTER:Boolean = false;
	
		private static var mSaveObj:SharedObject;
				
		private var mMainSprite:Sprite = null;
	
		private var mInfos:TextField;
		
		[Embed(source='../../../../art/link.png')]
		private var IconLink:Class;		
		[Embed(source='../../../../art/linkOut.png')]
		private var IconLinkOut:Class;			
		private var mStatsButton:MenuButton;;
		private var mMemoryProfilerButton:MenuButton;
		private var mInternalEventButton:MenuButton;
		
		private var mFunctionTimeButton:MenuButton;
		private var mLoaderProfilerButton:MenuButton;
		private var mMonsters:MenuButton;
		
		private var mButtonDict:Dictionary = new Dictionary(true);;
		private var mSaveDiskButton:MenuButton;
		
		public function Configuration(mainSprite:Sprite) 
		{
			Init(mainSprite);
		}
		
		private function Init(mainSprite:Sprite) : void
		{
			
			
			mMainSprite = mainSprite;
			
			//this.mouseChildren = false;
			this.mouseEnabled = false;
			
			var barWidth:int = mMainSprite.stage.stageWidth;
			var bgSprite:Sprite = new Sprite();
			this.graphics.beginFill(0x000000, 0.3);
			this.graphics.drawRect(0, 18, barWidth, mMainSprite.stage.stageHeight-18);
			this.graphics.endFill();
			this.graphics.beginFill(0xCCCCCC, 0.6);
			this.graphics.drawRect(0, 19, barWidth, 1);
			this.graphics.endFill();
			this.graphics.beginFill(0xFFFFFF, 0.8);
			this.graphics.drawRect(0, 18, barWidth, 1);
			this.graphics.endFill();


			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
			
			mInfos = new TextField();
			mInfos.mouseEnabled = false;
			mInfos.autoSize = TextFieldAutoSize.LEFT;
			mInfos.defaultTextFormat = myformat;
			mInfos.selectable = false;
			mInfos.appendText("FlashPreloadProfiler!nFor help or support:\nhttp://jpauclair.net/flashpreloadprofiler/\n");
			mInfos.appendText("\nContinous profiling:\n The profiler will run in background all the time\n and start before the profiled application");
			mInfos.appendText("\n*Each profiler running \"in background\" is going to use some CPU and memory");
			mInfos.filters = [ myglow ];
			mInfos.x = 2;
			mInfos.y = 22;
			addChild( mInfos );

			

			var vButtonPosX:int = 4;
			var vButtonSpacing:int = 16;
			var vButtonPosY:int = 130;

			
			mStatsButton = new MenuButton(vButtonPosX, vButtonPosY, Options.IconStatsOut, Options.IconStats, Options.IconStatsOut,
										null, null, "Toggle to ACTIVATE MemoryGraph continuous profiling",true,"Toggle to DEACTIVATE MemoryGraph continuous profiling");
			addChild(mStatsButton);
			mButtonDict[mStatsButton] = mStatsButton;
			vButtonPosX += 16			
			if (PROFILE_MEMGRAPH) mStatsButton.OnClick(null);
						
			mMemoryProfilerButton = new MenuButton(vButtonPosX, vButtonPosY, Options.IconPercentOut, Options.IconPercent, Options.IconPercentOut,
												null, null, "Toggle to ACTIVATE memory continuous profiling",true,"Toggle to DEACTIVATE memory continuous profiling");
			addChild(mMemoryProfilerButton);			
			mButtonDict[mMemoryProfilerButton] = mMemoryProfilerButton;
			vButtonPosX += 16
			if (PROFILE_MEMORY) mMemoryProfilerButton.OnClick(null);
			

			mInternalEventButton = new MenuButton(vButtonPosX, vButtonPosY, Options.IconProfilerOut, Options.IconProfiler, Options.IconProfilerOut,
												null, null, "Toggle to ACTIVATE InternalEvents continuous profiling",true,"Toggle to DEACTIVATE InternalEvents continuous profiling");
			addChild(mInternalEventButton);
			mButtonDict[mInternalEventButton] = mInternalEventButton;
			vButtonPosX += 16
			if (PROFILE_INTERNAL_EVENTS) mInternalEventButton.OnClick(null);
			

			mFunctionTimeButton = new MenuButton(vButtonPosX, vButtonPosY, Options.IconClockOut, Options.IconClock, Options.IconClockOut,
												null, null, "Toggle to ACTIVATE performance continuous profiling",true,"Toggle to DEACTIVATE performance continuous profiling");
			addChild(mFunctionTimeButton);
			mButtonDict[mFunctionTimeButton] = mFunctionTimeButton;
			vButtonPosX += 16
			if (PROFILE_FUNCTION) mFunctionTimeButton.OnClick(null);
			
			
			mLoaderProfilerButton = new MenuButton(vButtonPosX, vButtonPosY, Options.IconLoadersOut, Options.IconLoaders, Options.IconLoadersOut,
												null, null, "Toggle to ACTIVATE loaders continuous profiling",true,"Toggle to DEACTIVATE loaders continuous profiling");
			addChild(mLoaderProfilerButton);
			mButtonDict[mLoaderProfilerButton] = mLoaderProfilerButton ;
			vButtonPosX += 16
			//trace("mLoaderProfilerButton.mIsSelected = PROFILE_LOADERS", PROFILE_LOADERS);
			if (PROFILE_LOADERS) mLoaderProfilerButton.OnClick(null);
			
			mMonsters = new MenuButton(vButtonPosX, vButtonPosY, Options.IconMonsterOut, Options.IconMonster, Options.IconMonsterOut,
												null, null, "Toggle to ACTIVATE MonsterDebugger at next launch",true,"Toggle to DEACTIVATE MonsterDebugger at next launch");
			addChild(mMonsters);
			mButtonDict[mMonsters] = mMonsters ;
			vButtonPosX += 16
			//trace("mLoaderProfilerButton.mIsSelected = PROFILE_LOADERS", PROFILE_LOADERS);
			if (_PROFILE_MONSTER) mMonsters.OnClick(null);
			
			
			
			mInfos = new TextField();
			mInfos.mouseEnabled = false;
			mInfos.autoSize = TextFieldAutoSize.LEFT;
			mInfos.defaultTextFormat = myformat;
			mInfos.selectable = false;
			mInfos.appendText("* All options will still be valid at next launch if you save!");
			mInfos.filters = [ myglow ];
			mInfos.x = 2;
			mInfos.y = 150;
			addChild( mInfos );
			
			vButtonPosY = 170
			vButtonPosX = 4;
			mSaveDiskButton = new MenuButton(vButtonPosX, vButtonPosY, Options.IconDiskOut, Options.IconDisk, Options.IconDiskOut,
										null, null, "Save options in SharedObject");
			addChild(mSaveDiskButton);
			//mButtonDict[mSaveDiskButton] = mConfigButton;
			
		}
		
		public function Update() : void
		{
			if (mMemoryProfilerButton.mIsSelected != Configuration.PROFILE_MEMORY)
			{
				Configuration.PROFILE_MEMORY= mMemoryProfilerButton.mIsSelected
				//trace(Configuration.PROFILE_MEMORY);
			}			
			if (mStatsButton.mIsSelected != Configuration.PROFILE_MEMGRAPH)
			{
				Configuration.PROFILE_MEMGRAPH= mStatsButton.mIsSelected
				//trace(Configuration.PROFILE_MEMGRAPH);
			}			
			if (mInternalEventButton.mIsSelected != Configuration.PROFILE_INTERNAL_EVENTS)
			{
				Configuration.PROFILE_INTERNAL_EVENTS = mInternalEventButton.mIsSelected
				//trace(Configuration.PROFILE_INTERNAL_EVENTS);
			}
			if (mFunctionTimeButton.mIsSelected != Configuration.PROFILE_FUNCTION)
			{
				Configuration.PROFILE_FUNCTION = mFunctionTimeButton.mIsSelected
				//trace(Configuration.PROFILE_FUNCTION);
			}
			if (mLoaderProfilerButton.mIsSelected != Configuration.PROFILE_LOADERS)
			{
				Configuration.PROFILE_LOADERS = mLoaderProfilerButton.mIsSelected
				//trace(Configuration.PROFILE_LOADERS);
			}

			if (mMonsters.mIsSelected != Configuration.PROFILE_MONSTER)
			{
				Configuration.PROFILE_MONSTER = mMonsters.mIsSelected
			}
			

			if (mSaveDiskButton.mIsSelected)
			{
				mSaveDiskButton.mIsSelected = false;
				Save();
				mSaveDiskButton.Reset();
			}

		}
		public function Dispose() : void
		{
			this.graphics.clear();
			mInfos = null;
			
			if (mMainSprite != null && mMainSprite.stage != null)
			{
				mMainSprite = null;
			}
		}
		
		static public function Load():void
		{
			trace("Loading configs...");

			PROFILE_MEMORY = true;
			PROFILE_INTERNAL_EVENTS = true;
			PROFILE_FUNCTION = true;
			PROFILE_LOADERS = true;
			PROFILE_SOCKETS = true;
			PROFILE_MEMGRAPH = true;
			PROFILE_MONSTER = false;			
			try
			{
				//mSaveObj = SharedObject.getLocal("FlashPreloadProfiler");	
				//mSaveObj.clear();
				//mSaveObj.flush();
				mSaveObj = SharedObject.getLocal("FlashPreloadProfiler");	
				
				trace("valid object", mSaveObj.data);
				for (var o:* in mSaveObj.data)
				{
					trace(o, mSaveObj.data[o]);
				}
			}
			catch (e:Error)
			{
				mSaveObj = new SharedObject();
				
				Save();
				trace("creating new Save file");
			}			

			if (mSaveObj.data[SETUP_MEMORY_PROFILING_ENABLED] != undefined) PROFILE_MEMORY = mSaveObj.data[SETUP_MEMORY_PROFILING_ENABLED];
			if (mSaveObj.data[SETUP_INTERNALEVENT_PROFILING_ENABLED] != undefined) PROFILE_INTERNAL_EVENTS = mSaveObj.data[SETUP_INTERNALEVENT_PROFILING_ENABLED];
			if (mSaveObj.data[SETUP_FUNCTION_PROFILING_ENABLED] != undefined) PROFILE_FUNCTION = mSaveObj.data[SETUP_FUNCTION_PROFILING_ENABLED];
			if (mSaveObj.data[SETUP_LOADERS_PROFILING_ENABLED] != undefined) PROFILE_LOADERS = mSaveObj.data[SETUP_LOADERS_PROFILING_ENABLED];
			if (mSaveObj.data[SETUP_SOCKETS_PROFILING_ENABLED] != undefined) PROFILE_SOCKETS = mSaveObj.data[SETUP_SOCKETS_PROFILING_ENABLED];
			if (mSaveObj.data[SETUP_MEMGRAPH_PROFILING_ENABLED] != undefined) PROFILE_MEMGRAPH = mSaveObj.data[SETUP_MEMGRAPH_PROFILING_ENABLED];
			if (mSaveObj.data[SETUP_MONSTER_DEBUGGER] != undefined) PROFILE_MONSTER = mSaveObj.data[SETUP_MONSTER_DEBUGGER];
			
		}
		
		static private function Save():void
		{
			trace("Saving!");
			mSaveObj.clear();
			
			mSaveObj.setProperty(SETUP_MEMORY_PROFILING_ENABLED, PROFILE_MEMORY);
			mSaveObj.setProperty(SETUP_INTERNALEVENT_PROFILING_ENABLED, PROFILE_INTERNAL_EVENTS);
			mSaveObj.setProperty(SETUP_FUNCTION_PROFILING_ENABLED, PROFILE_FUNCTION);
			mSaveObj.setProperty(SETUP_LOADERS_PROFILING_ENABLED, PROFILE_LOADERS);
			mSaveObj.setProperty(SETUP_SOCKETS_PROFILING_ENABLED, PROFILE_SOCKETS);
			mSaveObj.setProperty(SETUP_MEMGRAPH_PROFILING_ENABLED, PROFILE_MEMGRAPH);
			mSaveObj.setProperty(SETUP_MONSTER_DEBUGGER, PROFILE_MONSTER);
			
			mSaveObj.flush();
		}
		
		static public function get PROFILE_MEMORY():Boolean { return _PROFILE_MEMORY; }
		static public function set PROFILE_MEMORY(value:Boolean):void 
		{
			_PROFILE_MEMORY = value;
		}

		static public function get PROFILE_FUNCTION():Boolean { return _PROFILE_FUNCTION; }
		static public function set PROFILE_FUNCTION(value:Boolean):void 
		{
			_PROFILE_FUNCTION = value;
		}
		
		static public function get PROFILE_INTERNAL_EVENTS():Boolean { return _PROFILE_INTERNAL_EVENTS; }
		static public function set PROFILE_INTERNAL_EVENTS(value:Boolean):void 
		{
			_PROFILE_INTERNAL_EVENTS = value;
		}
		
		static public function get PROFILE_LOADERS():Boolean { return _PROFILE_LOADERS; }
		static public function set PROFILE_LOADERS(value:Boolean):void 
		{
			_PROFILE_LOADERS = value;
		}
		
		static public function get PROFILE_SOCKETS():Boolean { return _PROFILE_SOCKETS; }
		static public function set PROFILE_SOCKETS(value:Boolean):void 
		{
			_PROFILE_SOCKETS = value;
		}
		
		static public function get PROFILE_MEMGRAPH():Boolean { return _PROFILE_MEMGRAPH; }
		static public function set PROFILE_MEMGRAPH(value:Boolean):void 
		{
			_PROFILE_MEMGRAPH = value;
		}
		
		static public function get PROFILE_MONSTER():Boolean { return _PROFILE_MONSTER; }
		static public function set PROFILE_MONSTER(value:Boolean):void 
		{
			_PROFILE_MONSTER = value;
		}
		
	}
}