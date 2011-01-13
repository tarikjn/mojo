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

$(function() {
	
	// the code after this point is executed when the DOM finished loading
	
	// animate
	//$("#anim .sliding")[0].left 0 -> -898
	$("#clickme").click(function() {
		var manager = new jsAnimManager(40);
		var anim = manager.createAnimObject("animit");
		anim.add({property: Prop.left, from: 0, to: -898, duration: 1500, ease: jsAnimEase.parabolicNeg});
	});
	
	// load Google Maps (code in mojo-geo.js)
	if ($('#map_canvas').length)
		Geo.initialize();
	
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
	$(".mj-choice, .mj-merged-choices, .mj-operation-choices").find("input[type=radio]").change(function() {
		
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
