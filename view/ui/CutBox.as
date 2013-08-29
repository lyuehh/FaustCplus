﻿package view.ui
{
    import flash.display.*;
    import view.*;

    public class CutBox extends Sprite
    {
		public var cutArea:Sprite;
        public var maskArea:Sprite;
		public var border:Sprite;
        public var flag:Flag;

        public function CutBox(_w:Number = 180, _h:Number = 180)
        {
            maskArea = new Sprite();
            cutArea = new Sprite();
            flag = new Flag();
			border = new Sprite();
			
			//选区边框
			border.graphics.lineStyle(1, 0, 0.2);
            border.graphics.beginFill(0, 0); 
            border.graphics.drawRect(0, 0, _w - 2, _h - 2);
			border.graphics.endFill();
			border.x = border.y = 1;
			
            maskArea.graphics.clear();
            maskArea.graphics.beginFill(0xFF);
            maskArea.graphics.drawRect(0, 0, _w, _h);
            maskArea.graphics.endFill();
            cutArea.graphics.clear();
            cutArea.graphics.beginFill(0, 0);
            cutArea.graphics.drawRect(0, 0, _w, _h);
            cutArea.graphics.endFill();
            flag.x = _w;
            flag.y = _h;
			
			addChild(border);
            addChild(maskArea);	// 遮罩层
            addChild(cutArea);		// 剪切区
            addChild(flag);		// 拖拽小方块
            return; //选区边框
        }

    }
}
