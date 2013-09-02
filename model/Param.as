package model
{
    import flash.external.*;
    import flash.utils.*;
    import FileLog;

    public class Param extends Object
    {
        public static var ticket:Array = new Array();
        public static var uid:String;
        public static var uploadUrl:String;
        public static var tmpImgUrl:String;
        public static var imgUrl:String;
        public static var jsFunc:String;
        public static var s:Object;
		
		public static var uploadSrc:Boolean;
		public static var showBrow:Boolean;
		public static var showCame:Boolean;

        public static var ticketTime:Number;
        public static var language:Object;
        public static var lang:Object;
        public static var langObj:Object = {
            "zh_cn": {
                "info1": "仅支持JPG、GIF、PNG图片文件，且文件小于2M",
                "info2": "上传本地图片",
                "info3": "拍照上传",
                "info4": "向左旋转",
                "info5": "向右旋转",
                "info6": "缩小",
                "info7": "放大",
                "info8": "预览",
                "info9": "保存",
                "info10": "取消"
            },
            "zh_tw": {

            },
            "en_us": {
                "info1": "Select JPG, GIF, PNG file, and < 2M",
                "info2": "Choose",
                "info3": "Take Photo",
                "info4": "Turn Left",
                "info5": "Turn Right",
                "info6": "Zoom In",
                "info7": "Zoom Out",
                "info8": "Preview",
                "info9": "Save",
                "info10": "Cancel"
            }
        };
        FileLog.trace(langObj);
        

        public function Param() : void
        {
            return;
        }

        public static function clearTicket() : void
        {
            var _loc_1 = new Array();
            var _loc_2:int = 0;
            while (_loc_2 < Param.ticket.length)
            {

                if (new Date().getTime() - Param.ticket[_loc_2][1] < 540000)
                {
                    _loc_1.push(Param.ticket[_loc_2]);
                }
                _loc_2++;
            }
            Param.ticket = _loc_1;
            return;
        }

        public static function initLanguage() : void
        {
            var _loc_1:Object = null;
            Param.language = {};
            if (ExternalInterface.available)
            {
                _loc_1 = ExternalInterface.call(Param.jsLang);
                if (_loc_1 != null)
                {
                    _loc_1 = null;
                }
            }
            return;
        }

        public static function getTicket() : void
        {
            clearTimeout(Param.ticketTime);
            Param.clearTicket();
            if (Param.ticket)
            {
                if (Param.ticket.length < 2)
                {
                    if (ExternalInterface.available)
                    {
                        ExternalInterface.call("App.requestTicket", 4);
                    }
                }
            }
            else if (ExternalInterface.available)
            {
                ExternalInterface.call("App.requestTicket", 4);
            }
            return;
        }

        public static function setTicket(param1:Array) : void
        {
            var _j = param1;
            if (_j.length == 0)
            {
                Param.getTicket();
                return;
            }
            var i:int;
            while (i < _j.length)
            {

                Param.ticket.push(_j[i]);
                i = (i + 1);
            }
            Param.ticketTime = setTimeout(function () : void
            {
                Param.getTicket();
                return;
            }
            , 540000);
            return;
        }

    }
}
