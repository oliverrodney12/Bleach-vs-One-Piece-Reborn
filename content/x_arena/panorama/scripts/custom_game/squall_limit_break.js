var limitBreakBox = $( "#LimitBreakBox" );
var limitBreaker = $( "#LimitBreak" );

function DisplayLimitBreak() {
	limitBreakBox.style.visibility = 'visible';
}

function HideLimitBreak() {
	limitBreakBox.style.visibility = 'collapse';
}

function MoveTimer( info ) {
	limitBreaker.style['margin-left'] = info.pos;
}

(function () {
  GameEvents.Subscribe( "move_timer", MoveTimer );
  GameEvents.Subscribe( "display_limit_break", DisplayLimitBreak );
  GameEvents.Subscribe( "hide_limit_break", HideLimitBreak );
})();