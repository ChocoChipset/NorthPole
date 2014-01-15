function abbreviationForDirection(direction)
{
    if (direction < 0.0)
    {
    	return "NA";
    }

    var allAbbreviations = ["N", "NW", "W", "SW", "S", "SE", "E", "NE"];

    var widthForPointInDegrees = 360.0 / allAbbreviations.length;

    direction = direction + (360 + (widthForPointInDegrees / 2.0));
	                    	    	                                
    direction = direction % 360;
	                    	    	                                        
    var position = direction / widthForPointInDegrees;
	                    	    	                                                
    return allAbbreviations[position];
}


function getCurrentPosition()
{
    window.navigator.geolocation.getCurrentPosition(locationSuccess, locationError, locationOptions);
}

function locationSuccess(pos) {
	var coordinates = pos.coords;
    
    var directionKey = abbreviationForDirection(coordinates.heading);

	Pebble.sendAppMessage({
		"altitude":Math.round(coordinates.altitude).toString()+"m",
        "direction":directionKey,
        "directionDegrees":Math.round(coordinates.heading).toString()+"º"
    });
}

function locationError(err) {
	Pebble.sendAppMessage({
		"altitude":"0.0",
		"direction":"NA",
		"directionDegrees":"0.0º"
    });
}

var locationOptions = { "timeout": 15000, "maximumAge": 60000 };

Pebble.addEventListener("ready",
    function(e) {
        locationWatcher = window.navigator.geolocation.watchPosition(locationSuccess, locationError, locationOptions);
  	    console.log("JavaScript app ready and running!");
  }
 );
