﻿package view.ui
{
    import flash.display.*;

    public class Flag extends Sprite
    {
        private var _height:Number;
        private var _width:Number;

        public function Flag(_w:Number = 6, _h:Number = 6)
        {
            this._width = _w;
            this._height = _h;
            this.init();
            return;
        }

        private function init() : void
        {
            ++this._width;
            var _loc_1 = (-++this._width) * 0.5;
            ++this._height;
            var _loc_2 = (-++this._height) * 0.5;
            this.graphics.lineStyle(1, 15658734);
            this.graphics.beginFill(3355443, 0.5);
            this.graphics.drawRect(_loc_1, _loc_2, this._width, this._height);
            this.graphics.endFill();
            return;
        }

    }
}
