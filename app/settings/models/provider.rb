module Carendar
  module Token
    class Provider

      FIELDS = {
        time: {
          hour:          %W[hh HH h],
          minute:        %W[mm],
          second:        %W[ss],
          period:        %W[a], #AM PM,
          milliseconds:  %W[SSS],
          time_zone:     %W[zzz Z ZZZZ VV v V vvvv zzzz],
        },
        date: {
          year:          %W[yyyy yy],
          month:         %W[M MM MMM MMMM MMMMM],
          day_of_week:   %W[eee eeeee eeeeee eeee],
          day_of_month:  %W[dd d],
          week_of_month: %W[W],
          day_of_year:   %W[D DD DDD],
          week_of_year:  %W[w],
          quartal:       %W[qqq qq q QQQQ],
        }
      }

      private_class_method :new

      class << self

        def defaults
          items = [instance.time_token.first, ":", instance.time_token[1]]
          items = NSArray.arrayWithArray(items)
          NSKeyedArchiver.archivedDataWithRootObject(items)
        end


        def value_for_format(value)
          @fmt ||= NSDateFormatter.new
          @fmt.dateFormat = value
          @fmt.stringFromDate(self.date)
        end


        def date_formatter
          @date_formatter ||= NSDateFormatter.new.tap do |df|
            df.locale = NSLocale.autoupdatingCurrentLocale
            df.timeZone = NSTimeZone.systemTimeZone
          end
        end


        def instance
          Dispatch.once { @instance ||= new }
          @instance
        end


        def date
          @__date__ ||= begin
            f1 = NSDateFormatter.new
            f1.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            f1.dateFromString("#{NSDate.date.year}-05-17 16:09:45 +0200")
          end
        end

      end


      def date_token
        @date_items ||= create_tokens(:date)
      end


      def time_token
        @time_items ||= create_tokens(:time)
      end


      private
      def create_tokens(type)
        FIELDS[type].map do |key, value|
          name = key.to_s.gsub("_", " ").split(/(\W)/).map(&:capitalize).join
          Token::Component.new(name, type, value)
        end
      end

    end
  end
end