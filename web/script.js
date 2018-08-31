$(document).ready(function () {
	
	var documentWidth = document.documentElement.clientWidth;
	var documentHeight = document.documentElement.clientHeight;
	
	// Retrieval form vars
	var rData 	= null;
	var rReason = document.getElementById('r-reason');
				
	window.addEventListener('message', function (event) {
		
		var data = event.data;
		
		if (data.action === "open") {
			
			
			if (data.form === "impound") {
				$('#impound-form').css('display', 'block');
				setupImpoundForm(data);
			}
			
			if (data.form === "retrieve") {
				$('#retrieve-form').css('display', 'block');
				setupRetrievalForm(data);
			}		
		}
		
		if (data.action == "close") {
			$('#impound-form').css('display', 'none');
			$('#retrieve-form').css('display', 'none');
		}
	});
		
	// On 'Esc' call close method
	document.onkeyup = function (data) {
		if (data.which == 27 ) {
			$.post('http://hrp_pd_impound/escape', JSON.stringify({}));
		}
	};
	
	function setupImpoundForm(data) {
		
		if (data.officer) {
			$('#officer').val(data.officer).prop('disabled', true);
		}
		
		if (data.mechanic) {
			$('#mechanic').val(data.mechanic).prop('disabled', true);
		}
		
		$('#owner').text(data.vehicle.owner);
		$('#plate').text(data.vehicle.plate);
	}
	
	
	$('#impound').click(function (event) {
		var releaseDate = new Date();
		var weeks 		= $('#weeks').val();
		var days 		= $('#days').val();
		var totalDays   = (parseInt(weeks) * 7) + parseInt(days);
				console.log(releaseDate);
		console.log(totalDays);
		releaseDate.setDate(releaseDate.getDate() + totalDays);
						console.log(releaseDate);
		releaseDate.addMonths(1);
				console.log(releaseDate);

		var datestring = releaseDate.getFullYear() + "-" + releaseDate.getMonth() + '-' + releaseDate.getDate();
		
		if(validateImpoundForm()) {
			$.post('http://hrp_pd_impound/impound', JSON.stringify({
				plate: $('#plate').text(),
				officer: $('#officer').val() || null,
				mechanic: $('#mechanic').val() || null,
				releasedate: datestring,
				fee: $('#fee').val(),
				reason: $('#reason').val(),
				notes: $('#notes').val() || null,
			}));
		}
	});
	
	function validateImpoundForm () {
		var success = true;
		var errors = $('#errors')
		errors.empty();
		
		var weeks = $('#weeks').val();
		var days = $('#days').val();
		var fee = $('#fee').val();
		var reason = $('#reason').val();
		
		if(weeks.isNaN || String(weeks).length < 1 || parseInt(weeks) < 0 || parseInt(weeks) > 41 || days.isNaN || String(days).length < 1 || parseInt(days) < 0 || parseInt(days) > 6) {
			errors.append(`<small>&#9679; Weeks have to be 0 or less than 41, days either 0 or less than 7.</small>`);
			success = false;
		}
		
		if(fee.isNaN || String(fee).length < 1 || parseInt(fee) < 250 || parseInt(fee) > 1000000) {
			errors.append(`<small>&#9679; Fee cannot be less than 250 or more than 1.000.000</small>`);
			success = false;
		}
		
		if(reason.length < 25 || reason.length > 10000) {
			errors.append(`<small>&#9679; Reason for impoundment cannot be less that 25 characters long.</small>`);
			success = false;
		}
		
		return success;
	}
	
	function setupRetrievalForm(data) {
		var vehicleHtml = "";
		rData = data;
		
		for(var i = 0; i < data.vehicles.length; i++) {
			
			var officer = "";
			
			var releasedate = new Date(data.vehicles[i].releasedate);
			var currentdate = new Date();
			
			if(data.vehicles[i].officer) {
				var t = data.vehicles[i].officer.split(" ");
				officer = t[0].charAt(0) + '. ' + t[1];
			}
			
			var row = `<tr>
				<td id="plate">${data.vehicles[i].plate}</td>
				<td id="date">${formatDate(releasedate)}</td>
				<td id="price">$ ${data.vehicles[i].fee}.00</td>
				<td id="officer">${officer}</td>`
						
			if(releasedate.getTime() > currentdate.getTime() || data.user.money < data.vehicles[i].fee) {
				button = `<td>
					<button class="btn info mr" id="info${i}">Info</button>
					<button class="btn pay success" id="pay${i}" disabled>Pay</button>
				</td></tr>`
			} else {
				button = `<td>
					<button class="btn info mr" id="info${i}">Info</button>
					<button class="btn pay success" id="${i}">Pay</button>
				</td></tr>`
			}
			
			row = row + button;
			vehicleHtml = vehicleHtml + row;
		}
		
		$(rReason).text(rData.vehicles[0].reason);
		$('#impounded-vehicles').html(vehicleHtml);
	}
	
	$('table').on('click', '.pay', function () {
		var plate = $(this).parent().parent().find('#plate').text();
		$.post('http://hrp_pd_impound/unimpound', JSON.stringify(plate));
	});
	
	$('table').on('click', '.info', function () {
		var index = $(this).attr('id');
		index = index.replace("info", "");
		$(rReason).text(rData.vehicles[parseInt(index)].reason);
	});
	
	
	$('#cancel, #exit').click(function (event) {
		$.post('http://hrp_pd_impound/escape', null);
	});
	
	function formatDate(date) {
		var year 	= date.getFullYear();
		var month 	= date.getMonth() + 1;
		var day 	= date.getDate();
		
		if (month < 10) {
				month = "0" + month.toString();
		}
		
		if (day < 10) {
			day = "0" + day.toString();
		}
		
		return `${month}-${day}-${year}`
	}
	
	// Date + months edge case handling: 
	Date.isLeapYear = function (year) { 
		return (((year % 4 === 0) && (year % 100 !== 0)) || (year % 400 === 0)); 
	};

	Date.getDaysInMonth = function (year, month) {
		return [31, (Date.isLeapYear(year) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
	};

	Date.prototype.isLeapYear = function () { 
		return Date.isLeapYear(this.getFullYear()); 
	};

	Date.prototype.getDaysInMonth = function () { 
		return Date.getDaysInMonth(this.getFullYear(), this.getMonth());
	};

	Date.prototype.addMonths = function (value) {
		var n = this.getDate();
		this.setDate(1);
		this.setMonth(this.getMonth() + value);
		this.setDate(Math.min(n, this.getDaysInMonth()));
		return this;
	};
});