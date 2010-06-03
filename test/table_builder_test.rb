require File.join(File.dirname(__FILE__), 'test_helper.rb')

class TableBuilderTest < ActionView::TestCase
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include TableHelper
  attr_accessor :output_buffer  
  
  def setup
    @drummer1 = Drummer.new(1, 'John "Stumpy" Pepys')
    @drummer2 = Drummer.new(2, 'Eric "Stumpy Joe" Childs')
    @drummer3 = Drummer.new(3, 'Peter "James" Bond')
    @drummer4 = Drummer.new(4, 'Mick Shrimpton (R. J. "Ric" Parnell)')
  end
  
  def test_table_for
    output = table_for([], :html => { :id => 'id', :style => 'style', :class => 'class'}) do |t|
    end
    expected = %(<table id="id" style="style" class="class">) <<
      %(</table>)
    assert_dom_equal expected, output
  end

  def test_table_for_without_an_array_raises_error
    assert_raises(ArgumentError) do
      table_for('a') {|t| }
    end
  end

  def test_head
    output = table_for([]) do |t|
      t.head do
        t.r do
          output_buffer.concat t.h('Id')
          output_buffer.concat t.h('Name')
        end
      end
    end
    expected = %(<table>) <<
        %(<thead>) <<
          %(<tr>) <<
            %(<th>Id</th>) <<
            %(<th>Name</th>) <<
          %(</tr>) <<
        %(</thead>) <<
      %(</table>)
    assert_dom_equal expected, output
  end

  def test_head_r
    output = table_for([]) do |t|
      t.head_r do
        output_buffer.concat t.h('Id')
        output_buffer.concat t.h('Name')
      end
    end
    expected = %(<table>) <<
        %(<thead>) <<
          %(<tr>) <<
            %(<th>Id</th>) <<
            %(<th>Name</th>) <<
          %(</tr>) <<
        %(</thead>) <<
      %(</table>)
    assert_dom_equal expected, output
  end

  def test_head_with_array
    output = table_for([@drummer1, @drummer2]) do |t|
      concat t.head('Id', 'Name')
    end
    expected = %(<table>) <<
        %(<thead>) <<
          %(<tr>) <<
            %(<th>Id</th>) <<
            %(<th>Name</th>) <<
          %(</tr>) <<
        %(</thead>) <<
      %(</table>)
    assert_dom_equal expected, output
  end

  def test_body
    output = table_for([@drummer3, @drummer4]) do |t|
      t.body do |e|
        t.r do
          concat t.d(e.id)
          concat t.d(e.name)
        end
      end
    end
    expected = %(<table>) <<
        %(<tbody>) <<
          %(<tr>) <<
            %(<td>3</td>) <<
            %(<td>Peter &quot;James&quot; Bond</td>) <<
          %(</tr>) <<
          %(<tr>) <<
            %(<td>4</td>) <<
            %(<td>Mick Shrimpton (R. J. &quot;Ric&quot; Parnell)</td>) <<
          %(</tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, output
  end

  def test_body_r
    output = table_for([@drummer3, @drummer4]) do |t|
      t.body_r do |e|
        concat t.d(e.id)
        concat t.d(e.name)
      end
    end
    expected = %(<table>) <<
        %(<tbody>) <<
          %(<tr>) <<
            %(<td>3</td>) <<
            %(<td>Peter &quot;James&quot; Bond</td>) <<
          %(</tr>) <<
          %(<tr>) <<
            %(<td>4</td>) <<
            %(<td>Mick Shrimpton (R. J. &quot;Ric&quot; Parnell)</td>) <<
          %(</tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, output
  end
  
  def test_td_with_options
     output = table_for([@drummer1]) do |t|
       t.body_r do |e|
         output_buffer.concat t.d(e.name, :class => 'class')
       end
     end
     expected = %(<table>) <<
         %(<tbody>) <<
           %(<tr>) <<
             %(<td class="class">John &quot;Stumpy&quot; Pepys</td>) <<
           %(</tr>) <<
         %(</tbody>) <<
       %(</table>)
     assert_dom_equal expected, output
   end  

   def test_td_with_block
      output = table_for([@drummer1]) do |t|
        t.body_r do |e|
          t.d do
            concat 'content'
          end
        end
      end
      expected = %(<table>) <<
          %(<tbody>) <<
            %(<tr>) <<
              %(<td>content</td>) <<
            %(</tr>) <<
          %(</tbody>) <<
        %(</table>)
      assert_dom_equal expected, output
    end

   def test_td_with_block_and_options
      output = table_for([@drummer1]) do |t|
        t.body_r do |e|
          t.d(:class => 'class') do
            concat 'content'
          end
        end
      end
      expected = %(<table>) <<
          %(<tbody>) <<
            %(<tr>) <<
              %(<td class="class">content</td>) <<
            %(</tr>) <<
          %(</tbody>) <<
        %(</table>)
      assert_dom_equal expected, output
    end

end

class Drummer < Struct.new(:id, :name); end
