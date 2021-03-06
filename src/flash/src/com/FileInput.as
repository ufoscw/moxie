package com
{
	import com.events.FileInputEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.utils.Dictionary;
	
	import mxi.Utils;
	
	public class FileInput extends Sprite
	{
		public static var dispatches:Object = { // hash of events dispatched by this class
			"Cancel": FileInputEvent.CANCEL,
			"Change": FileInputEvent.SELECT,
			"MouseEnter": MouseEvent.ROLL_OVER,
			"MouseLeave": MouseEvent.ROLL_OUT,
			"MouseDown": MouseEvent.MOUSE_DOWN,
			"MouseUp": MouseEvent.MOUSE_UP
		}; 
						
		protected var _options:Object = {};
		
		protected var _disabled:Boolean = false;
		
		protected var _filters:Array = null;
		
		protected var _picker:*;
		
		protected var _files:Array = [];
		
		public function init(options:Object = null) : void {
			var button:Sprite;
			
			if (Moxie.stageOccupied) {
				return;	
			}
			Moxie.stageOccupied = true; // occupies runtime's stage
						
			_options = Utils.extend({
				name: 'Filedata',
				multiple: false,
				accept: null
			}, options);
						
			
			if (_options.accept !== null) {				
				_filters = [];
				
				for (var i:int = 0; i < _options.accept.length; i++) {
					_filters.push(new FileFilter(
						_options.accept[i].title,
						'*.' + _options.accept[i].extensions.replace(/,/g, ";*."),
						_options.accept.mac_types
					));
				}
			}	
						
			button = new Sprite;
						
			button.graphics.beginFill(0x000000, 0); // Fill with transparent color
			button.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			button.graphics.endFill();
			button.buttonMode = true;
			button.useHandCursor = true;
			
			button.addEventListener(MouseEvent.CLICK, onClick);
			button.addEventListener(MouseEvent.ROLL_OVER, onEvent);
			button.addEventListener(MouseEvent.ROLL_OUT, onEvent);
			button.addEventListener(MouseEvent.MOUSE_DOWN, onEvent);
			button.addEventListener(MouseEvent.MOUSE_UP, onEvent);
			
			addChild(button);
		}
		
		
		public function disable(disabled:Boolean = true) : void {
			_disabled = disabled;
		}
		
		
		public function destroy() : void {
			Moxie.stageOccupied = false;
		}
		
		
		private function onEvent(e:MouseEvent) : void {			
			e.stopPropagation();
						
			if (_disabled) {
				return;
			}
						
			dispatchEvent(e);
		}
		
		
		private function onClick(e:MouseEvent) : void {			
			if (_disabled) {
				return;
			}
						
			_picker = _options.multiple ? new FileReferenceList : new FileReference;
			
			_picker.addEventListener(Event.CANCEL, onDialogEvent);
			_picker.addEventListener(Event.SELECT, onDialogEvent);
			_picker.browse(_filters);
		}
		
		
		public function getFiles() : Array {
			var files:Array = [];
			
			for each (var file:File in _files) {
				Moxie.blobPile.add(file);
				files.push(file.toObject());
			}
			return files;
		}
	
		
		private function onDialogEvent(e:Event) : void {
			_picker.removeEventListener(Event.CANCEL, onDialogEvent);
			_picker.removeEventListener(Event.SELECT, onDialogEvent);
			
			switch (e.type) {
					
				case Event.CANCEL:
					dispatchEvent(new FileInputEvent(FileInputEvent.CANCEL));
					break;
				
				case Event.SELECT:
					var fileRefList:Array = [], bb:BlobBuilder, file:File;
					
					if (!_options.multiple) {
						fileRefList.push(_picker);
					} else {
						fileRefList = _picker.fileList;
					}
					
					_files = [];
					
					for (var i:uint = 0; i < fileRefList.length; i++) {
						bb = new BlobBuilder;
						bb.append(fileRefList[i]);
						_files.push(bb.getFile());
					}
																				
					dispatchEvent(new FileInputEvent(FileInputEvent.SELECT));
					break;
			}
			
			
		}
	}
}