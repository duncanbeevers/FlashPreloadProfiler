package net.jpauclair
{
	import flash.display.Bitmap;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
  import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.sampler.*;
	import flash.system.ApplicationDomain;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Mouse;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import net.jpauclair.event.ChangeToolEvent;
	import net.jpauclair.ui.button.MenuButton;
	import net.jpauclair.window.Configuration;
	import net.jpauclair.window.Console;
	import net.jpauclair.window.FlashStats;
	
	import net.jpauclair.window.InstancesLifeCycle;
	import net.jpauclair.window.InternalEventsProfiler;
	import net.jpauclair.window.LoaderProfiler;
	import net.jpauclair.window.MouseListeners;
	import net.jpauclair.window.Overdraw;
	import net.jpauclair.window.PerformanceProfiler;
	import net.jpauclair.window.SamplerProfiler;
	import com.demonsters.debugger.MonsterDebugger;
	
	//Screen qui affiche les différent ApplicationDomain des moviesclips
	//Report good / bad site (google analytics)
	
	//Time to render 1 frame
	//Color for spawned after removal
	// time Code
	// Start Off (off by default)
	// Stage hierarchie info (D.O count, pronfondeur)
	// MouseListener sprites
	// instance created / removed
	
    public class FlashPreloadProfiler extends Sprite
    {
        public static var MySprite:Sprite = null;
        protected static var MainStage:Stage = null;
        public static var MainDisplayObject:DisplayObject = null;
		
		private static var mInitialized:Boolean = false;	//Only for class merging
		
		private var mHookClass:String = "";
		private var mTraceFiles:Boolean = false;
		
		[Embed(source="../../../art/logo.png")]
		private var mLogo:Class;			
		
		private var ShowInstancesLifeCycle:InstancesLifeCycle = null;
		private var ShowMouseListeners:MouseListeners = null;
		private var ShowOverdraw:Overdraw = null;
		private var ShowStats:FlashStats = null;
		private var ShowConfig:Configuration = null;
		private var ShowProfiler:SamplerProfiler = null;		
		private var ShowPerformanceProfiler:PerformanceProfiler = null;		
		private var ShowInternalEvents:InternalEventsProfiler = null;		
		private var ShowLoaderProfiler:LoaderProfiler = null;		
		private var OptionsLayer:Options = null;		

		private var mEmbeded:Boolean = false;
		private var mStartMonster:Boolean = false;
		private var mKeepOnTop:Boolean = false;
		
		private static var mInstance:FlashPreloadProfiler = null;
		
        public function FlashPreloadProfiler() : void
        {
			
			//trace(this.root.name);
			//return;
			mInstance = this;
            trace("Starting FlashPreloadProfiler!");
			
			Configuration.Load();
			
			if (stage) this.init();
            else {  addEventListener(Event.ADDED_TO_STAGE, this.init); }
			
        }
		
		private function OnEnterFrame(e:Event):void 
		{
			if (MainStage == null) return;
			pauseSampling();
			
			SampleAnalyzer.GetInstance().ProcessSampling();
			LoaderAnalyser.GetInstance().Update();
			
			if (this.ShowConfig != null) { this.ShowConfig.Update(); }
			if (this.OptionsLayer != null) { this.OptionsLayer.Update(); }
			if (this.ShowInstancesLifeCycle != null) { this.ShowInstancesLifeCycle.Update(); }
			if (this.ShowOverdraw != null) this.ShowOverdraw.Update();
			if (this.ShowMouseListeners != null) this.ShowMouseListeners.Update();
			if (this.ShowProfiler != null) this.ShowProfiler.Update();
			if (this.ShowPerformanceProfiler != null) this.ShowPerformanceProfiler.Update();
			if (this.ShowInternalEvents != null) this.ShowInternalEvents.Update();
			if (this.ShowLoaderProfiler != null) this.ShowLoaderProfiler.Update();
			if (this.ShowStats != null) { this.ShowStats.Update(); }		
			
			if (mMinimize)
			{
				OptionsLayer.ResetMenu(null);
				ClearTools();
				mMinimize = false;
			}
			
			if (mNextTool != null)
			{
				ChangeTool(mNextTool);
				mNextTool = null;
			}
			
			
			startSampling();
			clearSamples();
			
		}

        private function init(event:Event = null) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, this.init);

			this.OptionsLayer = new Options(MainStage);
			addChild(this.OptionsLayer);

			if (this.stage.loaderInfo.applicationDomain == this.loaderInfo.applicationDomain)
			{
				trace("Direct (embeded) profiler launch");
				SetRoot(this.stage as DisplayObject);
			}
			else
			{
				trace("Indirect profilier launch (waiting for main SWF to load)");
				root.addEventListener("allComplete", this.allCompleteHandler);	
			}
			

			TraceLocalParameters(this.loaderInfo);
			
			if (this.loaderInfo.parameters["HookClass"] != undefined)
			{
				
				mHookClass = this.loaderInfo.parameters["HookClass"];
				trace("Trying to hook to class:", mHookClass);
			}
			
			if (this.loaderInfo.parameters["TraceFiles"] != undefined)
			{
				if (this.loaderInfo.parameters["TraceFiles"] == "true")
				{
					mTraceFiles = true;
				}
				trace("Tracing files loaded...");
			}
			
			if (this.loaderInfo.parameters["MonsterDebugger"] != undefined)
			{
				if (this.loaderInfo.parameters["MonsterDebugger"] == "true")
				{
					mStartMonster = true;
				}
				trace("Monster debugger enabled");
			}			
			
			MySprite = this;
			this.mouseEnabled = false;
			
			
        }
		
        private function allCompleteHandler(event:Event) : void
        {			
            var loaderInfo:LoaderInfo;
			
            try
            {
                loaderInfo = LoaderInfo(event.target);
                
				if (mTraceFiles)
				{
					trace("File loaded:", loaderInfo.url, "Class:", getQualifiedClassName(loaderInfo.content));
				}
				
				if (mInitialized) return;
				
				if (loaderInfo.content.root.stage == null) 
				{
					trace("File loaded but no stage:", loaderInfo.url);
					return; 
				}
				else if (mHookClass != "" && mHookClass != getQualifiedClassName(loaderInfo.content))
				{
					trace("File loaded with stage but wrong class:", loaderInfo.url, getQualifiedClassName(loaderInfo.content));
					return; 					
				}
				else
				{
					trace("File loaded with stage:", loaderInfo.url, "Class:",getQualifiedClassName(loaderInfo.content));
				}
				
				SetRoot(loaderInfo.content.root as DisplayObject)
			}
            catch (e:Error)
            {
				trace(e);
            }
        }
		
		private function SetRoot(aDisplayObject:DisplayObject) : void
		{
			root.removeEventListener("allComplete", this.allCompleteHandler);	
			try 
			{	
                MainDisplayObject = aDisplayObject;
                MainStage = MainDisplayObject.stage;

				MainStage.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
				
				OptionsLayer.SetStage(MainStage);
				//Add our preloader to stage Sprite
                MainStage.addChild(this);				
				                
				//Trace all paramaters loaded in Main application
				TraceLocalParameters(loaderInfo);
				
				
				if (this.OptionsLayer != null)
				{
					//Configuration.PROFILE_MONSTER
					//this.OptionsLayer.AutoStartMonsterDebugger = true;
					//this.OptionsLayer.addEventListener(ChangeToolEvent.CHANGE_TOOL_EVENT, OnChangeTool);
				}
							
				if (Configuration.PROFILE_MONSTER)
				{
					MonsterDebugger.initialize(MainStage, '127.0.0.1', this.OptionsLayer.OnDebuggerConnect);
					//trace("DeMonsterDebugger instanciated");
				}
				else
				{
					this.OptionsLayer.SetMonsterDisabled();
				}
								
				//Timer Event (Keep this on top and add ShowProfiler option)
				if (mKeepOnTop)
				{
					var t:Timer = new Timer(1000,0);
					t.addEventListener(TimerEvent.TIMER, this.OnTimer);				
					t.start();
				}
			
				mInitialized = true;
				
				SampleAnalyzer.GetInstance().ClearSamples();
				
            }
            catch (e:Error)

            {
				trace(e);
            }
			
		}
		
		private static var mNextTool:Class = null;
		private static var mMinimize:Boolean = false;
		public static function StaticChangeTool(aButton:MenuButton) : void
		{
			if (aButton == null) 
			{
				mMinimize = true;
				return;
			}
			else
			{
				mMinimize = false;
			}
			mNextTool = aButton.mTool;
			if (mInstance.OptionsLayer != null)
			{
				mInstance.OptionsLayer.ResetMenu(aButton);
			}
		}
		private function OnChangeTool(e:ChangeToolEvent):void 
		{
			//SampleAnalyzer.GetInstance().PauseSampling();
			ChangeTool(e.mTool);
			//SampleAnalyzer.GetInstance().StartSampling();
		}
		
		
		private function TraceLocalParameters(loaderInfo:LoaderInfo) : void
		{
				var paramName:String;
                var paramValue:String;
                while (paramName in loaderInfo.parameters)
                {
                    paramValue = loaderInfo.parameters[paramName];
                    trace("Main Params:", paramName, " = ", paramValue);
                }
		}
						
        private function ShowBar(event:ContextMenuEvent) : void
        {
            this.visible = !this.visible;
            //trace(this.visible);
        }
		
		
        private function OnTimer(event:TimerEvent) : void
        {
            var menu:ContextMenu = null;
            var alreadyInMenu:Boolean = false;
            var i:int = 0;
            var menuItem:ContextMenuItem = null;
			
			Mouse.show();
			//Console.Trace("TEST", int(Math.random() * int.MAX_VALUE));
			
			//Make sure the stage is initialized
            if (MainStage != null)
            {
				//trace("SetOnTop");
				MainStage.addChildAt(this, MainStage.numChildren - 1);
				//Add On Top
                MainStage.addChildAt(MySprite, (MainStage.numChildren - 1));
                return;
				//Manage Contextual menu
				//Many application re-initialize the menu each frame depending on interaction...
				//toString make sure we stay in the menu we must made it on top each frame.
				//TODO is it really needed? (flash param? flash
				menu = MainDisplayObject.contextMenu;
                if (menu == null)
                {
                    menu = new ContextMenu();
                    MainDisplayObject.contextMenu = menu;
                }
                alreadyInMenu = false;
                if (menu.customItems != null)
                {
                    i = 0;
                    while (i < menu.customItems.length)
                    {
                        
                        if ((menu.customItems[i] as ContextMenuItem).caption == "Show Profiler")
                        {
                            alreadyInMenu = true;
                            break;
                        }
                        i = i + 1;
                    }
                }
                if (!alreadyInMenu)
                {
                    menuItem = new ContextMenuItem("Show Profiler");
                    menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, this.ShowBar);
                    menu.customItems.push(menuItem);
                }
            }
        }		

		private function ClearTools() : void 
		{
			if (this.ShowConfig != null) { this.ShowConfig.Dispose(); this.ShowConfig = null; }
			if (this.ShowInstancesLifeCycle != null) { this.ShowInstancesLifeCycle.Dispose(); this.ShowInstancesLifeCycle = null; }
			if (this.ShowOverdraw != null) { this.ShowOverdraw.Dispose(); this.ShowOverdraw = null; }
			if (this.ShowProfiler != null) { this.ShowProfiler.Dispose(); this.ShowProfiler = null; }
			if (this.ShowPerformanceProfiler != null) { this.ShowPerformanceProfiler.Dispose(); this.ShowPerformanceProfiler = null; }
			if (this.ShowInternalEvents!= null) { this.ShowInternalEvents.Dispose(); this.ShowInternalEvents = null; }
			if (this.ShowLoaderProfiler!= null) { this.ShowLoaderProfiler.Dispose(); this.ShowLoaderProfiler = null; }
			if (this.ShowMouseListeners != null) { this.ShowMouseListeners.Dispose(); this.ShowMouseListeners = null; }
			if (this.ShowStats != null) { this.ShowStats.Dispose(); this.ShowStats = null; }		
			Options.mIsCamEnabled = false;
			Options.mIsPerformanceSnaptopEnabled = false;
			Options.mIsLoaderSnaptopEnabled = false;
			
			Options.mIsSaveEnabled = false;				
			Options.mIsClockEnabled = false;

			OptionsLayer.ShowInterfaceCustomizer(false);
			
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
			this.addChild(OptionsLayer);
			
		}
		private function ChangeTool(aClass:Class):void
		{
			ClearTools();

			if (aClass == FlashStats)
			{
				Options.mIsSaveEnabled = false;				
				OptionsLayer.ShowInterfaceCustomizer(true);
				
				this.ShowStats = new FlashStats(MainStage);
				addChildAt(this.ShowStats,0);
			}
			else if (aClass == InstancesLifeCycle)
			{
				this.ShowInstancesLifeCycle = new InstancesLifeCycle(MainStage);
				addChildAt(this.ShowInstancesLifeCycle,0);
			}
			else if (aClass == Overdraw)
			{
				this.ShowOverdraw = new Overdraw(MainStage);
				addChildAt(this.ShowOverdraw,0);
			}
			else if (aClass == Configuration)
			{
				this.ShowConfig = new Configuration(MainDisplayObject);
				addChildAt(this.ShowConfig,0);
			}
			else if (aClass == SamplerProfiler)
			{
				Options.mIsCamEnabled = true;
				Options.mIsSaveEnabled = true;				
				Options.mIsClockEnabled = true;				
				OptionsLayer.ShowInterfaceCustomizer(true);
				this.ShowProfiler = new SamplerProfiler(MainStage);
				addChildAt(this.ShowProfiler,0);
			}	
			else if (aClass == PerformanceProfiler)
			{
				
				Options.mIsSaveEnabled = true;				
				Options.mIsClockEnabled = true;				
				Options.mIsPerformanceSnaptopEnabled = true;
				OptionsLayer.ShowInterfaceCustomizer(true);
				
				this.ShowPerformanceProfiler = new PerformanceProfiler(MainStage);
				addChildAt(this.ShowPerformanceProfiler,0);
			}				
			else if (aClass == InternalEventsProfiler)
			{
				Options.mIsSaveEnabled = true;				
				Options.mIsClockEnabled = true;				
				OptionsLayer.ShowInterfaceCustomizer(true);
				this.ShowInternalEvents = new InternalEventsProfiler(MainStage);
				addChildAt(this.ShowInternalEvents,0);
			}			
			else if (aClass == LoaderProfiler)
			{
				Options.mIsSaveEnabled = true;				
				Options.mIsClockEnabled = true;				
				Options.mIsLoaderSnaptopEnabled = true;
				OptionsLayer.ShowInterfaceCustomizer(true);
				this.ShowLoaderProfiler = new LoaderProfiler(MainStage);
				addChildAt(this.ShowLoaderProfiler,0);
			}			
			else if (aClass == MouseListeners)
			{
				this.ShowMouseListeners = new MouseListeners(MainStage);
				addChildAt(this.ShowMouseListeners,0);
			}		

			//SampleAnalyzer.GetInstance().ResumeSampling();
		}
    }
}
