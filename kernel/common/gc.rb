module GC
  def self.count
    data = stat
    data[:"gc.young.count"] + data[:"gc.immix.count"]
  end

  def self.time
    data = stat
    data[:"gc.young.ms"] +
      data[:"gc.immix.stop.ms"] +
      data[:"gc.large.sweep.ms"]
  end

  def self.stat
    Rubinius::Metrics.data.to_hash
  end

  module Profiler
    @enabled = true
    @since   = 0

    def self.clear
      @since = GC.time
      nil
    end

    def self.disable
      # Treat this like a request that we don't honor.
      ret = !@enabled
      @enabled = false
      ret
    end

    def self.enable
      # We don't support disable, so sure! enabled!
      ret = !@enabled
      @enabled = true
      ret
    end

    def self.enabled?
      @enabled
    end

    def self.report(out = $stdout)
      out.write result
    end

    def self.result
      stats = GC.stat

      out = <<-OUT
Complete process runtime statistics
===================================

Collections
                         Count       Total time / concurrent (ms)
Young   #{sprintf("% 22d", stats[:'gc.young.count'])} #{sprintf("% 16d             ", stats[:'gc.young.ms'])}
Full    #{sprintf("% 22d", stats[:'gc.immix.count'])} #{sprintf("% 16d / % 10d", stats[:'gc.immix.stop.ms'], stats[:'gc.immix.concurrent.ms'])}

Allocation
             Objects allocated        Bytes allocated
Young   #{sprintf("% 22d", stats[:'memory.young.objects'])} #{sprintf("% 22d", stats[:'memory.young.bytes'])}
Promoted#{sprintf("% 22d", stats[:'memory.promoted.objects'])} #{sprintf("% 22d", stats[:'memory.promoted.bytes'])}
Mature  #{sprintf("% 22d", stats[:'memory.immix.objects'])} #{sprintf("% 22d", stats[:'memory.immix.bytes'])}


Usage
                    Bytes used
Young   #{sprintf("% 22d", stats[:'memory.young.bytes'])}
Mature  #{sprintf("% 22d", stats[:'memory.immix.bytes'])}
Large   #{sprintf("% 22d", stats[:'memory.large.bytes'])}
Code    #{sprintf("% 22d", stats[:'memory.code.bytes'])}
Symbols #{sprintf("% 22d", stats[:'memory.symbols.bytes'])}
      OUT
    end

    def self.total_time
      (GC.time - @since) / 1000.0
    end
  end
end
