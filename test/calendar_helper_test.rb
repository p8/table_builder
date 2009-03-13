require File.join(File.dirname(__FILE__), 'test_helper.rb')

class CalendarHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include CalendarHelper
  attr_accessor :output_buffer

  def setup
    @events = [Event.new(3, 'Jimmy Page', Date.civil(2008, 12, 26)),
              Event.new(4, 'Robert Plant', Date.civil(2008, 12, 26))]
  end
  
  def test_calendar_for
    self.output_buffer = ''
    calendar_for(@events, :html => { :id => 'id', :style => 'style', :class => 'class'}) do |t|
    end
    expected = %(<table id="id" style="style" class="class">) <<
      %(</table>)
    assert_dom_equal expected, output_buffer
  end

  def test_calendar_for_without_an_array
    self.output_buffer = ''
    assert_raises(ArgumentError) do
      calendar_for('a') {|t| }
    end
  end
  
  def test_calendar_for_with_empty_array
    self.output_buffer = ''
    calendar_for([], :year=> 2008, :month => 12) do |c|
      c.day do |day, events|
        output_buffer.concat(events.collect{|e| e.id}.join)
      end
    end
    expected = %(<table>) <<
      %(<tbody>) <<
        %(<tr><td class="notmonth"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td class="notmonth"></td><td class="notmonth"></td><td class="notmonth"></td></tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, self.output_buffer
  end
  
  def test_calendar_for_with_events
    self.output_buffer = ''
    calendar_for(@events, :year=> 2008, :month => 12) do |c|
      c.day do |day, events|
        output_buffer.concat(events.collect{|e| e.id}.join)
      end
    end
    expected = %(<table>) <<
      %(<tbody>) <<
        %(<tr><td class="notmonth"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend" ></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td>34</td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td class="notmonth"></td><td class="notmonth"></td><td class="notmonth"></td></tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, output_buffer
  end
  
  def test_calendar_for_sets_css_classes
    self.output_buffer = ''
    calendar_for([], :year=> 2008, :month => 12, :today => Date.civil(2008, 12, 15)) do |c|
      c.day do |day, events|
        output_buffer.concat(events.collect{|e| e.id}.join)
      end
    end
    expected = %(<table>) <<
      %(<tbody>) <<
        %(<tr><td class="notmonth"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td class="today"></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td class="notmonth"></td><td class="notmonth"></td><td class="notmonth"></td></tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, self.output_buffer
  end  
end

class CalendarHelperTest < Test::Unit::TestCase

  def setup
    @events = [Event.new(3, 'Jimmy Page', Date.civil(2008, 12, 26)),
              Event.new(4, 'Robert Plant', Date.civil(2008, 12, 26))]
  end

  def test_objects_for_days_with_events
    calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12)
    objects_for_days = {}
    Date.civil(2008, 11, 30).upto(Date.civil(2009, 1, 3)){|day| objects_for_days[day.strftime("%Y-%m-%d")] = [day, []]}
    objects_for_days['2008-12-26'][1] = @events    
    assert_equal objects_for_days, calendar.objects_for_days(@events, :date)
  end

  def test_objects_for_days
    calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12)
    objects_for_days = {}
    Date.civil(2008, 11, 30).upto(Date.civil(2009, 1, 3)){|day| objects_for_days[day.strftime("%Y-%m-%d")] = [day, []]}
    assert_equal objects_for_days, calendar.objects_for_days([], :date)
  end

  def test_days
    calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12)
    days = []
    Date.civil(2008, 11, 30).upto(Date.civil(2009, 1, 3)){|day| days << day}
    assert_equal days, calendar.days
  end

  def test_first_day
    calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12)
    assert_equal Date.civil(2008, 11, 30), calendar.first_day
  end
  
  def test_last_day
    calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12)
    assert_equal Date.civil(2009, 1, 3), calendar.last_day
  end  
end

class Event < Struct.new(:id, :name, :date); end
