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

  it "should be active if it stats in the past and ends in the future" do
    i = Item.create
    Subly::Model.new(:name => 'Foo', :subscriber_type => 'Item', :subscriber_id => 1, :starts_at => Time.now - 1.minute, :ends_at => Time.now + 1.hour).active?.should be_true
  end
end
