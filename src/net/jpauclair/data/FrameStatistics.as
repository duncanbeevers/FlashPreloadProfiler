package net.jpauclair.data 
{
	/**
	 * ...
	 * @author jpauclair
	 */
	public class FrameStatistics 
	{
		public var FpsCurrent:int = 0;
		public var FpsMin:int = int.MAX_VALUE;
		public var FpsMax:int = 0;
		
		public var MemoryCurrent:int = 0;
		public var MemoryMin:int = int.MAX_VALUE;
		public var MemoryMax:int = 0;
		
		public var MemoryFree:uint = 0;
		public var MemoryPrivate:uint = 0;
		
		public function Copy(obj:FrameStatistics) : void
		{
			FpsCurrent = obj.FpsCurrent;
			FpsMin = obj.FpsMin;
			FpsMax = obj.FpsMax;
			
			MemoryCurrent = obj.MemoryCurrent;
			MemoryMin = obj.MemoryMin;
			MemoryMax = obj.MemoryMax;
			
			MemoryFree = obj.MemoryFree;
			MemoryPrivate = obj.MemoryPrivate;
		}
			
		public function FrameStatistics() 
		{
			
		}
		
	}
}