using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:glance)
class CryptoWatchGlance extends WatchUi.GlanceView {

	var lastRequest = null;

    function initialize() {
        GlanceView.initialize();   	       
    }
    
    function onUpdate(dc) {
    	// Clear screen
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
   		dc.clear();
   		
   		// Make request
   		var oneMinuteAgo = Time.now().subtract(new Time.Duration(Gregorian.SECONDS_PER_MINUTE));
   		if (lastRequest == null || lastRequest.lessThan(oneMinuteAgo)) {
   			lastRequest = Time.now();
   			makeRequest();
   		}
   		
   		// Handle Error in the UI
   		var error = Application.getApp().getProperty("errorResponse");
   		if(error != null){
   			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(15, 15, Graphics.FONT_TINY, "Error " + error, Graphics.TEXT_JUSTIFY_LEFT);
			return;
   		}
   		
   		updateView(Application.getApp().getProperty("apiResponse"), dc);
    }
    
    function updateView(prices, dc){
    	 if (prices != null){
    		var btc = prices[0]["quote"]["USD"];
	   		var eth = prices[1]["quote"]["USD"];
		    var eth_price = View.findDrawableById("eth_price");
		    
		    // Draw Ratio
		    dc.setColor(0x4EE2EC, Graphics.COLOR_TRANSPARENT);
		    dc.drawText(15, 1, Graphics.FONT_XTINY, "Ratio " + (eth["price"] / btc["price"]).format("%.5f"), Graphics.TEXT_JUSTIFY_LEFT);
		    
		    // Draw ETH Price
		    dc.setColor(getColor(eth), Graphics.COLOR_TRANSPARENT);
		    dc.drawText(15, 21, Graphics.FONT_XTINY, "ETH " + generateText(eth), Graphics.TEXT_JUSTIFY_LEFT);
		    
		    // Draw BTC Price
		    dc.setColor(getColor(btc), Graphics.COLOR_TRANSPARENT);
		    dc.drawText(15, 41, Graphics.FONT_XTINY, "BTC " + generateText(btc), Graphics.TEXT_JUSTIFY_LEFT);
		} else {
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(15, 15, Graphics.FONT_TINY, "Loading...", Graphics.TEXT_JUSTIFY_LEFT);
		}
    }
    
    function onReceive(responseCode, data) {
	   	if (responseCode != 200) {
	   		Application.getApp().setProperty("errorResponse", responseCode);
	   		return;
	   	}
		Application.getApp().setProperty("errorResponse", null);
	   	Application.getApp().setProperty("apiResponse", data["data"]);
	    WatchUi.requestUpdate();
    }
    
    function makeRequest() {
       var url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest";                         
       var params = { "start" => 1, "limit" => 2, "convert" => "USD", "CMC_PRO_API_KEY" => "fe4e4160-8052-4500-b8d2-2add261aa758"};
       var options = {
           :method => Communications.HTTP_REQUEST_METHOD_GET,
           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
       };
       Communications.makeWebRequest(url, params, options, method(:onReceive));
    }
    
    function generateText(data){
    	 return data["price"].format("%02d") + "$ (" +  data["percent_change_24h"].format("%.2f") + "%)";
    }
    
    function getColor(data){
    	 return data["percent_change_24h"] >= 0 ? 0x00FF00 : 0xFF0000;
    }
}