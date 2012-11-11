package src{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import gs.TweenLite;
	import gs.easing.*;
	
	public class MovingControl extends Sprite {
		//用于控制在一个限定范围内mc的移动，缩放等
		private var _zoomStep:Number;
		private var _movingMc:Sprite;
		private var tweenlite:TweenLite;
		private var left:Number;
		private var right:Number;
		private var up:Number;
		private var down:Number;
		private var _time:Number;//每次移动时间，秒数
		
		public function MovingControl(movingMc:Sprite, leftUpCorner:Point, rightDownCorner:Point, time:Number = 0.3, zoomStep:Number = 1.1) {
			//stage-舞台，movingMc-需要移动的MC，leftUpCorner-左上角，rightDownCorner-右下角
			//speed-移动速度，建议100-300之间，数值越小，移动越慢，zoomStep-放大/缩小乘数
			_zoomStep = zoomStep;
			_movingMc = movingMc;
			left = leftUpCorner.x;
			up = leftUpCorner.y;
			right = rightDownCorner.x;
			down = rightDownCorner.y;
			_time = time;
			_movingMc.x = leftUpCorner.x;
			_movingMc.y = leftUpCorner.y;
		}
		public function pan(xOffset:Number, yOffset:Number):void{
			//PAN是MC跟随手势移动的处理
			var newX:Number = _movingMc.x + xOffset;
			var newY:Number = _movingMc.y + yOffset;
			if(newX <= left && newX + _movingMc.width >= right) _movingMc.x = newX;
			if(newY <= up && newY + _movingMc.height >= down) _movingMc.y = newY;
		}
		public function swipeLeft(distance:Number):void {
			var target:Number;
			if(_movingMc.x + _movingMc.width >= right + distance){
				//如果可以向左移动一个整的distance
				target = _movingMc.x - distance;				
			}else {
				target = -(_movingMc.width - right);
			}
			tweenlite = TweenLite.to(_movingMc, _time, { x: target, ease:Linear.easeNone } );
		}
		public function swipeRight(distance:Number):void {
			var target:Number;
			if(_movingMc.x <= left - distance){
				//如果可以向右移动一个整的distance
				target = _movingMc.x + distance;
			}else{
				target = left;
			}
			tweenlite = TweenLite.to(_movingMc, _time, { x:target, ease:Linear.easeNone } );				
		}
		public function swipeUp(distance:Number):void {
			//向上滑动
			var target:Number;
			if(_movingMc.y + _movingMc.height > down + distance){
				target = _movingMc.y - distance;
			}else {
				target = down - _movingMc.height;
			}
			tweenlite = TweenLite.to(_movingMc, _time, { y:target, ease:Linear.easeNone } );
		}
		public function swipeDown(distance:Number):void {
			var target:Number;// = up - _movingMc.y;
			if(_movingMc.y < up - distance){
				target = _movingMc.y + distance;
			}else{
				target = up;
			}
			tweenlite = TweenLite.to(_movingMc, _time, { y:target, ease:Linear.easeNone } );
		}
		public function zoomIn():void {
			//缩小
			TweenLite.to(_movingMc, 0.2, { scaleX:_movingMc.scaleX / _zoomStep, scaleY:_movingMc.scaleY / _zoomStep, ease:Linear.easeNone } );
		}
		public function zoomOut():void {
			//放大
			TweenLite.to(_movingMc, 0.2, { scaleX:_movingMc.scaleX * _zoomStep, scaleY:_movingMc.scaleY * _zoomStep, ease:Linear.easeNone } );
		}
		public function zoomOne():void {
			//复原大小
			TweenLite.to(_movingMc, 0.2, { scaleX:1, scaleY:1, ease:Linear.easeNone } );
		}
	}
}