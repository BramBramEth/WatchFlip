using Toybox.WatchUi;

class CryptoWatchView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onUpdate(dc) {
    	var prices = Application.getApp().getProperty("apiResponse");
    	if (prices != null) {
	    	var btc = prices[0]["quote"]["USD"];
		   	var eth = prices[1]["quote"]["USD"];
	   	
	   		// Draw Ratio
	   		var ratio = View.findDrawableById("ratio");
		    ratio.setColor(0x4EE2EC);
		    ratio.setText((eth["price"] / btc["price"]).format("%.5f"));
		}
        View.onUpdate(dc);
    }
 
}