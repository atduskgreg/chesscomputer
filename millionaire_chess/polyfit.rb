class Polyfit
	COEFFICIENTS = [ -3.33050902e-12, 7.69651076e-09, -6.73076942e-06, 2.79500149e-03, 4.92282512e-01] # from numpy fit

	def polyval(coefficients, val)
		result = 0
		coefficients.each_with_index do |coef,i|
			result += coef * (val**(coefficients.length - (i+1)))
		end
		return result
	end

	def odds(elo1, elo2)
		return polyval(COEFFICIENTS, elo1 - elo2)
	end
end