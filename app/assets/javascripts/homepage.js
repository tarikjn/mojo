var Animate = {
	leftToRight: function() {
		
		$(this).animate({
			backgroundPosition: "("+$(this).attr("data-slide")+" 0)"
		}, 180000, Animate.rightToLeft);
	},
	rightToLeft: function() {
		
		$(this).animate({
			backgroundPosition: "(0 0)"
		}, 180000, Animate.leftToRight);
	}
}

// class for testimonial fadein/out roller
var AlternateElement = {
	active: 0,
	next: 1,
	size: 4,
	blocks: undefined,
	animTime: 500,
	rollTime: 7000,
	
	initialize: function(block) {
		AlternateElement.blocks = $(block).children().toArray();
		
		// not using abort (return)
		// TODO: pause on mouseover + navigate
		setTimeout(AlternateElement.roll, AlternateElement.rollTime);
	},
	roll: function()
	{
		var active = AlternateElement.active;
		var size = AlternateElement.size;
		var animTime = AlternateElement.animTime;
		
		//animation
		$(AlternateElement.blocks[active]).fadeOut(animTime, function() {
			
			// increment pointer
			AlternateElement.active = ++active % size;
			AlternateElement.next = (active + 1) % size;
			
			// fade-in and set timer for next fade-out
			$(AlternateElement.blocks[AlternateElement.active]).fadeIn(animTime, function() {
				
				// set next time-out
				setTimeout(AlternateElement.roll, AlternateElement.rollTime);
			});
		});
	}
}

$(function() {
	
	// the code after this point is executed when the DOM finished loading
	
	
	
	// testimonials rolling
	$("#testimonials .alternate-elements").each(function() {
		AlternateElement.initialize(this);
	});
	
	// homepage graphic animation
	$("#landing .illustration").find(".layer-0, .layer-2").each(Animate.leftToRight);
	
	
});
