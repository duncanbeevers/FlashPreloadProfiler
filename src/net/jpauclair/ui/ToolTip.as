package net.jpauclair.ui 
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author jpauclair
	 */
	public class ToolTip extends Sprite
	{
		private var mText:TextField = null;
		private static var mInstance:ToolTip = null;
		public function ToolTip() 
		{
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff,true );
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );
			
			this.visible = false;
			mText = new TextField();
			mText.width = 800;
			mText.selectable = false;
			mText.defaultTextFormat = myformat;
			//mText.text = "FlashPreloadProfiler BETA";
			mText.filters = [ myglow ];
			mText.x = 2
			//mText.y = 1;
			addChild( mText );
			mInstance = this;
			
		}

		public static function set Visible(isVisible:Boolean) : void
		{
			mInstance.visible = isVisible;
		}
		public static function SetToolTip(text:String, aX:int, aY:int) : void
		{
			mInstance.SetToolTipText(text);
			mInstance.x = aX;
			mInstance.y = aY;
		}

		public static function set Text(aText:String) : void
		{
			mInstance.SetToolTipText(aText);
		}		
		
		public static function SetPosition(aX:int, aY:int) : void
		{
			mInstance.x = aX;
			mInstance.y = aY;
		}		
		
		public function SetToolTipText(text:String) : void
		{
			mText.text = text;
			
			this.graphics.clear();
			this.graphics.beginFill(0x888888,0.5);
			this.graphics.drawRect(0, 0, mText.textWidth + 7, mText.textHeight + 4);
			this.graphics.endFill();
			
			this.graphics.beginFill(0x000000,0.5);
			this.graphics.drawRect(1, 1, mText.textWidth + 5, mText.textHeight + 2);
			this.graphics.endFill();			
		}
		
	}

}