package net.jpauclair.data
{
	import flash.sampler.StackFrame;
	/**
	 * ...
	 * @author 
	 */
	public class InternalEventEntry
	{
		public var qName:String = null;
		public var mStack:String = null;
		public var mStackFrame:Array = null;
		public var entryCount:int;
		public var entryCountTotal:int;
		public var entryTime:int;
		public var entryTimeTotal:int;
		
		public function InternalEventEntry() 
		{
		}
		
		public function SetStack(aStack:Array) : void
		{
			mStackFrame = aStack;
			mStack = "";
			for (var i:int = aStack.length-1; i >=0 ; i--)
			{
				
				mStack += "-" + aStack[i].name
				
				if (i > 0)
				{
					mStack += "\n";
					for (var j:int = aStack.length-1; j >= i; j--)
					{
						mStack += "\t";
					}
					
				}
			}
			
		}
		
		public function Add(time:Number) : void
		{
			entryCount++;
			entryCountTotal++;
			entryTime+= time;
			entryTimeTotal += time;		
		}
		public function AddParentTime(time:Number) : void
		{
			entryTimeTotal += time;		
		}
		
		
		
		public function Reset() : void
		{
			entryTime = 0;
			entryCount = 0;
		}
		public function Clear() : void
		{
			entryCount = 0;
			entryCountTotal = 0;
			entryTime = 0;
			entryTimeTotal = 0;
		}
	}

}