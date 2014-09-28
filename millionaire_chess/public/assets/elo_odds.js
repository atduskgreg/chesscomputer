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