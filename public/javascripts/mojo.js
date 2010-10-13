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

$(function() {
	
	// the code after this point is executed when the DOM finished loading
	
	$("input[type=radio]").fix_radios();
	$(".mj-choice input[type=radio]").change(function() {
		
		var label = $(this).parent();
		var group = label.parents(".hybrid-input:eq(0)");
		
		group.find(".selected").removeClass("selected");
		label.addClass("selected");
	});
	
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
				$(this).parents("form").attr("action", $(this).attr("formaction"));
			});
		}
	});
	
});
