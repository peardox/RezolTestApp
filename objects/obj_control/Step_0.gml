if(keyboard_check(vk_escape)) {
   game_end();
}

if(RezolScreens) {
	if(keyboard_check_released(vk_f2)) {
	    playscn++;
	    if(playscn >= array_length(RezolScreens.screen)) {
	        playscn = 0;
	    }
	    RezolScreens.SwitchTo(playscn);
	}
}