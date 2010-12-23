package net.jpauclair
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author jpauclair
	 */
	public class Layers extends Sprite
	{
		private var mStatistics:Sprite = null;
		private var mOptions:Sprite = null;
		private var mInstancesLifeCycleLayer:Sprite = null;
		private var mOverDraw:Sprite = null;
		private var mMouseTarget:Sprite = null;
		private var mLogo:Sprite = null;
		
		
		public function Layers() 
		{
			Init();
		}
		
		final private function Init() : void
		{
			this.mouseEnabled = false;
			
			mStatistics = new Sprite();
			mOptions = new Sprite();
			mInstancesLifeCycleLayer = new Sprite();
			mOverDraw = new Sprite();
			mMouseTarget = new Sprite();
			mLogo = new Sprite();

			mStatistics.mouseEnabled = false;
			mOptions.mouseEnabled  = false;
			mInstancesLifeCycleLayer.mouseEnabled  = false;
			mOverDraw.mouseEnabled  = false;
			mMouseTarget.mouseEnabled  = false;
			mLogo.mouseEnabled  = false;
			
			this.addChild(mInstancesLifeCycleLayer);
			this.addChild(mOverDraw);
			this.addChild(mMouseTarget);	
			this.addChild(mStatistics);
			this.addChild(mOptions);
			this.addChild(mLogo);
		}
		
		
		final public function get StatisticsLayer() : FlashStats
		{
			if (mStatistics== null || mStatistics.numChildren == 0) return null;
			
			return mStatistics.getChildAt(0) as FlashStats;
		}
		final public function set StatisticsLayer(stats:FlashStats) : void
		{
			ResetLayer(mStatistics, stats);
		}
		
		//Overdraw Layer
		final public function get OverdrawLayer() : Overdraw
		{
			if (mOverDraw == null || mOverDraw.numChildren == 0) return null;
			
			return mOverDraw.getChildAt(0) as Overdraw;
		}				
		final public function set OverdrawLayer(overdraw:Overdraw) : void
		{
			ResetLayer(mOverDraw, overdraw);
		}		

		//Instance Life Layer
		final public function get InstancesLifeCycleLayer() : InstancesLifeCycle
		{
			if (mInstancesLifeCycleLayer == null || mInstancesLifeCycleLayer.numChildren == 0) return null;
			
			return mInstancesLifeCycleLayer.getChildAt(0) as InstancesLifeCycle;
		}
		final public function set InstancesLifeCycleLayer(instance:InstancesLifeCycle) : void
		{
			ResetLayer(mInstancesLifeCycleLayer, instance);
		}		
		
		//Mouse Listeners Layer
		final public function get MouseListenerLayer() : MouseListeners
		{
			if (mMouseTarget == null || mMouseTarget.numChildren == 0) return null;
			
			return mMouseTarget.getChildAt(0) as MouseListeners;
		}				
		final public function set MouseListenerLayer(mouseListener:MouseListeners) : void
		{
			ResetLayer(mMouseTarget, mouseListener);
		}		
		
		//Options Layer
		final public function get OptionsLayer() : Options
		{
			if (mOptions == null || mOptions.numChildren == 0) return null;
			
			return mOptions.getChildAt(0) as Options;
		}				
		final public function set OptionsLayer(options:Options) : void
		{
			ResetLayer(mOptions, options);
		}				

		//Logo Layer
		final public function get LogoLayer() : Bitmap
		{
			if (mLogo == null || mLogo.numChildren == 0) return null;
			
			return mLogo.getChildAt(0) as Bitmap;
		}				
		final public function set LogoLayer(logo:Bitmap) : void
		{
			ResetLayer(mLogo, logo);
		}
		
		final private function ResetLayer(layer:Sprite, data:DisplayObject) : void
		{
			while (layer.numChildren > 0)
			{
				layer.removeChildAt(0);
			}
			if (data != null)
			{
				layer.addChild(data);			
			}
		}		
	}

}