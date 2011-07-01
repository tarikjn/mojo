var CCSlider =
{
	moveBar: function(bg, pos, scaleFactor)
	{
		var func = ($(bg).closest(".cc-slider-control").hasClass("centered-slider")) ?
			this.moveCenteredBar
			: this.moveLeveledBar;
		
		func(bg, pos, scaleFactor);
	},
	moveLeveledBar: function(bg, pos, scaleFactor)
	{
		// select right ruler mark
	    $(bg).closest(".cc-slider").find(".cc-slider-marks").children()
	        .removeClass("selected")
	        .eq(pos).addClass("selected");
	    
	    // update background bar
	    $(bg).find(".cc-slider-bar").width(2 + pos * scaleFactor)
	        .css('background-color', "#" + leveledSliderColors[pos]);
	},
	moveCenteredBar: function(bg, pos, scaleFactor)
	{
		// update background bar
	    $(bg).find(".cc-slider-bar").css({left: (4 + pos * scaleFactor) + 'px'})
	    	.css('background-color', "#" + centeredSliderColors[pos]);
	},
	
	// hack for YUI Slider
	// required for smooth sync of slider-bar
	moveThumb: function(x, y, skipAnim, midMove)
	{
		var t = this.thumb,
		    self = this,
		    p,_p,anim;
		
		if (!t.available) {
		    return;
		}
		
		
		t.setDelta(this.thumbCenterPoint.x, this.thumbCenterPoint.y);
		
		_p = t.getTargetCoord(x, y);
		p = [Math.round(_p.x), Math.round(_p.y)];
		
		// no animation
		t.setDragElPos(x, y);
		if (!midMove) { // hack is on this line
		    this.endMove();
		}
	}		
}

/**
* CC Slider Initialization
*/
function CCSliderSetup(bg, thumb, textfield)
{
    var Event = YAHOO.util.Event,
        Dom   = YAHOO.util.Dom,
        lang  = YAHOO.lang,
        slider;

    // The slider can move 0 pixels up
    var topConstraint = 0;

    // The slider can move 200 pixels down
    var bottomConstraint = 200;

    // Custom scale factor for converting the pixel offset into a real value
    var scaleFactor = 50;

    // The amount the slider moves when the value is changed with the arrow
    // keys
    var keyIncrement = 50;

    var tickSize = 50;

    // what follows should always be executed on DOM Ready

	slider = YAHOO.widget.Slider.getHorizSlider(bg, 
	                 thumb, topConstraint, bottomConstraint, tickSize);
	slider.keyIncrement = keyIncrement;
	slider.moveThumb = CCSlider.moveThumb;
	
	slider.getRealValue = function() {
	    return Math.round(this.getValue() / scaleFactor + 1);
	}
	
	slider.subscribe("change", function(offsetFromStart) {
	    
	    var fld = Dom.get(textfield);
	
	    // use the scale factor to convert the pixel offset into a real
	    // value
	    var actualValue = slider.getRealValue();
	
	    // update the text box with the actual value
	    fld.value = actualValue;
	
	    // Update the title attribute on the background.  This helps assistive
	    // technology to communicate the state change
	    //Dom.get(bg).title = "slider value = " + actualValue;
	    
	    CCSlider.moveBar(Dom.get(bg), actualValue - 1, scaleFactor);
	});
	
	// set slider default value
	slider.setValue(Math.round((Dom.get(textfield).value - 1) * scaleFactor));
}

/**
* colors
*/
var leveledSliderColors = ['ff0000', 'ff8000', 'ffff00', '80ff00', '00ff00'],
    centeredSliderColors = ['ff0000', 'ffff00', '00ff00', 'ffff00', 'ff0000'];

var SortieReport = {
	hideExtend: function() {
		
	},
	applyReportState: function() {
		switch (this.value)
		{
			case 'on-time':
				$(".report-culprits").hide();
				$(".ratings").show();
				break;
			case 'late':
				$(".report-culprits").show();
				$(".ratings").show();
				break;
			case 'cancelled':
				$(".ratings").hide();
				$(".report-culprits").show();
				break;
			default: // none selected, DRY up with the onload
				$(".report-culprits").hide();
				$(".ratings").hide();
				break;
		}
	},
	applyReportPlace: function() {
		switch (this.value)
		{
			case '0':
				$(".place-review").hide();
				break;
			case '1':
				$(".place-review").show();
				break;
		}
	},
	setCulpritTitle: function() {
		var that = ($(this).is("input"))? $(this) : $(this).parents("label:eq(0)").find("input");
		var title = undefined;
		
		switch (that.val())
		{
			case 'late':
				title = 'was late';
				break;
			case 'cancelled':
				switch (that.parent().find("select").val())
				{
					case 'no-show':
						title = 'didn\'t show';
						break;
					default: // before, after
						title = 'cancelled';
						break;
				}
				break;
		}
		
		$(".report-culprits .title .section").text(title);
	}
}

$(function() {
	
	// the code after this point is executed when the DOM finished loading
	$("form .reply .extend").each(function() {
		if (!$(this).parent().hasClass("selected")) $(this).hide();
		// Lib.applySelected takes care of the rest (maybe extend it)
	})
	
	$(".report-culprits").hide();
	$(".ratings").hide();
	$(".place-review").hide();
	
	$(".mj-choice.report-state").find("input[type=radio]")
		.change(SortieReport.applyReportState).filter(":checked").each(SortieReport.applyReportState);
		
	$(".mj-choice.report-place").find("input[type=radio]")
		.change(SortieReport.applyReportPlace).filter(":checked").each(SortieReport.applyReportPlace);
		
	// set title for culprit
	$(".mj-choice.report-state").find("input[type=radio][value=late|cancelled]")
		.change(SortieReport.setCulpritTitle).filter(":checked").each(SortieReport.setCulpritTitle);
	$(".mj-choice.report-state").find("input[type=radio][value=cancelled]").parent().find("select")
		.change(SortieReport.setCulpritTitle);
	
	// quick selects
	$(".quick-selects button").click(function() {
		
		var elements = $(this).parent().parent().find("input");
		var checked = ($(this).hasClass("select-all"))? true:false;
		
		elements.prop("checked", checked).change();
		
		return false;
	})
	
	/**
	 * rating widget
	 */
	// mouse over rating
	$(".rating-input").find(".rating-label").hover(function() {
		for (var p = $(this).prev(); p.length > 0; p = p.prev())
		{
			p.addClass("fill");
		}
	}, function() {
		for (var p = $(this).prev(); p.length > 0; p = p.prev())
		{
			p.removeClass("fill");
		}
	});
	// load value from hidden input
	$(".rating").each(function() {
		var score = $(this).find("input").val();
		if (score !== undefined) {
			$(this).find(".rating-input .rating-label").slice(0, score).addClass("set");
		}
	})
	// handle click and set input
	$(".rating .rating-input .rating-label").click(function() {
		// better event handling would listen event on .rating-input and look for target/work with indexes
		for (var p = $(this); p.length > 0; p = p.prev())
		{
			p.addClass("set");
		}
		for (var p = $(this).next(); p.length > 0; p = p.next())
		{
			p.removeClass("set");
		}
		
		// set input
		$(this).parents(".rating:eq(0)").find("input").val($(this).index() + 1);
	})
	
	// autogrow textarea's
	$(".question textarea").autogrow();
	
	/**
	* CC Slider Set-up
	*/
	// markup replacement
	$(".cc-slider-control").each(function() {
		var name = $(this).find("input").attr('name'),
		    defaultVal = $(this).find("input:checked").val() || 3,
		    input = document.createElement('input'),
		    slider = document.createElement('div'),
		    thumbImg;

		slider.className = "cc-slider yui-skin-sam";

		// $(this).hasClass("centered-slider")
		thumbImg = "/images/slider/centered-thumb.png";

		input.setAttribute('type', 'hidden');
		input.setAttribute('name', name);
		input.setAttribute('id', name + '-slider-converted-value');
		input.value = defaultVal;

		var SliderMarkup =
			'<div id="' + name + '-slider-bg" class="yui-h-slider" tabindex="0">\
        		<div id="' + name + '-slider-thumb" class="yui-slider-thumb"><img src="' + thumbImg + '"></div>\
	    		<div class="cc-slider-bar"></div>\
	    	</div>';

	    $(slider).append(SliderMarkup);
	    slider.appendChild(input);

	    // replacement
	    this.replaceChild(slider, this.firstChild);
	});
	// initialization
	$(".cc-slider").each(function() {
		var bg = $(this).find(".yui-h-slider").attr('id'),
		    thumb = $(this).find(".yui-slider-thumb").attr('id'),
		    textfield = $(this).find("input").attr('id');
		CCSliderSetup(bg, thumb, textfield);
	});
});
