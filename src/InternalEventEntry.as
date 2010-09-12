package  
{
	/**
	 * ...
	 * @author 
	 */
	public class InternalEventEntry
	{
		public var entryCount:int;
		public var entryCountTotal:int;
		public var entryTime:int;
		public var entryTimeTotal:int;
		
		public function InternalEventEntry() 
		{
			
		}
		
		public function Add(time:Number) : void
		{
			entryCount++;
			entryCountTotal++;
			entryTime+= time;
			entryTimeTotal += time;		
		}
		
		public function Reset() : void
		{
			entryTime = 0;
			entryCount = 0;
		}
		
		
	}

}