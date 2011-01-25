package net.jpauclair.ui.button 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import net.jpauclair.data.InternalEventEntry;
	import net.jpauclair.data.LoaderData;
	import net.jpauclair.event.ChangeToolEvent;
	import net.jpauclair.FlashPreloadProfiler;
	import net.jpauclair.Options;
	import net.jpauclair.ui.ToolTip;
	import net.jpauclair.window.PerformanceProfiler;
	/**
	 * ...
	 * @author jpauclair
	 */
	
	public class MenuButton extends Sprite
	{
		private var mIconOver:Bitmap;
		private var mIconSelected:Bitmap;
		private var mIconOut:Bitmap;
		private var mToolTipText:String;
		private var mToggleText:String;
		private var mToggleEventName:String;
		public var mIsSelected:Boolean = false;
		public var mTool:Class = null;
		private var mIsToggle:Boolean = true;
		public var mInternalEvent:InternalEventEntry = null;
		public var mUrl:String = null;
		public var mLD:LoaderData = null;
		
		public function MenuButton(posX:int, posY:int, iconOut:Class, iconSelected:Class, iconOver:Class, toggleEventName:String, aTool:Class, tooltipText:String, aIsToggle:Boolean = true , aToggleText:String=null) 
		{
			mIconOut = new iconOut() as Bitmap
			mIconSelected = new iconSelected() as Bitmap
			mIconSelected.visible = false;
			mToggleText = aToggleText;
			mIsToggle = aIsToggle
			mTool = aTool;
			
			this.mouseChildren = false;
			addChild(mIconOut);
			addChild(mIconSelected);
			
			mToggleEventName = toggleEventName;
			mToolTipText = tooltipText
			x = posX; y = posY;
			
			addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OVER, OnMouseOver, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, OnMouseOut, false, 0, true);
			addEventListener(MouseEvent.CLICK, OnClick, false, 0, true);			
		}
		
		private function OnMouseMove(e:MouseEvent):void 
		{
			ToolTip.SetPosition(e.stageX + 12, e.stageY + 6);
			e.stopPropagation();
			e.stopImmediatePropagation();
		}
		
		public function OnClick(e:MouseEvent) : void
		{
			if (e != null)
			{
				e.stopPropagation();
				e.stopImmediatePropagation();
			}
			mIconSelected.visible = true;
			if (mIsSelected)
			{
				mIsSelected = false;
				if (mToggleText != null)
				{
					SetToolTipText(mToolTipText);
				}
				
				if (mToggleEventName == Options.SAVE_RECORDING_EVENT)
				{
					var e2:Event = new Event(Options.SAVE_RECORDING_EVENT,true);
					dispatchEvent(e2);
				}				
				return;
			}
			
			if (mIsToggle)
			{
				mIsSelected = true;	
				if (mIsSelected && mToggleText != null)
				{
					ToolTip.Text = mToggleText;
				}
				
			}
			
			if (mToggleEventName != null)
			{
				if (mToggleEventName == ChangeToolEvent.CHANGE_TOOL_EVENT)
				{
					FlashPreloadProfiler.StaticChangeTool(this);
					//var cte:ChangeToolEvent = new ChangeToolEvent(mTool);
					//dispatchEvent(cte);
				}
				else if (mToggleEventName == Options.SAVE_RECORDING_EVENT)
				{
					
				}
				else if (mToggleEventName == Options.SAVE_SNAPSHOT_EVENT)
				{
					var e3:Event = new Event(Options.SAVE_SNAPSHOT_EVENT,true);
					dispatchEvent(e3);
				}
				else if (mToggleEventName == PerformanceProfiler.SAVE_FUNCTION_STACK_EVENT)
				{
					var e4:Event = new Event(PerformanceProfiler.SAVE_FUNCTION_STACK_EVENT,true);
					dispatchEvent(e4);
				}
				else {
					FlashPreloadProfiler.StaticChangeTool(null);
				}
			}
		}
		
		public function OnMouseOver(e:MouseEvent) : void
		{
			e.stopPropagation();
			e.stopImmediatePropagation();
			mIconSelected.visible = true;
			if (mIsSelected && mToggleText != null)
			{
				ToolTip.Text = mToggleText;
			}
			else
			{
				ToolTip.Text = mToolTipText;	
			}
			ToolTip.Visible = true;
			
		}
		
		public function SetToolTipText(text:String) : void
		{
			mToolTipText = text;
			if (mIconSelected.visible)
			{
				ToolTip.Text = text;
			}
		}
		
		public function OnMouseOut(e:MouseEvent) : void
		{
			e.stopPropagation();
			e.stopImmediatePropagation();
			ToolTip.Visible = false;
			if (mIsSelected) return;
			if (mIconSelected != null)
			{
				mIconSelected.visible = false;
			}
		}	
		
		public function Reset() : void
		{
			mIsSelected = false;
			mIconSelected.visible = false;
		}
		public function Dispose() : void
		{
			if (mIconOver != null)
			{
				if (mIconOver.bitmapData != null) mIconOver.bitmapData.dispose();
				mIconOver = null;
			}
			if (mIconSelected != null)
			{
				if (mIconSelected.bitmapData != null) mIconSelected.bitmapData.dispose();
				mIconSelected = null;
			}	
			if (mIconOut != null)
			{
				if (mIconOut.bitmapData != null) mIconOut.bitmapData.dispose();
				mIconOut = null;
			}
			mToolTipText= null;
			mToggleEventName = null;
			
			mTool = null;

			mInternalEvent = null;
			
		}
	}

}