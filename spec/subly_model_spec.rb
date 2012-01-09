require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Item < ActiveRecord::Base
  subly
end

class Thing < ActiveRecord::Base
  subly
end

describe Subly::Model do
  it "should not create a subscription without a subscriber_id" do
    lambda{Subly::Model.create!(:name => 'Foo', :subscriber_type => 'Boo')}.should raise_error
  end

  it "should not create a subscription without a subscriber" do
    lambda{Subly::Model.create!(:name => 'Foo', :subscriber_id => 3)}.should raise_error
  end

  it "subscription should not be created when ends before starts" do
    lambda{Subly::Model.create!(:name => 'Foo', :subscriber_type => 'Foo', :subscriber_id => 1, :starts_at => Time.now + 1.minute, :ends_at => Time.now - 1.minute)}.should raise_error
  end

  it "should be expire immediately" do
    s = Subly::Model.create(:name => 'Foo', :subscriber_type => 'Item', :subscriber_id => 1, :starts_at => Time.now - 5.minute)
    s.active?.should be_true
    s.expire_now.should be_true
    s.reload
    s.active?.should be_false
  end

  it "should be active if it starts in the past and ends in the future" do
    Subly::Model.new(:name => 'Foo', :subscriber_type => 'Item', :subscriber_id => 1, :starts_at => Time.now - 1.minute, :ends_at => Time.now + 1.hour).active?.should be_true
  end

  it "should be expired if it ends in the past" do
    Subly::Model.new(:name => 'Foo', :subscriber_type => 'Item', :subscriber_id => 1, :starts_at => Time.now - 5.minute, :ends_at => Time.now - 4.minutes).expired?.should be_true
  end

  it "should be in_the_future if it starts and ends in the future" do
    Subly::Model.new(:name => 'Foo', :subscriber_type => 'Item', :subscriber_id => 1, :starts_at => Time.now + 5.minute, :ends_at => Time.now + 14.minutes).in_the_future?.should be_true
  end
end
