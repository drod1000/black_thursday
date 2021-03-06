module SAAssistant
  def sum(array)
    array.reduce(0) do |sum, number|
      sum += number
      sum
    end
  end

  def mean(array)
    sum(array) / array.length.to_f
  end

  def average(num_1, num_2)
    (num_1.to_f / num_2).round(2)
  end

  def squared_differences_sum(array)
    array.reduce(0) do |result, number|
      result += (mean(array) - number) ** 2
      result
    end
  end

  def standard_deviation(array)
    Math.sqrt(squared_differences_sum(array)/ (array.length - 1).to_f).round(2)
  end

  def above_standard_deviation(array, standard_deviations)
    cutoff = mean(array) + (standard_deviations * standard_deviation(array))
    array.find_all do |number|
      number > cutoff
    end
  end

  def cutoff(array, deviations)
    mean(array) + (deviations * standard_deviation(array))
  end

  def days_of_week
    { 0 => "Sunday",
      1 => "Monday",
      2 => "Tuesday",
      3 => "Wednesday",
      4 => "Thursday",
      5 => "Friday",
      6 => "Saturday",
    }
  end

end
