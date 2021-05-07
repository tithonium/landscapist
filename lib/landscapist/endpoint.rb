module Landscapist
  class Endpoint < Definition

    def self.status_name(status)
      if status.is_a?(Integer)
        "#{status} #{Rack::Utils::HTTP_STATUS_CODES[status]}"
      else
        status.to_sym
      end
    end


    attr_reader :path, :http_method, :expects, :expect_type, :returns, :return_type
    def initialize(*)
      super
      @path = nil
      @http_method = nil
      @expects = nil
      @expect_type = nil
      @returns = {}
      @return_type = {}
    end

    def set_path(path)
      @path = path
    end

    def set_http_method(http_method)
      @http_method = http_method
    end

    def add_expect(spec, options = {})

      Landscapist::Endpoint::Expectation.new(spec, options[:optional])


      value = update_structures(@expects, spec, options)
      @expects = value
      @expect_type = value.is_a?(Hash) ? :hash : (value.is_a?(Array) && value.length == 1 ? :array : :payload)
      warn "Warning: Swagger will require a union type for the expect of #{full_name}" if value.is_a?(Array) && value.length > 1
    end

    def add_return(spec, options = {})
      status = Rack::Utils.status_code(options[:status] || 200)
      raise MixedReturnType, "Endpoint #{name} is already returning a single type on #{status}" if returns_single_type?(status)
      value = update_structures(@returns[status], spec, options)
      @returns[status] = value
      @return_type[status] = if value.is_a?(Hash)
        :hash
      elsif value.is_a?(Array) && value.length == 1
        :array
      elsif value.is_a?(Type::CoreType)
        :scalar
      else
        :payload
      end
      warn "Warning: Swagger does not permit defining mulitple return types for the same http response. It will require a union type for the #{status} return of #{full_name}" if value.is_a?(Array) && value.length > 1
    end

    %i[payload array hash].each do |type|
      class_eval <<-"EOF", __FILE__, __LINE__
        def expects_#{type}?
          return nil if @expect_type.nil?
          @expect_type == :#{type} ? true : false
        end

        def returns_#{type}?(status = 200)
          return nil if @return_type[status].nil?
          @return_type[status] == :#{type} ? true : false
        end
      EOF
    end

    def expects_single_type?
      return nil if @expect_type.nil?
      @expect_type == :hash ? false : true
    end

    def returns_single_type?(status = 200)
      return nil if @return_type[status].nil?
      @return_type[status] == :hash ? false : true
    end

    def update_structures(value, spec, options = {})
      case spec
      when Hash
        value ||= {}
        value.merge!(spec.each_with_object({}){|(k,v), h| h[k] = _resolve_spec(v) })
      when Array
        raise MixedReturnType, "Can't return an array of multiple types" if value.is_a?(Array)
        value = spec.map(&method(:_resolve_spec))
      else
        value = _resolve_spec(spec)
      end
      value
    end

    def inspect
      "<#E:#{name}(#{http_method.to_s.upcase}) #{path.inspect}" +
      (expects ? " expects: #{expects.inspect}" : '') +
      (returns ? " returns: #{returns.inspect}" : '') +
      ">"
    end

    class DSL < Landscapist::Definition::DSL

      def path(*a)
        set_path a.first
      end

      def expects(*a)
        add_expect *a
      end

      def returns(*a)
        add_return *a
      end

      def method(*a)
        set_http_method *a
      end

    end

  end
end

require "landscapist/endpoint/expectation"
