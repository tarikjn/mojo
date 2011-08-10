var Friendship = {
	init: function(el) {
		$(el).submit(function() {

			// show it's loading
			$(this).find(".submit .button").addClass("loading");

			// ajax the form
			$.post(this.action, $(this).serialize(), function(r) {
				
				if (r.action == 'block')
				{
					// what needs to be replaced
					var fields = $(r.block).find("form");
					
					// replace block with new block (which includes errors)
					$("#add-friend-box form").replaceWith(fields);
					var new_form = $("#add-friend-box form")[0];
					
					// re-init
					LiveInit.all(new_form);
					Friendship.init(new_form);
				}
				else if (r.action == 'redirect')
				{
					window.location = r.redirect_path;
				}

			});

			// cancel default action
			return false;
		});
	}
}

$(function() {
	
	// the code after this point is executed when the DOM finished loading
		
	$("#new-friend-button").click(function() {
		var box = $("#add-friend-box");
		if (box.is(":visible"))
		{
			box.hide();
		}
		else
		{
			box.show();
			box.find(".form-item input:eq(0)").focus();
		}
	});
	
	$("#add-friend-box form").each(function() {
		Friendship.init(this);
	});
});
