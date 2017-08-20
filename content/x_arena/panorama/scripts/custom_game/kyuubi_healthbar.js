var damageRadiant = $( "#DamageRadiant" );
var damageDire = $( "#DamageDire" );
var kyuubiHealthContainer = $( "#KyuubiHealthContainer" );

function DisplayHealthbar() {
	kyuubiHealthContainer.style.visibility = 'visible';
}

function UpdateHealth( info ) {
	damageRadiant.style['width'] = info.radiant;
	damageDire.style['width'] = info.dire;
}

(function () {
  GameEvents.Subscribe( "display_healthbar", DisplayHealthbar );
  GameEvents.Subscribe( "update_healthbar", UpdateHealth );
})();