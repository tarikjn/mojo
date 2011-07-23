$(function() {
	
	// the code after this point is executed when the DOM finished loading
	
	$(".columns > div > .tabs > h3").click(function() {
		
		if ($(this).hasClass("inactive")) {
			
			var index = $(this).index();
			var activeTab = $(this).parent().find("h3:not(.inactive)");
			var activeBlock = $(this).parent().parent().find("> ul, > .empty").not(".inactive");
			var newBlock = $(this).parent().parent().find("> ul, > .empty").eq(index);
			
			// disable previous tab
			activeTab.addClass("inactive");
			// activate new tab
			$(this).removeClass("inactive");
			
			// diabled previous block
			activeBlock.addClass("inactive");
			// show new block
			newBlock.removeClass("inactive");
		}
	})
	
});
