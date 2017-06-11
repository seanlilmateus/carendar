module TimeIntervalUtils
  module_function
  def time_interval(interval)
    return "At time of event" if interval.zero?
    minute = 60.0
    hour   = minute * 60.0
    day    = hour * 24.0
    week   = day * 7.0
  
    num  = interval.abs
    unit = ""
  
    if num >= week
      value, num = num.divmod(week)
      unit = "#{value} weeks" if value > 1
      unit = localized_string('one.week') if value == 1 
    end
  
    if num >= day
      value, num = num.divmod(day)
      ret = (value > 1) ? "#{value} days" : 'all-day'
      unit += "|#{localized_string(ret)}"
    end
  
    if num >= hour
      value, num = num.divmod(hour)
      ret = (value > 1) ? "#{value} hours" : 'one.hour'
      unit += "|#{localized_string(ret)}"
    end
    
    if num >= minute
      value, num = num.divmod(minute)
      ret = if (value > 1)
        "#{value} minutes"
      elsif value == 1
        'one.minute'
      end
      unit += "|#{localized_string(ret)}" if ret
    end
  
    unit = replace_all_but_last(unit, '|', ', ')
    "#{unit.strip}"
  end

  def replace_all_but_last(str, target, substr)
    result = str.stringByReplacingOccurrencesOfString(target, withString:substr)
    result.sub!(/,/, '')
    result.reverse.sub(substr.reverse, localized_string('and').reverse).reverse
  end
  
end