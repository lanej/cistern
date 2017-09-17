# frozen_string_literal: true

module Cistern
  class Mock
    def self.not_implemented(method = '')
      fail NotImplementedError, method ? "The call '#{method}' is not implemented" : ''
    end

    def self.random_hex(length)
      rand(('f' * length).to_i(16)).to_s(16).rjust(length, '0')
    end

    def self.random_numbers(length)
      rand(('9' * length).to_i).to_s
    end
  end
end
