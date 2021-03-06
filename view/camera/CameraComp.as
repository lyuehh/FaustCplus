﻿package view.camera
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.media.*;
    import flash.system.*;
    import flash.utils.*;
    import view.*;
    import view.avatar.*;
    import view.ui.*;
    import fl.controls.Button;
    import model.*;

	/*
	* 摄像头拍摄
	*/
    public class CameraComp extends Sprite
    {
        private var _video:Video;
        public var hasCamera:Boolean = false;
        private var _tTwo:Timer;
        private var _t600:Timer;
        private var _tOne:Timer;
        private var _camera:Camera;
        private var _parent:CutView;
        private var _countDown:MovieClip;
        private var _currentFrame:int = 1;
        private var _t100:Timer;
        private var _blackSP:Shape;
        private var _videoBg:RectBox;
        public var _tip:TipB;
        private var _sourceBMD:BitmapData;
        private var _nowPicture:Bitmap;
        private var _delayTime:int = 0;
        private var _nowBMP:Bitmap;
        public var cameraBtn;//:SK_BtnCamera;
        private var _avatar:AvatarArea;
        private var _t:Timer;

        public function CameraComp(param1:DisplayObject)
        {
            this.init(param1);
            return;
        }

        private function changeCountDown(event:TimerEvent) : void
        {
			this._currentFrame ++;
            this._countDown.gotoAndStop(this._currentFrame);
            return;
        }

        private function showBlack(event:TimerEvent) : void
        {
            this._tOne.removeEventListener(TimerEvent.TIMER, this.showBlack);
            if (this._blackSP == null)
            {
                this._blackSP = new Shape();
                this._blackSP.graphics.beginFill(2236962);
                this._blackSP.graphics.drawRect(1, 1, 300, 300);
                this._blackSP.graphics.endFill();
            }
            addChild(this._blackSP);
            this._t100 = this._t100 || new Timer(100);
            this._t100.addEventListener(TimerEvent.TIMER, this.showNowScene);
            this._t100.start();
            return;
        }

        private function init(param1:DisplayObject) : void
        {
            this._parent = param1 as CutView;
            this._avatar = this._parent.avatarArea;
            this.addEventListener(Event.ADDED_TO_STAGE, this.onStage);
            this._videoBg = new RectBox(300, 300);
            addChild(this._videoBg);
            if (Camera.names.length)
            {
                this._camera = Camera.getCamera();
                this._video = new Video(300, 300);
                this._video.smoothing = true;
                this._video.x = 1 + this._video.width;
                this._video.y = 1;
                this._video.scaleX = -1;
                if (this._camera != null)
                {
                    this.hasCamera = true;
                    this._camera.setMode(300, 300, 30, false);
                    this._camera.setQuality(0, 100);
                    this._camera.addEventListener(StatusEvent.STATUS, this.cameraStatusHandler);
                    this._video.attachCamera(this._camera);
                    this.addViewElements();
                    this._t = new Timer(100);
                    this._t.addEventListener(TimerEvent.TIMER, this.checkCamera);
                    this._t.start();
                }
            }
            else
            {
                this.showTip();
            }
            return;
        }

        private function beginCountDown(event:MouseEvent) : void
        {
            this.cameraBtn.removeEventListener(MouseEvent.CLICK, this.beginCountDown);
            this.cameraBtn.mouseEnabled = false;
            this.cameraBtn.alpha = 0.5;
            this._tTwo = this._tTwo || new Timer(1000, 2);
            this._currentFrame = 1;
            this._tTwo.addEventListener(TimerEvent.TIMER, this.changeCountDown);
            this._tTwo.addEventListener(TimerEvent.TIMER_COMPLETE, this.showFrameOne);
            this._tTwo.reset();
            this._tTwo.start();
            this._countDown = this._countDown || new SK_CountDown() as MovieClip;
            this._countDown.x = 69;
            this._countDown.y = 74;
            this._countDown.gotoAndStop(1);
            addChild(this._countDown);
            return;
        }

        private function getAvatarBMD() : void
        {
            this._sourceBMD = this._sourceBMD || new BitmapData(this._video.width, this._video.height, true);
            var _loc_1:* = new Matrix();
            _loc_1.scale(-1, 1);
            _loc_1.translate(this._video.width, 0);
            this._sourceBMD.draw(this._video, _loc_1);
            this._nowPicture = this._nowPicture || new Bitmap(null, "auto", true);
            this._nowPicture.bitmapData = this._sourceBMD;
            addChild(this._nowPicture);
            return;
        }

        private function changeScene(event:TimerEvent) : void
        {
            this._t600.removeEventListener(TimerEvent.TIMER, this.changeScene);
            this._t600.reset();
            this.cameraBtn.addEventListener(MouseEvent.CLICK, this.beginCountDown);
            this.cameraBtn.mouseEnabled = true;
            this.cameraBtn.alpha = 1;
            removeChild(this._countDown);
            removeChild(this._nowPicture);
            removeChild(this._blackSP);
			with(this._parent){				
				avatarModel.bmd = this._sourceBMD;
				avatarModel.type = 1;
				avatarArea.visible = true;
				localPicArea.visible = true;
				browseComp.label.visible = true;
				splitLines.visible = true;
				cancleBtn.visible = true;
				saveBtn.visible = true;
				cameraBtn.mouseEnabled = true;
				//colorAdj.visible = true;
			}
            this.visible = false;
            return;
        }

        private function checkCamera(event:TimerEvent) : void
        {
            if (this._camera.currentFPS > 0)
            {
                this.removeTip();
                this.cameraBtn.visible = true;
            }
            else
            {
                if (this._delayTime >= 30)
                {
                    this.showTip();
                }
                var _loc_2:String = this;
                var _loc_3:* = this._delayTime + 1;
                //_loc_2._delayTime = _loc_3;
                this.cameraBtn.visible = false;
            }
            return;
        }

        private function showFrameOne(event:TimerEvent) : void
        {
            this._countDown.gotoAndStop(this._currentFrame);
            this._tTwo.removeEventListener(TimerEvent.TIMER, this.changeCountDown);
            this._tTwo.removeEventListener(TimerEvent.TIMER_COMPLETE, this.showFrameOne);
            this._tOne = new Timer(1000);
            this._tOne.addEventListener(TimerEvent.TIMER, this.showBlack);
            this._tOne.reset();
            this._tOne.start();
            return;
        }

        private function cameraStatusHandler(event:StatusEvent) : void
        {
            if (event.code == "Camera.Muted")
            {
                addChild(this._videoBg);
                this.showTip();
                this._t.reset();
                this.cameraBtn.visible = false;
            }
            else
            {
                this.removeTip();
                this._t.start();
            }
            return;
        }

        private function showTip() : void
        {
            if (this._tip == null)
            {
                this._tip = new TipB();
                var _loc_1:int = 1;
                this._tip.y = 1;
                this._tip.x = _loc_1;
            }
            addChild(this._tip);
            return;
        }

        private function onStage(event:Event) : void
        {
            this.removeEventListener(Event.ADDED_TO_STAGE, this.onStage);
            return;
        }

        private function newSecurityPanel(event:MouseEvent) : void
        {
            Security.showSettings(SecurityPanel.PRIVACY);
            return;
        }

        private function showNowScene(event:TimerEvent) : void
        {
            this._t100.removeEventListener(TimerEvent.TIMER, this.showNowScene);
            this._t100.reset();
            this.getAvatarBMD();
            this._t600 = this._t600 || new Timer(600);
            this._t600.addEventListener(TimerEvent.TIMER, this.changeScene);
            this._t600.start();
            return;
        }

        private function addViewElements() : void
        {
            //this.cameraBtn = new SK_BtnCamera();
            this.cameraBtn = new Button();
            this.cameraBtn.label = Param.lang.info13; // 拍照
            this.cameraBtn.width = 50;
            this.cameraBtn.x = 96;
            this.cameraBtn.y = 310;
            this.cameraBtn.addEventListener(MouseEvent.CLICK, this.beginCountDown);
            addChildAt(this._videoBg, 0);
            addChildAt(this._video, 1);
            addChild(this.cameraBtn);
            return;
        }

        private function removeTip() : void
        {
            if (this._tip != null && this.contains(this._tip))
            {
                removeChild(this._tip);
            }
            return;
        }

    }
}
