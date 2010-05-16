package 
{
	import com.bit101.components.RadioButton;
	import com.bit101.components.WheelMenu;
	import flash.display.Bitmap;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.sampler.*;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Mouse;
	import flash.utils.getQualifiedClassName;
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
        protected static var MySprite:Sprite = null;
        protected static var MainStage:Stage = null;
        protected static var MainSprite:Sprite = null;
		
		private static var mLoadedOnce:Boolean = false;	//Only for class merging
		private var debugger:MonsterDebugger;
		private var mLayers:Layers = null; 
		private var mHookClass:String = "";
		private var mTraceFiles:Boolean = false;
		private var mMonsterDebugger:Boolean = false;
		
		[Embed(source="logo.png")]
		private var BeeLabLogo:Class;			
		
        public function FlashPreloadProfiler() : void
        {
            trace("Starting FlashXRay...");
            
			if (stage) this.init();
            else {  addEventListener(Event.ADDED_TO_STAGE, this.init); }
        }

        final private function init(event:Event = null) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, this.init);

			
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
					mMonsterDebugger = true;
				}
				trace("Monster debugger enabled");
			}			
			
			MySprite = this;
			this.mouseEnabled = false;
			
			
			
			mLayers= new Layers();
			this.addChild(mLayers);			
			this.ShowOptions =			true;
        }
		
        final private function allCompleteHandler(event:Event) : void
        {
			//trace("FlashPreloadProfiler allCompleteHandler",mLoadedOnce);
			
			//trace("FlashPreloadProfiler allCompleteHandler");
			
            var loaderInfo:LoaderInfo;
			
            try
            {
                loaderInfo = LoaderInfo(event.target);
                
				if (mTraceFiles)
				{
					trace("File loaded:", loaderInfo.url, "Class:", getQualifiedClassName(loaderInfo.content));
				}
				
				if (mLoadedOnce) return;
				
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
                MainSprite = loaderInfo.content.root as Sprite;
                MainStage = MainSprite.stage;

				//trace("Listening to resize");
                MainStage.addEventListener(Event.RESIZE, OnStageResize);
								
				//Add our preloader to stage Sprite
                MainStage.addChild(this);				
				                
				//Trace all paramaters loaded in Main application
				TraceLocalParameters(loaderInfo);
				
				/*
				this.ShowOptions =			true;
				
				this.ShowOverdraw =			false;

				this.ShowStats =			false;
				
				this.ShowMouseListeners =	false;
				
				this.ShowInstancesLifeCycle =	false;
				*/
				this.ShowLogo =				true;
				
				if (mLayers.OptionsLayer != null)
				{
					mLayers.OptionsLayer.AutoStartMonsterDebugger = true;
					mLayers.OptionsLayer.addEventListener("toggleOverdraw", function():void { ResetTools(); ShowOverdraw = (mLayers.OverdrawLayer == null) } );
					mLayers.OptionsLayer.addEventListener("toggleMouseListeners", function():void { ResetTools();ShowMouseListeners = (mLayers.MouseListenerLayer==null) } );
					mLayers.OptionsLayer.addEventListener("toggleStats", function():void { ResetTools(); ShowStats = (mLayers.StatisticsLayer == null) } );
					mLayers.OptionsLayer.addEventListener("toggleInstancesLifeCycle", function():void { ResetTools(); ShowInstancesLifeCycle = (mLayers.InstancesLifeCycleLayer==null) } );
				}
				
				//if (mLayers.OptionsLayer != null && mLayers.OptionsLayer.AutoStartMonsterDebugger)
				if (mMonsterDebugger)
				{
					debugger = new MonsterDebugger(MainStage);	
					MainStage.addEventListener("DebuggerDisconnected", mLayers.OptionsLayer.OnDebuggerDisconnect);
					MainStage.addEventListener("DebuggerConnected", mLayers.OptionsLayer.OnDebuggerConnect);
					//mLayers.OptionsLayer.
					trace("DeMonsterDebugger instanciated");
				}
				else
				{
					mLayers.OptionsLayer.SetMonsterDisabled();
				}
				
				//EnterFrame Event
				MainStage.addEventListener(Event.ENTER_FRAME, this.OnEnterFrame);
				
				//Timer Event (Keep this on top and add ShowProfiler option)
				var t:Timer = new Timer(500,0);
                t.addEventListener(TimerEvent.TIMER, this.OnTimer);
                t.start();	
				
				mLoadedOnce = true;
				
				
				
            }
            catch (e:Error)
            {
				trace(e);
            }
        }
		
		final private function TraceLocalParameters(loaderInfo:LoaderInfo) : void
		{
				var paramName:String;
                var paramValue:String;
                while (paramName in loaderInfo.parameters)
                {
                    paramValue = loaderInfo.parameters[paramName];
                    trace("Main Params:", paramName, " = ", paramValue);
                }
		}
		
		final private function OnStageResize(e:Event):void 
		{
			trace("On Stage Resize");
			mLayers.OptionsLayer.y = 0;// MainStage.stage.stageHeight - mLayers.OptionsLayer.height;
		}
		
		
		final private function OnEnterFrame(e:Event):void
		{

		}
		
        final private function ShowBar(event:ContextMenuEvent) : void
        {
            this.visible = !this.visible;
            trace(this.visible);
        }
		
		
        final private function OnTimer(event:TimerEvent) : void
        {
            var menu:ContextMenu = null;
            var alreadyInMenu:Boolean = false;
            var i:int = 0;
            var menuItem:ContextMenuItem = null;
			
			Mouse.show();
			//Make sure the stage is initialized
            if (MainStage != null)
            {
				//Add On Top
				//trace("Set on top");
                MainStage.addChildAt(MySprite, (MainStage.numChildren - 1));
                
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

		
		public function set ShowLogo(active:Boolean) : void
		{
			trace("ShowLogo", active, mLayers.LogoLayer);
			if (active == true && mLayers.LogoLayer == null)
			{
				var logo:Bitmap = new BeeLabLogo();
				logo.x = this.stage.stageWidth - logo.width;
				//logo.y = this.stage.stageHeight - logo.height;
				//logo.alpha = 0.2
				logo.alpha = 0.0
				
				mLayers.LogoLayer = logo;
			}
			else if (active == false && mLayers.LogoLayer != null)
			{
				mLayers.LogoLayer.bitmapData.dispose();
				mLayers.LogoLayer = null;
			}
		}		
		
		public function set ShowInstancesLifeCycle(active:Boolean) : void
		{
			trace("ShowInstancesLifeCycle", active, mLayers.InstancesLifeCycleLayer);
			if (active == true && mLayers.InstancesLifeCycleLayer == null)
			{
				mLayers.InstancesLifeCycleLayer = new InstancesLifeCycle(MainSprite);
			}
			else if (active == false && mLayers.InstancesLifeCycleLayer != null)
			{
				mLayers.InstancesLifeCycleLayer.Dispose();
				mLayers.InstancesLifeCycleLayer = null;
			}
		}
		
		public function set ShowMouseListeners(active:Boolean) : void
		{
			trace("ShowMouseListeners", active, mLayers.MouseListenerLayer);
			if (active == true && mLayers.MouseListenerLayer == null)
			{
				mLayers.MouseListenerLayer = new MouseListeners(MainStage);
			}
			else if (active == false && mLayers.MouseListenerLayer != null)
			{
				mLayers.MouseListenerLayer.Dispose();
				mLayers.MouseListenerLayer = null;
			}
		}
		
		
		public function set ShowStats(active:Boolean) : void
		{
			trace("ShowStats", active, mLayers.StatisticsLayer);
			if (active == true && mLayers.StatisticsLayer == null)
			{
				mLayers.StatisticsLayer = new FlashStats(MainStage);
				mLayers.StatisticsLayer.y = MainStage.stageHeight - mLayers.StatisticsLayer.height
			}
			else if (active == false && mLayers.StatisticsLayer != null)
			{
				mLayers.StatisticsLayer.Dispose();
				mLayers.StatisticsLayer = null;
			}
		}
		
		public function set ShowOptions(active:Boolean) : void
		{
			trace("ShowOptions", active, mLayers.OptionsLayer);
			if (active == true && mLayers.OptionsLayer == null)
			{
				mLayers.OptionsLayer = new Options();
				//mLayers.OptionsLayer.y = 0MainStage.stageHeight - mLayers.OptionsLayer.height
			}
			else if (active == false && mLayers.OptionsLayer != null)
			{
				mLayers.OptionsLayer.Dispose();
				mLayers.OptionsLayer = null;
			}
		}
		
		public function set ShowOverdraw(active:Boolean) : void
		{
			trace("ShowOverdraw", active, mLayers.OverdrawLayer);
			if (active == true && mLayers.OverdrawLayer == null)
			{
				mLayers.OverdrawLayer = new Overdraw(MainStage);
				MainSprite.alpha = 0;
			}
			else if (active == false && mLayers.OverdrawLayer != null)
			{
				MainSprite.alpha = 1;
				mLayers.OverdrawLayer.Dispose();
				mLayers.OverdrawLayer = null;
			}
		}
		final private function ResetTools():void
		{
			this.ShowInstancesLifeCycle = false;
			this.ShowMouseListeners = false;
			this.ShowOverdraw = false;
			this.ShowStats = false;
		}
    }
}
