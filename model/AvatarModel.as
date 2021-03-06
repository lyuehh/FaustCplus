﻿package model
{
    import events.*;
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;

    public class AvatarModel extends EventDispatcher
    {
        private var _type:int = 2;
        private var _bmd:BitmapData;

        public function AvatarModel()
        {
            return;
        }
        public function set bmd(bmd:BitmapData) : void
        {
            this._bmd = bmd;
            this.dispatchEvent(new UploadEvent(UploadEvent.IMAGE_CHANGE));
            return;
        }
        public function set initBmd(bmd:BitmapData) : void
        {
            this._bmd = bmd;
            this.dispatchEvent(new UploadEvent(UploadEvent.IMAGE_INIT));
            return;
        }
		/**
		* 加载初始头像
		* @param   url
		*/
		public function loaderPic(url:String):void
		{
			var picReq:URLRequest = new URLRequest(url);
			var picLoader:Loader = new Loader();
			var lc:LoaderContext = new LoaderContext(true);
			picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, initPicHandler);
			picLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, initPicHandler);
			picLoader.load(picReq,lc);
		}
		/**
		* 初始头像加载完成
		* @param   evt
		*/
		private function initPicHandler(evt:Event):void
		{
			var tgt:LoaderInfo = evt.target as LoaderInfo;
			tgt.removeEventListener(Event.COMPLETE, initPicHandler);
			tgt.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, initBMD);
			loader.loadBytes(tgt.bytes);
		}
		private function errorHandler(event:IOErrorEvent) : void
        {
            trace(event);
            return;
        }
		/**
		* 得到初始头像的 BitmapData
		* @param   evt
		*/
		private function initBMD(evt:Event):void
		{
			var tgt:LoaderInfo = evt.target as LoaderInfo;
			tgt.removeEventListener(Event.COMPLETE, initBMD);
			var loader:Loader = tgt.loader as Loader;
			var bmd:BitmapData = new BitmapData(loader.width, loader.height);
			bmd.draw(loader);
			this.initBmd = bmd;
			loader.unload();
			return;
		}

        public function get bmd() : BitmapData
        {
            return this._bmd;
        }
		public function get type() : int
        {
            return this._type;
        }
        public function set type(_type:int) : void
        {
            this._type = _type;
            return;
        }

    }
}
