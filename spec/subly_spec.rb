require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Item < ActiveRecord::Base
  subly :is_methods => [:subby]
end

class Thing < ActiveRecord::Base
  subly
end

describe Subly do
  it "should add a subscription" do
    thing_one = Thing.create(:name => 'Thing One', :description => 'foo')
    thing_one.add_subscription('sub name',:value => 'sub value').should be_true
    thing_one.reload
    thing_one.sublies.count.should == 1
  end

  it "subscription should default to active" do
    Time.stub!(:zone).and_return(Time)
    thing_one = Thing.create(:name => 'Thing One', :description => 'foo')
    thing_one.add_subscription('sub name').should be_true
    thing_one.reload
    thing_one.has_active_subscription?('sub name').should be_true
  end

  it "has_subscription should return true even for expired subscription" do
    thing_one = Thing.create(:name => 'Thing One', :description => 'foo')
    thing_one.add_subscription('sub name', :starts_at => Time.now - 1.day, :ends_at => Time.now - 2.hours).should be_true
    thing_one.reload
    thing_one.has_subscription?('sub name').should be_true
  end


  it "should find models with active subscription" do
    Thing.delete_all
    thing_one = Thing.create(:name => 'Thing One', :description => 'foo')
    thing_one.add_subscription('sub name').should be_true
    Thing.with_active_subscription('sub name').should == [thing_one]
  end

  it "should find models with even expired subscriptions" do
    Thing.delete_all
    thing_one = Thing.create(:name => 'Thing One', :description => 'foo')
    thing_one.add_subscription('sub name', :starts_at => Time.now - 1.day, :ends_at => Time.now - 2.hours).should be_true
    Thing.with_subscription('sub name').should == [thing_one]
    thing_one.destroy
  end

  it "should define methods for is" do
    Item.instance_method(:is_subby?).should be_true
  end

  it "is method should be false if it does not have an active sub" do
    Time.stub!(:zone).and_return(Time)
    Item.new.is_subby?.should be_false
  end

  it "is method should be true if it has an active sub" do
    Time.stub!(:zone).and_return(Time)
    item = Item.create(:name => 'foo')
    item.add_subscription('subby')
    item.is_subby?.should be_true
  end

  it "should convert duration to time" do
    time = Time.parse('2001-01-01T010101+0000')
    Time.stub!(:zone).and_return(Time)
    Time.stub!(:now).and_return(time)
    item = Item.create(:name => 'foo')
    item.add_subscription('subby', :duration => "1 year")
    item.is_subby?.should be_true
    item.sublies.last.ends_at.should == time + 1.year
  end
end
