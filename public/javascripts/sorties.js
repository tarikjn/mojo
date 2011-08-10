$(function() {
	
	// the code after this point is executed when the DOM finished loading
		
	// actions buttons on date page
	$(".cancel-action").click(function() {
		
		var date = $(this).parents(".date:eq(0)");
		var prompt = date.next(".action-box.cancel:eq(0)");
		var action = this;
		
		$(action).addClass("disabled");
		date.css('z-index', '1000');
		$("body").append('<div id="black-screen"></div>');
		prompt.show();
		
		prompt.find(".abort").click(function() {
			prompt.hide();
			$("#black-screen").remove();
			date.css('z-index', 'auto');
			$(action).removeClass("disabled");
			
			return false;
		});
		
		return false;
	});
	
	// show/hide description on date
	$(".toggle-text").click(function() {
		$(this).toggleClass("ellipsis");
	});
	
});
