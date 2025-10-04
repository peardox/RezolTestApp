// GMEX 4CC end of buffer data marker
#macro MAGIC $474D4558

// For use by 
enum REZOL_DATA_BUFFER {
    SCREENINFOHEADER,
    SCREENINFO,
    PHYSICALSCREEN,
    WINDOWCHROME
};

function rezol_box(_width, _height) constructor {
	self.width = _width;
	self.height = _height;
	
	static aspect = function() {
		if((self.height) == 0) {
			throw("Zero height window");
		}
		return (self.width) / real(self.height);
	}
}

function rezol_screenrect(_left, _top, _right, _bottom) constructor {
	self.left := _left;
	self.top := _top;
	self.right := _right;
	self.bottom := _bottom;
	
	static width = function() {
		return real(self.right - self.left);
	}
	
	static height = function() {
		return real(self.bottom - self.top);
	}
	
	static aspect = function() {
		if((self.bottom - self.top) == 0) {
			throw("Zero height window");
		}
		return (self.right - self.left) / real(self.bottom - self.top);
	}
}

function rezol_physical(_width, _height, _diagonal) : rezol_box(_width, _height) constructor {
	self.diagonal = _diagonal;

	// Diagonal screen size in inches
	static size = function() {
		return self.diagonal / 25.4;
	}
}

function rezol_screen() constructor {
	self.error    = 0;
	self.refresh  = 0;
	self.primary  = false;
	self.virtual  = undefined;
	self.working  = undefined;
	self.box      = undefined;
	self.physical = undefined;
	self.desc     = "";
	
	static set_description = function(_name) {
		self.desc    = _name;
	}
	
	static set_error = function(_error) {
		self.error    = _error;
	}
	
	static set_refresh = function(_refresh) {
		self.refresh  = _refresh;
	}
	
	static set_primary = function(_primary) {
		self.primary  = _primary;
	}

	static add_virtual = function(_left, _top, _right, _bottom) {
		self.virtual = new rezol_screenrect(_left, _top, _right, _bottom);
	}
	
	static add_working = function(_left, _top, _right, _bottom) {
		self.working = new rezol_screenrect(_left, _top, _right, _bottom);
	}
	
	static add_box = function(_width, _height) {
		self.box = new rezol_box(_width, _height);
	}
	
	static add_physical = function(_width, _height, _diagonal) {
		self.physical = new rezol_physical(_width, _height, _diagonal);
	}
	
	// DPI X
	static ppix = function() {
		return (self.virtual.width() / real(self.physical.width)) * 25.4;
	}

	// DPI Y	
	static ppiy = function() {
		return (self.virtual.height() / real(self.physical.height)) * 25.4;
	}

	// DPI
	static ppi = function() {
		return (self.ppix() + self.ppiy()) / 2.0;
	}

	static is_primary = function() {
		if(primary) {
			return true;
		} else {
			return false;
		}
	}
	
}

function window_chrome() constructor {
	self.virtual  = undefined;
	self.working  = undefined;

	static add_virtual = function(_left, _top, _right, _bottom) {
		self.virtual = new rezol_screenrect(_left, _top, _right, _bottom);
	}
	
	static add_working = function(_left, _top, _right, _bottom) {
		self.working = new rezol_screenrect(_left, _top, _right, _bottom);
	}
	
	// The actual chrome height is the difference between virtual and working
	// minus the border (from width) which results in caption height
	static height = function() {
		return (self.virtual.height() - self.working.height() - self.width());
	}
	
	// The actual chrome width is 1/2 the difference between virtual and working
	// as this results in the border width being returned which is a meaningful figure
	static width = function() {
		return (self.virtual.width() - self.working.width()) / 2.0;
	}
	
	static overlap = function(_target) {
	    // Compute horizontal overlap
	    var overlap_w = max(0,
	        min(self.virtual.right, _target.virtual.right)
	      - max(self.virtual.left, _target.virtual.left)
	    );
    
	    // Compute vertical overlap
	    var overlap_h = max(0,
	        min(self.virtual.bottom, _target.virtual.bottom)
	      - max(self.virtual.top, _target.virtual.top)
	    );
    
	    // Area is width * height
	    return overlap_w * overlap_h;
	}
	
	static on_screen = function(_screens) {
		var _scount = array_length(_screens);
		var _overlaps = array_create(_scount);
		for(var _i = 0; _i < _scount; _i++) {
			_overlaps[_i] = self.overlap(_screens[_i]);
		}
		var _scr = -1;
		var _largest = 0;
		for(var _i = 0; _i < _scount; _i++) {
			if(_overlaps[_i] > _largest) {
				_scr = _i;
				_largest = _overlaps[_i];
			}
		}
	return _scr;
	}
	
}

function rezol_screen_info() constructor {
	self.screen = [];
	self.count = 0;
	self.active = -1;
		
	static add_screen = function() {
		var _screen = new rezol_screen();
		var _screen_index = self.count;
		array_resize(self.screen, _screen_index + 1);
		self.screen[_screen_index] = _screen;
		self.count++;
		return _screen;
	}
	
	static get_primary = function() {
		var _res = -1;
		
		for(var _i = 0; _i < self.count; _i++) {
			if(screen[_i].primary) {
				_res = _i;
				break;
			}
		}
		
		return _res;
	}
	
	static activate = function(_which) {
		if((_which >= 0) && (_which < self.count)) {
			self.active = _which;
		}
	}
	static start = function() {
		var _p = self.get_primary();
		if(_p != -1) {
			self.activate(_p);
		}
	}

	static SwitchTo = function(_which) {
		if((_which >= 0) && (_which < array_length(RezolScreens.screen))) {
			self.active = _which;
			var _scr = get_chrome();
			window_set_rectangle(
				self.screen[self.active].virtual.left + _scr.height() + ((self.screen[self.active].virtual.width() - _scr.virtual.width()) / 2) ,
				self.screen[self.active].virtual.top + ((self.screen[self.active].virtual.height() - _scr.virtual.height()) / 2),
				room_width,
				room_height
				);
			
		}
	}

}

function read_screen_data() {
	var _inf = false;
	var _screen_info_buf_size = rezol_ext_get_buffer_size(REZOL_DATA_BUFFER.SCREENINFO);
	var _screen_info_header_size = rezol_ext_get_buffer_size(REZOL_DATA_BUFFER.SCREENINFOHEADER);
	var _screen_info_physical_size = rezol_ext_get_buffer_size(REZOL_DATA_BUFFER.PHYSICALSCREEN);
	if(_screen_info_buf_size > 0) {
		var _buf = buffer_create(_screen_info_buf_size, buffer_fixed, 1);
		try {
			if(rezol_ext_get_screen_info(string(buffer_get_address(_buf))) == 0) {
				if(buffer_peek(_buf, _screen_info_buf_size - 4, buffer_u32) != MAGIC) {
					throw("Magic didn't match");
				}  else {
					// Process buffer
					var _count        = buffer_read(_buf, buffer_s32);
					var _macCount     = buffer_read(_buf, buffer_s32);
					var _fromScreen   = buffer_read(_buf, buffer_s32);
					var _pageNum      = buffer_read(_buf, buffer_s32);
					var _autoHide     = buffer_read(_buf, buffer_s32);
					var _haveMore     = buffer_read(_buf, buffer_u8);
					var _versionMajor = buffer_read(_buf, buffer_u8);
					var _versionMinor = buffer_read(_buf, buffer_u8);
					var _versionBuild = buffer_read(_buf, buffer_u8);
					var _bpos = buffer_tell(_buf);
					if(_bpos != _screen_info_header_size) {
						throw("Wrong buffer position");
					} else {
						var _a1, _a2, _a3, _a4;
						_inf = new rezol_screen_info();
						for(var _i = 0; _i < _count; _i++) {
							buffer_seek(_buf, buffer_seek_start, _screen_info_header_size + (_screen_info_physical_size * _i));
							var _scr = _inf.add_screen();
							_scr.set_error(buffer_read(_buf, buffer_s32));
							_scr.set_refresh(buffer_read(_buf, buffer_s32));
							_scr.set_primary(buffer_read(_buf, buffer_s32));
							_a1 = buffer_read(_buf, buffer_s32);
							_a2 = buffer_read(_buf, buffer_s32);
							_scr.add_box(_a1, _a2);
							_a1 = buffer_read(_buf, buffer_s32);
							_a2 = buffer_read(_buf, buffer_s32);
							_a3 = buffer_read(_buf, buffer_s32);
							_a4 = buffer_read(_buf, buffer_s32);
							_scr.add_virtual(_a1, _a2, _a3, _a4);
							_a1 = buffer_read(_buf, buffer_s32);
							_a2 = buffer_read(_buf, buffer_s32);
							_a3 = buffer_read(_buf, buffer_s32);
							_a4 = buffer_read(_buf, buffer_s32);
							_scr.add_working(_a1, _a2, _a3, _a4);
							_a1 = buffer_read(_buf, buffer_s32);
							_a2 = buffer_read(_buf, buffer_s32);
							_a3 = buffer_read(_buf, buffer_s32);
							_scr.add_physical(_a1, _a2, _a3);
							_scr.set_description(buffer_read(_buf, buffer_string));
						}
					}
				}
			} else {
				throw("DLL call didn't work");
			}
		} finally {
			buffer_delete(_buf);
			if(_inf) {
				_inf.start();
			}
		}
	}
	return _inf;
}
// show_debug_message(string(_hwnd));

function get_chrome() {
	var _ret = false;
	var _screen_chrome_buf_size = rezol_ext_get_buffer_size(REZOL_DATA_BUFFER.WINDOWCHROME);
	if(_screen_chrome_buf_size > 0) {
		var _buf = buffer_create(_screen_chrome_buf_size, buffer_fixed, 1);
		try {
			var _rv = rezol_ext_get_window_chrome(string(buffer_get_address(_buf)), string(window_handle()));
			if(_rv == 0) {
				if(buffer_peek(_buf, _screen_chrome_buf_size - 4, buffer_u32) != MAGIC) {
					throw("Magic didn't match");
				}  else {
					var _a1, _a2, _a3, _a4;
					_ret = new window_chrome();
					_a1 = buffer_read(_buf, buffer_s32);
					_a2 = buffer_read(_buf, buffer_s32);
					_a3 = buffer_read(_buf, buffer_s32);
					_a4 = buffer_read(_buf, buffer_s32);
					_ret.add_virtual(_a1, _a2, _a3, _a4);
					_a1 = buffer_read(_buf, buffer_s32);
					_a2 = buffer_read(_buf, buffer_s32);
					_a3 = buffer_read(_buf, buffer_s32);
					_a4 = buffer_read(_buf, buffer_s32);
					_ret.add_working(_a1, _a2, _a3, _a4);
				}
			} else {
				throw("DLL call didn't work");
			}
		} finally {
			buffer_delete(_buf);
        }
	}
  return _ret;				
}