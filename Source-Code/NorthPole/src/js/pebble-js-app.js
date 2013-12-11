
function locationSuccess(pos) {
	var coordinates = pos.coords;



	Pebble.sendAppMessage({
		"altitude":coordinates.altitude,
        "direction":"NA",
        "directionDegrees":coordinates.heading
    });
}

function locationError(err) {
	Pebble.sendAppMessage({
		"altitude":0.0,
		"direction":"NA"
		"directionDegrees":0.0
    });
}

var locationOptions = { "timeout": 15000, "maximumAge": 60000 };

Pebble.addEventListener("ready",
    function(e) {
        locationWatcher = window.navigator.geolocation.watchPosition(locationSuccess, locationError, locationOptions);
  	    console.log("JavaScript app ready and running!");
  }
 );

//Pebble.addEventListener("appmessage",
//                        function(e) {
//        window.navigator.geolocation.getCurrentPosition(locationSuccess, locationError, locationOptions);
//                        });
