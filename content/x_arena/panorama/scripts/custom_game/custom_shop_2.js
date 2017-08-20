var shop = $( "#ButtonPanel" );
var secret = $( "#Item_secret" );

function OnBuyItem( item ) {
	var iPlayerID = Players.GetLocalPlayer();
	GameEvents.SendCustomGameEventToServer( "buy_custom_item_2", { pID: iPlayerID, item: item })
}

function OnEnter2( data ) {
	shop.style.visibility = 'visible';
}

function OnLeave2( data ) {
	shop.style.visibility = 'collapse';
}

function Unlock() {
	secret.style.visibility = 'visible';
}

(function () {
  GameEvents.Subscribe( "display_shop_2", OnEnter2 );
  GameEvents.Subscribe( "close_shop_2", OnLeave2 );
  GameEvents.Subscribe( "unlock_secret", Unlock );
})();