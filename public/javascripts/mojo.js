// setup of accept format for Rails' respond_to format.js
jQuery.ajaxSetup({
    'beforeSend': function(xhr) {
        xhr.setRequestHeader("Accept", "application/jsonrequest")
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
    $( 'input[name="' + this.name + '"]' ).each( function() {
      this.was_checked = this.checked;
    } );
  }

  // attach the handlers and return so chaining works
  return this.focus( focus ).change( change );
}

// Mojo's custom library
var Lib = {
	pad: function(number, length) {

	    var str = '' + number;
	    while (str.length < length) {
	        str = '0' + str;
	    }

	    return str;

	},
	formatTime: function(hour)
	{
		var H = Math.floor(hour);
		var M = (hour - H) * 60;
		
		return Lib.pad(H, 2) + ':' + Lib.pad(M, 2);
	}
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
		
		SubsetForm.parent = formItem;
		SubsetForm.arrow = $(formItem).find(".subset-form-arrow:eq(0)")[0];
		SubsetForm.selected = $(formItem).find(".subset-form.active")[0];
		
		// set up variables and events for personas
		$(formItem).find(".hybrid-input .mj-choice").find(".person.host").each(function(i) {
			
			if (i == 0)
				SubsetForm.selected_persona = this;
			
			// find index
			var index = $(this).index() - 1;
			// set up variables for personas: link_to, arrow_pos
			this.link_to = $(formItem).find(".subset-form").eq(index)[0];
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
		$(formItem).find(".hybrid-input .mj-choice").change(function() {
			
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
	this.ds = 19; // half-hour size in px
	this.base = this.ds;
	
	function initialize()
	{
		// remove use of jQuery
		that.input = this;
		that.timeline = $(this).find(".timeline")[0];
		that.range = $(this).find(".selected-time")[0];
		
		// init dragging for selected time
		that.limiter = $(this).find(".frame")[0];
		var baseEnd = that.timeline.scrollWidth - that.ds;
		
		// TODO: set cursor when dragging
		// TODO: implement keyboard nav
		
		that.initDrag(that.range, {
			limitRef: function() { return parseInt(that.dragged.style.left); },
			limitLow: that.base,
			limitHigh: function() { return baseEnd - parseInt(that.dragged.style.width); },
			handler: function(m) {
				that.dragged.style.left = parseInt(that.dragged.style.left) + m + "px";
			}
		});
		that.initDrag($(that.range).find(".stop-hand")[0], {
			limitRef: function() { return parseInt(that.dragged.parentElement.style.width); },
			limitLow: 2 * that.ds, // select a 1 hour range minimum
			limitHigh: function() { return baseEnd - parseInt(that.dragged.parentElement.style.left); },
			handler: function(m) {
				that.dragged.parentElement.style.width = parseInt(that.dragged.parentElement.style.width) + m + "px";
			}
		});
		// TODO: implement double-limit: add width limit
		that.initDrag($(that.range).find(".start-hand")[0], {
			limitRef: function() { return parseInt(that.dragged.parentElement.style.left); },
			limitLow: that.base,
			limitHigh: function() { return baseEnd; },
			handler: function(m) {
				that.dragged.parentElement.style.left = parseInt(that.dragged.parentElement.style.left) + m + "px";
				that.dragged.parentElement.style.width = parseInt(that.dragged.parentElement.style.width) - m + "px";
			}
		});
		
		$(".day-tabs label").click(that.selectDay);
	}
	
	this.selectDay = function()
	{
		if (!$(this).hasClass("active")){
			
			var tabs = $(this.parentNode).children();
			var timebar = $(that.timeline).find(".elapsed-and-current-time");
			
			// disable/enable elapsed time bar
			if (tabs.index(this) == 0)
				timebar.show();
			else
				timebar.hide();
			
			// de-activate former tab, activate *this
			tabs.filter(".active").removeClass("active");
			$(this).addClass("active");
		}
	}
	
	this.updateTimeInputs = function()
	{
		// start_time: 06:00 + 1h per each 2 * ds in left pos (-base)
		// end_time: + 1h per each 2 * ds in width
		
		var left = parseInt($(that.range).css("left"));
		var width = parseInt($(that.range).css("width"));
		
		var start_time_input = $(that.input).children("input[name$=\"time_start]\"]");
		var end_time_input = $(that.input).children("input[name$=\"time_end]\"]");
		
		var start_hour = ((left - that.base) / (2 * that.ds)) + 6;
		var end_hour = start_hour + (width / (2 * that.ds));
		
		// set
		start_time_input.val(Lib.formatTime(start_hour));
		end_time_input.val(Lib.formatTime(end_hour));
	}
	
	// drag support, may be namespaced
	this.initDrag = function(el, spec)
	{
		// using standard limiter
		
		// assign spec
		el.mj_drag_spec = spec;
		
		$(el).bind('mousedown', that.startDrag, false);
	}
	this.startDrag = function(e)
	{
		that.dragged = this;
		
		that.limiter.mj_drag_startPos = e.pageX; // we only need horizontal
		
		$(that.limiter).mouseup(that.endDrag)
		               .mouseleave(that.endDrag)
		               .mousemove(that.moveDrag); // dragging
		
		document.onselectstart = that.preventSelect;
		
		// stop bubbling
		e.stopPropagation();
	}
	this.moveDrag = function(e)
	{
		var delta = e.pageX - this.mj_drag_startPos;
		var increments = Math.round(Math.abs(delta / that.ds));
		var direction = (delta < 0)? -1 : 1;
		
		if (increments > 0)
		{
			var move = direction * increments * that.ds;
			
			// use spec
			var limitLow = that.dragged.mj_drag_spec.limitLow;
			var limitHigh = that.dragged.mj_drag_spec.limitHigh();
			var current = that.dragged.mj_drag_spec.limitRef();
			
			if (limitLow !== undefined && current + move < limitLow)
				move = -(current - limitLow);
			else if (limitHigh !== undefined && current + move > limitHigh)
				move = limitHigh - current;
			
			// action
			that.dragged.mj_drag_spec.handler(move);
			
			this.mj_drag_startPos += move;
		}
	}
	this.preventSelect = function(e)
	{
		e.preventDefault();
		return false;
	}
	this.endDrag = function(e)
	{
		document.onselectstart = undefined;
		
		$(this).unbind('mousemove')
		       .unbind('mouseleave')
		       .unbind('mouseup');
		
		this.mj_drag_startPos = undefined;
		
		that.dragged = undefined;
		
		// update inputs
		that.updateTimeInputs();
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
		return $(".mj-timerange-input .activities .activity.date-"+date_id)[0];
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

var LiveInit = {
	
	navOnly: function(c) {
		
		// JS support for formaction on button elements (HTML5)
		$(c).find("button[formaction]").each(function() {

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
	},
	all: function(c) {
		
		// flash date pointers and markers
		$(c).find(".mj-activity").mouseenter(function(){
			var id = DateList.getId(this);
			
			Flash.set(id);
			$('#map_canvas')[0].mj_map.animateMarker(id);
		}).mouseleave(function(){
			var id = DateList.getId(this);

			// stop flashing
			Flash.stop(id);
			// stop bouncing
			$('#map_canvas')[0].mj_map.stopAnimateMarker(id);
		});

		// afinity
		$(c).find("canvas.afinity-chart").each(function(){
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
		
		// load Google Maps (code in mojo-geo.js)
		$(c).find('#map_canvas').each(function() {
			
			if ($("label.mj-activity").length) // TODO: add scope!!
			{
				var points = {}; // move outside block?
				
				$("label.mj-activity").each(function() {
					var lat = $(this).find(".point .lat").text();
					var lng = $(this).find(".point .lng").text();
					points[this.id] = [lat, lng];
				});
			}
			
			this.mj_map = new Map(this, points);
		});

		// mj-timerange-input
		$(c).find(".mj-timerange-input").each(function() {
			new TimeRangeInput(this);
		});

		// initialize SubsetForm
		$(c).find("#form_item_who").each(function() {
			SubsetForm.initialize($(this));
			AutoselectPersona.initialize(this);
		})

		// apply "selected" class to label when switching radio
		$(c).find(".mj-choice, .mj-merged-choices, .mj-operation-choices, .mj-micro-select").find("input[type=radio]").change(function() {
			
			var label = $(this).parents("label:eq(0)"); // parents + :eq(0): fix for fields_with_errors
			var group = label.parents(".hybrid-input:eq(0)");

			group.find(".selected").removeClass("selected");
			label.addClass("selected");
		});

		// activate mj-check-roll
		$(c).find("label.mj-check-roll").each(function() {

			var dependant = $(this).parent().next();
			dependant.hide();

			$(this).change(function() {
				dependant.toggle();
			});

			// TODO: autofill age/height + autoselect
		});
		
		
		/*
		 * General fixes
		 */

		$(c).find("input[type=radio]").fix_radios();
		
		LiveInit.navOnly(c);
	}
}


$(function() {
	
	// the code after this point is executed when the DOM finished loading
	
	// inits in liveInit need to be called after ajax calls and subsequent DOM manipulations
	LiveInit.all(document);
	
	// handling stepflow submit/animation
	$(".stepflow-frame > form").submit(function() {

		// save reference
		var form = this;

		// nav loading
		$("#stepflow-nav button").attr('disabled', 'disabled');
		$("#stepflow-nav ." + ((this.action.search(/\/stepflow$/) != -1)? 'next':'previous') + " .ajax-loading").show();

		$.post(this.action, $(this).serialize(), function(r) {
			
			if (r.move != 'redirect')
			{
				// added ".find("stepflow-blocks").contents()" after small layout refactoring
				var fields = $(r.block).find("#stepflow-blocks .form-inputs");
				var nav = $(r.block).find("#stepflow-nav").contents();
			}
			
			if (r.move == 'next')
			{
				var pos = {from: 0, to: -898}
				var op = function(f, a) { return f.appendTo(a); }
			}
			else if (r.move == 'prev')
			{
				var pos = {from: -898, to: 0}
				var op = function(f, a) { return f.prependTo(a); }
			}
			
			if (['next', 'prev'].indexOf(r.move) != -1)
			{
				var outgoing = $("#stepflow-blocks .form-inputs");
				var timing = 1000; //ms
				
				var incoming = op(fields, $('#stepflow-blocks')).css({opacity: 0});
				$('#stepflow-blocks').css({left: pos.from}); // specific to prev
				LiveInit.all(incoming[0]);
				$('#stepflow-blocks').cleanWhitespace();

				// nav loaded
				nav.find("button").attr('disabled', 'disabled');
				$("#stepflow-nav").html(nav);
				LiveInit.navOnly($("#stepflow-nav")[0]);
				
				// update form action, (fix formaction change), specific to prev
				form.action = '/stepflow';

				// sliding animation
				outgoing.animate({opacity: 0}, timing, 'swing');
				incoming.animate({opacity: 1}, timing, 'swing');
				$("#stepflow-blocks").animate({left: pos.to}, timing, 'swing', function() {
					// complete
					outgoing.remove();
					$('#stepflow-blocks').css({left: 0}); // specific to next
					// nav activate
					$("#stepflow-nav button").removeAttr('disabled');
				});
			}
			else if (r.move == 'prev')
			{
				var outgoing = $("#stepflow-blocks .form-inputs");
				var timing = 1000; //ms
				
				var incoming = fields.prependTo($('#stepflow-blocks')).css({opacity: 0});
				$('#stepflow-blocks').css({left: -898});
				LiveInit.all(incoming[0]);
				$('#stepflow-blocks').cleanWhitespace();

				// nav loaded
				nav.find("button").attr('disabled', 'disabled');
				$("#stepflow-nav").html(nav);
				LiveInit.navOnly($("#stepflow-nav")[0]);
				
				// update form action, (fix formaction change)
				form.action = '/stepflow';

				// sliding animation
				outgoing.animate({opacity: 0}, timing, 'swing');
				incoming.animate({opacity: 1}, timing, 'swing');
				$("#stepflow-blocks").animate({left: 0}, timing, 'swing', function() {
					// complete
					outgoing.remove();
					// nav activate
					$("#stepflow-nav button").removeAttr('disabled');
				});
			}
			else if (r.move == 'error')
			{
				// replace block with new block (which includes errors)
				$('#stepflow-blocks').children().first().replaceWith(fields);
				LiveInit.all($('#stepflow-blocks')[0]);

				$("#stepflow-nav .ajax-loading").hide();
				$("#stepflow-nav button").removeAttr('disabled');
			}
			else if (r.move == 'redirect')
			{
				window.location = r.redirect_path;
			}

		});

		return false;
	});
	
	// drag and drop
	if ($(".participants-view").length) {
		DragAndDrop.init();
	}
	
	// login bubble
	$("#login-link").click(function() {
		$("#login-bubble").slideToggle(250);
		return ($("#login-bubble").length > 0)? false : true;
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
	
});
