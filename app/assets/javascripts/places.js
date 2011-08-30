var Places = {
	sendSearch: function(e) {
		
		if (e.type == 'keypress') {
			// check if Enter was hit
			var code = (e.keyCode ? e.keyCode : e.which);
			if (code != 13) return; // 13 = Enter keycode
		}
		
		var results = $(this).parents(".place-view").find(".results");
		var map = $(this).parents(".place-view").find("#map_canvas")[0].mj_map; // Map object
		
		var query = $(this).parent().find("input").val();
		var bounds = map.gmap.getBounds().toUrlValue();
		
		// clear previous makers
		map.clearMarkers();
		
		// remove results
		results.empty()
		
		// show it's loading
		results.addClass("loading");
		
		$.ajax({
			url: "/places/search",
			data: {'bounds': bounds, 'q': query},
			context: document.body,
			success: function(r) {
				
				// print results TODO: replace name of input with desired form context
				results.removeClass("loading");
				results.html(r.block);
				
				// add new markers
				for (var i = 0; r.markers[i]; i++)
				{
					// place marker on the map
					map.addMarker(Map.L(r.markers[i]));
				}
				
				// set results/markers association
				results.children(".result").each(function(i) {
					this.mj_marker = map.markers[i];
				});
				
				// set markers animation event
				results.children(".result").hover(function(){
					this.mj_marker.setAnimation(google.maps.Animation.BOUNCE);
				}, function(){
					this.mj_marker.setAnimation(null);
				});
				
				LiveInit.mapResultsOnly(results[0]);
			}
		});
		
		// cancel return or button click (would submit whole form)
		return false;
		
	}
}
