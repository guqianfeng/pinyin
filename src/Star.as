package src{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Star extends MovieClip {
		public function Star(id:int):void {
			this.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOutHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			this.name = "score" + id;
		}
		private function onMouseRollOverHandler(event:MouseEvent):void {
			this.dispatchEvent(new Event("STAR_ROLLOVER"));
		}
		private function onMouseUpHandler(event:MouseEvent):void {
			this.dispatchEvent(new Event("STAR_MOUSEUP"));
		}
		private function onMouseRollOutHandler(event:MouseEvent):void {
			this.dispatchEvent(new Event("STAR_ROLLOUT"));
		}
	}
}