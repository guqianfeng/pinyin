package src{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.GesturePhase;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getDefinitionByName;
	
	import gs.TweenLite;
	import gs.easing.*;
	
	import src.MovingControl;
	
	public class Main extends MovieClip {
		private var xOffset:int = 4;//整个表格左边距
		private var yOffset:int = 4;//上边距
		//private const distanceOfCells:int = 0;//cell之间间距
		private const cellWidth:int = 84;//方格宽度
		private const cellHeight:int = 74;//方格高度
		private var cellcontainer:Sprite;
		private var leftButton:SimpleButton;
		private var rightButton:SimpleButton;
		private var movingControl:MovingControl;
		//private var logBtn:Button;
		private var log:Log;
		
		private var scale:Number;//本程序是针对320x480屏幕开发的，针对其他屏幕需要设一个缩放比例
		private var screenWidth:int;
		private var screenHeight:int;

		public function Main() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			if (Capabilities.os.substr(0, 7) == "Windows") {
				screenWidth = 480;
				screenHeight = 800;//用于windows系下调试，不过到了CS6就不用了
			}else if (Capabilities.os.substr(0, 5) == "Linux" || Capabilities.os.substr(0, 6) == "iPhone") {
				screenWidth =  Capabilities.screenResolutionX;
				screenHeight =  Capabilities.screenResolutionY;
			}
			scale = screenWidth / 480;
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			init();
		}
		private function init():void {
			initBoard();
			initCells();
			initActiveBar();
			initLog();
			//initCellContainerTouchEvent();
			initCellContainerGestureEvent();
			//initScore();
			//initZoomButtons();
			//initMovingControl();
		}
		private function initLog():void{
			log = new Log();
			log.width = log.width * scale;
			log.height = log.height * scale;
			log.x = 0;
			log.y = screenHeight;
			
			this.addChild(log);
		}
		private var board:Sprite;
		private var activeBar:Sprite;
		/*
		private function initCellContainerTouchEvent(bl:Boolean = true):void {
			//设置TouchEvent
			if (bl) {
				cellcontainer.addEventListener(TouchEvent.TOUCH_TAP, oncellcontainerTouchHandler);
				cellcontainer.addEventListener(TouchEvent.TOUCH_BEGIN, oncellcontainerTouchBeginHandler);
				cellcontainer.addEventListener(TouchEvent.TOUCH_END, oncellcontainerTouchEndHandler);
				
			}
		}
		*/
		private function initCellContainerGestureEvent(bl:Boolean = true):void{
			//设置GestureEvent
			if(bl){
				cellcontainer.addEventListener(TransformGestureEvent.GESTURE_SWIPE, onCellContainerGestureSwipeHandler, false, 0, true);
				cellcontainer.addEventListener(TransformGestureEvent.GESTURE_PAN, onCellContainerGesturePanHandler, false, 0, true);
			}else{
				cellcontainer.removeEventListener(TransformGestureEvent.GESTURE_SWIPE, onCellContainerGestureSwipeHandler);
				cellcontainer.removeEventListener(TransformGestureEvent.GESTURE_PAN, onCellContainerGesturePanHandler);
			}
		}
		private function initBoard():void {
			//初始化背景
			board = new Board();
			board.width = screenWidth;
			board.height = screenHeight;
			board.x = 0;
			board.y = 0;
			this.addChild(board);
		}
		private function initActiveBar():void {
			//初始化ActiveBar
			activeBar = new ActiveBar();
			activeBar.width = screenWidth;
			activeBar.height = activeBar.height * scale;
			activeBar.x = 0;
			activeBar.y = 0;
			this.addChild(activeBar);
			
			//重新设定cellContainer位置和movingControl
			xOffset = 4;//定位Cell的位置
			yOffset = activeBar.height + 4;
			cellcontainer.x = xOffset;
			cellcontainer.y = yOffset;
			movingControl = new MovingControl(cellcontainer, new Point(xOffset, yOffset), 
				new Point(screenWidth, screenHeight - xOffset), 0.5);			
		}
		private function initCells() {
			//初始化cell容器
			cellcontainer = new Sprite();
			//初始化cell容器抬头
			var i:int;
			var j:int;
			var textField:TextField;
			for (j = 0; j < Config.yunmu.length; j++) {
				//韵母，行
				var titleYunmu:Sprite = new Yunmu();
				titleYunmu.x = j * cellWidth;
				titleYunmu.y = 0;
				textField = titleYunmu.getChildByName("txt") as TextField;
				textField.mouseWheelEnabled = false;
				textField.selectable = false;
				textField.text = Config.yunmu[j];
				titleYunmu.name = Config.yunmu[j];
				cellcontainer.addChild(titleYunmu);
			}
			
			for (i = 0; i < Config.shenmu.length; i++) {
				//声母，列
				var titleShenmu:Sprite = new Shenmu();
				titleShenmu.y = i * cellHeight;
				titleShenmu.x = 0;
				textField = titleShenmu.getChildByName("txt") as TextField;
				textField.mouseWheelEnabled = false;
				textField.selectable = false;
				textField.text = Config.shenmu[i];
				titleShenmu.name = Config.shenmu[i];
				cellcontainer.addChild(titleShenmu);
			}
			//初始化cell内容
			for (i = 1; i < Config.shenmu.length; i++) {
				for (j = 1; j < Config.yunmu.length; j++) {
					var cell:Cell = new Cell(cellcontainer, Config.shenmu[i], Config.yunmu[j]);
					cell.x = j * cellWidth;
					cell.y = i * cellHeight;
					cellcontainer.addChild(cell);
				}
			}
			cellcontainer.width = cellcontainer.width * scale;
			cellcontainer.height = cellcontainer.height * scale;
			this.addChild(cellcontainer);
		}
		/*
		private function initScore():void {
			//读取上次存在本机的成绩表
			var i; var j;
			for (i = 0; i < Config.shenmu.length; i++) {
				for (j = 0; j < Config.yunmu.length; j++) {
					var str:String = Config.shenmu[i] + Config.yunmu[j];
					var cell:Cell = cellcontainer.getChildByName(str) as Cell;
					cell.setScore();
				}
			}
		}
		private var zoomInBtn:SimpleButton;
		private var zoomOutBtn:SimpleButton;
		private var zoomOneBtn:SimpleButton;
		private var zoomStep:Number = 1.05;//每次放大倍数
		private var moveStep:Number = 30;//移动步长
		private var moveSpeed:Number = 3;//移动速度
		private var tweenlite:TweenLite;
		
		private function initZoomButtons():void {
			//初始化放大缩小按钮
			zoomInBtn = new Zoomin();
			zoomOneBtn = new Zoomone();
			zoomOutBtn = new Zoomout();
			zoomInBtn.x = 900; zoomInBtn.y = 18;
			zoomOneBtn.x = 935; zoomOneBtn.y = 18;
			zoomOutBtn.x = 970; zoomOutBtn.y = 18;
			this.addChild(zoomInBtn);
			this.addChild(zoomOutBtn);
			this.addChild(zoomOneBtn);
			zoomInBtn.addEventListener(MouseEvent.CLICK, onZoomInBtnHandler);
			zoomOutBtn.addEventListener(MouseEvent.CLICK, onZoomOutBtnHandler);
			zoomOneBtn.addEventListener(MouseEvent.CLICK, onZoomOneBtnHandler);
			
		}
		private function onZoomInBtnHandler(event:Event):void {
			movingControl.zoomIn();
		}
		private function onZoomOutBtnHandler(event:Event):void {
			movingControl.zoomOut();
		}
		private function onZoomOneBtnHandler(event:Event):void {
			movingControl.zoomOne();
		}
		private function initMovingControl():void {
			movingControl = new MovingControl(stage, cellcontainer, new Point(xOffset, yOffset), 
											new Point(stage.stageWidth - xOffset, stage.stageHeight - 5), 1.1, 200);
		}
		private function oncellcontainerTouchHandler(event:TouchEvent):void {
			trace("短触摸");
		}
		private function oncellcontainerTouchBeginHandler(event:TouchEvent):void {
			trace("触摸开始");
		}
		private function oncellcontainerTouchEndHandler(event:TouchEvent):void {
			trace("触摸结束");
		}
		*/
		private function onCellContainerGestureSwipeHandler(event:TransformGestureEvent):void{
			//左右滑动
			if(event.offsetX < 0) {
				//log.message("向左移动：" + event.offsetX);
				movingControl.swipeLeft(screenWidth);
			}else if(event.offsetX > 0) {
				//log.message("向右移动：" + event.offsetX);
				movingControl.swipeRight(screenWidth);
			}else if(event.offsetY < 0){
				movingControl.swipeUp(screenHeight / 2);
			}else if(event.offsetY > 0){
				movingControl.swipeDown(screenHeight / 2);
			}
		}
		private function onCellContainerGesturePanHandler(event:TransformGestureEvent):void{
			//trace("onCellContainerGesturePanHandler");
			//左右平移
			if(event.phase == GesturePhase.UPDATE){
				//trace("UPDATE: " + event.offsetX);
				movingControl.pan(event.offsetX, event.offsetY);
			}
			if(event.phase == GesturePhase.BEGIN) {
				//trace("BEGIN: " + event.offsetX);
			}
			if(event.phase == GesturePhase.END) {
				//trace("END: " + event.offsetX);
				var cell:Cell = getCellNameByPosition(new Point(event.localX, event.localY));
				if(cell) {
					log.message(cell.name);
					var mp3Array:Array = cell.getMP3File(cell.name);
					if(mp3Array){
						log.message("播音库：" + mp3Array[0] + ".mp3");
						playMp3(mp3Array[0] + ".mp3");
					}
				}
			}
		}
		private function playMp3(linkName:String):void{
			var aClass:Class = getDefinitionByName(linkName) as Class;
			var sound:Sound = new aClass() as Sound;
			sound.play(0);
		}
		private function getCellNameByPosition(pos:Point):Cell{
			//根据位置查找到拼音名字
			//trace(pos);
			var _y:int = pos.y / 74 + 1;
			var _x:int = pos.x / 84 + 1;
			var cellName:String;
			var cell:src.Cell = null;
			if(_y > 0 && _x > 0){
				cellName = Config.shenmu[_y] + Config.yunmu[_x];
				cell = cellcontainer.getChildByName(cellName) as Cell;
			}
			return cell;
		}
	}
}