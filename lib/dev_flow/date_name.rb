# encoding: utf-8
module DateName

  # return the name of `from_date` on the view point of `to_date`
  def self.zh from_date, to_date = DateTime.now
    from_date = DateTime.parse(from_date) if from_date.is_a?(String)
    to_date = DateTime.parse(to_date) if to_date.is_a?(String)
    days = (from_date - to_date).to_i

    case days
    when -3 then "大前天"
    when -2 then "前天"
    when -1 then "昨天"
    when 0 then "今天"
    when 1 then "明天"
    when 2 then "后天"
    when 3 then "大后天"
    when -9 .. -4 then "#{(0-days).to_s}天前"
    when 4 .. 9 then "#{days.to_s}天后"
    else
      from_date.year == to_date.year ? from_date.strftime("%m月%d日") 
                                     :  from_date.strftime("%Y年%m月%d日")
    end
  end

end
