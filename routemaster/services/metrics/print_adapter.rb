require 'singleton'
require 'routemaster/services'
require 'routemaster/mixins/log'

module Routemaster
  module Services
    module Metrics
      class PrintAdapter
        include Singleton
        include Mixins::Log

        def batched
          yield
        end

        def gauge(name, value, tags)
          _log.info("#{__callee__}:#{name}:#{value} (#{tags.join(",")})")
        end

        # `counter` and `gauge` have identical implementations —
        # they're distinguished by sending the called method name (__callee__)
        # as the datapoint `type`
        alias_method :counter, :gauge
      end
    end
  end
end
