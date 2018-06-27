module DcpChecker
  class Time
    def duration
      rest, secs = self.divmod(60)
      rest, mins = rest.divmod(60)
      days, hours = rest.divmod(24)

      result = []
      result << "#{days} days" if days > 0
      result << "#{hours} hours" if hours > 0
      result << "#{mins} minutes" if mins > 0
      result << "#{secs} seconds" if secs > 0
      result.join(' ')
    end
  end
end
