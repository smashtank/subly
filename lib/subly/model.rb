module Subly
  class Model < ActiveRecord::Base
    set_table_name 'subly_models'

    belongs_to :subscriber, :polymorphic => true

    validates_presence_of :subscriber_type
    validates_presence_of :subscriber_id, :unless => Proc.new { |subly| subly.subscriber_type.nil? }
    validate :ends_after_starts

    def self.active
      now = Time.zone.now
      scoped(:conditions => ['starts_at <= ? AND (ends_at > ? OR ends_at IS NULL)', now, now])
    end

    def self.expired
      now = Time.zone.now
      scoped(:conditions => ['starts_at <= ? AND ends_at <= ?', now, now])
    end

    def self.for_subscriber(sub)
      raise ArgumentError('wrong number of arguments (0 for 1)') if sub.blank?
      scoped(:conditions => ['subscriber_type = ? AND subscriber_id = ?',sub.class.to_s, sub.id])
    end

    def self.by_name(name)
      scoped(:conditions => {:name => name})
    end

    private
    def ends_after_starts
      if !starts_at.nil? && !ends_at.nil? && (ends_at < starts_at)
        raise "ends_at must be after starts_at"
      end
    end
  end
end