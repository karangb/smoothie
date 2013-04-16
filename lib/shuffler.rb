module Smoothie
  class Shuffler

    attr_reader :seed

    def initialize(values, seed = nil)
      @values = values
      @seed = seed || Random.new_seed
    end

    def get(opts = {})
      shuffle_values! unless @shuffled

      offset = opts[:offset] || 0
      limit = opts[:limit]   || 10

      @values[offset...(offset+limit)]
    end

    private

    def shuffle_values!
      generator = Random.new(@seed)
      length = @values.length

      @values = @values.dup

      i = length - 1
      while i > 0 do
        swap!(i, generator.rand(i + 1))
        i -= 1
      end

      @shuffled = true
    end

    def swap!(i, j)
      @values[i], @values[j] = @values[j], @values[i]
    end

  end
end