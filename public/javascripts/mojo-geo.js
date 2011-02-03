var Geo = {
	
	start: ['San Francisco', 37.77493, -122.41942, 11], // TODO: use fitBounds
	startLatLng: undefined, // we need to wait forGoogleMapsAPI to load before using LatLng
	geocoder: undefined,
	map: undefined,
	
	cap_center: undefined,
	date_points: {}, // id: [lat, lng]
	date_markers: {}, // id: google.maps.Marker
	outofrange_markers: [
		[37.76017247811132, -122.44073878344726], // Castro
		[37.769943111128704, -122.47524272021484] // GG Park
	],
	
	setDatePoints: function(points) {
		Geo.date_points = points;
	},
	
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
		/*google.maps.event.addListener(this.map, 'click', function(event) {
		    Geo.addMarker(event.latLng);
		});*/
		
		if ($("#map_canvas").hasClass("with-range-selector"))
		{
			this.cap_center = Geo.L([37.793812, -122.411384]);
			
			Geo.map.setCenter(this.cap_center);
			Geo.map.setZoom(12);
			Geo.addRangeSelector(this.map);
			Geo.addDateMarkers(this.map);
		}
		else
		{
			this.addMarker(Geo.startLatLng, Geo.start[0]);
		}
	},
	
	addRangeSelector: function(map_obj) {
		var circle = new google.maps.Circle({
			center: Geo.cap_center,
			fillColor: "#e1ecff",
			fillOpacity: .5,
			map: Geo.map,
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
	        position: Geo.cap_center,
	        map: this.map,
	        icon: cross
	    });
	},

	addDateMarkers: function(map_obj) {
		
		for (var i in (Geo.date_points))
		{
			Geo.date_markers[i] = Geo.addMarker(Geo.L(Geo.date_points[i]), "", 'in_range');
		}
		for (var i in Geo.outofrange_markers)
		{
			Geo.addMarker(Geo.L(Geo.outofrange_markers[i]), "", 'out_of_range');
		}
	},
	
	animateMarker: function(date_id) {
		var marker = Geo.date_markers['date-'+date_id];
		
		// start animation
		marker.setAnimation(google.maps.Animation.BOUNCE);
	},
	
	stopAnimateMarker: function(date_id) {
		var marker = Geo.date_markers['date-'+date_id];
		
		// stop animation
		marker.setAnimation(null);
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
	
	addMarker: function(point, title, type) {
		
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
	        map: this.map,
	        icon: image,
	        shadow: shadow,
			title: title
	    });
	
		return marker;
	},
	
	L: function(a) {
		var s = a.length;
		var p = new google.maps.LatLng(a[s-2], a[s-1]);
		return (p);
	}
};
