# frozen_string_literal: true

module Cistern::HashSupport
  def hash_slice(*args, **kwargs); Cistern::Hash.slice(*args, **kwargs); end
  def hash_except(*args, **kwargs); Cistern::Hash.except(*args, **kwargs); end
  def hash_except!(*args, **kwargs); Cistern::Hash.except!(*args, **kwargs); end
  def hash_stringify_keys(*args, **kwargs); Cistern::Hash.stringify_keys(*args, **kwargs); end
end
