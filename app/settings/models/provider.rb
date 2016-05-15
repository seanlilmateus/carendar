module Carendar
  module Token
    class Provider

      FIELDS = {
        time: {
          hour:         %W[HH h hh],
          minute:       %W[mm],
          second:       %W[ss],
          period:       %W[a], #AM PM,
          milliseconds: %W[SSS],
          time_zone:    %W[ZZZ ZZZZ ZZ],
        },
        date: {
          year:          %W[yyy yy yyyy],
          month:         %W[M MM MMM MMMM],
          day_of_week:   %W[eee eeee eeeee eeeeee],
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
          [instance.time_token.first, ":", instance.time_token[1]]
        end


        def value_for_format(value)
          @fmt ||= NSDateFormatter.new
          @fmt.dateFormat = value
          @fmt.stringFromDate(self.date)
        end


        def date_formatter
          @date_formatter ||= NSDateFormatter.new
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
      def create_tokens(key)
        FIELDS[key].map do |key, value|
          name = key.to_s.gsub("_", " ").split(/(\W)/).map(&:capitalize).join
          Token::Component.new(name, key, value)
        end
      end

    end
  end
end
