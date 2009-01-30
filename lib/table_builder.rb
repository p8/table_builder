module TableHelper

  def table_for(objects, *args)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.last.is_a?(Hash) ? args.pop : {}
    html_options = options[:html]
    builder = options[:builder] || TableBuilder
    
    concat(tag(:table, html_options, true))
    yield builder.new(objects || [], self, options)
    concat('</table>')
  end

  class TableBuilder
    include ::ActionView::Helpers::TagHelper

    def initialize(objects, template, options)
      raise ArgumentError, "TableBuilder expects an Array but found a #{objects.inspect}" unless objects.is_a? Array
      @objects, @template, @options = objects, template, options
    end

    def head(*cols)
      @num_of_columns = cols.size
      content_tag(:thead,
        content_tag(:tr,
          cols.collect { |c| content_tag(:th, c)}.join('')
        )
      )
    end

    def body(*args)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      tbody do
        @objects.each { |c| yield(c) }
      end
    end
    
    def body_r(*args, &proc)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      tbody do
        @objects.each { |c|
          concat(tag(:tr, options, true))
          yield(c)
          concat('</tr>')
        }
      end
    end    

    def r(*args)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      tr(options) do
        yield
      end
    end

    def d(content, *args)
      options = options_from_hash(args)
      content_tag(:td, content, options)
    end

    private
    
    def options_from_hash(args)
      args.last.is_a?(Hash) ? args.pop : {}
    end
    
    def concat(tag)
       @template.concat(tag)
    end

    def content_tag(tag, content, *args)
      options = options_from_hash(args)
      @template.content_tag(tag, content, options)
    end
    
    def tbody
      concat('<tbody>')
      yield
      concat('</tbody>')
    end
    
    def tr options
      concat(tag(:tr, options, true))
      yield
      concat('</tr>')      
    end
  end
end