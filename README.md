# Yoga
[![Build Status][build-status]][build-status-link] [![Coverage Status][coverage-status]][coverage-status-link]

A helper for your Ruby parsers.  This adds helper methods to make parsing
(and scanning!) easier and more structured.  If you're looking for an LALR
parser generator, that isn't this.  This is designed to help you construct
Recursive Descent parsers - which are solely LL(k).  If you want an LALR parser
generator, see [_Antelope_](https://github.com/medcat/antelope) or [Bison](https://www.gnu.org/software/bison/).

Yoga requires [Mixture](https://github.com/medcat/mixture) for parser node
attributes.  However, the use of the parser nodes included with Yoga are
completely optional.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "yoga"
```

And then execute:

    $ bundle

## Usage

To begin your parser, you will first have to create a scanner.  A scanner
takes the source text and generates "tokens."  These tokens are abstract
representations of the source text of the document.  For example, for the
text `class A do`, you could have the tokens `:class`, `:CNAME`, and `:do`.
The actual names of the tokens are completely up to you.  These token names
are later used in the parser to set up expectations - for example, for the
definition of a class, you could expect a `:class`, `:CNAME`, and a `:do`
token.

Essentially, the scanner breaks up the text into usable, bite-sized pieces
for the parser to chomp on.  Here's what scanner may look like:

```ruby
module MyLanguage
  class Scanner
    # All of the behavior from Yoga for scanners.  This provides the
    # `match/2` method, the `call/0` method, the `match_line/1` method,
    # the `location/1` method, and the `emit/2` method.  The major ones that
    # are used are the `match/2`, the `call/0`, and the `match_line/1`
    # methods.
    include Yoga::Scanner

    # This must be implemented.  This is called for the next token.  This
    # should only return a Token, or true.
    def scan
      # Match with a string value escapes the string, then turns it into a
      # regular expression.
      match("[") || match("]") ||
      # Match with a symbol escapes the symbol, and turns it into a regular
      # expression, suffixing it with `symbol_negative_assertion`.  This is
      # to prevent issues with identifiers and keywords.
      match(:class) || match(:func) ||
      # With a regular expression, it's matched exactly.  However, a token
      # name is highly recommended.
      match(/[a-z][a-zA-Z0-9_]*[!?=]?/, :IDENT)
    end
  end
end
```

And that's it!  You now have a fully functioning scanner.  In order to use it,
all you have to do is this:

```ruby
source = "class alpha [func a []]"
MyLanguage::Scanner.new(source).call # => #<Enumerable ...>
```

Note that `Scanner#call` returns an enumerable.  `#call` is aliased as `#each`.
What this means is that tokens aren't generated until they're requested by the
parser - each token is generated from the source incrementally.  If you want
to retrieve all of the tokens immediately, you have to first convert it into
a string, or perform some other operation on the enumerable (since it isn't
lazy):

```ruby
MyLanguage::Scanner.new(source).call.to_a # => [...]
```

The scanner also automatically adds location information to all of the tokens.
This is handled automatically by `match/2` and `emit/2` - the only issue being
that all regular expressions **must not** include a newline.  Newlines should
be matched with `match_line/1`; if lines must be emitted as a token, you can
pass the kind of token to emit to `match_line/1` using the `kind:` keyword.

You may notice that all of the tokens have `<anon>` set as the location's file.
This is the default location, which is provided to the initializer:

```ruby
MyLanguage::Scanner.new(source, "foo").call.first.location.to_s # => "foo:1.1-6"
```

Parsers are a little bit more complicated.  Before we can pull up the parser,
let's define a grammar and some node classes.

```
; This is the grammar.
<root> = *<statement>
<statement> = <expression> ';'
<expression> = <expression> <op> <expression>
<expression> /= <int> ; here, <int> is defined by the scanner.
<op> = '+' / '-' / '*' / '/' / '^' / '%' / '='
```

```ruby
module MyLanguage
  class Parser
    class Root < Yoga::Node
      # An attribute on the node.  This is required for Yoga nodes since the
      # update syntax requires them.  The type for the attribute is optional.
      attribute :statements, type: [Yoga::Node]
    end

    class Expression < Yoga::Node
    end

    class Operation < Expression
      attribute :operator, type: ::Symbol
      attribute :left, type: Expression
      attribute :right, type: Expression
    end

    class Literal < Expression
      attribute :value, type: ::Integer
    end
  end
end
```

With those out of the way, let's take a look at the

## Development



## Contributing

Bug reports and pull requests are welcome on GitHub at
<https://github.com/medcat/yoga>. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

[build-status]: https://travis-ci.org/medcat/yoga.svg?branch=master
[coverage-status]: https://coveralls.io/repos/github/medcat/yoga/badge.svg?branch=master
[build-status-link]: https://travis-ci.org/medcat/yoga
[coverage-status-link]: https://coveralls.io/github/medcat/yoga?branch=master
