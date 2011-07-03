require File.join(File.dirname(__FILE__), 'test_helper.rb')

class CalendarHelperTest < ActionView::TestCase
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include CalendarHelper
  attr_accessor :output_buffer

  def setup
    @events = [Event.new(3, 'Jimmy Page', Date.civil(2008, 12, 26)),
              Event.new(4, 'Robert Plant', Date.civil(2008, 12, 26))]
  end
  
  def test_calendar_for
    output = calendar_for(@events, :html => { :id => 'id', :style => 'style', :class => 'class'}) do |t|
    end
    expected = %(<table id="id" style="style" class="class">) <<
      %(</table>)
    assert_dom_equal expected, output
  end

  def test_calendar_for_without_an_array
    self.output_buffer = ''
    assert_raises(ArgumentError) do
      calendar_for('a') {|t| }
    end
  end
  
  def test_calendar_for_with_empty_array
    output = calendar_for([], :year=> 2008, :month => 12) do |c|
      c.day do |day, events|
        concat(events.collect{|e| e.id}.join)
      end
    end
    expected = %(<table>) <<
      %(<tbody>) <<
        %(<tr><td class="notmonth weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td class="notmonth"></td><td class="notmonth"></td><td class="notmonth weekend"></td></tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, output
  end
  
  def test_calendar_for_with_events
    output = calendar_for(@events, :year=> 2008, :month => 12) do |c|
      c.day do |day, events|
        content = events.collect{|e| e.id}.join
        concat("(#{day.day})#{content}")
      end
    end
    expected = %(<table>) <<
      %(<tbody>) <<
        %(<tr><td class="notmonth weekend">(30)</td><td>(1)</td><td>(2)</td><td>(3)</td><td>(4)</td><td>(5)</td><td class="weekend">(6)</td></tr>) <<
        %(<tr><td class="weekend">(7)</td><td>(8)</td><td>(9)</td><td>(10)</td><td>(11)</td><td>(12)</td><td class="weekend">(13)</td></tr>) <<
        %(<tr><td class="weekend">(14)</td><td>(15)</td><td>(16)</td><td>(17)</td><td>(18)</td><td>(19)</td><td class="weekend">(20)</td></tr>) <<
        %(<tr><td class="weekend">(21)</td><td>(22)</td><td>(23)</td><td>(24)</td><td>(25)</td><td>(26)34</td><td class="weekend">(27)</td></tr>) <<
        %(<tr><td class="weekend">(28)</td><td>(29)</td><td>(30)</td><td>(31)</td><td class="notmonth">(1)</td><td class="notmonth">(2)</td><td class="notmonth weekend">(3)</td></tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, output
  end
  
  def test_calendar_for_sets_css_classes
    output = calendar_for([], :year=> 2008, :month => 12, :today => Date.civil(2008, 12, 15)) do |c|
      c.day do |day, events|
        concat(events.collect{|e| e.id}.join)
      end
    end
    expected = %(<table>) <<
      %(<tbody>) <<
        %(<tr><td class="notmonth weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>) <<
        %(<tr><td class="weekend"></td><td class="today"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="weekend future"></td></tr>) <<
        %(<tr><td class="weekend future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="weekend future"></td></tr>) <<
        %(<tr><td class="weekend future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="notmonth future"></td><td class="notmonth future"></td><td class="notmonth weekend future"></td></tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, output
  end

  def test_calendar_for_sets_custom_css_classes
    custom_css = lambda { |day| day.day.even? ? "even" : "odd" }
    output = calendar_for([], :year=> 2008, :month => 12, :today => Date.civil(2008, 12, 15)) do |c|
      c.day(:class => custom_css) do |day, events|
        concat(events.collect{|e| e.id}.join)
      end
    end
    expected = %(<table>) <<
      %(<tbody>) <<
        %(<tr><td class="notmonth weekend even"></td><td class="odd"></td><td class="even"></td><td class="odd"></td><td class="even"></td><td class="odd"></td><td class="weekend even"></td></tr>) <<
        %(<tr><td class="weekend odd"></td><td class="even"></td><td class="odd"></td><td class="even"></td><td class="odd"></td><td class="even"></td><td class="weekend odd"></td></tr>) <<
        %(<tr><td class="weekend even"></td><td class="today odd"></td><td class="future even"></td><td class="future odd"></td><td class="future even"></td><td class="future odd"></td><td class="weekend future even"></td></tr>) <<
        %(<tr><td class="weekend future odd"></td><td class="future even"></td><td class="future odd"></td><td class="future even"></td><td class="future odd"></td><td class="future even"></td><td class="weekend future odd"></td></tr>) <<
        %(<tr><td class="weekend future even"></td><td class="future odd"></td><td class="future even"></td><td class="future odd"></td><td class="notmonth future odd"></td><td class="notmonth future even"></td><td class="notmonth weekend future odd"></td></tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, output
  end

  def test_calendar_for_thirty_days
    today = Date.civil(2008, 12, 15)
    output = calendar_for([], :today => today, :year=>2008, :month=>12, :first=>today, :last=>:thirty_days) do |c|
      c.day do |day, events|
        concat(events.collect{|e| e.id}.join)
      end
    end
    expected = %(<table>) <<
      %(<tbody>) <<
        %(<tr><td class="weekend"></td><td class="today"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="weekend future"></td></tr>) <<
        %(<tr><td class="weekend future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="weekend future"></td></tr>) <<
        %(<tr><td class="weekend future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="notmonth future"></td><td class="notmonth future"></td><td class="notmonth weekend future"></td></tr>) <<
        %(<tr><td class="notmonth weekend future"></td><td class="notmonth future"></td><td class="notmonth future"></td><td class="notmonth future"></td><td class="notmonth future"></td><td class="notmonth future"></td><td class="notmonth weekend future"></td></tr>) <<
        %(<tr><td class="notmonth weekend future"></td><td class="notmonth future"></td><td class="notmonth future"></td><td class="notmonth future"></td><td class="notmonth future"></td><td class="notmonth future"></td><td class="notmonth weekend future"></td></tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, output
  end

  def test_calendar_for_week
    today = Date.civil(2008, 12, 15)
    output = calendar_for([], :today => today, :year=>2008, :month=>12, :first=>today, :last=>:week) do |c|
      c.day do |day, events|
        concat(events.collect{|e| e.id}.join)
      end
    end
    expected = %(<table>) <<
      %(<tbody>) <<
        %(<tr><td class="weekend"></td><td class="today"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="future"></td><td class="weekend future"></td></tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, output
  end

  def test_calendar_for_sets_css_ids
    output = calendar_for([], :year=> 2008, :month => 12, :today => Date.civil(2008, 12, 15)) do |c|
      c.day(:id => 'day_%d') do |day, events|
        concat(events.collect{|e| e.id}.join)
      end
    end
    expected = %(<table>) <<
      %(<tbody>) <<
        %(<tr><td class="notmonth weekend" id="day_30"></td><td id="day_01"></td><td id="day_02"></td><td id="day_03"></td><td id="day_04"></td><td id="day_05"></td><td class="weekend" id="day_06"></td></tr>) <<
        %(<tr><td class="weekend" id="day_07"></td><td id="day_08"></td><td id="day_09"></td><td id="day_10"></td><td id="day_11"></td><td id="day_12"></td><td class="weekend" id="day_13"></td></tr>) <<
        %(<tr><td class="weekend" id="day_14"></td><td class="today"id="day_15"></td><td class="future" id="day_16"></td><td class="future" id="day_17"></td><td class="future" id="day_18"></td><td class="future" id="day_19"></td><td class="future" class="weekend future" id="day_20"></td></tr>) <<
        %(<tr><td class="weekend future" id="day_21"></td><td class="future" id="day_22"></td><td class="future" id="day_23"></td><td class="future" id="day_24"></td><td class="future" id="day_25"></td><td class="future" id="day_26"></td><td class="weekend future" id="day_27"></td></tr>) <<
        %(<tr><td class="weekend future" id="day_28"></td><td class="future" id="day_29"></td><td class="future" id="day_30"></td><td class="future" id="day_31"></td><td class="notmonth future" id="day_01"></td><td class="notmonth future" id="day_02"></td><td class="notmonth weekend future" id="day_03"></td></tr>) <<
        %(</tbody>) <<
      %(</table>)
    assert_dom_equal expected, output
  end  
  
end

class CalendarHelperTest < ActionView::TestCase

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

  def test_days_with_first_day_of_week_set
    calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12, :first_day_of_week => 1)
    days = []
    Date.civil(2008, 12, 1).upto(Date.civil(2009, 1, 4)){|day| days << day}
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
  
  def test_last_day_with_first_day_of_week_set
    calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12, :first_day_of_week => 1)
    assert_equal Date.civil(2009, 1, 4), calendar.last_day
  end  
end

class Event < Struct.new(:id, :name, :date); end
