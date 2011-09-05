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


$(function() {

	// the code after this point is executed when the DOM finished loading
	
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
		thumbImg = "/assets/slider/centered-thumb.png";

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
}