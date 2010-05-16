package 
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	public class FlashStats extends Sprite implements IDisposable
	{
		protected static var BACKGROUND_COLOR:uint = 0xff666666;
		protected static var LINE_COLOR:uint = 0x33999999;
		protected static var GRAPH_COLOR:uint = 0xffF29F05;

		
		private var _mytext:TextField;
		private var _fps:uint;
		private var _timer:Timer;
		private var _graph:BitmapData;
		private var _graphMem:BitmapData;
		private var _lineRect:Rectangle = new Rectangle();

		private var _lastTotalMem:uint;
		private var _lastTotalMemMax:uint;
		
		private var mLastUpdateTime:int = 0;
		private var memGraphWidth:int = 160;
		private var memGraphHeight:int = 12;
		private var MinimumBartimeStamp:int = 0;
		private var MinimumBar:Sprite
		private var MinimumBarValue:Number = 9999999;
		
		public function FlashStats(obj:DisplayObject) 
		{
			Init();
			this.mouseChildren = false;
			this.mouseEnabled = false;
			MinimumBartimeStamp = getTimer();
		}

		final private function Init():void 
		{
			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
		
			var barWidth:int = 540;
			var bgSprite:Sprite = new Sprite();
			bgSprite.graphics.beginFill(0x000000, 0.3);
			bgSprite.graphics.drawRect(0, 0, barWidth, 17);
			bgSprite.graphics.endFill();
			bgSprite.graphics.beginFill(0xCCCCCC, 0.6);
			bgSprite.graphics.drawRect(0, 1, barWidth, 1);
			bgSprite.graphics.endFill();
			bgSprite.graphics.beginFill(0xFFFFFF, 0.8);
			bgSprite.graphics.drawRect(0, 0, barWidth, 1);
			bgSprite.graphics.endFill();
			addChild(bgSprite);

			// fps graph
			var memGraphHolder:Sprite = new Sprite();
			memGraphHolder.x = 210;
			addChild( memGraphHolder );			
			_graphMem = new BitmapData( memGraphWidth, memGraphHeight, false, BACKGROUND_COLOR );
			_graphMem.fillRect(_graphMem.rect, 0xFF000000);
			var bmpMem:Bitmap = new Bitmap( _graphMem )
			bmpMem.y = 2;
			memGraphHolder.addChild( bmpMem );
//			DrawGraphLines();

			MinimumBar = new Sprite();
			MinimumBar.graphics.beginFill(0xFFDD00, 0.7);
			MinimumBar.graphics.drawRect(0, 2, 1, memGraphHeight);
			MinimumBar.graphics.endFill();	
			addChild(MinimumBar);
			
			var graphHolder:Sprite = new Sprite();
			graphHolder.x = 65;
			addChild( graphHolder );
			_graph = new BitmapData( 40, 12, false, BACKGROUND_COLOR );
			var bmp:Bitmap = new Bitmap( _graph )
			bmp.y = 2;
			graphHolder.addChild( bmp );
			DrawGraphLines();
			
			// display label
			_mytext = new TextField();
			_mytext.autoSize = TextFieldAutoSize.LEFT;
			_mytext.defaultTextFormat = myformat;
			_mytext.selectable = false;
			_mytext.text = "  FPS = 0\t Mem = 0000 Ko \tMemMax = 0000 Ko";
			_mytext.filters = [ myglow ];
			_mytext.y = -1;
			addChild( _mytext );
			
			// setup our timers
			_fps = 0;
			_timer = new Timer( 1000 );
			_timer.addEventListener( TimerEvent.TIMER, OnTimerEvent,false,0,true);
			_timer.start();
			
			this.addEventListener( Event.ENTER_FRAME, OnEnterFrame );
		}

		final public function Dispose():void
		{
			this.removeEventListener( Event.ENTER_FRAME, OnEnterFrame );
			
			_mytext = null;
			if (_timer != null)
			{
				_timer.removeEventListener(TimerEvent.TIMER, OnTimerEvent);
			}
			_timer = null;
			if (_graph != null)
			{
				_graph.dispose();	
				_graph.dispose();	
			}
			
			if (_graphMem != null)
			{
				_graphMem.dispose();
			}
			
			_lineRect = null;

			MinimumBar = null;
		}
		
		final private function DrawGraphLines():void 
		{
			for ( var i:Number = 5; i < _graph.height; i += 5 ) 
			{
				_lineRect.x = 0;
				_lineRect.y = i;
				_lineRect.width = _graph.width;
				_lineRect.height = 1;
				_graph.fillRect( _lineRect, LINE_COLOR );
			}
		}
		
		final private function OnEnterFrame( e:Event ):void 
		{
			var totalMem:int = int(System.totalMemory / 1000)
			var diff:int = totalMem - _lastTotalMem;
			var time:int = getTimer();
			
			mLastUpdateTime = time;
			_fps++;
			_graphMem.scroll(0, -1);
			var posX:int = (Number(_lastTotalMem) / Number(_lastTotalMemMax))  * _graphMem.width-1;
			//trace(posX);
			_graphMem.lock();
			
			for (var i:int = 0; i < memGraphWidth; i++)
			{
				var color:uint = (_graphMem.getPixel(i, memGraphHeight - 2))
				var r:uint = (((color&0xFF0000) >> 16) *0.99) << 16;
				var g:uint = (((color&0x00FF00) >> 8) *0.99) << 8;
				var b:uint = (((color & 0x0000FF)) *0.99);
				color = r + g + b;
				_graphMem.setPixel32(i, memGraphHeight - 1, color);
			}
			
			_graphMem.setPixel32(posX, _graphMem.height - 1, 0xFFFFFFFF)			
			_graphMem.unlock();
			
			if (MinimumBar != null)
			{
				var posBar:int 
				if (_lastTotalMem < MinimumBarValue)
				{
					posBar = (Number(_lastTotalMem) / Number(_lastTotalMemMax))  * _graphMem.width-2;
					MinimumBarValue = _lastTotalMem;
					MinimumBartimeStamp = getTimer();
					MinimumBar.x = 210 + posBar;
				}
				if (MinimumBarValue == 0)
				{
					MinimumBarValue = 1
				}				
				if (getTimer() - MinimumBartimeStamp > 1000 * 10)
				{
					if (_lastTotalMem - MinimumBarValue < 30)
					{
						MinimumBarValue = _lastTotalMem;
						MinimumBartimeStamp = getTimer();
					}
					else
					{
						MinimumBarValue += (_lastTotalMem-MinimumBarValue)*0.01;
					}
					posBar = (Number(MinimumBarValue) / Number(_lastTotalMemMax))  * _graphMem.width - 2;
					if (posBar > _graphMem.width-2)
					{
						posBar = _graphMem.width-2
					}
					
					MinimumBar.x = 210 + posBar;
				}
			}
			
			
		}
		/**
		 * Manage the Timer event to update number on screen
		 * @param	e
		 */
		final private function OnTimerEvent( e:Event ):void 
		{
			// update our graph for the current tick
			_lineRect.x = _graph.width -1 ;
			_lineRect.y = 0;
			_lineRect.width = 1;
			_lineRect.height = _graph.height;			
			_graph.fillRect( _lineRect, BACKGROUND_COLOR );
			var val:Number = ( _fps / 2 );
			_lineRect.x = _graph.width - 1;
			_lineRect.width = 1;
			if (this.stage != null)
			{
				_lineRect.height = _graph.height * (Number(_fps) / Number(this.stage.frameRate));
			}
			else
			{
				_lineRect.height = _graph.height;
			}		
			_lineRect.y = _graph.height-_lineRect.height;
			_graph.fillRect( _lineRect, GRAPH_COLOR );
			_graph.scroll( -2, 0 );
			DrawGraphLines();



			var totalMem:int = int(System.totalMemory / 1000)
			_lastTotalMem = totalMem;
			if (_lastTotalMem > _lastTotalMemMax)
			{
				_lastTotalMemMax = _lastTotalMem;
			}
			

			
			_mytext.text = "  FPS = "
			_mytext.appendText(_fps.toString());
			_mytext.appendText("\t\t\t\tMem = ");
			_mytext.appendText(totalMem.toString());
			_mytext.appendText(" Ko");			
			_mytext.appendText("\t\t\t\t\t\t\t\t\t\t\tMax = ");
			_mytext.appendText(_lastTotalMemMax.toString());
			_mytext.appendText(" Ko");							
			_fps = 0;
		}
	}
}
