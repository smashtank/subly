require "subly/version"
require "subly/model"

module Subly
  def subly(args = {})
    self.has_many :sublies, :as => :subscriber, :class_name => 'Subly::Model'
    self.accepts_nested_attributes_for :sublies, :allow_destroy => true, :reject_if => :all_blank

    #we don't want to use method missing for all "is" methods
    if is_methods = args.delete(:is_methods)
      is_methods.collect(&:to_s).each do |is_name|
        if self.instance_methods.include?(is_name)
          warn("Subly: Method is_#{is_name}? is already available to #{self.class.to_s}")
        else
          self.class_eval <<-EOV
            def is_#{is_name}?
              self.has_active_subscription?('#{is_name}')
            end
          EOV
        end
      end
    end

    extend ClassMethods
    include InstanceMethods
  end

  module ClassMethods
    def with_subscription(name)
      scoped(:include => :sublies, :conditions => {:subly_models => {:name => name}})
    end

    def with_active_subscription(name)
      now = Time.now
      with_subscription(name).scoped(:joins => :sublies, :conditions => ['subly_models.starts_at <= ? AND (ends_at IS NULL or ends_at > ?)', now, now])
    end
  end

  module InstanceMethods
    def add_subscription(name, args = {})
      args[:starts_at] ||=  Time.now
      args[:name] = name
      self.sublies.create(args)
    end

    def has_subscription?(name)
      self.sublies.by_name(name).count > 0
    end

    def has_active_subscription?(name)
      self.sublies.active.by_name(name).count > 0
    end

    def cancel_active_subscriptions(name)
      self.sublies.active.by_name(name).collect(&:expire_now)
    end

    def cancel_all_subscriptions(name)
      self.sublies.unexpired.by_name(name).each do |sub|
        #if active, deactivate, else destroy as and end_time greater than start is not valid
        sub.active? ? sub.expire_now : sub.destroy
      end
    end
  end
end

ActiveRecord::Base.send :extend, Subly
