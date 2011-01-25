package net.jpauclair 
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import net.jpauclair.data.LoaderData;
	/**
	 * ...
	 * @author jpauclair
	 */
	public class LoaderAnalyser 
	{
		private static var mInstance:LoaderAnalyser = null;
		private var mLoaderDict:Dictionary;
		private var mDisplayLoaderRef:Dictionary;
		private var mLoadersData:Array;
		
		public function LoaderAnalyser() 
		{
			mLoadersData = new Array();
			mLoaderDict = new Dictionary(true);
			mDisplayLoaderRef = new Dictionary(true);
		}
		
		public static function GetInstance() : LoaderAnalyser
		{
			if (mInstance == null)
			{
				mInstance = new LoaderAnalyser();
			}
			return mInstance;
		}
		
		public function Update() : void
		{
			for (var obj:* in mDisplayLoaderRef)
			{
				
				if (obj == null) continue;
				var li:LoaderInfo = obj.contentLoaderInfo;
				if (li == null) continue;
				var ld:LoaderData = mLoaderDict[li];
				if (ld == null)
				{
					//PushLoader(obj,null);
				}
			}
			
		}
		
		public function GetLoadersData() : Array
		{
			return mLoadersData;
		}
		
		public function PushLoader(aLoader:*) : void
		{
			//trace("Pushing a loader:", aLoader);
			if (aLoader == null) return;
			{
				var o:LoaderData;
				if (aLoader is Loader)
				{
					var l:Loader = aLoader;
					if (l.contentLoaderInfo == null) return;
					o = mLoaderDict[l.contentLoaderInfo];
					if (o != null) return;
			
					mDisplayLoaderRef[aLoader] = true;
					
					o = new LoaderData();
					
					if (l.contentLoaderInfo.url !=null)
						o.mUrl = l.contentLoaderInfo.url;
					mLoadersData.push(o);
					//mLoaderDict[l.contentLoaderInfo] = o;
					mLoaderDict[l.contentLoaderInfo] = o;
					
					o.mType = LoaderData.DISPLAY_LOADER;
					configureListeners(l.contentLoaderInfo);
					
				}
				else if (aLoader is URLStream)
				{
					o = mLoaderDict[aLoader];
					if (o != null) return;
					
					//trace("Pushing URLStream")
					var ls:URLStream = aLoader;
					o = new LoaderData();
					//o.mFirstEvent = getTimer();
					mLoaderDict[aLoader] = o;
					mLoadersData.push(o);
					o.mType = LoaderData.URL_STREAM;
					configureListeners(aLoader);
				}
				else if (aLoader is URLLoader) 
				{
					o = mLoaderDict[aLoader];
					if (o != null) return;
					
					var ll:URLLoader = aLoader;
					o = new LoaderData();
					//o.mFirstEvent = getTimer();
					mLoadersData.push(o);
					mLoaderDict[aLoader] = o;
					o.mType = LoaderData.URL_LOADER;
					configureListeners(aLoader);
				}
				
				
			}
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void 
		{
			//Shared events
			
			//trace("Setting Listeners on:", dispatcher);
			
			var useCapture:Boolean = false;
			var useWeak:Boolean = true;
			var prio:int = int.MAX_VALUE;
			
            dispatcher.addEventListener(Event.COMPLETE, completeHandler,useCapture,prio,useWeak);
            dispatcher.addEventListener(Event.OPEN, openHandler,useCapture,prio,useWeak);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler,useCapture,prio,useWeak);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler,useCapture,prio,useWeak);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler,useCapture,prio,useWeak);
			
			
			if (dispatcher is Loader)
			{
				dispatcher.addEventListener(Event.INIT, initHandler,useCapture,prio,useWeak);
				dispatcher.addEventListener(Event.UNLOAD, unLoadHandler,useCapture,prio,useWeak);
			}
			else if (dispatcher is URLLoader)
			{
				dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler,useCapture,prio,useWeak);
			}
			else if  (dispatcher is URLStream)
			{
				dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler,useCapture,prio,useWeak);
			}
        }

        private function completeHandler(event:Event):void 
		{
			var ld:LoaderData = mLoaderDict[event.target];
			if (ld != null)
			{
				if (ld.mFirstEvent == -1) ld.mFirstEvent = getTimer();
				if (ld.mIsFinished)
				{
					ld = PreventReUse(ld,event.target);
				}
				ld.mProgress = 1;
				ld.mProgressText = LoaderData.LOADER_STATUS_COMPLETED;
				ld.mIsFinished = true;
				if (ld.mUrl == null && ld.mType == LoaderData.DISPLAY_LOADER)
				{
					ld.mUrl = event.target.url;
				}
				else if (event.target is URLStream)
				{
					ld.mUrl = "No Url: URLStream"
				}
				if (event.target is URLLoader)
				{
					ld.mUrl = "No Url: URLLoader"
				}
			}

            //trace("completeHandler: " + event);
        }

		private function PreventReUse(ld:LoaderData, aLoader:Object) : LoaderData
		{
			var ld2:LoaderData = new LoaderData();
			ld2.mFirstEvent = getTimer();
			ld2.mType = ld.mType;
			mLoadersData.push(ld2);
			mLoaderDict[aLoader] = ld2;
			return ld2;
		}
        private function httpStatusHandler(event:HTTPStatusEvent):void 
		{
			var ld:LoaderData = mLoaderDict[event.target];
			if (ld != null)
			{
				if (ld.mFirstEvent == -1) ld.mFirstEvent = getTimer();
				ld.mHTTPStatusText = event.status.toString();
				ld.mStatus = event;
				//ld.mProgressText = "foo";
				if (ld.mUrl == null)
				{
					//ld.mUrl = event.responseURL;
				}
			}
			
            //trace("httpStatusHandler: " + event.target, event.currentTarget);
        }

        private function initHandler(event:Event):void 
		{
			var ld:LoaderData = mLoaderDict[event.target];
			if (ld != null)
			{
				if (ld.mFirstEvent == -1) ld.mFirstEvent = getTimer();
				//ld.mProgress = event.bytesLoaded/event.bytesTotal;
				ld.mProgressText = "Init";
				if (ld.mUrl == null && ld.mType == LoaderData.DISPLAY_LOADER)
				{
					
					ld.mUrl = event.target.url;
				}				
			}			
            //trace("initHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void 
		{
			var ld:LoaderData = mLoaderDict[event.target];
			if (ld != null)
			{
				if (ld.mFirstEvent == -1) ld.mFirstEvent = getTimer();
				ld.mIOError = event;
				ld.mProgressText = "IO Error";
				if (ld.mUrl == null)// && ld.mType == LoaderData.DISPLAY_LOADER)
				{
					var err:Array = event.text.split("URL: ");
					if (err.length > 1)
					{
						ld.mUrl = err[1];
					}
				}				
			}
            //trace("ioErrorHandler: " + event);
        }

        private function openHandler(event:Event):void 
		{
			var ld:LoaderData = mLoaderDict[event.target];
			if (ld != null)
			{
				if (ld.mFirstEvent == -1) ld.mFirstEvent = getTimer();
				//ld.mProgressText = "Open";
				if (ld.mUrl == null && ld.mType == LoaderData.DISPLAY_LOADER)
				{
					ld.mUrl = event.target.url;
				}
			}			
            //trace("openHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void 
		{
			var ld:LoaderData = mLoaderDict[event.target];
			//trace("Progress OUT", event.target);
			
			
			if (ld != null)
			{
				if (ld.mFirstEvent == -1) ld.mFirstEvent = getTimer();
				if (event.bytesTotal > 0)
				{
					var tmpProgress:Number = (int(event.bytesLoaded / event.bytesTotal * 10000) / 100);
					if (ld.mProgress > (event.bytesLoaded/event.bytesTotal))
					{
						ld = PreventReUse(ld,event.target);
					}
					ld.mLoadedBytes = int(event.bytesLoaded )
					ld.mLoadedBytesText = String(int(event.bytesLoaded ));
					ld.mProgress = event.bytesLoaded/event.bytesTotal;
					
					if (tmpProgress == 100)
					{
						ld.mProgressText = LoaderData.LOADER_STATUS_COMPLETED;
					}
					else
					{
						ld.mProgressText = tmpProgress.toString() + " %";
					}
				}
				else
				{
					if (ld.mProgress > event.bytesLoaded)
					{
						ld = PreventReUse(ld,event.target);
					}
					ld.mLoadedBytes = int(event.bytesLoaded)
					ld.mLoadedBytesText = String(event.bytesLoaded);
					ld.mProgress = event.bytesLoaded;
					ld.mProgressText = int(ld.mProgress).toString();
				}
				if (ld.mUrl == null && ld.mType == LoaderData.DISPLAY_LOADER)
				{
					ld.mUrl = event.target.url;
				}				
			}

			
            //trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
        }

        private function unLoadHandler(event:Event):void 
		{
			var ld:LoaderData = mLoaderDict[event.target];
			if (ld != null)
			{
				if (ld.mFirstEvent == -1) ld.mFirstEvent = getTimer();
				ld.mProgressText = "Unload";
				if (ld.mUrl == null && ld.mType == LoaderData.DISPLAY_LOADER)
				{
					ld.mUrl = event.target.url;
				}
			}			
            //trace("unLoadHandler: " + event);
        }

        private function clickHandler(event:MouseEvent):void 
		{
			var ld:LoaderData = mLoaderDict[event.target];
			if (ld != null)
			{
				if (ld.mFirstEvent == -1) ld.mFirstEvent = getTimer();
				ld.mProgressText = "mClick";
				if (ld.mUrl == null && ld.mType == LoaderData.DISPLAY_LOADER)
				{
					ld.mUrl = event.target.url;
				}
			}			
            //trace("clickHandler: " + event);
            var loader:Loader = Loader(event.target);
            loader.unload();
        }
		
		private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			var ld:LoaderData = mLoaderDict[event.target];
			if (ld != null)
			{
				if (ld.mFirstEvent == -1) ld.mFirstEvent = getTimer();
				ld.mSecurityError = event;
				ld.mProgressText = "Security Error";
				if (ld.mUrl == null && ld.mType == LoaderData.DISPLAY_LOADER)
				{
					ld.mUrl = event.target.url;
				}				
				
			}
            //trace("securityErrorHandler: " + event);
        }
	}

}