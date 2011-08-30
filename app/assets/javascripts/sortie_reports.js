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
});
