package net.jpauclair.data
{
	/**
	 * ...
	 * @author 
	 */
	public class InternalEventsStatsHolder
	{
		public var mVerify:InternalEventEntry = new InternalEventEntry();
		public var mReap:InternalEventEntry = new InternalEventEntry();
		public var mMark:InternalEventEntry = new InternalEventEntry();
		public var mSweep:InternalEventEntry = new InternalEventEntry();
		
		public var mEnterFrame:InternalEventEntry = new InternalEventEntry();
		public var mTimers:InternalEventEntry = new InternalEventEntry();
		public var mPreRender:InternalEventEntry = new InternalEventEntry();
		public var mRender:InternalEventEntry = new InternalEventEntry();
		
		public var mAvm1:InternalEventEntry = new InternalEventEntry();
		public var mMouse:InternalEventEntry = new InternalEventEntry();
		public var mIo:InternalEventEntry = new InternalEventEntry();
		public var mExecuteQueue:InternalEventEntry = new InternalEventEntry();
		
		public var mFree:InternalEventEntry = new InternalEventEntry();
		
		
		public function get FrameTime():Number
		{
			var time:Number = mReap.entryTime 
								+ mEnterFrame.entryTime 
								+ mMark.entryTime
								+ mPreRender.entryTime
								+ mRender.entryTime
								+ mVerify.entryTime
								+ mTimers.entryTime
								+ mFree.entryTime;
			return time;
			
		}
		
		public function TraceFrame() : void
		{
			var out:String = new String();
			//out += "reap" + reapCount.toString() + ":" + reapTime.toString() +", ";
			//out += "enterFrameEvent" + enterFrameEventCount.toString() + ":" + enterFrameEventTime.toString() +", ";
			//out += "mark" + markCount.toString() + ":" + markTime.toString() +", ";
			//out += "sweep" + sweepCount.toString() + ":" + sweepTime.toString() +", ";
			//out += "preRender" + preRenderCount.toString() + ":" + preRenderTime.toString() +", ";
			//out += "render" + renderCount.toString() + ":" + renderTime.toString() +", ";
			//out += "verify" + verifyCount.toString() + ":" + verifyTime.toString() +", ";
			//out += "timers" + timersCount.toString() + ":" + timersTime.toString();
			//trace(out);
		}
		
		public function ResetFrame() : void
		{
			mVerify.Reset();
			mReap.Reset();
			mMark.Reset();
			mSweep.Reset();
			
			mEnterFrame.Reset();
			mTimers.Reset();
			mPreRender.Reset();
			mRender.Reset();
			
			mAvm1.Reset();
			mMouse.Reset();
			mIo.Reset();
			mExecuteQueue.Reset();
			mFree.Reset();
		}
	}
}