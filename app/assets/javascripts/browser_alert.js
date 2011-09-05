$(function() {
	
	// the code after this point is executed when the DOM finished loading
		
	$("#close-browser-alert").click(function() {
		
		// save cookie so that rails doesn't display the message for 7 days
		var date = new Date();
		date.setTime(date.getTime()+(7*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
		document.cookie = "browser_alert=hide"+expires+"; path=/";
		
		// remove message
		$("#browser-alert").remove();
		
	});
});
