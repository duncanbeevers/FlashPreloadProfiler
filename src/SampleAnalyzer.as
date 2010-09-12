package  
{
	import flash.net.LocalConnection;
	import flash.sampler.clearSamples;
	import flash.sampler.DeleteObjectSample;
	import flash.sampler.getSamples;
	import flash.sampler.NewObjectSample;
	import flash.sampler.pauseSampling;
	import flash.sampler.Sample;
	import flash.sampler.startSampling;
	import flash.sampler.stopSampling;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author 
	 */
	public class SampleAnalyzer
	{
		private static const INTERNAL_EVENT_VERIFY:String = "[verify]()";
		private static const INTERNAL_EVENT_MARK:String = "[mark]()";
		private static const INTERNAL_EVENT_REAP:String = "[reap]()";
		private static const INTERNAL_EVENT_SWEEP:String = "[sweep]()";

		private static const INTERNAL_EVENT_ENTERFRAME:String = "[enterFrameEvent]()";
		private static const INTERNAL_EVENT_TIMER_TICK:String = "flash.utils::Timer/tick()"
		private static const INTERNAL_EVENT_PRE_RENDER:String = "[pre-render]()";
		private static const INTERNAL_EVENT_RENDER:String = "[render]()";
		
		private static const INTERNAL_EVENT_AVM1:String = "[avm1]()";
		private static const INTERNAL_EVENT_MOUSE:String = "[mouseEvent]()"
		private static const INTERNAL_EVENT_IO:String = "[io]()";
		private static const INTERNAL_EVENT_EXECUTE_QUEUE:String = "[execute-queued]()";
				
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

		private var mStatsTypeList:Array = null;
		private var lastSampleTime:Number = 0;
		
		private var mIsSampling:Boolean = false;
		private var mIsSamplingPaused:Boolean = false;
		
		private static var mInstance:SampleAnalyzer = null;
		
		private var mEnableObjectStats:Boolean = true;
		private var mEnableInternalEventStats:Boolean = true;
		//private var mInstance
		
		public function SampleAnalyzer() 
		{
			mFullObjectDict = new Dictionary();
			mObjectTypeDict = new Dictionary();
			mInternalPlayerActionDict = new Dictionary();

			mStatsTypeList = new Array();
			lastSampleTime = 0;			
			mInstance = this;
			tempArray = new Array();
		}
		
		public static function GetInstance() : SampleAnalyzer
		{
			if (mInstance == null)
			{
				mInstance = new SampleAnalyzer();
			}
			return mInstance;
		}
		
		public function set ObjectStatsEnabled(enable:Boolean) : void
		{
			mEnableObjectStats = enable;
		}
		
		public function set InternalEventStatsEnabled(enable:Boolean) : void
		{
			mEnableInternalEventStats = enable;
		}		
		
		public function StartSampling() : void
		{
			mIsSampling = true;
			mIsSamplingPaused = false;
			startSampling();
		}
		
		public function PauseSampling() : void
		{
			if (mIsSampling && !mIsSamplingPaused)
			{
				pauseSampling();
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
		
		public function GetClassInstanciationStats():Array
		{
			return mStatsTypeList;
		}		
		
		public function GetFrameDataArray() : Array
		{
			return tempArray;
		}
		
		public function ResetStats() : void
		{
			for each (var stat:ClassTypeStatsHolder in mStatsTypeList)
			{
				stat.Added = 0;
				stat.Removed = 0;
				stat.Current = 0;
				stat.Cumul = 0;
			}
		}
		private var tempArray:Array = null;
		private var mIsRecording:Boolean = false;
		public function ProcessSampling():void
		{
			//var f:LastObject = new LastObject();
			
			pauseSampling();
			
			var o:* = getSamples();
			
			var newSample:NewObjectSample;
			var deleteSample:DeleteObjectSample;
			var basicSample:Sample;
			var holder:ClassTypeStatsHolder = null;
			
			var lastO:uint = 0;
			var firstO:uint = 0;
			var selfTime:uint = 0;
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
			for each (var s:Sample in o) 
			{
				if ((newSample = s as NewObjectSample) != null)
				{
					if (Options.mIsCollectingData)
					{
						if (s.stack != null)
						{
							tempArray.push(s.time, "NewObject-"+newSample.id + "\tType: " + newSample.type+ "\t" + s.stack);
						}
					}						
					if (!mEnableObjectStats) continue;
					
					holder = mObjectTypeDict[newSample.type] as ClassTypeStatsHolder;
					if (newSample.type == FirstObject)
					{
						firstO = newSample.time;
					}
					else if (newSample.type == LastObject)
					{
						lastO = newSample.time;
						selfTime = lastO - firstO;
					}
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
					//trace(newSample.time, newSample.stack);
				}
				else if ((deleteSample = s as DeleteObjectSample)!=null)
				{
					if (Options.mIsCollectingData)
					{
						tempArray.push(s.time, "DeletedObject-"+deleteSample.id);
					}						
					if (!mEnableObjectStats) continue;
					if (mFullObjectDict[deleteSample.id] != undefined)
					{
						holder = mFullObjectDict[deleteSample.id];
						
						holder.Removed++;
						holder.Current--;
						delete mFullObjectDict[deleteSample.id];
					}
				}
				else
				{
					if (Options.mIsCollectingData)
					{
						if (s.stack != null)
						{
							tempArray.push(s.time, "OtherSample\t" + s.stack);
						}
					}						
					if (!mEnableInternalEventStats) continue;
					basicSample = s;
					if (lastSampleTime == 0)
					{
						lastSampleTime = basicSample.time;
					}	
					var sf:String = basicSample.stack[basicSample.stack.length-1];
					
					var timeDiff:Number = basicSample.time - lastSampleTime;
					lastSampleTime =  basicSample.time;
					
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

					lastSampleTime = s.time;
				}
			
			}

			if (mInternalStats.mSweep.entryTime > 0)
			{
				Console.TraceSweep(mInternalStats.mSweep.entryTime);
			}
			//mInternalStats.ResetFrame();
			
			
			if ((!mIsSamplingPaused && mIsSampling) || mInternalStats.FrameTime == 0)
			{
				clearSamples();
				startSampling();
			}
			
			
			var f2:FirstObject = new FirstObject();
		}
		
	}

}

internal class FirstObject
{
	
}
internal class LastObject
{
	
}