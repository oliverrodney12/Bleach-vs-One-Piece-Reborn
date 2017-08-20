var shop = $( "#ButtonPanel" );

function OnBuyItem( item, amount ) {
	var iPlayerID = Players.GetLocalPlayer();
	GameEvents.SendCustomGameEventToServer( "buy_custom_item", { pID: iPlayerID, item: item, amount: amount })
}

function OnEnter( data ) {
	shop.style.visibility = 'visible';
}

function OnLeave( data ) {
	shop.style.visibility = 'collapse';
}

(function () {
  GameEvents.Subscribe( "display_shop", OnEnter );
  GameEvents.Subscribe( "close_shop", OnLeave );
})();