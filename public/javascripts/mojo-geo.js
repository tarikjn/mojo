var Geo = {
	
	start: ['San Francisco', 37.77493, -122.41942, 11], // TODO: use fitBounds
	startLatLng: undefined, // we need to wait forGoogleMapsAPI to load before using LatLng
	geocoder: undefined,
	map: undefined,
	
	initialize: function() {
		
	    this.geocoder = new google.maps.Geocoder();
	
	    var latlng = new google.maps.LatLng(37.796221,-122.419281);
		
		Geo.startLatLng = new google.maps.LatLng(Geo.start[1], Geo.start[2]);
	
	    var myOptions = {
			zoom: this.start[3],
			center: Geo.startLatLng,
			mapTypeControl: true,
			mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
			navigationControl: true,
			navigationControlOptions: {style: google.maps.NavigationControlStyle.SMALL},
			streetViewControl: false,
			mapTypeId: google.maps.MapTypeId.ROADMAP
	    }
	    this.map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
		this.addMarker(Geo.startLatLng, Geo.start[0]);
		/*google.maps.event.addListener(this.map, 'click', function(event) {
		    Geo.addMarker(event.latLng);
		});*/
	},

	codeAddress: function() {
		var address = document.getElementById("address").value;
		if (this.geocoder) {
		  this.geocoder.geocode( { 'address': address}, function(results, status) {
		    if (status == google.maps.GeocoderStatus.OK) {
		      this.map.setCenter(results[0].geometry.location);
		      var marker = new google.maps.Marker({
		          map: this.map, 
		          position: results[0].geometry.location
		      });
		    } else {
		      alert("Geocode was not successful for the following reason: " + status);
		    }
		  });
		}
		
	},
	
	addMarker: function(point, title) {
	    var image = new google.maps.MarkerImage(
			"/images/markers/location-selected.png",
	        new google.maps.Size(16, 27),
	        new google.maps.Point(0, 0),
	        new google.maps.Point(8, 27)
	    );
	    var shadow = new google.maps.MarkerImage(
			"/images/markers/location-selected_shadow.png",
	        new google.maps.Size(30, 27),
	        new google.maps.Point(0, 0),
	        new google.maps.Point(8, 27)
	    );
	    var marker = new google.maps.Marker({
	        position: point,
	        map: this.map,
	        icon: image,
	        shadow: shadow,
			title: title
	    });
	}
};
