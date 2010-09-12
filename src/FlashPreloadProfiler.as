package 
{
	import flash.display.Bitmap;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.sampler.*;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Mouse;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import nl.demonsters.debugger.MonsterDebugger;
	
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
        protected static var MainSprite:Sprite = null;
		
		private static var mInitialized:Boolean = false;	//Only for class merging
		
		private var debugger:MonsterDebugger;
		private var mHookClass:String = "";
		private var mTraceFiles:Boolean = false;
		
		[Embed(source="../art/logo.png")]
		private var mLogo:Class;			
		
		private var ShowInstancesLifeCycle:InstancesLifeCycle = null;
		private var ShowMouseListeners:MouseListeners = null;
		private var ShowOverdraw:Overdraw = null;
		private var ShowStats:FlashStats = null;
		private var ShowHelp:Help = null;
		private var ShowProfiler:SamplerProfiler = null;		
		private var ShowInternalEvents:InternalEventsProfiler = null;		
		private var OptionsLayer:Options = null;		

		private var mEmbeded:Boolean = false;
		private var mStartMonster:Boolean = false;
		private var mKeepOnTop:Boolean = false;
		
        public function FlashPreloadProfiler(embded:Boolean = false, startMonster:Boolean = false, traceLoadedFiles:Boolean = true, keepOnTop:Boolean = true ) : void
        {
            trace("Starting FlashPreloadProfiler...");
            mEmbeded = embded;
            mStartMonster = startMonster;
			mTraceFiles = traceLoadedFiles;
			mKeepOnTop = keepOnTop;
			
			if (stage) this.init();
            else {  addEventListener(Event.ADDED_TO_STAGE, this.init); }
        }

        private function init(event:Event = null) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, this.init);

			if (mEmbeded)
			{
				SetRoot(this.stage as Sprite);
			}
			else
			{

				root.addEventListener("allComplete", this.allCompleteHandler);

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
			}				
			
			MySprite = this;
			this.mouseEnabled = false;
			
			
			this.OptionsLayer = new Options(MainStage);
			addChild(this.OptionsLayer);
			
			addChild(new Console());
			//this.ShowOptions =	true;
			
			//Console.Trace("test", 0xFFFF0000);
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
				
				SetRoot(loaderInfo.content.root as Sprite)
			}
            catch (e:Error)
            {
				trace(e);
            }
        }
		
		private function SetRoot(aSprite:Sprite) : void
		{
			try 
			{	
                MainSprite = aSprite;
                MainStage = MainSprite.stage;

				OptionsLayer.SetStage(MainStage);
				//Add our preloader to stage Sprite
                MainStage.addChild(this);				
				                
				//Trace all paramaters loaded in Main application
				TraceLocalParameters(loaderInfo);
				
				
				if (this.OptionsLayer != null)
				{
					this.OptionsLayer.AutoStartMonsterDebugger = true;
					this.OptionsLayer.addEventListener("toggleMinimize", function():void { ChangeTool(null); } );
					this.OptionsLayer.addEventListener("toggleOverdraw", function():void { ChangeTool(Overdraw); } );
					this.OptionsLayer.addEventListener("toggleMouseListeners", function():void { ChangeTool(MouseListeners); } );
					this.OptionsLayer.addEventListener("toggleStats", function():void { ChangeTool(FlashStats); } );
					this.OptionsLayer.addEventListener("toggleInstancesLifeCycle", function():void { ChangeTool(InstancesLifeCycle); } );
					this.OptionsLayer.addEventListener("toggleProfiler", function():void { ChangeTool(SamplerProfiler); } );
					this.OptionsLayer.addEventListener("toggleInternalEvents", function():void { ChangeTool(InternalEventsProfiler); } );
					this.OptionsLayer.addEventListener("toggleHelp", function():void { ChangeTool(Help); } );
				}
							
				if (mStartMonster)
				{
					debugger = new MonsterDebugger(MainStage);	
					MainStage.addEventListener("DebuggerDisconnected", this.OptionsLayer.OnDebuggerDisconnect);
					MainStage.addEventListener("DebuggerConnected", this.OptionsLayer.OnDebuggerConnect);
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
				
				
				
            }
            catch (e:Error)

            {
				trace(e);
            }
			
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
			var t:int = getTimer();
			while (getTimer() - t < 100) { }
			
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
				menu = MainSprite.contextMenu;
                if (menu == null)
                {
                    menu = new ContextMenu();
                    MainSprite.contextMenu = menu;
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

		private function ChangeTool(aClass:Class):void
		{
			if (this.ShowHelp != null) { this.ShowHelp.Dispose(); this.ShowHelp = null; }
			if (this.ShowInstancesLifeCycle != null) { this.ShowInstancesLifeCycle.Dispose(); this.ShowInstancesLifeCycle = null; }
			if (this.ShowOverdraw != null) { this.ShowOverdraw.Dispose(); this.ShowOverdraw = null; }
			if (this.ShowProfiler != null) { this.ShowProfiler.Dispose(); this.ShowProfiler = null; }
			if (this.ShowInternalEvents!= null) { this.ShowInternalEvents.Dispose(); this.ShowInternalEvents = null; }
			if (this.ShowMouseListeners != null) { this.ShowMouseListeners.Dispose(); this.ShowMouseListeners = null; }
			if (this.ShowStats != null) { this.ShowStats.Dispose(); this.ShowStats = null; }		

			Options.mIsCamEnabled = false;
			Options.mIsSaveEnabled = false;				
			Options.mIsClockEnabled = false;

			OptionsLayer.ShowInterfaceCustomizer(false);
			
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
			this.addChild(OptionsLayer);

			
			
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
			else if (aClass == Help)
			{
				this.ShowHelp = new Help(MainSprite);
				addChildAt(this.ShowHelp,0);
			}
			else if (aClass == SamplerProfiler)
			{
				Options.mIsCamEnabled = true;
				Options.mIsSaveEnabled = true;				
				OptionsLayer.mRecordingTxt.text = "Save to Clipboard:";
				OptionsLayer.ShowInterfaceCustomizer(true);
				this.ShowProfiler = new SamplerProfiler(MainStage);
				addChildAt(this.ShowProfiler,0);
			}	
			else if (aClass == InternalEventsProfiler)
			{
				Options.mIsSaveEnabled = true;				
				OptionsLayer.mRecordingTxt.text = "Save to Clipboard:";
				OptionsLayer.ShowInterfaceCustomizer(true);
				this.ShowInternalEvents = new InternalEventsProfiler(MainStage);
				addChildAt(this.ShowInternalEvents,0);
			}			
			else if (aClass == MouseListeners)
			{
				this.ShowMouseListeners = new MouseListeners(MainStage);
				addChildAt(this.ShowMouseListeners,0);
			}		


		}
    }
}
