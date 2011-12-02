require "subly/version"
require "subly/model"

module Subly
  def subly(args = {})
    self.has_many :sublies, :as => :subscriber, :class_name => 'Subly::Model'

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
    def add_subscription(name, value = nil, start_date = Time.now, end_date = nil)
      self.sublies.create(:name => name, :value => value, :starts_at => start_date, :ends_at => end_date)
    end

    def has_subscription?(name)
      self.sublies.by_name(name).count > 0
    end

    def has_active_subscription?(name)
      self.sublies.active.by_name(name).count > 0
    end
  end
end

ActiveRecord::Base.send :extend, Subly