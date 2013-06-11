require 'time'
require 'base64'

#Pulled from ActiveSupport
class Hash

  DEFAULT_ENCODINGS = {
      "binary" => "base64"
    } unless defined?(DEFAULT_ENCODINGS)

    TYPE_NAMES = {
      "Symbol"     => "symbol",
      "Fixnum"     => "integer",
      "Bignum"     => "integer",
      "BigDecimal" => "decimal",
      "Float"      => "float",
      "TrueClass"  => "boolean",
      "FalseClass" => "boolean",
      "Date"       => "date",
      "DateTime"   => "dateTime",
      "Time"       => "dateTime",
      "Array"      => "array",
      "Hash"       => "hash"
    } unless defined?(TYPE_NAMES)

    FORMATTING = {
      "symbol"   => Proc.new { |symbol| symbol.to_s },
      # "date"     => Proc.new { |date| date.to_s(:db) },
      # "dateTime" => Proc.new { |time| time.xmlschema },
      # "binary"   => Proc.new { |binary| ::Base64.encode64(binary) },
      # "yaml"     => Proc.new { |yaml| yaml.to_yaml }
    } unless defined?(FORMATTING)

  # Returns a string containing an XML representation of its receiver:
  #
  #   {'foo' => 1, 'bar' => 2}.to_xml
  #   # =>
  #   # <?xml version="1.0" encoding="UTF-8"?>
  #   # <hash>
  #   #   <foo type="integer">1</foo>
  #   #   <bar type="integer">2</bar>
  #   # </hash>
  #
  # To do so, the method loops over the pairs and builds nodes that depend on
  # the _values_. Given a pair +key+, +value+:
  #
  # * If +value+ is a hash there's a recursive call with +key+ as <tt>:root</tt>.
  #
  # * If +value+ is an array there's a recursive call with +key+ as <tt>:root</tt>,
  #   and +key+ singularized as <tt>:children</tt>.
  #
  # * If +value+ is a callable object it must expect one or two arguments. Depending
  #   on the arity, the callable is invoked with the +options+ hash as first argument
  #   with +key+ as <tt>:root</tt>, and +key+ singularized as second argument. The
  #   callable can add nodes by using <tt>options[:builder]</tt>.
  #
  #     'foo'.to_xml(lambda { |options, key| options[:builder].b(key) })
  #     # => "<b>foo</b>"
  #
  # * If +value+ responds to +to_xml+ the method is invoked with +key+ as <tt>:root</tt>.
  #
  #     class Foo
  #       def to_xml(options)
  #         options[:builder].bar 'fooing!'
  #       end
  #     end
  #
  #     { foo: Foo.new }.to_xml(skip_instruct: true)
  #     # => "<hash><bar>fooing!</bar></hash>"
  #
  # * Otherwise, a node with +key+ as tag is created with a string representation of
  #   +value+ as text node. If +value+ is +nil+ an attribute "nil" set to "true" is added.
  #   Unless the option <tt>:skip_types</tt> exists and is true, an attribute "type" is
  #   added as well according to the following mapping:
  #
  #     XML_TYPE_NAMES = {
  #       "Symbol"     => "symbol",
  #       "Fixnum"     => "integer",
  #       "Bignum"     => "integer",
  #       "BigDecimal" => "decimal",
  #       "Float"      => "float",
  #       "TrueClass"  => "boolean",
  #       "FalseClass" => "boolean",
  #       "Date"       => "date",
  #       "DateTime"   => "dateTime",
  #       "Time"       => "dateTime"
  #     }
  #
  # By default the root node is "hash", but that's configurable via the <tt>:root</tt> option.
  #
  # The default XML builder is a fresh instance of <tt>Builder::XmlMarkup</tt>. You can
  # configure your own builder with the <tt>:builder</tt> option. The method also accepts
  # options like <tt>:dasherize</tt> and friends, they are forwarded to the builder.
  def to_xml(options = {})
    require 'active_support/builder' unless defined?(Builder)

    options = options.dup
    options[:indent]  ||= 2
    options[:root]    ||= 'hash'
    options[:builder] ||= Builder::XmlMarkup.new(indent: options[:indent])

    builder = options[:builder]
    builder.instruct! unless options.delete(:skip_instruct)

    root = rename_key(options[:root].to_s, options)

    builder.tag!(root) do
      each { |key, value| to_tag(key, value, options) }
      yield builder if block_given?
    end
  end

  def to_tag(key, value, options)
    type_name = options.delete(:type)
    merged_options = options.merge(:root => key, :skip_instruct => true)

    if value.is_a?(::Method) || value.is_a?(::Proc)
      # if value.arity == 1
      #   value.call(merged_options)
      # else
      #   value.call(merged_options, key.to_s.singularize)
      # end
    elsif value.respond_to?(:to_xml)
      value.to_xml(merged_options)
    else
      type_name ||= TYPE_NAMES[value.class.name]
      type_name ||= value.class.name if value && !value.respond_to?(:to_str)
      type_name   = type_name.to_s   if type_name
      type_name   = "dateTime" if type_name == "datetime"

      key = rename_key(key.to_s, options)

      attributes = options[:skip_types] || type_name.nil? ? { } : { :type => type_name }
      attributes[:nil] = true if value.nil?

      encoding = options[:encoding] || DEFAULT_ENCODINGS[type_name]
      attributes[:encoding] = encoding if encoding

      formatted_value = FORMATTING[type_name] && !value.nil? ?
        FORMATTING[type_name].call(value) : value

      options[:builder].tag!(key, formatted_value, attributes)
    end
  end

  def rename_key(key, options = {})
    camelize  = options[:camelize]
    dasherize = !options.has_key?(:dasherize) || options[:dasherize]
    # if camelize
    #   key = true == camelize ? key.camelize : key.camelize(camelize)
    # end
    key = _dasherize(key) if dasherize
    key
  end

  def _dasherize(key)
    # $2 must be a non-greedy regex for this to work
    left, middle, right = /\A(_*)(.*?)(_*)\Z/.match(key.strip)[1,3]
    "#{left}#{middle.tr('_ ', '--')}#{right}"
  end

  # Return a new hash with all keys converted using the block operation.
  #
  #  hash = { name: 'Rob', age: '28' }
  #
  #  hash.transform_keys{ |key| key.to_s.upcase }
  #  # => { "NAME" => "Rob", "AGE" => "28" }
  def transform_keys
    result = {}
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end

  # Return a new hash with all keys converted to symbols, as long as
  # they respond to +to_sym+.
  #
  #   hash = { 'name' => 'Rob', 'age' => '28' }
  #
  #   hash.symbolize_keys
  #   #=> { name: "Rob", age: "28" }
  def symbolize_keys
    transform_keys{ |key| key.to_sym rescue key }
  end
  alias_method :to_options,  :symbolize_keys
end