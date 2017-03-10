# encoding: utf-8
# frozen_string_literal: true

module Yoga
  # A scanner.  This performs scanning over a series of tokens.
  # It is built to lazily scan whenever it is required, instead
  # of all at once.  This integrates nicely with the parser.
  module Scanner
    # The file of the scanner.  This can be overwritten to provide a descriptor
    # for the file.
    #
    # @return [::String]
    attr_reader :file

    # Initializes the scanner with the given source.  Once the
    # source is set, it shouldn't be changed.
    #
    # @param source [::String] The source.
    def initialize(source, file)
      @source = source
      @file = file
      @line = 1
      @last_line_at = 0
    end

    # @overload call(&block)
    #   For every token that is scanned, the block is yielded to.
    #
    #   @yieldparam token [Scanner::Token]
    #   @return [self]
    # @overload call
    #   Returns an enumerable over the tokens in the scanner.
    #
    #   @return [::Enumerable<Scanner::Token>]
    def call
      return to_enum(:call) unless block_given?
      @scanner = StringScanner.new(@source)
      @line = 1

      until @scanner.eos?
        value = scan
        yield value unless value == true || !value
      end

      yield eof_token
      self
    end

    # The scanning method.  This should return one of two values: a {Token},
    # or `true`.  `nil` should _never_ be returned.  This performs an
    # incremental scan of the document; it returns one token at a time.  If
    # something matched, but should not emit a token, `true` should be
    # returned.  The implementing class should mark this as private or
    # protected.
    #
    # @abstract
    #   Please implement this method in order to make the class a scanner.
    # @return [Yoga::Token, true]
    def scan
      fail NotImplementedError, "Please implement #{self.class}#scan"
    end

  protected

    # Returns a location at the given location.  If a size is given, it reduces
    # the column number by the size and returns the size from that.
    #
    # @example
    #   @scanner.string # => "hello"
    #   @line # => 1
    #   @scanner.charpos # => 5
    #   location # => #<Yoga::Location <anon>:1.6>
    #   location(5) # => #<Yoga::Location <anon>:1.1-6
    # @param size [::Numeric] The size of the token.
    # @return [Yoga::Location]
    def location(size = 0)
      start = (@scanner.charpos - @last_line_at) + 1
      column = (start - size)..start
      Location.new(file, current_line, column)
    end

    # Creates a scanner token with the given name and source.  This grabs the
    # location using {#location}, setting the size to the size of the source
    # text.  The source is frozen before initializing the token.
    #
    # @example
    #   emit(:<, "<") # => #<Yoga::Token kind=:< source="<">
    # @return [Yoga::Token]
    def emit(kind, source = @scanner[0])
      Token.new(kind.freeze, source.freeze, location(source.length))
    end

    # Attempts to match the given token.  The first argument can be a string,
    # a symbol, or a regular expression.  If the matcher is a symbol, it's
    # coerced into a regular expression, with a forward negative assertion for
    # any alphanumeric characters, to prevent partial matches (see
    # {#symbol_negative_assertion}).  If the matcher is a regular expression,
    # it is left alone.  Otherwise, `#to_s` is called and passed to
    # `Regexp.escape`.  If the text is matched at the current position, a token
    # is returned; otherwise, nil is returned.
    #
    # @param matcher [::Symbol, ::Regexp, #to_s]
    # @param kind [::Symbol] The kind of token to emit.  This defaults to a
    #   symbol version of the matcher.
    # @return [Yoga::Token, nil]
    def match(matcher, kind = :"#{matcher}")
      matcher = case matcher
                when ::Symbol then /#{::Regexp.escape(matcher.to_s)}#{symbol_negative_assertion}/
                when ::Regexp then matcher
                else /#{::Regexp.escape(matcher.to_s)}/
                end

      ((kind && emit(kind)) || true) if @scanner.scan(matcher)
    end

    # A regular expression to match all kinds of lines.  All of them.
    #
    # @return [::Regexp]
    LINE_MATCHER = /\r\n|\n\r|\n|\r/

    # Matches a line.  This is separate in order to allow internal logic,
    # such as line counting and caching, to be performed.
    #
    # @return [Boolean] If the line was matched.
    def match_line(kind: false, required: false)
      result = @scanner.scan(LINE_MATCHER)
      (required ? return : fail UnexpectedCharacterError) unless result
      @line += 1
      @last_line_at = @scanner.charpos
      (kind && emit(kind)) || true
    end

    # Returns the number of lines that have been covered so far in the scanner.
    # I recommend replacing this with an instance variable that caches the
    # result of it, so that whenever you scan a new line, it just increments
    # the line count.
    #
    # @return [::Numeric]
    def current_line
      # @scanner.string[0..@scanner.charpos].scan(/\A|\r\n|\n\r|\n|\r/).size
      @line
    end

    # The negative assertion used for converting a symbol matcher to a regular
    # expression.  This is used to prevent premature matching of other
    # identifiers.  For example, if `module` is a keyword, and `moduleA` is
    # an identifier, this negative assertion allows the following expression
    # to properly match as such: `match(:module) || module(/[a-zA-Z], :IDENT)`.
    #
    # @return [#to_s]
    def symbol_negative_assertion
      "(?![a-zA-Z])"
    end

    # Returns a token that denotes that the scanner is done scanning.
    #
    # @return [Yoga::Token]
    def eof_token
      emit(:EOF, "")
    end
  end
end
