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
        public static var jsLang;
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
                "info10": "取消",
                "info11": "没有检测到摄像头",
                "info12": "1.检查电脑是否连接摄像头。\n2.检查摄像头是否被其他程序占用。\n3.检查是否拒绝了FlashPlayer的访问：鼠标右键->设置->允许。\n4.如果不是以上原因，请尝试刷新页面",
                "info13": "拍照"
            },
            "zh_tw": {
                "info1": "僅支持JPG、GIF、PNG圖片文件，且文件小於2M",
                "info2": "上傳本地圖片",
                "info3": "拍照上傳",
                "info4": "向左旋轉",
                "info5": "向右旋轉",
                "info6": "縮小",
                "info7": "放大",
                "info8": "預覽",
                "info9": "保存",
                "info10": "取消"
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
                "info10": "Cancel",
                "info11": "No Carema Found",
                "info12": "1.Check if the camera connected to the computer.\n2.Check if the camera is used by other program.\n3.Check if the FlashPlayer is forbid：Right Click->Setting->Allow.\n4.Or you can try to refresh the page",
                "info13": "Take"
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
