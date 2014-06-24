package dae
{
	public class DAEAnimation extends DAEElement
	{
		public var samplers:Vector.<DAESampler>;
		public var channels:Vector.<DAEChannel>;
		public var sources:Object;
		
		public function DAEAnimation(element:XML = null)
		{
			super(element);
		}
		
		public override function deserialize(element:XML):void
		{
			super.deserialize(element);
			this.samplers = new Vector.<DAESampler>();
			this.channels = new Vector.<DAEChannel>();
			this.sources = {};
			traverseChildren(element);
			setupChannels(this.sources);
		}
		
		protected override function traverseChildHandler(child:XML, nodeName:String):void
		{
			switch (nodeName) {
				case "source":
					var source:DAESource = new DAESource(child);
					this.sources[source.id] = source;
					break;
				case "sampler":
					this.samplers.push(new DAESampler(child));
					break;
				case "channel":
					this.channels.push(new DAEChannel(child));
			}
		}
		
		private function setupChannels(sources:Object):void
		{
			for each (var channel:DAEChannel in this.channels) {
				for each (var sampler:DAESampler in this.samplers) {
					if (channel.source == sampler.id) {
						sampler.create(sources);
						channel.sampler = sampler;
						break;
					}
				}
			}
		}
	}
}