# Copyright (C) 2009-2013 MongoDB, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module BSON

  # generates a wrapped Regexp with lazy compilation.
  # can represent flags not supported in Ruby's core Regexp class before compilation.
  class MongoRegexp

    # DOTALL in other implementations is MULTILINE in Ruby
    DOTALL = Regexp::MULTILINE
    LOCALE_DEPENDENT = DOTALL<<1
    UNICODE = LOCALE_DEPENDENT<<1

    attr_accessor :pattern
    alias_method  :source, :pattern
    attr_accessor :options

    # Create a new regexp.
    #
    # @param pattern [String]
    # @param options [Array, String]
    def initialize(pattern, *opts)
      @pattern = pattern
      @options = opts.first.is_a?(Fixnum) ? opts.first : str_opts_to_int(opts.join)
    end

    # Attempt to convert a native Ruby Regexp to a MongoRegexp.
    #
    # @param regexp [Regexp] The native Ruby regexp object to convert to MongoRegexp.
    #
    # @return [MongoRegexp]
    def self.from_native(regexp)
      warn 'Ruby Regexps use different syntax and set of flags than BSON regular expressions.'
      pattern = regexp.source
      opts = 0
      opts |= Regexp::IGNORECASE if (Regexp::IGNORECASE & regexp.options != 0)
      opts |= DOTALL             if (Regexp::MULTILINE & regexp.options != 0)
      opts |= Regexp::EXTENDED   if (Regexp::EXTENDED & regexp.options != 0)
      self.new(pattern, opts)
    end

    # Check equality of this wrapped Regexp with another.
    #
    # @param [MongoRegexp] regexp
    def eql?(regexp)
      regexp.kind_of?(MongoRegexp) &&
        self.pattern == regexp.pattern &&
        self.options == regexp.options
    end
    alias_method :==, :eql?

    # Get a human-readable representation of this Regexp wrapper.
    def inspect
      "#<BSON::MongoRegexp:0x#{self.object_id} " <<
      "@pattern=#{@pattern}>, @options=#{@options}>"
    end

    # Clone or dup the current MongoRegexp.
    def initialize_copy
      a_copy = self.dup
      a_copy.pattern = self.pattern.dup
      a_copy.options = self.options.dup
      a_copy
    end

    # Compile the MongoRegexp.
    #
    # @return [Regexp] A ruby core Regexp object.
    def unsafe_compile
      warn 'Regular expressions retreived from the server may contain a pattern or flags ' <<
           'not supported by Ruby Regexp objects.'
      regexp_opts = 0
      regexp_opts |= Regexp::IGNORECASE if (options & Regexp::IGNORECASE != 0)
      regexp_opts |= Regexp::MULTILINE  if (options & DOTALL != 0)
      regexp_opts |= Regexp::EXTENDED   if (options & Regexp::EXTENDED != 0)
      Regexp.new(pattern, regexp_opts)
    end

    private
    # Convert the string options to an integer.
    #
    # @return [Fixnum] The Integer representation of the options.
    def str_opts_to_int(str_opts="")
      opts = 0
      opts |= Regexp::IGNORECASE if str_opts.include?('i')
      opts |= LOCALE_DEPENDENT if str_opts.include?('l')
      opts |= DOTALL  if str_opts.include?('s')
      opts |= UNICODE if str_opts.include?('u')
      opts |= Regexp::EXTENDED  if str_opts.include?('x')
      opts
    end
  end
end
