module Landscapist
  class Renderer
    class Tree < Renderer
      
      def to_s
        tree
      end
      
      def tree(depth = 0)
      
        out = []
        out << "#{name}:" unless depth == 0
      
        if (payloads.count > 0 || types.count > 0) && depth == 0
          out << 'Global:'
        end
      
        if payloads.count > 0
          out << "  - Payloads: #{payloads.map(&:name).join(", ")}"
        end
      
        if types.count > 0
          out << "  - Types: #{types.map(&:name).join(", ")}"
        end
      
        if payloads.count > 0 || types.count > 0
          out << ''
        end
        
        if endpoints.count > 0
          endpoints.each do |ep|
            out << "  * #{ep.name}: #{ep.http_method.to_s.upcase} #{ep.expanded_path}"
            if ep.expects
              case ep.expect_type
              when :hash, :array
                out << "    Expects: #{ep.expects.inspect}"
              when :payload
                case ep.expects
                when Array
                  out << "    Expects: #{ep.expects.map(&:inspect).join(" | ")}"
                else
                  out << "    Expects: #{ep.expects.inspect}"
                end
              end
            end
            if ep.returns
              out << "    Returns:"
              returns = ep.returns.sort.map do |status, returns|
                [
                  Endpoint.status_name(status),
                  case ep.return_type[status]
                  when :hash, :array
                    returns.inspect
                  when :payload
                    case returns
                    when Array
                      returns.map(&:inspect).join(" | ")
                    else
                      returns.inspect
                    end
                  end
                ]
              end
              width = returns.map(&:first).map(&:length).max
              returns.each do |pair|
                out << "      %*s  %s" % [-width, *pair]
              end
            end
            out << ''
          end
          out << ''
        end
      
        if yards.count > 0
          yards.each do |y|
            out += Landscapist::Renderer::Tree.new(y).tree(depth + 1)
          end
          out << ''
        end
      
        out.map!{|l| l.gsub(/^/, '  ') } if depth > 1
        return out.join("\n").gsub(/ *\n *\n(?: *\n)+/, "\n\n") if depth == 0
        out
      end
  
    end
  end
end
