package src{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import gs.TweenLite;
	import gs.easing.*;

	public class Cell extends MovieClip {
		private var cellContainer:Sprite;
		private var textField:TextField;
		private var scale:Number = 1.8;//放大倍数
		//private var myCookie:Cookie;
		private var buttonsGroup:MovieClip;

		private var tone1:SimpleButton;
		private var tone2:SimpleButton;
		private var tone3:SimpleButton;
		private var tone4:SimpleButton;
		private var close:SimpleButton;
		
		public function Cell(container:Sprite, shenmu:String, yunmu:String) {
			cellContainer = container;
			initCell(shenmu, yunmu);
		}
		private function initCell(shenmu:String, yunmu:String):void {
			textField = this.getChildByName("txt") as TextField;
			textField.mouseWheelEnabled = false;
			textField.selectable = false;
			var py:String = shenmu + yunmu;
			//隐藏声调按钮组
			//buttonsGroup = this.getChildByName("buttons") as MovieClip;
			//buttonsGroup.visible = false;
			if (ifExist(py)) {
				textField.text = py;
				this.name = py;
				/*
				this.addEventListener(MouseEvent.CLICK, onCellClickHandler);
				this.addEventListener(MouseEvent.MOUSE_DOWN, onCellMouseDownHandler);
				this.addEventListener(MouseEvent.MOUSE_DOWN, onCellMouseUpHandler);
				*/
				//this.addEventListener(MouseEvent.ROLL_OVER, onCellRollOverHandler);
				//this.addEventListener(MouseEvent.ROLL_OUT, onCellRollOutHandler);
				
				//放置打分按钮
				/*
				var scoreMCArray:Array = new Array();//5颗星数组
				for (var i:int = 1; i < 6; i++) {
					var scoreMc:Star = new Star(i);
					scoreMc.x = -23.1 + 9.2 * (i - 1);
					scoreMc.y = 11;
					scoreMc.name = "score" + i;
					this.addChild(scoreMc);
					scoreMCArray.push(scoreMc);
				}
				*/
				
				//读取语调mc和关闭窗口的mc
				//tone1 = buttonsGroup.getChildByName("tone1") as SimpleButton;
				//tone2 = buttonsGroup.getChildByName("tone2") as SimpleButton;
				//tone3 = buttonsGroup.getChildByName("tone3") as SimpleButton;
				//tone4 = buttonsGroup.getChildByName("tone4") as SimpleButton;
				//close = buttonsGroup.getChildByName("close") as SimpleButton;
			}
			else textField.text = "";
		}
		public function setScore():void {
			//读取分数并打星星
			//var score:int = readCookie(this.name);//循环读取本地分数记录时,速度很慢,数据丢失？？？？？？？？？？？
			//showScore(score);
		}
		private function showScore(score:int):void {
			//显示五角星
			var n:int;
			var mc:Star;
			for (n = 1; n <= score; n++) {
				mc = this.getChildByName("score" + n) as Star;
				if(mc) mc.gotoAndStop(2);
			}
			for (n = score + 1; n <= 5; n++) {
				mc = this.getChildByName("score" + n) as Star;
				if(mc) mc.gotoAndStop(1);
			}
		}
		private function onStarRolloutHandler(event:Event):void {
			//鼠标移出时，读取分数并打星星
			//var score:int = readCookie(this.name);//读取本地分数记录
			//showScore(score);
		}
		private function onStarRolloverHandler(event:Event):void {
			var star:Star = event.currentTarget as Star;
			var score:int = int(star.name.substr(5, 1));
			showScore(score);
		}
		private function onStarMouseUpHandler(event:Event):void {
			var star:Star = event.currentTarget as Star;
			var score:int = int(star.name.substr(5, 1));
			//writeCookie(this.name, score);
			zoomInCell();
		}
		private function ifExist(pinyin:String):Boolean {
			//检验该声韵母组合是否存在
			var re:Boolean = false;
			for (var i = 0; i < Config.mp3List.length; i++) {
				var str:String = Config.mp3List[i] as String;
				if (str.substr(0, str.length - 1) == pinyin) {
					re = true;
					break;
				}
			}
			return re;
		}
		private function onCellClickHandler(event:MouseEvent):void {
			//播放声音
			trace("onCellClick");
		}
		private function onCellMouseDownHandler(event:MouseEvent):void{
			//侦听是否长按
			
		}
		private function onCellMouseUpHandler(event:MouseEvent):void{
			//侦听是否双击
			
		}
		private function getMP3File(pinyin:String):Array {
			var re:Array = new Array();
			for (var i = 0; i < Config.mp3List.length; i++) {
				var str:String = Config.mp3List[i] as String;
				if (str.substr(0, str.length - 1) == this.name) {
					re.push(str);
				}
			}
			return re;
		}
		private function playMusic(filename:String):void {
			var s:Sound = new Sound();
			s.addEventListener(Event.COMPLETE, onSoundLoadFinished);
			s.addEventListener(ProgressEvent.PROGRESS, onSoundLoadingHandler);
			s.addEventListener(IOErrorEvent.IO_ERROR, onSoundLoadError);
			s.load(new URLRequest(filename));
		}
		private function onSoundLoadFinished(event:Event):void {
			var localSound:Sound = event.target as Sound;
			localSound.play();
		}
		private function onSoundLoadingHandler(event:ProgressEvent):void {
			
		}
		private function onSoundLoadError(event:IOErrorEvent):void {

		}
		private function onCellRollOverHandler(event:MouseEvent):void {
			//放大图片
			zoomOutCell();
		}
		private function onCellRollOutHandler(event:MouseEvent):void {
			//还原图片
			zoomInCell();
		}
		private function zoomOutCell():void {
			buttonsGroup.visible = true;
			
			//播放声音文件
			mp3Array = getMP3File(this.name);
			
			//交换层级，换字体，渐变放大
			cellContainer.setChildIndex(this, cellContainer.numChildren - 1);
			var format:TextFormat = new TextFormat();
			format.bold = true;
			textField.setTextFormat(format);
			TweenLite.to(this, 0.3, { scaleX:scale, scaleY:scale, ease:Quart.easeOut } );
			setStarEvent(true);
		}
		private function setStarEvent(bl:Boolean):void {
			//当放大Cell时，侦听星星事件
			var i:int;
			var scoreMc:Star;
			if (bl) {
				for (i = 1; i < 6; i++) {
					scoreMc = this.getChildByName("score" + i) as Star;
					scoreMc.addEventListener("STAR_ROLLOVER", onStarRolloverHandler);
					scoreMc.addEventListener("STAR_MOUSEUP", onStarMouseUpHandler);
					scoreMc.addEventListener("STAR_ROLLOUT", onStarRolloutHandler);
					tone1.addEventListener(MouseEvent.CLICK, onTone1ClickHandler);
					tone2.addEventListener(MouseEvent.CLICK, onTone2ClickHandler);
					tone3.addEventListener(MouseEvent.CLICK, onTone3ClickHandler);
					tone4.addEventListener(MouseEvent.CLICK, onTone4ClickHandler);
					//close.addEventListener(MouseEvent.CLICK, onCloseClickHandler);
				}
			}else {
				for (i = 1; i < 6; i++) {
					scoreMc = this.getChildByName("score" + i) as Star;
					scoreMc.removeEventListener("STAR_ROLLOVER", onStarRolloverHandler);
					scoreMc.removeEventListener("STAR_MOUSEUP", onStarMouseUpHandler);
					scoreMc.removeEventListener("STAR_ROLLOUT", onStarRolloutHandler);
					tone1.removeEventListener(MouseEvent.CLICK, onTone1ClickHandler);
					tone2.removeEventListener(MouseEvent.CLICK, onTone2ClickHandler);
					tone3.removeEventListener(MouseEvent.CLICK, onTone3ClickHandler);
					tone4.removeEventListener(MouseEvent.CLICK, onTone4ClickHandler);
					//close.removeEventListener(MouseEvent.CLICK, onCloseClickHandler);
				}
			}
		}
		private function zoomInCell():void {
			setStarEvent(false);
			//读取分数并打星星
			//var score:int = readCookie(this.name);//读取本地分数记录
			//showScore(score);
			//恢复小字体
			var format:TextFormat = new TextFormat();
			format.bold = false;
			textField.setTextFormat(format);
			TweenLite.to(this, 0.3, { scaleX:1, scaleY:1, ease:Quart.easeIn } );
			buttonsGroup.visible = false;
		}
		/*
		private function readCookie(key:String):int{
			myCookie = new Cookie("www.pinyin.com", 24 * 60 * 60 * 1000);
			if (myCookie.contain(key)) return myCookie.get(key).score;
			else return 0;
		}
		private function writeCookie(key:String, value:int):void{
			myCookie = new Cookie("www.pinyin.com", 24 * 60 * 60 * 1000);
			if(myCookie.contain("key")) myCookie.remove("key");
			myCookie.put(key,{score:value});
		}
		*/
		private var mp3Array:Array;
		private function onTone1ClickHandler(event:MouseEvent):void {
			playMusic(Config.mp3FileDir + mp3Array[0] + ".mp3");//测试播放第一个音调文件			
		}
		private function onTone2ClickHandler(event:MouseEvent):void {
			playMusic(Config.mp3FileDir + mp3Array[1] + ".mp3");//测试播放第一个音调文件			
		}
		private function onTone3ClickHandler(event:MouseEvent):void {
			playMusic(Config.mp3FileDir + mp3Array[2] + ".mp3");//测试播放第一个音调文件			
		}
		private function onTone4ClickHandler(event:MouseEvent):void {
			playMusic(Config.mp3FileDir + mp3Array[3] + ".mp3");//测试播放第一个音调文件			
		}
		private function onCloseClickHandler(event:MouseEvent):void {
			zoomInCell();
		}
	}
}