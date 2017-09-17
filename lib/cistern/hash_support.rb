# frozen_string_literal: true

module Cistern::HashSupport
  def hash_slice(*args); Cistern::Hash.slice(*args); end
  def hash_except(*args); Cistern::Hash.except(*args); end
  def hash_except!(*args); Cistern::Hash.except!(*args); end
  def hash_stringify_keys(*args); Cistern::Hash.stringify_keys(*args); end
end
