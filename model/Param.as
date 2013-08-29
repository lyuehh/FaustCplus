﻿package model
{
    import flash.external.*;
    import flash.utils.*;

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
                    Param.language["CX0189"] = _loc_1["CX0189"];
                    Param.language["CX0193"] = _loc_1["CX0193"];
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
