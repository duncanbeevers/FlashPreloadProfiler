package net.jpauclair
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.net.LocalConnection;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.sampler.clearSamples;
	import flash.sampler.DeleteObjectSample;
	import flash.sampler.getSamples;
	import flash.sampler.NewObjectSample;
	import flash.sampler.pauseSampling;
	import flash.sampler.Sample;
	import flash.sampler.setSamplerCallback;
	import flash.sampler.startSampling;
	import flash.sampler.stopSampling;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import net.jpauclair.data.ClassTypeStatsHolder;
	import net.jpauclair.data.InternalEventEntry;
	import net.jpauclair.data.InternalEventsStatsHolder;
	import net.jpauclair.window.Configuration;
	import net.jpauclair.window.Console;
	import net.jpauclair.window.FlashStats;
	/**
	 * ...
	 * @author 
	 */
	public class SampleAnalyzer
	{
		private static const INTERNAL_EVENT_VERIFY:String = "[verify]";
		private static const INTERNAL_EVENT_MARK:String = "[mark]";
		private static const INTERNAL_EVENT_REAP:String = "[reap]";
		private static const INTERNAL_EVENT_SWEEP:String = "[sweep]";

		private static const INTERNAL_EVENT_ENTERFRAME:String = "[enterFrameEvent]";
		private static const INTERNAL_EVENT_TIMER_TICK:String = "flash.utils::Timer/tick"
		private static const INTERNAL_EVENT_PRE_RENDER:String = "[pre-render]";
		private static const INTERNAL_EVENT_RENDER:String = "[render]";
		
		private static const INTERNAL_EVENT_AVM1:String = "[avm1]";
		private static const INTERNAL_EVENT_MOUSE:String = "[mouseEvent]"
		private static const INTERNAL_EVENT_IO:String = "[io]";
		private static const INTERNAL_EVENT_EXECUTE_QUEUE:String = "[execute-queued]";
				
															// [avm1]()
															// [abc-decode]() 561226135231 global$init(),[abc-decode]()
															// [mouseEvent]()
															// [execute-queued]()
															// [enter-frame]()
															// [io]() 561226308233 [io]()
															// [openEvent]() 561230207465 [verify]()
															// [swf]() 561230432373 [swf]()
															// [activation-object]()

		private var mInternalStats:InternalEventsStatsHolder = new InternalEventsStatsHolder();

		private var mFullObjectDict:Dictionary = null;
		private var mObjectTypeDict:Dictionary = null;
		private var mInternalPlayerActionDict:Dictionary = null;
		
		private var mFunctionTimes:Dictionary = null;
		private var mFunctionTimesArray:Array = null;

		private var mStatsTypeList:Array = null;
		private var lastSampleTime:Number = 0;
		private var lastSample:Sample = null;
		
		private var mIsSampling:Boolean = false;
		private var mIsSamplingPaused:Boolean = false;
		
		private static var mInstance:SampleAnalyzer = null;
		
		//private var mInstance
		
		public function SampleAnalyzer() 
		{
			mFullObjectDict = new Dictionary();
			mObjectTypeDict = new Dictionary();
			mInternalPlayerActionDict = new Dictionary();
			mFunctionTimes = new Dictionary();
			mFunctionTimesArray = new Array();

			mStatsTypeList = new Array();
			lastSampleTime = 0;			
			mInstance = this;
			tempArray = new Array();
			setSamplerCallback(SamplerCallBack);
		}
		
		public static function GetInstance() : SampleAnalyzer
		{
			if (mInstance == null)
			{
				mInstance = new SampleAnalyzer();
			}
			return mInstance;
		}
		
		public function StartSampling() : void
		{
			mIsSampling = true;
			mIsSamplingPaused = false;
			//trace("Start sampling");
			startSampling();
		}
		
		public function PauseSampling() : void
		{
			if (mIsSampling && !mIsSamplingPaused)
			{
				
				pauseSampling();
				//trace("pausing sampling");
				mIsSamplingPaused = true;
			}
		}
		
		public function IsSamplingPaused() : Boolean
		{
			return mIsSamplingPaused;
		}
		
		public function ResumeSampling() : void
		{
			if (mIsSampling && mIsSamplingPaused)
			{
				//trace("Resume sampling");
				startSampling();
				mIsSamplingPaused = false;
			}
		}
		
		public function StopSampling() : void
		{
			mIsSampling = false;
			mIsSamplingPaused = false;
			stopSampling();
		}
		
		public function ClearSamples() : void
		{
			clearSamples();
		}
		
		public function ForceGC() : void
		{
			try {
				new LocalConnection().connect('Force GC!');
				new LocalConnection().connect('Force GC!');
			} catch (e:Error) { }			
		}
		
		public function GetInternalsEvents():InternalEventsStatsHolder
		{
			return mInternalStats;
		}
		
		public function GetFunctionTimes():Array
		{
			return mFunctionTimesArray;
		}
		
		public function GetClassInstanciationStats():Array
		{
			return mStatsTypeList;
		}		
		
		public function GetFrameDataArray() : Array
		{
			return tempArray;
		}
		
		public function ResetMemoryStats() : void
		{
			for each (var stat:ClassTypeStatsHolder in mStatsTypeList)
			{
				stat.Added = 0;
				stat.Removed = 0;
				stat.Current = 0;
				stat.Cumul = 0;
			}
		}
		
		public function ResetPerformanceStats() : void
		{
			for each (var stat:InternalEventEntry in mFunctionTimes)
			{
				stat.Clear();
			}
		}

		private function SamplerCallBack(e:*= null) : void
		{
			pauseSampling();
			ProcessSampling();
			startSampling();
		}
		
		private var tempArray:Array = null;
		private var mIsRecording:Boolean = false;
		private var ms_prev:int=0;
		//private var mLastURLRequest:URLRequest = null;
		public function ProcessSampling():void
		{
			pauseSampling();
			
			
			if (Configuration.PROFILE_MEMGRAPH)
			{
				var timer:int = getTimer();

				if ( timer >= ms_prev+300 ) 
				{ 
					FlashStats.mSamplingStartIdx--;
					if (FlashStats.mSamplingStartIdx < 0) FlashStats.mSamplingStartIdx = FlashStats.mSamplingCount - 1;
					
					ms_prev = timer;
					
					FlashStats.mMemoryValues[FlashStats.mSamplingStartIdx % FlashStats.mSamplingCount] = System.totalMemory / 1024;
					if (System.totalMemory / 1024 > FlashStats.stats.MemoryMax)
					{
						FlashStats.stats.MemoryMax = System.totalMemory / 1024;;
					}
					FlashStats.mMemoryMaxValues[FlashStats.mSamplingStartIdx % FlashStats.mSamplingCount] = FlashStats.stats.MemoryMax;
				}
			}
			
			
			var o:* = getSamples();
			
			var newSample:NewObjectSample;
			var deleteSample:DeleteObjectSample;
			var holder:ClassTypeStatsHolder = null;
			
			if (Options.mIsCollectingData)
			{
				if (!mIsRecording)
				{
					tempArray.splice();
					mIsRecording = true;
				}
			}
			else
			{
				mIsRecording = false;
			}
			
			var sampleStack:Array = null;
			for each (var s:Sample in o) 
			{
				if (lastSampleTime == 0) lastSampleTime = s.time;
				var timeDiff:Number = s.time - lastSampleTime;
				lastSampleTime = s.time;
				newSample = s as NewObjectSample
				sampleStack = s.stack;
				if (newSample != null)
				{
					var obj:* = newSample.object;
					if (Options.mIsCollectingData)
					{
						if (sampleStack != null)
						{
							tempArray.push(s.time, "NewObject\t"+newSample.id + "\t" + newSample.type+ "\t" + sampleStack);
						}
					}		
					
					if (obj is Event && sampleStack != null && sampleStack.length == 1)
					{
						if (sampleStack[0].name == INTERNAL_EVENT_ENTERFRAME)
						{
							mInternalStats.mFree.Add(timeDiff);
						}
					}
					
					//if (obj is URLRequest) mLastURLRequest = obj;
					if (Configuration.PROFILE_LOADERS)
					{
						
						if (obj is Loader) LoaderAnalyser.GetInstance().PushLoader(obj);
						else if (obj is URLStream) LoaderAnalyser.GetInstance().PushLoader(obj);
						else if (obj is URLLoader) LoaderAnalyser.GetInstance().PushLoader(obj);
					}
					
					if (Configuration.PROFILE_MEMORY)
					{
						holder = mObjectTypeDict[newSample.type] as ClassTypeStatsHolder;
						if (holder == null)
						{
							
							holder = new ClassTypeStatsHolder()
							holder.Type = newSample.type;
							holder.TypeName = getQualifiedClassName(newSample.type);
							mStatsTypeList.push(holder);

							mObjectTypeDict[newSample.type] = holder;
							mFullObjectDict[newSample.id] = holder;
						}
						else
						{
							holder.Added++;
							holder.Cumul++;
							holder.Current++;
							mFullObjectDict[newSample.id] = holder;
						}
					}
				}
				else if ((deleteSample = s as DeleteObjectSample)!=null)
				{
					if (Options.mIsCollectingData)
					{
						tempArray.push(s.time, "DeletedObject\t"+deleteSample.id);
					}		
					
					//if (!mEnableObjectStats) { continue; }

					if (Configuration.PROFILE_MEMORY)
					{
						if (mFullObjectDict[deleteSample.id] != undefined)
						{
							holder = mFullObjectDict[deleteSample.id];
							
							holder.Removed++;
							holder.Current--;
							if (holder.Current > int.MAX_VALUE / 2) holder.Current = 0;
							delete mFullObjectDict[deleteSample.id];
						}
					}
				}
				else
				{
					if (Options.mIsCollectingData)
					{
						if (sampleStack != null)
						{
							tempArray.push(s.time, "BaseSample\t" + sampleStack);
						}
					}	

					var sf:String = null;
					if (Configuration.PROFILE_FUNCTION)
					{
						
						var stackLen:int = sampleStack.length;
						sf = sampleStack[stackLen-1].name;
						
						
						for (var currentStackDepth:int = 0; currentStackDepth < stackLen; currentStackDepth++)
						{
							var functionName:String = sampleStack[currentStackDepth].name;
							var stat:* = mFunctionTimes[functionName];
							
							
							if (stat == undefined) {
								stat = new InternalEventEntry();
								stat.SetStack(sampleStack);
								stat.qName = functionName;// + vStack;
								mFunctionTimesArray.push(stat);
								mFunctionTimes[functionName] = stat;
							}
							var statEntry:InternalEventEntry = stat;

							if (currentStackDepth == 0)
							{
								statEntry.Add(timeDiff);
							}
							else
							{
								statEntry.AddParentTime(timeDiff);
							}
						}
					}
					
					if (Configuration.PROFILE_INTERNAL_EVENTS)
					{
						if (sf == null)
						{
							sf = sampleStack[sampleStack.length-1].name;
						}
						switch(sf)
						{
							case INTERNAL_EVENT_ENTERFRAME:
								
								mInternalStats.mEnterFrame.Add(timeDiff);
								break;
							case INTERNAL_EVENT_MARK:
								mInternalStats.mMark.Add(timeDiff);
								break;
							case INTERNAL_EVENT_REAP:
								mInternalStats.mReap.Add(timeDiff);
								break;
							case INTERNAL_EVENT_SWEEP:
								mInternalStats.mSweep.Add(timeDiff);
								break;
							case INTERNAL_EVENT_PRE_RENDER:
								mInternalStats.mPreRender.Add(timeDiff);
								break;
							case INTERNAL_EVENT_RENDER:
								mInternalStats.mRender.Add(timeDiff);
								break;
							case INTERNAL_EVENT_VERIFY:
								mInternalStats.mVerify.Add(timeDiff);
								break;
							case INTERNAL_EVENT_TIMER_TICK:
								mInternalStats.mTimers.Add(timeDiff);
								break;								
							case INTERNAL_EVENT_AVM1:
								mInternalStats.mAvm1.Add(timeDiff);
								break;						
							case INTERNAL_EVENT_MOUSE:
								mInternalStats.mMouse.Add(timeDiff);
								break;						
							case INTERNAL_EVENT_IO:
								mInternalStats.mIo.Add(timeDiff);
								break;						
							case INTERNAL_EVENT_EXECUTE_QUEUE:
								mInternalStats.mExecuteQueue.Add(timeDiff);
								break;													
								
							default:
								
								//trace(sf, s.time,s.stack);// , sf.scriptID);	
								break;
						}
					}
				}
			}
			lastSample = s;

			//if (mInternalStats.mSweep.entryTime > 0)
			//{
				//Console.TraceSweep(mInternalStats.mSweep.entryTime);
			//}
			clearSamples();
			
		}
		
	}

}

