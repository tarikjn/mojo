var TimeSelector = {
	applySelected: function() {
		
		var label = $(this).parents("label:eq(0)");
		var timeSelector = $(this).parents(".mj-time-selector").find(".time-selector");
		
		// move and show time-selector
		timeSelector.css({left: ($(label).index() * 78) + "px"}).show();
		
		// TODO: focus time-selector? (tricky)
		
		// TODO: scroll if label is overflowing viewport
	}
}

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
	
	$("#add-host-button").click(function() {
		// move to friendship.js?
		
		var button = $(this);
		var selector = $(".friend-selection");
		
		button.toggleClass("pushed");
		selector.toggle();
		
		// unselect any radio:
		if (!selector.is(":visible")) {
			selector.find("input[type=radio]").prop('checked', false);
		}
	});
	
	// autogrow textarea's
	$("#sortie_description").autogrow();
	
	// remove wingmate
	$("#remove-wingmate").click(function() {
		$(".set-wingmate").remove();
		$(".add-host").removeClass("inactive");
	})
	
	// handle selection on mj-time-selector
	$(".mj-time-selector").find("input[type=radio]")
		.change(TimeSelector.applySelected).filter(":checked").each(TimeSelector.applySelected);
	
	// TODO: use a more OO approach for autoscroll: see old timerange
	$(".mj-time-selector").find(".move-end, .move-start").click(function () {
		
		var timeSelector = $(this).parents(".mj-time-selector");
		var viewport = timeSelector.find(".viewport:eq(0)")[0];
		var scrollLeft = ($(this).is(".move-end")) ? viewport.scrollWidth - viewport.offsetWidth : 0;
		var otherButton = timeSelector.children($(this).is(".move-end") ? ".move-start" : ".move-end");
		
		// hide
		$(this).hide();
		
		// scroll viewport
		$(viewport).animate({scrollLeft: scrollLeft}, function() {
			
			// show move-start
			otherButton.show();
		})
	})
	
});
