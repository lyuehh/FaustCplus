﻿package view.browse
{
    import com.adobe.serialization.json.*;
    import flash.display.*;
    import flash.events.*;
    import flash.external.*;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;
    import model.*;
    import view.*;
    import fl.controls.Button;

	/**
	* 本地上传图片
	*/
    public class BrowseComp extends Sprite
    {
        public var btnBrowse;//:MovieClip;
        private var _parent:CutView;
        private var _avatarModel:AvatarModel;
        private var _imgFilter:FileFilter;
        private var Version:String;
        public var label:TextField;
        private var _picLoader:Loader;
        private var _fileRef:FileReference;

        public function BrowseComp(param1:AvatarModel) : void
        {
            this.init(param1);
            this.addEventListener(Event.ADDED_TO_STAGE, this.onStage);
            return;
        }
		private function init(param1:AvatarModel) : void
        {
            var cutModel = param1;
            var labelFormat = new TextFormat("宋体,Arial,Helvetica", 12, 10066329);
            this.label = new TextField();
            with (this.label)
            {
                selectable = false;
                width = 270;
                height = 24;
                x = 0;
                y = 38;
                defaultTextFormat = labelFormat;
                text = "仅支持JPG、GIF、PNG图片文件，且文件小于2M";
            }
            addChild(this.label);
            //this.btnBrowse = new SK_Browse() as MovieClip;
            this.btnBrowse = new Button();
            this.btnBrowse.label = '上传本地图片';
            this.btnBrowse.width = 80;
            this.btnBrowse.buttonMode = true;
            this.btnBrowsAddEvents();
            this._avatarModel = cutModel;
            this._fileRef = new FileReference();
            this._imgFilter = new FileFilter("Image Files (*.jpg, *.gif, *.jpeg, .*.png)", "*.jpg; *.gif; *.jpeg; *.png");
            addChild(this.btnBrowse);

			/*
			ExternalInterface.available
			属性指示当前的 Flash Player 是否位于提供外部接口的容器中。如果外部接口可用，则此属性为 true；否则，为 false。
			简单的说：嵌入这个flash的浏览器,支持flash交互就是true,不支持就是false
			*/
            if (ExternalInterface.available)
            {
                ExternalInterface.addCallback("setTicket", Param.setTicket);
            }
            Param.getTicket();
            return;
        }

        private function startPhotoCut(event:DataEvent) : void
        {
            var evt = event;
            this._fileRef.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, this.startPhotoCut);
            this._fileRef.removeEventListener(IOErrorEvent.IO_ERROR, this.upTmpPhotoError);
            this._fileRef.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.upTmpPhotoError);
            var jsons = JSON.decode(evt["data"]);
            if (jsons["status"] == "1")
            {
                if (jsons["url"])
                {
                    Param.tmpImgUrl = jsons["url"];
                }
                this.loadTempPic(Param.tmpImgUrl + "?" + new Date().getTime());
            }
            else
            {
                try
                {
                    ExternalInterface.call(Param.jsFunc, jsons["status"]);
                }
                catch (e:Error)
                {
                }
                return;
            }
            return;
        }
		// 切换状态
        private function changeStatus(event:MouseEvent) : void
        {
            if (event.type == MouseEvent.MOUSE_OVER)
            {
                //this.btnBrowse.gotoAndStop(2);
            }
            else
            {
                //this.btnBrowse.gotoAndStop(1);
            }
            return;
        }



        private function refPicOK(event:Event) : void
        {
            this._picLoader = new Loader();
            this._picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.passImgToModel);
            this._picLoader.loadBytes(this._fileRef.data);
            return;
        }

        private function loadTempPic(param1:String) : void
        {
            var _loc_2 = new URLRequest(param1);
            var _loc_3 = new Loader();
            var _loc_4 = new LoaderContext(true);
            _loc_3.contentLoaderInfo.addEventListener(Event.COMPLETE, this.passImgToModel);
            _loc_3.load(_loc_2, _loc_4);
            return;
        }

        private function upTmpPhotoError(event:IOErrorEvent) : void
        {
            this._fileRef.removeEventListener(IOErrorEvent.IO_ERROR, this.upTmpPhotoError);
            return;
        }

        public function btnBrowsAddEvents() : void
        {
            this.btnBrowse.addEventListener(MouseEvent.CLICK, this.selectLocalPic);
            this.btnBrowse.addEventListener(MouseEvent.MOUSE_OVER, this.changeStatus);
            this.btnBrowse.addEventListener(MouseEvent.MOUSE_OUT, this.changeStatus);
            return;
        }

        public function btnBrowsRemoveEvents() : void
        {
            this.btnBrowse.removeEventListener(MouseEvent.MOUSE_OUT, this.changeStatus);
            this.btnBrowse.removeEventListener(MouseEvent.MOUSE_OVER, this.changeStatus);
            //this.btnBrowse.gotoAndStop(3);
            return;
        }

        private function uploadFile() : void
        {
            var urlrequest:URLRequest;
            if (this.getFile())
            {
                urlrequest = new URLRequest(Param.uploadUrl + "?action=uploadtmp&" + new Date().getTime());
                Param.ticket.shift();
                Param.getTicket();
                try
                {
                    this._fileRef.upload(urlrequest);
                }
                catch (e:Error)
                {
                }
                this._fileRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, this.startPhotoCut);
                this._fileRef.addEventListener(IOErrorEvent.IO_ERROR, this.upTmpPhotoError);
                this._fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.upTmpPhotoError);
            }
            return;
        }

        private function onStage(event:Event) : void
        {
            this.removeEventListener(Event.ADDED_TO_STAGE, this.onStage);
            var _loc_2 = this.root as Main;
            this.Version = _loc_2.Version;
            this._parent = this.parent as CutView;
            return;
        }

        private function passImgToModel(event:Event) : void
        {
            var _loc_2 = event.target as LoaderInfo;
            _loc_2.removeEventListener(Event.COMPLETE, this.passImgToModel);
            var _loc_3 = _loc_2.content as Bitmap;
            this._avatarModel.bmd = _loc_3.bitmapData;
            this._avatarModel.type = 2;
            _loc_2.loader.unload();
            return;
        }

        private function getFile() : Boolean
        {
            if (this._fileRef.size > 5242880)
            {
                try
                {
                    ExternalInterface.call(Param.jsFunc, "M01108");
                }
                catch (e:Error)
                {
                }
                return false;
            }
            if (!/.+\.(jpg|png|gif|jpeg)$/i.test(this._fileRef.name))
            {
                try
                {
                    ExternalInterface.call(Param.jsFunc, "M01107");
                }
                catch (e:Error)
                {
                }
                return false;
            }
            return true;
        }

        private function onFileSelected(event:Event) : void
        {
            this._fileRef.removeEventListener(Event.SELECT, this.onFileSelected);
            this._fileRef.removeEventListener(Event.CANCEL, this.onCancel);
            switch(this.Version)
            {
				case "12":
				case "11":
                case "10":
                    this._fileRef.load();
                    this._fileRef.addEventListener(Event.COMPLETE, this.refPicOK);
                    break;
                case "9":
                    this._parent.localPicArea.loaddingUI.visible = true;
                    this._parent.localPicArea.loaddingUI.play();
                    if (this._parent.localPicArea.tip != null)
                    {
                        this._parent.localPicArea.tip.visible = false;
                    }
                    this.uploadFile();
                    break;
					
                default:
                    break;
            }
            return;
        }

        private function onCancel(event:Event) : void
        {
            this._fileRef.removeEventListener(Event.CANCEL, this.onCancel);
            return;
        }

        private function selectLocalPic(event:MouseEvent) : void
        {
            this.btnBrowsRemoveEvents();
            if (this._parent.localPicArea.visible == false)
            {
				with(this._parent){
                	localPicArea.visible = true;
                	avatarArea.visible = true;
                	splitLines.visible = true;
					colorAdj.visible = true;
                	cameraArea.visible = false;
					if (saveBtn != null){
						cancleBtn.visible = true;
						saveBtn.visible = true;
					}
					cameraBtn.mouseEnabled = true;
					cameraBtnAddEvents();
				}
				this._parent.localPicArea.setLocalPicSize(this._avatarModel.bmd);
                this.label.visible = true;
				//stop();
            }
           // this._parent.cameraBtn.gotoAndStop(1);
            this._fileRef.browse([this._imgFilter]);
            this._fileRef.addEventListener(Event.SELECT, this.onFileSelected);
            this._fileRef.addEventListener(Event.CANCEL, this.onCancel);
            return;
        }

    }
}
