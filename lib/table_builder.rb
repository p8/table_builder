module TableHelper

  def table_for(objects, *args, &proc)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.last.is_a?(Hash) ? args.pop : {}
    html_options = options[:html]
    builder = options[:builder] || TableBuilder
    
    concat(tag(:table, html_options, true), proc.binding)
    yield builder.new(objects || [], self, options, proc)
    concat('</table>', proc.binding)
  end

  class TableBuilder
    include ::ActionView::Helpers::TagHelper

    def initialize(objects, template, options, proc)
      raise ArgumentError, "TableBuilder expects an Array but found a #{objects.inspect}" unless objects.is_a? Array
      @objects, @template, @options, @proc = objects, template, options, proc
    end

    def head(*cols)
      @num_of_columns = cols.size
      content_tag(:thead,
        content_tag(:tr,
          cols.collect { |c| content_tag(:th, c)}.join('')
        )
      )
    end

    def body(*args, &proc)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      tbody(proc) do
        @objects.each { |c| yield(c) }
      end
    end
    
    def body_r(*args, &proc)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      tbody(proc) do
        @objects.each { |c|
          concat(tag(:tr, options, true), proc)
          yield(c)
          concat('</tr>', proc)
        }
      end
    end    

    def r(*args, &proc)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      tr(options, proc) do
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
    
    def concat(tag, proc)
       @template.concat(tag, proc.binding)
    end

    def content_tag(tag, content, *args)
      options = options_from_hash(args)
      @template.content_tag(tag, content, options)
    end
    
    def tbody proc
      concat('<tbody>', proc)     
      yield
      concat('</tbody>', proc)
    end
    
    def tr options, proc
      concat(tag(:tr, options, true), proc)
      yield
      concat('</tr>', proc)      
    end
  end
end