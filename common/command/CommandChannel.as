package common.command
{
	import flash.utils.Dictionary;

	public class CommandChannel
	{
		static private var _instance :CommandChannel = null;
		private var _channel :Dictionary = new Dictionary();
		
		public function CommandChannel()
		{
		}

		public static function get instance():CommandChannel
		{
			if (!_instance)
				_instance = new CommandChannel();
			
			return _instance;
		}
		
		public function bindHandler(command:int, handler:Function):void
		{
			var handlers :Vector.<Function> = _channel[command];
			
			if (!handlers)
			{
				handlers = new Vector.<Function>();
				_channel[command] = handlers;
			}

			if (handlers.indexOf(handler) < 0)
				handlers.push(handler);
		}
		
		public function postCommand(command:int, ...args):void
		{
			var handlers :Vector.<Function> = _channel[command];
			
			if (handlers)
			{
				var len :uint = args.length;
				var handler :Function;
				if (len == 0)
					for each (handler in handlers) handler();
				else if (len == 1)
					for each (handler in handlers) handler(args[0]);
				else if (len == 2)
					for each (handler in handlers) handler(args[0], args[1]);
				else if (len == 3)
					for each (handler in handlers) handler(args[0], args[1], args[2]);
				else if (len == 4)
					for each (handler in handlers) handler(args[0], args[1], args[2], args[3]);
				else if (len == 5)
					for each (handler in handlers) handler(args[0], args[1], args[2], args[3], args[4]);
				else if (len == 6)
					for each (handler in handlers) handler(args[0], args[1], args[2], args[3], args[4], args[5]);
				else if (len == 7)
					for each (handler in handlers) handler(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
				else
					for each (handler in handlers) handler(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
			}
		}

	}
}