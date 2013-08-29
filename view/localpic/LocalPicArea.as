﻿package view.localpic
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.ui.*;
	import model.*;
    import view.*;
    import view.avatar.*;
    import view.ui.*;
	import fl.controls.Button;
	import flash.events.MouseEvent;

	/*
	* 处理头像选区、缩放、旋转等操作类
	*/
    public class LocalPicArea extends Sprite
    {
		public var tip:MovieClip;

		private var swfStage:Stage;

		public var cutBox:CutBox;
		private var cutBox_minW:Number = 30;
        private var cutBox_minH:Number = 30;

        private var TurnLeft:SK_TurnLeft;
		private var TurnRight:SK_TurnRight;
        private var cutAreaBg:RectBox;

        private var flagCurX:Number;
        private var flagCurY:Number;
        private var flagVX:Number;
        private var flagVY:Number;

        private var picRate:Number;

        private var _cursorScale:SK_CursorScale;
        public var _sourceBMD:BitmapData;
        private var _cursorMove:SK_CursorMove;


        private var _picX:Number;
        private var _picY:Number;
        private var _pic_minX:Number = 100;
        private var _pic_minY:Number = 100;
        private var _pic_maxX:Number = Param.pSize[0] - 100;
        private var _pic_maxY:Number = Param.pSize[1] - 100;
        private var _picW:Number;
        private var _picH:Number;
        private var _cutX:Number;
        private var _cutY:Number;
        private var _cutW:Number;
        private var _cutH:Number;
        private var _picContainer:Sprite;
        private var _avatar:AvatarArea;

        public var loaddingUI:MovieClip;

        public function LocalPicArea()
        {

            init();
            return;
        }
		// 控件初始化
        private function init() : void
        {
            cutAreaBg = new RectBox(Param.pSize[0], Param.pSize[1]);
			
            _picContainer = new Sprite();			
			_picContainer.addEventListener(MouseEvent.MOUSE_DOWN, moveImg);
			_picContainer.buttonMode = true;
			
            _cursorMove = new SK_CursorMove();
            _cursorMove.mouseEnabled = _cursorMove.visible = false;
            _cursorScale = new SK_CursorScale();
            _cursorScale.mouseEnabled = _cursorScale.visible = false;

            tip = new SK_Tip() as MovieClip;
            tip.y = tip.x = 1;
            tip.stop();
            tip.mouseEnabled = false;

			 //左右旋转
            TurnLeft = new SK_TurnLeft();
			TurnRight = new SK_TurnRight();
            TurnLeft.y = TurnRight.y = Param.pSize[1] + 12;
            TurnRight.x = 220;
			TurnLeft.addEventListener(MouseEvent.CLICK, rotationPicLeft);
            TurnRight.addEventListener(MouseEvent.CLICK, rotationPicRight);
            showTunBtns(false);

            createLoaddingUI();
			
            addChild(cutAreaBg);
            addChild(tip);
            addChild(_picContainer);
            addChild(TurnLeft);
            addChild(TurnRight);
            addChild(loaddingUI);
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			var btnZoomIn = new Button();
			var btnZoomOut = new Button();
			btnZoomIn.label = "缩小";
			btnZoomOut.label = "放大";
			btnZoomIn.width = btnZoomOut.width = 50;
			btnZoomIn.y = btnZoomOut.y = Param.pSize[1] + 12;
			btnZoomIn.x = 100;
			btnZoomOut.x = 150;			
			btnZoomIn.addEventListener(MouseEvent.CLICK, zoomIn);
            btnZoomOut.addEventListener(MouseEvent.CLICK, zoomOut);			
			addChild(btnZoomIn);
			addChild(btnZoomOut);
			
			//底图遮罩
			var _picMask:Sprite = new Sprite();
			_picMask.graphics.beginFill(0xFF); 
			_picMask.graphics.drawRect(0, 0, Param.pSize[0], Param.pSize[1]);
			_picMask.graphics.endFill();
			_picMask.x = _picMask.y = 1;
			addChild(_picMask);
			_picContainer.mask = _picMask;			

			return;
        }

        private function resetCursor(event:MouseEvent) : void
        {
            Mouse.show();
            _cursorMove.visible = _cursorScale.visible = false;
            cutBox.removeEventListener(MouseEvent.ROLL_OUT, resetCursor);
            cutBox.removeEventListener(MouseEvent.MOUSE_MOVE, moveCursor);
            cutBox.removeEventListener(MouseEvent.MOUSE_DOWN, changeCutBox);
            return;
        }

		// 左旋转/右旋转  按钮状态
        public function showTunBtns(s:Boolean) : void
        {
            TurnRight.visible = TurnLeft.visible = s;
            return;
        }

        private function moveCursor(event:MouseEvent) : void
        {
            var sprite:Sprite = null;
            var tgt = event.target as Sprite;
            switch(tgt)
            {
                case cutBox.cutArea:
                {
                    sprite = _cursorMove as Sprite;
                    break;
                }
                case cutBox.flag:
                {
                    sprite = _cursorScale as Sprite;
                    break;
                }
                default:
                {
                    break;
                }
            }
            cursorFollow(sprite);
            event.updateAfterEvent();
            return;
        }

        private function createLoaddingUI() : void
        {
            loaddingUI = new SK_Loading() as MovieClip;
            loaddingUI.x = Math.ceil(Param.pSize[0] / 2);
            loaddingUI.y = Math.ceil(Param.pSize[1] / 2);
            loaddingUI.stop();
            loaddingUI.visible = false;
            return;
        }

		// 缩略结束
        private function stopResizeCutBox(event:MouseEvent) : void
        {
            Mouse.show();
            _cursorScale.visible = false;
            cutBox.addEventListener(MouseEvent.MOUSE_OVER, changeCursor);
            swfStage.removeEventListener(Event.ENTER_FRAME, resizeCutBox);
            swfStage.removeEventListener(MouseEvent.MOUSE_UP, stopResizeCutBox);
            return;
        }

        private function addedToStage(event:Event) : void
        {
            swfStage = stage;
            var _cutview = parent as CutView;
            _avatar = _cutview.avatarArea;
            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
            return;
        }

        private function changeCursor(event:MouseEvent) : void
        {
            var tgt = event.target as Sprite;
            if (tgt == cutBox.cutArea)
            {
                Mouse.hide();
                _cursorMove.visible = true;
                _cursorScale.visible = false;
                _cursorMove.x = mouseX;
                _cursorMove.y = mouseY;
            }
            else if (tgt == cutBox.flag)
            {
                Mouse.hide();
                _cursorScale.visible = true;
                _cursorMove.visible = false;
                _cursorScale.x = mouseX;
                _cursorScale.y = mouseY;
            }
            cutBox.addEventListener(MouseEvent.MOUSE_MOVE, moveCursor);
            cutBox.addEventListener(MouseEvent.MOUSE_DOWN, changeCutBox);
            cutBox.addEventListener(MouseEvent.MOUSE_OUT, resetCursor);
            return;
        }

        private function cursorFollow(param1:Sprite) : void
        {
            param1.x = mouseX;
            param1.y = mouseY;
            return;
        }

		// 创建 剪切选择框
        public function addCutBox(pic:Bitmap) : void
        {
            var _w:Number = NaN;
            var _h:Number = NaN;
            if (cutBox != null)
            {
                removeChild(cutBox);
                cutBox = null;
            }
			if(_cutW && _cutH){
				_w = _cutW;
				_h = _cutH;
			}
            else if (pic.width < Param.pSize[2] || pic.height < Param.pSize[3])
            {	// 原版 _w = pic.width > pic.height ? (pic.height) : (pic.width);
				if(pic.width/pic.height >= Param.pSize[2]/Param.pSize[3]){
					_h = pic.height;
                    _w = _h * Param.pSize[2] / Param.pSize[3];
				}
				else{
					_w = pic.width;
                    _h = _w * Param.pSize[3] / Param.pSize[2];
				}
            }
            else
            {
                _w = Param.pSize[2];
                _h = Param.pSize[3];
            }
            cutBox = new CutBox(_w, _h);
			if(_cutX && _cutY){
				cutBox.x = _cutX;
				cutBox.y = _cutY;
			}else{
				cutBox.x = _picContainer.x + (_picContainer.width - cutBox.cutArea.width) * 0.5;
				cutBox.y = _picContainer.y + (_picContainer.height - cutBox.cutArea.height) * 0.5;
			}
			
			addChild(cutBox);
            addChild(_cursorMove);
            addChild(_cursorScale);
            pic.mask = cutBox.maskArea;
            cutBox.addEventListener(MouseEvent.MOUSE_OVER, changeCursor);
            freshAvatar();
            return;
        }

        public function setLocalPicSize(bmd:BitmapData) : void
        {
            var _pic:Bitmap = null;

            if (tip != null)
            {
                removeChild(tip);
                tip = null;
            }
            _sourceBMD = bmd;
            var _sourcePic:Bitmap = new Bitmap(bmd);
            var _widthRate = Param.pSize[0] / _sourcePic.width;
            var _heightRate = Param.pSize[1] / _sourcePic.height;
            picRate = _widthRate < _heightRate ? (_widthRate) : (_heightRate); //缩略时取最小长宽比
            _sourcePic.width = _sourcePic.width * picRate;
            _sourcePic.scaleY = _sourcePic.scaleX;

			picZoomPos();
			
            while (_picContainer.numChildren)
            {
                _pic = _picContainer.removeChildAt((_picContainer.numChildren - 1)) as Bitmap;
                _pic = null;
            }

            _sourceBMD = _sourcePic.bitmapData;
            var albumPic = new Bitmap(bmd);		// 原图缩略
				albumPic.width = _sourcePic.width;
				albumPic.scaleY = albumPic.scaleX;

            _sourcePic.alpha = 0.5;
			_picContainer.addChild(_sourcePic);
            _picContainer.addChild(albumPic);

			if(_picX == 0 && _picY == 0){
            	_picX = _picContainer.x = (Param.pSize[0] - _sourcePic.width) * 0.5 + 1;
            	_picY = _picContainer.y = (Param.pSize[1] - _sourcePic.height) * 0.5 + 1;
			}else{
				picZoomPos(true);
			}
			
            addCutBox(albumPic);
            showTunBtns(true);
            return;
        }

/* **************** 左右旋转 **************** */
		// 左旋转
        private function rotationPicLeft(event:MouseEvent) : void
        {
            _sourceBMD = changeBmdLeft(_sourceBMD);
            setLocalPicSize(_sourceBMD);
            return;
        }
        private function changeBmdLeft(bmd:BitmapData) : BitmapData
        {
            var _w = bmd.width;
            var _h = bmd.height;
            var newBmd = new BitmapData(_h, _w, false);
            var _tmp = new Matrix();
            _tmp.rotate((-Math.PI) * 0.5);
            _tmp.translate(0, _w);
            newBmd.draw(bmd, _tmp);
            return newBmd;
        }
		// 右旋转
        private function rotationPicRight(event:MouseEvent) : void
        {
            _sourceBMD = changeBmdRight(_sourceBMD);
            setLocalPicSize(_sourceBMD);
            return;
        }
        private function changeBmdRight(bmd:BitmapData) : BitmapData
        {
            var _w = bmd.width;
            var _h = bmd.height;
            var newBmd = new BitmapData(_h, _w, false);
            var _tmp = new Matrix();
            _tmp.rotate(Math.PI * 0.5);
            _tmp.translate(_h, 0);
            newBmd.draw(bmd, _tmp);
            return newBmd;
        }

/* **************** 剪切框动作 **************** */

        private function getAvatarBMD(_x:Number, _y:Number, picRate:Number, cutbox:CutBox) : BitmapData
        {
			picRate *= _picContainer.scaleX;
            var _w = cutbox.maskArea.width / picRate;
            var _h = cutbox.maskArea.height / picRate;
            var _bmd = new BitmapData(_w, _h, false);
            var _RectangleX = (int((cutbox.x - _x) / picRate) + 0.5) - ((_picContainer.x - _picX) / picRate);
            var _RectangleY = (int((cutbox.y - _y) / picRate) + 0.5) - ((_picContainer.y - _picY) / picRate);
            _bmd.copyPixels(_sourceBMD, new Rectangle(_RectangleX, _RectangleY, _w, _h), new Point(0, 0));
            return _bmd;
        }
		// 拖动
        private function moveCutBox(event:MouseEvent) : void
        {
            //cutBox.startDrag(false, new Rectangle(_picContainer.x, _picContainer.y, _picContainer.width - cutBox.maskArea.width, _picContainer.height - cutBox.maskArea.height));
            cutBox.startDrag(false, new Rectangle(0, 0, Param.pSize[0] - cutBox.maskArea.width, Param.pSize[1] - cutBox.maskArea.height));
			_cutX = cutBox.x;
			_cutY = cutBox.y;
			freshAvatar();
            return;
        }
		// 结束拖动
        private function stopMoveCutBox(event:Event) : void
        {
            cutBox.stopDrag();
            swfStage.removeEventListener(MouseEvent.MOUSE_MOVE, moveCutBox);
            swfStage.removeEventListener(MouseEvent.MOUSE_UP, stopMoveCutBox);
            return;
        }
		// 改变大小
        private function changeCutBox(event:MouseEvent) : void
        {
            var tgt = event.target as Sprite;
            switch(tgt)
            {
                case cutBox.cutArea:
                {
                    swfStage.addEventListener(MouseEvent.MOUSE_MOVE, moveCutBox);
                    swfStage.addEventListener(MouseEvent.MOUSE_UP, stopMoveCutBox);
                    break;
                }
                case cutBox.flag:
                {
                    flagVY = mouseY - cutBox.y - cutBox.maskArea.height;
                    flagVX = mouseX - cutBox.x - cutBox.maskArea.width;
                    flagCurX = mouseX;
                    flagCurY = mouseY;
                    cutBox.removeEventListener(MouseEvent.MOUSE_OVER, changeCursor);
                    swfStage.addEventListener(Event.ENTER_FRAME, resizeCutBox);
                    swfStage.addEventListener(MouseEvent.MOUSE_UP, stopResizeCutBox);
                    break;
                }
                default:
                {
                    break;
                }
            }
            return;
        }
		
        private function resizeCutBox(event:Event) : void
        {
            var _currW:Number = NaN;
            var _currH:Number = NaN;
            var _loc_4:Number = NaN;
            var _loc_5:Number = NaN;
            var bmd:BitmapData = null;
            Mouse.hide();
            _cursorScale.x = mouseX;
            _cursorScale.y = mouseY;
            _cursorScale.visible = true;
            if (mouseX != flagCurX || mouseY != flagCurY)
            {
                _currW = mouseX - cutBox.x - flagVX;
                _currH = mouseY - cutBox.y - flagVY;
				if((cutBox.y + _currH) >= Param.pSize[1])
				//if (_currH > _picContainer.y + _picContainer.height - cutBox.y)
                {
                    //_currH = _picContainer.y + _picContainer.height - cutBox.y;
                    _currH = Param.pSize[1] - cutBox.y;
                }
                if (_currH < cutBox_minH)
                {
                    _currH = cutBox_minH;
                }
				
				if((cutBox.x + _currW) >= Param.pSize[0])
                //if (_currW > _picContainer.x + _picContainer.width - cutBox.x)
                {
                    //_currW = _picContainer.x + _picContainer.width - cutBox.x;
					_currW = Param.pSize[0] - cutBox.x;
                }
                if (_currW < cutBox_minW)
                {
                    _currW = cutBox_minW;
                }
                _loc_4 = _currW - cutBox.maskArea.width;
                _loc_5 = _currH - cutBox.maskArea.height;
				
				if(_loc_4/_loc_5 >= Param.pSize[2]/Param.pSize[3]){
					cutBox.maskArea.height = _currH;
                    cutBox.maskArea.width = _currH * Param.pSize[2] / Param.pSize[3];
				}
				else{
					cutBox.maskArea.width = _currW;
                    cutBox.maskArea.height = _currW * Param.pSize[3] / Param.pSize[2];
				}
				
                cutBox.cutArea.width = cutBox.maskArea.width;
                cutBox.cutArea.height = cutBox.maskArea.height;
                cutBox.flag.x = cutBox.maskArea.width;
                cutBox.flag.y = cutBox.maskArea.height;
				
				cutBox.border.height = cutBox.maskArea.height - 1;
				cutBox.border.width = cutBox.maskArea.width - 1;
				
				_cutW = cutBox.maskArea.width;
				_cutH = cutBox.maskArea.height;

                freshAvatar();
            }
            return;
        }
		
/* **************** 底图动作 **************** */
		
		// 拖动
        private function moveImg(event:MouseEvent) : void
        {
			stage.addEventListener(MouseEvent.MOUSE_UP, stopMoveImg);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveCutImg);
            _picContainer.startDrag(false);
            return;
        }
        private function moveCutImg(event:MouseEvent) : void{
		
			with(_picContainer){
				if(x > _pic_maxX) x = _pic_maxX;
				if((x + width) < _pic_minX)	x = _pic_minX - width;
				if(y > _pic_maxY) y = _pic_maxY;
				if((y + height) < _pic_minY) y = _pic_minY - height;
			}
			
			freshAvatar();
		}
		// 结束拖动
        private function stopMoveImg(event:Event) : void
        {
			with(_picContainer){
				if(x > _pic_maxX) x = _pic_maxX;
				if((x + width) < _pic_minX)	x = _pic_minX - width;
				if(y > _pic_maxY) y = _pic_maxY;
				if((y + height) < _pic_minY) y = _pic_minY - height;
			}
			
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveCutImg);
            stage.removeEventListener(MouseEvent.MOUSE_UP, stopMoveImg);
            _picContainer.stopDrag();
            return;
        }
		
		//底图缩小
        private function zoomIn(event:MouseEvent) : void{
			if(_picContainer.scaleX < 0.4) return;
			picZoomPos();
			_picContainer.scaleX = _picContainer.scaleY -= 0.1;
			picZoomPos(true);
			freshAvatar();
        }
		
		//底图放大
        private function zoomOut(event:MouseEvent) : void{
			if(_picContainer.scaleX > 2.5) return;
			picZoomPos();
			_picContainer.scaleX = _picContainer.scaleY += 0.1;
			picZoomPos(true);
			freshAvatar();
		}
		
		//缩放时保持当前中心点
		private function picZoomPos(e:Boolean = false){
			if(e){
				_picContainer.x -= ((_picContainer.width - _picW) / 2);
				_picContainer.y -= ((_picContainer.height - _picH) / 2);
			}
			_picX = _picContainer.x;
			_picY = _picContainer.y;
			_picW = _picContainer.width;
			_picH = _picContainer.height;
		}
		
		//刷新头像预览
		private function freshAvatar(){
			var avatar = getAvatarBMD(_picX, _picY, picRate, cutBox);
			_avatar.changeAvatars(avatar);
		}

    }
}
