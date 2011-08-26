var Friendship = {
	initAddButton: function() {
		$(this).click(function() {

			// not targeting the a element
			var button = $(this).parent();

			if (button.hasClass("loading"))
				return false;

			if (button.hasClass('active'))
			{
				$("#add-friend-box").remove();
				button.removeClass("active");
			}
			else
			{
				button.addClass("loading");
				var ul = $(this).parents("ul:eq(0)");

				// load form
				$.ajax({
				    url : this.href,
				    method : 'get',
				    beforeSend : function (xhr) {
				        xhr.setRequestHeader('Accept', 'text/html');
				    },
					success: function(data) {

						ul.after(data);
						$("#add-friend-box form").each(function() {
							Friendship.init(this);
						});
						$("#add-friend-box").find(".form-item input:eq(0)").focus();

						button.removeClass("loading").addClass("active");
					}
				});
			}

			return false;
		});
	},
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
				else if (r.action == 'redirect') // create a special action detect to get either block or new_friendlist
				{
					var friendlist = $(el).parents(".hybrid-input.friend-selection:eq(0)");
					
					if (friendlist.length == 0) {
						console.log(friendlist);
						//window.location = r.redirect_path;
					}
					else
					{
						// refresh friendlist without reloading the page
						friendlist.html(r.new_friendlist);
						
						// re-init add button
						$("#new-friend-button > a").each(Friendship.initAddButton);
						// TODO: don't replace the add button but instead add/replace friends' li only
					}
				}

			});

			// cancel default action
			return false;
		});
	}
}

$(function() {
	
	// the code after this point is executed when the DOM finished loading
		
	$("#new-friend-button > a").each(Friendship.initAddButton);
});
