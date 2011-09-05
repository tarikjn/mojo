var Subscriber = {
	init: function() {
		$(this).submit(function() {
			
			// cancel if an action is already loading
			if ($(this).find(".submit button").is(":disabled"))
				return false;
			
			// save data (prop=disabled erases input data)
			var dataString = $(this).serialize();
			
			// show it's loading
			$(this).find(".submit button").prop("disabled", true);
			$(this).find("input[type=text], input[type=email]").addClass('progressBar').prop("disabled", true);
			
			// post the form
			$.ajax({
			    type: 'POST',
			    url: this.action,
				data: dataString,
				success: function(r) {
					
					var container = document.getElementById('subscribers-xhr-content');
					
					// replace content
					$(container).html(r);
					
					if ($(container).find("form").length) {
						
						// re-init form
						$(container).find("form").each(Subscriber.init);
					}
					else {
						
						// parse fb plugin
						FB.XFBML.parse(container);
					}
					
				},
			    beforeSend: function (xhr) {
			        xhr.setRequestHeader('Accept', 'text/html');
			    }
			});

			// cancel default action
			return false;
		});
	}
}

$(function() {
	
	// the code after this point is executed when the DOM finished loading
		
	$("form#subscriber-form").each(Subscriber.init);
});

