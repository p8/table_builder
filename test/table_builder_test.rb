require File.join(File.dirname(__FILE__), 'test_helper.rb')

class TableBuilderTest < Test::Unit::TestCase
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include TableHelper
  
  def setup
    @drummer1 = Drummer.new(1, 'John "Stumpy" Pepys')
    @drummer2 = Drummer.new(2, 'Eric "Stumpy Joe" Childs')
    @drummer3 = Drummer.new(3, 'Peter "James" Bond')
    @drummer4 = Drummer.new(4, 'Mick Shrimpton (R. J. "Ric" Parnell)')
  end
  
  def test_table_for
    _erbout = ''
    table_for([], :html => { :id => 'id', :style => 'style', :class => 'class'}) do |t|
    end
    expected = %(<table id="id" style="style" class="class">) <<
      %(</table>)
    assert_dom_equal expected, _erbout
  end

  def test_table_for_without_an_array_raises_error
    _erbout = ''
    assert_raises(ArgumentError) do
      table_for('a') {|t| }
    end
  end

  def test_table_for_head
    _erbout = ''
    table_for([@drummer1, @drummer2]) do |t|
      _erbout.concat t.head('Id', 'Name')
    end
    expected = %(<table>) <<
        %(<thead>) <<
          %(<tr>) <<
            %(<th>Id</th>) <<
            %(<th>Name</th>) <<
          %(</tr>) <<
        %(</thead>) <<
      %(</table>)
    assert_dom_equal expected, _erbout
  end

  def test_table_for_body
    _erbout = ''
    table_for([@drummer3, @drummer4]) do |t|
      t.body do |e|
        t.r do
          _erbout.concat t.d(e.id)
          _erbout.concat t.d(e.name)
        end
      end
    end
    expected = %(<table>) <<
        %(<tbody>) <<
          %(<tr>) <<
            %(<td>3</td>) <<
            %(<td>Peter "James" Bond</td>) <<
          %(</tr>) <<
          %(<tr>) <<
            %(<td>4</td>) <<
            %(<td>Mick Shrimpton (R. J. "Ric" Parnell)</td>) <<
          %(</tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, _erbout
  end

  def test_table_for_body_r
    _erbout = ''
    table_for([@drummer3, @drummer4]) do |t|
      t.body_r do |e|
        _erbout.concat t.d(e.id)
        _erbout.concat t.d(e.name)
      end
    end
    expected = %(<table>) <<
        %(<tbody>) <<
          %(<tr>) <<
            %(<td>3</td>) <<
            %(<td>Peter "James" Bond</td>) <<
          %(</tr>) <<
          %(<tr>) <<
            %(<td>4</td>) <<
            %(<td>Mick Shrimpton (R. J. "Ric" Parnell)</td>) <<
          %(</tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, _erbout
  end
  
  def test_table_for_td_with_options
     _erbout = ''
     table_for([@drummer1]) do |t|
       t.body_r do |e|
         _erbout.concat t.d(e.name, :class => 'class')
       end
     end
     expected = %(<table>) <<
         %(<tbody>) <<
           %(<tr>) <<
             %(<td class="class">John "Stumpy" Pepys</td>) <<
           %(</tr>) <<
         %(</tbody>) <<
       %(</table>)
     assert_dom_equal expected, _erbout
   end  

end

class Drummer < Struct.new(:id, :name); end