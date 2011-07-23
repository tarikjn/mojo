var Follow = {
	init: function(el) {
		
		// hover on unfollow
		$(el).find("a.unfollow").hover(function() {

			// DRY-up
			var new_text = $(this).attr('data-hover');
			$(this).attr('data-hover', $(this).text()).text(new_text);

			$(this).removeClass("green").addClass("red");

		}, function() {

			// DRY-up
			var new_text = $(this).attr('data-hover');
			$(this).attr('data-hover', $(this).text()).text(new_text);

			$(this).removeClass("red").addClass("green");

		});
		
		// handle AJAX
		$(el).find("a").click(function() {
			
			var block = $(this).parent();
			
			// 'disable' a element
			Follow.disableLink(this);
			
			// show it's loading
			block.addClass("loading");
			
			// send request
			$.ajax({url: this.href, beforeSend: function(xhr) {
				
				// override mojo.js default (which is json)
				// TODO: replace with html/partial?
				xhr.setRequestHeader("Accept", "text/javascript");
				
			}, dataType: 'html', success: function(r) {
				
				// replace with new button
				var new_block = $(r);
				block.replaceWith(new_block);
				
				// re-init events
				Follow.init(new_block[0]);
				
			}});
			
			// cancel link action
			return false;
			
		});
		
	},
	disableLink: function(el) {
		
		// make it look disabled
		$(el).addClass("disabled");
		// unbind event
		$(el).unbind('click');
		// block default
		$(el).bind('click', false);
	}
}

$(function() {
	
	// the code after this point is executed when the DOM finished loading
	
	$(".follow-action").each(function() { Follow.init(this); });
	
});
