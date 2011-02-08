// setup of accept format for Rails' respond_to format.js
jQuery.ajaxSetup({
    'beforeSend': function(xhr) {
        xhr.setRequestHeader("Accept", "text/javascript")
    }
});

jQuery.fn.cleanWhitespace = function() {
    textNodes = this.contents().filter(
        function() { return (this.nodeType == 3 && !/\S/.test(this.nodeValue)); })
        .remove();
}

// http://evilstreak.co.uk/blog/fixing-change-events-on-radios
$.fn.fix_radios = function() {
  function focus() {
    // if this isn't checked then no option is yet selected. bail
    if ( !this.checked ) return;

    // if this wasn't already checked, manually fire a change event
    if ( !this.was_checked ) {
      $( this ).change();
    }
  }

  function change( e ) {
    // shortcut if already checked to stop IE firing again
    if ( this.was_checked ) {
      e.stopImmediatePropagation();
      return;
    }

    // reset all the was_checked properties
    $( "input[name=" + this.name + "]" ).each( function() {
      this.was_checked = this.checked;
    } );
  }

  // attach the handlers and return so chaining works
  return this.focus( focus ).change( change );
}

// Class managing selection of Subset form
var SubsetForm = {
	
	parent: undefined,
	arrow: undefined,
	selected_persona: undefined,
	selected: undefined,
	that: this,
	ap: [54, 204, 204 + 56], // TODO: use offsets
	
	initialize: function(formItem) {
		
		SubsetForm.parent = formItem[0];
		SubsetForm.arrow = formItem.find(".subset-form-arrow:eq(0)")[0];
		SubsetForm.selected = formItem.find(".subset-form.active")[0];
		
		// set up variables and events for personas
		formItem.find(".hybrid-input .mj-choice").find(".person.host").each(function(i) {
			
			if (i == 0)
				SubsetForm.selected_persona = this;
			
			// find index
			var index = $(this).index() - 1;
			// set up variables for personas: link_to, arrow_pos
			this.link_to = formItem.find(".subset-form").eq(index)[0];
			this.arrow_pos = SubsetForm.ap[i];
			this.is_selected = (i == 0) ? true : false;
			
			// set up click event listener on personas
			// check is parent is selected
			$(this).click(function () {
				
				if ($(this).parent().hasClass("selected"))
					SubsetForm.select(this);
			})
		});
		
		// set up change event listener on mj-merged
		formItem.find(".hybrid-input .mj-choice").change(function() {
			
			// select first persona
			SubsetForm.select($(this).find(".person.host:eq(0)")[0]);
		})
	},
	
	select: function(persona) {
		if (persona.is_selected)
			return;
		
		// toggle is_selected
		SubsetForm.selected_persona.is_selected = false;
		SubsetForm.selected_persona = persona;
		SubsetForm.selected_persona.is_selected = true;
		
		// move arrow
		SubsetForm.arrow.style.left = persona.arrow_pos + 'px';
		
		// toggle form
		if (persona.link_to != SubsetForm.selected)
		{
			$(SubsetForm.selected).removeClass("active");
			SubsetForm.selected = persona.link_to;
			$(SubsetForm.selected).addClass("active");
		}
	}
	
};

// Class managing selection of personas gender
var AutoselectPersona = {
	
	formItem: undefined,
	genderClasses: 'neutral male female',
	defaultPref: {
		male: 'female',
		female: 'male'
	},
	
	initialize: function(formItem) {
		
		AutoselectPersona.formItem = formItem;
		
		$(formItem).find(".subset-form").each(function(i) {
			
			subsetForm = this;
			
			// find gender radios in this subset
			$(this).find(".mj-merged-choices input[type=radio][name$=sex]").each(function() {
				
				this.mj_pref = $(subsetForm).find(".mj-merged-choices input[type=radio][name$=sex_preference]");
				this.mj_hosts = $(formItem).find(".hybrid-input .mj-choice").find(".person.host:eq(" + i + ")");

				$(this).change(AutoselectPersona.changeGender);
			});
			
			// find gender preference radios in this subset
			$(this).find(".mj-merged-choices input[type=radio][name$=sex_preference]").each(function() {

				this.mj_guests = $(formItem).find(".hybrid-input .mj-choice").find(".person.guest:eq(" + i + ")")

				$(this).change(AutoselectPersona.changeGenderPreference);
			});
		});
	},
	
	changeGender: function() {
		
		// select radio and fire change event
		this.mj_pref.filter("[value="+AutoselectPersona.defaultPref[this.value]+"]").attr('checked', 'checked').change();
		
		// change gender of host persona on parent tab
		this.mj_hosts.removeClass(AutoselectPersona.genderClasses).addClass(this.value);
	},
	
	changeGenderPreference: function() {
		
		// change gender of guest persona on parent tab
		this.mj_guests.removeClass(AutoselectPersona.genderClasses).addClass(this.value);
	}
};

// Class for time range input
function TimeRangeInput(obj)
{
	// defaults
	that = this;
	this.offset = 50; // px
	this.timer = {
		timeout: 500, // >= interval
		interval: 50
	};
	
	function initialize()
	{
		// remove use of jQuery
		that.viewport = $(this).children(".view-container")[0];
		
		// this contructs allows us to do assignements with buttons[0] and buttons[1] with a unique jQuery traverse
		(function(buttons) {
			that.buttons = {
				before: {
					el: buttons[0],
					isDisabled: function() { return !(that.viewport.scrollLeft > 0); },
					offsetFactor: -1
				},
				after: {
					el: buttons[1],
					isDisabled: function() { return !((that.viewport.scrollLeft + that.viewport.offsetWidth) < that.viewport.scrollWidth); },
					offsetFactor: 1
				}
			};
			
			buttons[0].mj_timerange_button = that.buttons.before;
			buttons[1].mj_timerange_button = that.buttons.after;
			
		} ($(this).children("button")));
		
		// attach event listeners to both buttons
		$([that.buttons.before.el, that.buttons.after.el]).bind('mousedown', that.mousedown).bind('mouseup', that.mouseup);
	}
	
	this.mousedown = function()
	{
		// no action if disabled
		if (this.disabled)
			return;
		
		// scroll
		that.scroll.call(this);
		
		// copy this so "this" doesn't get overwrriten by timeout scope
		var me = this;
		
		// set timeout
		if (!this.disabled) // state can change after scroll
			this.mj_timerange_button.timeout = setTimeout(function() { that.timeout.call(me); }, that.timer.timeout - that.timer.interval);
			// we remove the interval so it starts scrolling right after timeout
		
	}
	
	this.mouseup = function()
	{
		var b = this.mj_timerange_button;
		
		// stop any timers
		if (b.timeout !== undefined)
		{
			clearTimeout(b.timeout);
			b.timeout = undefined;
		}
		else
			that.stopTimer(b.timer);
	}
	
	this.timeout = function()
	{
		var b = this.mj_timerange_button;
		
		// the timeout is over
		b.timeout = undefined;
		
		// copy this so "this" doesn't get overwrriten by interval scope
		var me = this;
		
		// set interval instead
		this.mj_timerange_button.timer = setInterval(function() { that.scroll.call(me); }, that.timer.interval);
	}
	
	this.scroll = function()
	{
		var b = this.mj_timerange_button;
		
		// how much do we move the scrollbar
		offset = that.offset * b.offsetFactor;

		// this scrolls the viewport
		that.viewport.scrollLeft += offset;
		
		// stop any mousedown timer if the current button is about to be disabled
		if ( b.isDisabled() )
			that.stopTimer(b.timer);
		
		// check/update state for both buttons
		for (button in that.buttons)
			that.buttons[button].el.disabled = that.buttons[button].isDisabled();
		
	}
	
	this.stopTimer = function(timer)
	{
		if (timer !== undefined)
		{
			clearInterval(timer);
			timer = undefined;
		}
	}
	
	// constructor
	initialize.call(obj);
};

// class for testimonial fadein/out roller
var AlternateElement = {
	active: 0,
	next: 1,
	size: 4,
	blocks: undefined,
	animTime: 500,
	rollTime: 5000,
	
	initialize: function(block) {
		AlternateElement.blocks = $(block).children().toArray();
		
		// not using abort (return)
		// NOTE: lead time is 5s, 4s after
		// TODO: pause on mouseover
		setInterval(AlternateElement.roll, AlternateElement.rollTime);
	},
	roll: function()
	{
		var active = AlternateElement.active;
		var size = AlternateElement.size;
		var animTime = AlternateElement.animTime;
		
		//animation
		$(AlternateElement.blocks[active]).fadeOut(animTime, function() {
			$(AlternateElement.blocks[AlternateElement.next]).fadeIn(animTime);
			AlternateElement.active = ++active % size;
			AlternateElement.next = (active + 1) % size;
		});
	}
}

var Flash = {
	timing: 50,
	set: function(id) {
		var el = Flash.getEl(id);
		el.mj_flashInterval = setInterval(function() {Flash.toggle(el)}, Flash.timing);
	},
	toggle: function(el) {
		$(el).toggle();
	},
	stop: function(id) {
		var el = Flash.getEl(id);
		if (el.mj_flashInterval)
		{
			clearInterval(el.mj_flashInterval);
			mj_flashInterval = null;
		}
		$(el).show();
	},
	getEl: function(date_id) {
		return $(".mj-timeline-input .activities .activity.date-"+date_id)[0];
	}
};

var DateList = {
	getId: function(el) {
		var match = (el.id).match(/(\d+)$/g);
		return match[0];
	}
}

var DragAndDrop = {
	blinkTime: 200, // ms
	
	init: function() {
		
		var droppable = {
			invite: document.getElementById("drop-invite"),
			pass: document.getElementById("drop-pass")
		}
		
		for (var el in droppable)
		{
			// Tells the browser that we *can* drop on this target
			$(droppable[el]).bind('dragover', DragAndDrop.cancel);
			$(droppable[el]).bind('dragenter', DragAndDrop.cancel);
			$(droppable[el]).bind('dragleave', DragAndDrop.leave);

			$(droppable[el]).bind('drop', DragAndDrop.drop);
		}
		
		DragAndDrop.initDraggable();
	},
	initDraggable: function() {
		
		$("[draggable=true]").bind('dragstart', DragAndDrop.start);
	},
	drop: function(event) {
		
		// jQuery access
		var dataTransfer = event.originalEvent.dataTransfer;
		
		// stops the browser from redirecting off to the text.
		if (event.preventDefault) { event.preventDefault(); }

		var id = dataTransfer.getData('Text') ;
		
		//this.innerHTML += '<p>' + dataTransfer.getData('Text') + '</p>';
		$(this).addClass("drop-loading");
		$(this).removeClass("drag-over");
		
		// disable dragging
		$("#" + id).attr("draggable", false);
		
		var drop = this;
		
		// send action, removed (document.location)
		$.get("/entries/" + this.getAttribute("data-action") + "/" + id.match(/(\d+)$/g)[0], function(r) {
			
			$(drop).removeClass("drop-loading");
			
			switch (r.message)
			{
				case 'done':
					// redirect
					window.location = r.redirect_path;
					break;
				case 'removed':
					// TODO: handle case where no entry is remaining
					var removed_entry = $("#" + id);
					var block = $(".participants-viewport .participants");
					var eject = $(".participants-view .eject .symbol span");
					var incoming = block.find(".incoming");
					
					// hide for blink
					removed_entry.css({visibility: 'hidden'});
					eject.css({visibility: 'hidden'});
					
					setTimeout(function() {
						// blink removed_entry and eject
						removed_entry.css({visibility: 'visible'});
						eject.css({visibility: 'visible'});
						
						setTimeout(function() {
							removed_entry.css({visibility: 'hidden'});
							eject.css({visibility: 'hidden'});
							
							setTimeout(function() {
								// blink only eject
								eject.css({visibility: 'visible'});

								// replace
								incoming.replaceWith(r.new_list);
								// remove
								removed_entry.remove();
								// position bottom
								block.css({bottom: "90px"});
								// animate
								block.animate({bottom: 0}, 500, function() {
									
									// re-assign dragstart event
									DragAndDrop.initDraggable();
								});

							}, DragAndDrop.blinkTime);
							
						}, DragAndDrop.blinkTime);
						
					}, DragAndDrop.blinkTime);
					
					break;
				case 'error':
					// TODO: implement
					break;
			}
		});
		
		return false;
	},
	cancel: function(event) {
		
		$(this).addClass("drag-over");
		
		if (event.preventDefault) { event.preventDefault(); }
		  return false;
	},
	leave: function(event) {
		
		$(this).removeClass("drag-over");
	},
	start: function(event) {
		
		// jQuery access
		var dataTransfer = event.originalEvent.dataTransfer;
	
		// setup drag icon
		var dragIcon = $(this).find(".drag-icon")[0];
		dataTransfer.setDragImage(dragIcon, 18, 18);
		
		// store the ID of the element, and collect it on the drop later on, required for Firefox support
	    dataTransfer.setData('Text', this.id);
	}
}


$(function() {
	
	// the code after this point is executed when the DOM finished loading
	
	// drag and drop
	if ($(".participants-view").length) {
		
		DragAndDrop.init();
	}
	
	// flash date pointers and markers
	$(".mj-activity").mouseenter(function(){
		var id = DateList.getId(this);
		
		Flash.set(id);
		Geo.animateMarker(id);
	}).mouseleave(function(){
		var id = DateList.getId(this);
		
		// stop flashing
		Flash.stop(id)
		// stop bouncing
		Geo.stopAnimateMarker(id);
	});
	
	// afinity
	$("canvas.afinity-chart").each(function(){
		var r = this.width / 2; // radius
		var a = parseInt($(this.parentNode.parentNode).find(".score .int").text()) / 100; // afinity
		
		var red = Math.round(255 - ((a > .5)? 255 * (a - .5) * 2 : 0));
		var green = Math.round((a > .5)? 255 : 255 * a * 2);
		
		var ctx = this.getContext("2d");
		
		// colored
		ctx.beginPath();
		ctx.arc(r, r, r, -.5*Math.PI, -.5*Math.PI + Math.PI*2*a, false);
		ctx.lineTo(r, r);
		ctx.closePath();
		ctx.fillStyle = 'rgb('+red+', '+green+', 0)';
		ctx.fill();
		
		// remaining in gray
		ctx.beginPath();
		ctx.arc(r, r, r, -.5*Math.PI + Math.PI*2*a, -.5*Math.PI + Math.PI*2, false);
		ctx.lineTo(r, r);
		ctx.closePath();
		ctx.fillStyle = 'rgba('+red+', '+green+', 0, .25)';
		ctx.fill();
	});
	
	// animating stepflow
	$(".stepflow-frame > form").submit(function() {
		
		// save reference
		var form = this;
		
		// nav loading
		$("#stepflow-nav button").attr('disabled', 'disabled');
		$("#stepflow-nav .ajax-loading").show();
		
		$.post(this.action, $(this).serialize(), function(r) {
			
			if (r.move == 'next')
			{
				var outgoing = $('#stepflow-blocks').children().first();
				var timing = 1000;

				var incoming = $(r.block).appendTo($('#stepflow-blocks')).css({opacity: 0});
				$('#stepflow-blocks').cleanWhitespace();

				// nav loaded
				var nav = $(r.nav);
				nav.find("button").attr('disabled', 'disabled');
				$("#stepflow-nav").html(nav);

				// update form action
				form.action = r.action;

				// sliding animation
				outgoing.animate({opacity: 0}, timing, 'swing');
				incoming.animate({opacity: 1}, timing, 'swing');
				$("#stepflow-blocks").animate({left: -898}, timing, 'swing', function() {
					// complete
					outgoing.remove();
					$('#stepflow-blocks').css({left: 0});
					// nav activate
					$("#stepflow-nav button").removeAttr('disabled');
				});
			}
			else if (r.move = 'redirect')
			{
				window.location = r.redirect_path;
			}
			
		});
		
		return false;
	});
	
	
	// login bubble
	$("#login-link").click(function() {
		$("#login-bubble").toggle(250);
		return ($("#login-bubble").length > 0)? false : true;
	});
	
	// load Google Maps (code in mojo-geo.js)
	if ($('#map_canvas').length)
	{
		if ($("label.mj-activity").length)
		{
			var points = {};
			
			$("label.mj-activity").each(function() {
				var lat = $(this).find(".point .lat").text();
				var lng = $(this).find(".point .lng").text();
				points[this.id] = [lat, lng];
			});
			
			Geo.setDatePoints(points);
		}
		
		Geo.initialize();
	}
	
	$("input[type=radio]").fix_radios();
	
	// mj-timeline-input
	$(".mj-timeline-input").each(function() {
		new TimeRangeInput(this);
	});
	
	// initialize SubsetForm
	var subsetFormItem = $("#form_item_who")[0];
	if (subsetFormItem)
	{
		SubsetForm.initialize($(subsetFormItem));
		AutoselectPersona.initialize(subsetFormItem);
	}
	
	// apply "selected" class to label when switching radio
	$(".mj-choice, .mj-merged-choices, .mj-operation-choices, .mj-micro-select").find("input[type=radio]").change(function() {
		
		var label = $(this).parent();
		var group = label.parents(".hybrid-input:eq(0)");
		
		group.find(".selected").removeClass("selected");
		label.addClass("selected");
	});
	
	// activate mj-check-roll
	$("label.mj-check-roll").each(function() {
		
		var dependant = $(this).parent().next();
		dependant.hide();
		
		$(this).change(function() {
			dependant.toggle();
		});
		
		// TODO: autofill age/height + autoselect
	});
	
	// homepage tab animations
	$(".tab-widget .tab-button div").hover(function() {
		
		var id = $(this).index();
		var idOff = (id + 1) % 2;
		var tabEl = $(this).parent().find("div");
		var contentEl = $(this).parent().parent().find(".tab-content>*");
		
		// interrupt any ongoing animation
		tabEl.stop().removeAttr('style');
		contentEl.stop();
		
		// do nothing if tab is already selected
		if (!tabEl.eq(id).hasClass("selected"))
		{
			tabEl.eq(idOff).removeClass("selected");
			contentEl.eq(idOff).hide().css({opacity: null});
			
			// TODO: reference px and color directly from CSS values
			tabEl.eq(id).animate({top: "-3px", backgroundColor: "gray"}, 150);
			
			contentEl.eq(id).fadeIn(300, function() {
				tabEl.eq(id).stop().removeAttr('style').addClass("selected");
				contentEl.eq(id).removeAttr('style');
			});
		}
	});
	
	// testimonials rolling
	$("#testimonials .alternate-elements").each(function() {
		AlternateElement.initialize(this);
	});
	
	// JS support for formaction on button elements (HTML5)
	$("button[formaction]").each(function() {
		
		if ($(this).attr("formaction") !== null && this.formaction === undefined)
		{
			// HTML5's button -> formaction is unsupported
			$(this).click(function() {
				var form = $(this).parents("form");
				form.attr("action", $(this).attr("formaction"));
				form.submit();
				return false;
			});
		}
	});
	
});
