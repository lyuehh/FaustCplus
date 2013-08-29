﻿package view.avatar
{
    import flash.display.*;
    import flash.text.*;
    import model.*;
    import view.ui.*;

    public class AvatarArea extends Sprite
    {
		public var bigPic:Bitmap;
		private var bigBox:RectBox;
		private var bigTxt:TextField;

		public var midPic:Bitmap;
        private var midBox:RectBox;
		private var midTxt:TextField;

        public var smallPic:Bitmap;
        private var smallBox:RectBox;
        private var smalltxt:TextField;

        public function AvatarArea()
        {
            this.init();
            return;
        }
		private function init() : void
        {
            this.initBoxs();
            this.initTxt();
            return;
        }
		// 创建 头像预览框
        private function initBoxs() : void
        {
			// 大头像框
            this.bigBox = this.setBoxs(Param.pSize[2], Param.pSize[3], 0, 40);
			addChild(this.bigBox);
			// 中头像框
            if(Param.pSize[4]>0){
				this.midBox = this.setBoxs(Param.pSize[4], Param.pSize[5], Param.pSize[2]+10, 40);
				addChild(this.midBox);
			}
			// 小头像框
			if(Param.pSize[6]>0){
				this.smallBox = this.setBoxs(Param.pSize[6], Param.pSize[7], Param.pSize[2]+Param.pSize[4]+20, 40);
				addChild(this.smallBox);
			}
            return;
        }
        private function setBoxs(_w:Number, _h:Number, _x:Number, _y:Number) : RectBox
        {
            var box = new RectBox(_w, _h);
            box.x = _x;
            box.y = _y;
            return box;
        }

        private function initTxt() : void
        {
            var _txtFormat = new TextFormat("宋体", 12, 13460736);
				_txtFormat.leading = 4;
			var _txtFormat2 = _txtFormat3 = new TextFormat("宋体", 12, 10132122);
				_txtFormat2.align = TextFormatAlign.LEFT;

			var label:TextField;
            label = new TextField();
            label.multiline = true;
            label.wordWrap = true;
            label.selectable = false;
            label.width = 300;
            label.text = Param.language["CX0189"] || "hahahha";
            label.setTextFormat(_txtFormat);
			addChild(label);

			// 大头像文本框
            this.bigTxt	= this.setText(Param.pSize[2],0,Param.pSize[3]+46,Param.pSize[2]+"*"+Param.pSize[3]+"像素",_txtFormat2);
			addChild(this.bigTxt);
			// 中头像文本框
			if(Param.pSize[4]>0){
				this.midTxt	= this.setText(100,Param.pSize[2]+10,Param.pSize[5]+46, Param.pSize[4]+"*"+Param.pSize[5]+"像素", _txtFormat3);
				 addChild(this.midTxt);
			}
			// 小头像文本框
			if(Param.pSize[6]>0){
				this.smalltxt = this.setText(100,Param.pSize[2]+Param.pSize[4]+20,Param.pSize[5]+36, Param.pSize[6]+"*"+Param.pSize[7]+"像素", _txtFormat3);
				addChild(this.smalltxt);
			}
            return;
        }
		// 文本
        private function setText(_w:Number, _x:Number, _y:Number, _txt:String, _format:TextFormat) : TextField
        {
            if (_w == 66)
            {
                _format.leading = 4;
            }
            var newTxt = new TextField();
            new TextField().selectable = false;
            newTxt.mouseEnabled = false;
            newTxt.width = _w;
            newTxt.multiline = true;
            newTxt.wordWrap = true;
            newTxt.x = _x;
            newTxt.y = _y;
            newTxt.text = _txt;
            newTxt.setTextFormat(_format);
            return newTxt;
        }
		// 上传或载入成功后重置（大中小）预览框
        public function initAvatars(pic:BitmapData) : void
        {
            this.bigPic = new Bitmap(pic);
            this.setAvatarSize(this.bigPic, Param.pSize[2]);
			this.bigPic.x = 1;
			this.bigPic.y = 1;
			this.bigBox.addChild(this.bigPic);

			if(Param.pSize[4]>0){
            this.midPic = new Bitmap(pic);
            this.setAvatarSize(this.midPic, Param.pSize[4]);
			this.midPic.x = 1;
			this.midPic.y = 1;
			this.midBox.addChild(this.midPic);
			}
			if(Param.pSize[6]>0){
            this.smallPic = new Bitmap(pic);
            this.setAvatarSize(this.smallPic, Param.pSize[6]);
			this.smallPic.x = 1;
			this.smallPic.y = 1;
			this.smallBox.addChild(this.smallPic);
			}
            return;
        }
		// 更换头像
        public function changeAvatars(pic:BitmapData) : void
        {
            this.bigPic.bitmapData = pic;
			this.bigPic.smoothing = true;
			this.setAvatarSize(this.bigPic, Param.pSize[2]);

			if(Param.pSize[4]>0){
            this.midPic.bitmapData = pic;
			this.midPic.smoothing = true;
			this.setAvatarSize(this.midPic, Param.pSize[4]);
			}
			if(Param.pSize[6]>0){
            this.smallPic.bitmapData = pic;
			this.smallPic.smoothing = true;
            this.setAvatarSize(this.smallPic, Param.pSize[6]);
			}
            return;
        }
		// 按尺寸重置头像
        private function setAvatarSize(bmp:Bitmap, w:Number) : void
        {
            bmp.width = w;
            bmp.scaleY = bmp.scaleX;
            return;
        }


    }
}
