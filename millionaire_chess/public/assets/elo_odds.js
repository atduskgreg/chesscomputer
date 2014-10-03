function eloString(whiteElo, blackElo, names){
	p = percentageOdds(whiteElo, blackElo);
	percent = toPrecision(parseFloat(toPrecision(p,2)) * 100, 0);

	roundedPercent = Math.round(percent/10.0)*10


	odds = reduceFraction(roundedPercent,100);

	var winnerString = "";
	if(whiteElo > blackElo){
		winnerString = "white";

		if(names){
			winnerString = names[0];
		} 
	} else {
		winnerString = "black";
		if(names){
			winnerString = names[1];
		} 
	}

	return "<p><b>Favorite: " +winnerString + "<br/>"+percent+"% ("+odds[0]+"/"+odds[1]+")</b></p>";

}

function polyval(coefficients, val){
	var result = 0;
	for(var i = 0; i < coefficients.length; i++){
		result += coefficients[i]*Math.pow(val,coefficients.length-(i+1));
	}
	return result;
}
function reduceFraction(numerator,denominator){
  var gcd = function gcd(a,b){
    return b ? gcd(b, a%b) : a;
  };
  gcd = gcd(numerator,denominator);
  return [numerator/gcd, denominator/gcd];
}

function toPrecision(value, precision) {
	var precision = precision || 0,
    neg = value < 0,
    power = Math.pow(10, precision),
    value = Math.round(value * power),
    integral = String((neg ? Math.ceil : Math.floor)(value / power)),
    fraction = String((neg ? -value : value) % power),
    padding = new Array(Math.max(precision - fraction.length, 0) + 1).join('0');
	
    return precision ? integral + '.' +  padding + fraction : integral;
}

function percentageOdds(elo1, elo2){
	var diff = Math.abs(elo1-elo2);

	if(diff > 600){
		return 0.99;
	}else {
		var c = [ -3.33050902e-12, 7.69651076e-09, -6.73076942e-06, 2.79500149e-03, 4.92282512e-01];
		return polyval(c, diff);
	}
}