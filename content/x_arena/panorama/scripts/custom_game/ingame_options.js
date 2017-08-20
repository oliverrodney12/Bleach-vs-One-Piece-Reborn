var voice_on = false
var toggle_voice = $( "#ToggleVoice" );

function VoiceToggle() {
	voice_on = !voice_on
	var iPlayerID = Players.GetLocalPlayer();
	GameEvents.SendCustomGameEventToServer( "toggle_voice", { pID: iPlayerID, voice: voice_on })
	if (voice_on) {
		toggle_voice.style['wash-color'] = "#00ff00"
	}
	else {
		toggle_voice.style['wash-color'] = "#ff0000"
	}
}

(function () {
  //GameEvents.Subscribe( "display_shop", OnEnter );
  //GameEvents.Subscribe( "close_shop", OnLeave );
})();