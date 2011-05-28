// Static Class


// Class
function Map(obj, activity_points) {
	
	// defaults
	var that = this;
	that.gmap = undefined;
	that.geocoder = new google.maps.Geocoder();
	that.markers = [];
	
	// params
	that.p = {
		
		start: ['San Francisco', 11, 37.77493, -122.41942], // TODO: use fitBounds

		cap_center: Map.L([37.793812, -122.411384]),
		date_points: (activity_points !== undefined)? activity_points : {}, // id: [lat, lng]
		date_markers: {}, // id: google.maps.Marker
		outofrange_markers: [
			[37.76017247811132, -122.44073878344726], // Castro
			[37.769943111128704, -122.47524272021484] // GG Park
		]
	};
	
	/*
	 * Private methods
	 */
	function initialize() {
		
		var startLatLng = Map.L(that.p.start);
	
	    var options = {
			zoom: that.p.start[1],
			center: startLatLng,
			mapTypeControl: true,
			mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
			navigationControl: true,
			navigationControlOptions: {style: google.maps.NavigationControlStyle.SMALL},
			streetViewControl: false,
			mapTypeId: google.maps.MapTypeId.ROADMAP
	    }
	    that.gmap = new google.maps.Map(this, options);
		/*google.maps.event.addListener(this.map, 'click', function(event) {
		    Geo.addMarker(event.latLng);
		});*/
		
		if ($(this).hasClass("with-range-selector"))
		{
			that.gmap.setCenter(that.p.cap_center);
			that.gmap.setZoom(12);
			that.addRangeSelector();
			that.addDateMarkers();
		}
		else if ($(this).hasClass("city-only"))
		{
			that.addMarker(startLatLng, that.p.start[0]);
		}
	}
	
	/*
	 * Privileged methods
	 */
	this.addRangeSelector = function() {
		var circle = new google.maps.Circle({
			center: that.p.cap_center,
			fillColor: "#e1ecff",
			fillOpacity: .5,
			map: that.gmap,
			radius: 3000, // meters
			strokeColor: "#0080ff",
			strokeWeight: 2
		});
		var cross = new google.maps.MarkerImage(
			"/images/markers/range-center.png",
	        new google.maps.Size(11, 11),
	        new google.maps.Point(0, 0),
	        new google.maps.Point(5, 5)
	    );
		var marker = new google.maps.Marker({
	        position: that.p.cap_center,
	        map: that.gmap,
	        icon: cross
	    });
	};
	
	this.clearMarkers = function () {
		for (i in that.markers) {
			that.markers[i].setMap(null);
		}
	};
	
	this.addMarker = function(point, title, type) {
		
		if (type === undefined) type = 'city';
		types = {
			city: "-selected",
			in_range: "-scoped",
			out_of_range: ""
		};
		
	    var image = new google.maps.MarkerImage(
			"/images/markers/location"+types[type]+".png",
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
	        map: that.gmap,
	        icon: image,
	        shadow: shadow,
			title: title
	    });
		
		that.markers.push(marker);
		
		return marker;
	};
	
	this.addDateMarkers = function() {
		
		for (var i in that.p.date_points)
		{
			that.p.date_markers[i] = that.addMarker(Map.L(that.p.date_points[i]), "", 'in_range');
		}
		for (var i in that.p.outofrange_markers)
		{
			that.addMarker(Map.L(that.p.outofrange_markers[i]), "", 'out_of_range');
		}
	};
	
	this.animateMarker = function(date_id) {
		var marker = that.p.date_markers['date-'+date_id];
		
		// start animation
		marker.setAnimation(google.maps.Animation.BOUNCE);
	};
	
	this.stopAnimateMarker = function(date_id) {
		var marker = that.p.date_markers['date-'+date_id];
		
		// stop animation
		marker.setAnimation(null);
	};
	
	// constructor
	initialize.call(obj);
	
	return this;
}

// Static functions
// adding to prototype not needed as we call using Map.*
Map.L = function(a) {
	var s = a.length;
	var p = new google.maps.LatLng(a[s-2], a[s-1]);
	return (p);
};

/*
codeAddress: function(map) {
	var address = document.getElementById("address").value;
	if (map.geocoder) {
	  map.geocoder.geocode( { 'address': address}, function(results, status) {
	    if (status == google.maps.GeocoderStatus.OK) {
	      map.gmap.setCenter(results[0].geometry.location);
	      var marker = new google.maps.Marker({
	          map: map.gmap, 
	          position: results[0].geometry.location
	      });
	    } else {
	      alert("Geocode was not successful for the following reason: " + status);
	    }
	  });
	}
	
},
*/
