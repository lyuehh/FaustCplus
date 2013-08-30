package
{
	import flash.external.*;
	public class FileLog
	{
		public function FileLog()
		{
		}		
		public static function trace( log : * ):void{
			ExternalInterface.call( "console.log",log );
		}		
	}
}