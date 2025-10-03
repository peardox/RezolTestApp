if(RezolScreens) {
	draw_text(16, 16, "Hi There : We are on screen " + string(RezolScreens.active + 1) + " of " + string(RezolScreens.count));
	
	var _s = RezolScreens.screen[RezolScreens.active];
	
	draw_text(16, 48, "This screen is a " + _s.desc + " and is "+ string(_s.box.width) + " wide and " + string(_s.box.height) + " tall with an aspect ratio of " + string(_s.box.aspect()) + " and a refresh rate of " + string(_s.refresh));
	draw_text(16, 64, "It is " + string(_s.physical.size()) + "\" diagonally with " + string(_s.ppi()) + " PPI : " +  + string(_s.ppix()) + "/" + string(_s.ppiy()) + " Pixels Per Inch (X/Y)");
	draw_text(16, 80, "The whole screen is " + string(_s.virtual.width()) + " wide and " + string(_s.virtual.height()) + " tall with an origin at ( " +  string(_s.virtual.left) + ", " + string(_s.virtual.top) + ")");
	draw_text(16, 96, "The screen has a working area of " + string(_s.working.width()) + " wide and " + string(_s.working.height()) + " tall with an origin at ( " +  string(_s.working.left) + ", " + string(_s.working.top) + ")");

    var _chrome = get_chrome();
	if(_chrome) {
		draw_text(16, 120, "The game window is  " + string(_chrome.virtual.width()) + " wide and " + string(_chrome.virtual.height()) + " tall with an origin at ( " +  string(_chrome.virtual.left) + ", " + string(_chrome.virtual.top) + ")");
		draw_text(16, 136, "The game content is " + string(_chrome.working.width()) + " wide and " + string(_chrome.working.height()) + " tall with an origin at ( " +  string(_chrome.working.left) + ", " + string(_chrome.working.top) + ")");
		
		var _onscr = _chrome.on_screen(RezolScreens.screen);
		if(_onscr >= 0) {
			if(RezolScreens.active != _onscr) {
				RezolScreens.active = _onscr;
			}
			draw_text(16, 168, "On Screen " + string(_onscr + 1));
		
			for(var _i = 0; _i < array_length(RezolScreens.screen); _i++) {
				draw_text(16, 190 + (_i * 16), "Screen" + string(_i+1) + " : " + string(RezolScreens.screen[_i].virtual));
			}
		}
	}
}
