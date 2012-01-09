module Subly
  class Model < ActiveRecord::Base
    require 'chronic_duration'
    set_table_name 'subly_models'

    belongs_to :subscriber, :polymorphic => true

    before_validation :convert_duration

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

    def duration=(duration)
      @duration = duration
    end

    def duration
      @duration
    end

    def active?
      now = Time.now
      !!(starts_at <= now && (ends_at.nil? || ends_at > now))
    end

    private
    def ends_after_starts
      if !starts_at.nil? && !ends_at.nil? && (ends_at < starts_at)
        raise "ends_at must be after starts_at"
      end
    end

    def convert_duration
      unless duration.blank?
        self.starts_at = Time.zone.now if self.starts_at.blank?
        self.ends_at = self.starts_at + ::ChronicDuration.parse(self.duration.to_s).seconds
      end
    end
  end
end
