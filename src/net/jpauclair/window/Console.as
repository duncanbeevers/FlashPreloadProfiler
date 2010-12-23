package net.jpauclair.window
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import net.jpauclair.IDisposable;
	/**
	 * ...
	 * @author 
	 */
	public class Console extends Bitmap implements IDisposable
	{
		private static var mInterfaceHolder:Sprite = new Sprite();
		private static var mTextLineOutput:TextField = new TextField();
		private static var mFullLog:ByteArray = new ByteArray();
		
		private static var mInstance:Console;
		
		
		private static const COLOR_ERROR:uint = 0xFFFF0000;
		private static const COLOR_WARNING:uint = 0xFFF2B705;
		private static const COLOR_INFO:uint = 0xFFFFFFFF;
		private static const COLOR_SUGGESTION:uint = 0xFF0000AA;
		private static const MAX_LINE_COUNT:int = 25;
		
		private static var mNextLineId:int = MAX_LINE_COUNT - 1;
		
		private static var mDimention:Point = new Point();
		
		private static const COLOR_SWEEP:uint = 0xFFF2B705;
		public function Console() 
		{
			this.y = 22;
			mInstance = this;
			if (stage) this.init();
            else {  addEventListener(Event.ADDED_TO_STAGE, this.init); }
			
		}
		
        private function init(event:Event = null) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, this.init);
			
			bitmapData = new BitmapData(10, 10, true, 0x66000000);
			//bitmapData = new BitmapData(this.root.stage.width, this.root.stage.height, true, 0x66000000);
	
			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
			
			mTextLineOutput = new TextField();
			mTextLineOutput.autoSize = TextFieldAutoSize.LEFT;
			mTextLineOutput.defaultTextFormat = myformat;
			mTextLineOutput.selectable = false;
			mTextLineOutput.filters = [ myglow ];
			
			mBitmapMatrix.tx = 2;
			mBitmapMatrix.ty = mInstance.bitmapData.height - 22-14
			
			mDimention.x = this.root.stage.stageWidth
			mDimention.y = this.root.stage.stageHeight
		}		
		
		private static function Resize():void 
		{
			var newBmp:BitmapData= new BitmapData(mInstance.stage.stageWidth, mInstance.stage.stageHeight, true, 0x66000000);	
			newBmp.draw(mInstance);
			mInstance.bitmapData = newBmp;
			
			mTextLineOutput.width = mInstance.stage.stageWidth;
			mTextLineOutput.height = mInstance.stage.stageHeight;
			mBitmapMatrix.tx = 2;
			mBitmapMatrix.ty = mInstance.stage.stageHeight - 22-14;
			
			mDimention.x = mInstance.stage.stageWidth
			mDimention.y = mInstance.stage.stageHeight
			
			//Trace(mInstance.stage.stageWidth.toString() + "x" + mInstance.stage.stageWidth.toString());
		}
		
		private static const mBitmapMatrix:Matrix = new Matrix();
		/* INTERFACE IDisposable */
		
		public function Dispose():void
		{
			
		}
		
		public static function Trace(text:String, color:uint = COLOR_INFO) : void
		{
			mFullLog.writeUTF(text);
			mFullLog.writeUTF("\n");
						
			mTextLineOutput.text = text;
			mTextLineOutput.textColor = color;
		
			if (mInstance != null && mInstance.stage != null)
			{
				if  (mDimention.x != mInstance.stage.stageWidth ||  mDimention.y != mInstance.stage.stageHeight)
				{
					Resize();
				}
				mInstance.bitmapData.scroll(0, -14);
				mInstance.bitmapData.draw(mTextLineOutput, mBitmapMatrix );
			}

			
		}
		
		
		private static function initTextfields() : Array
		{
			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );

			var arr:Array = new Array();
			for (var i:int = 0; i < MAX_LINE_COUNT; i++)
			{
				arr[i] = new TextField();
				arr[i].autoSize = TextFieldAutoSize.LEFT;
				arr[i].defaultTextFormat = myformat;
				arr[i].selectable = false;
				arr[i].filters = [ myglow ];
				arr[i].x = 2;
				arr[i].y = 300 - (i * 12);
				
				//arr[i].text = "foo:" + i;
				(arr[i] as TextField).textColor = 0xFF00FF00;
				mInterfaceHolder.addChild(arr[i]);
				
			}
			
			return arr;
		}
		
		public static function TraceSweep(time:Number) : void
		{
			Trace("[SWEEP] " + int((time/1000)).toString() + " ms", COLOR_SWEEP)
		}
		
	}

}