module Blamer
  module Userstamp
    extend ActiveSupport::Concern

    included do
      class_attribute :record_userstamps, instance_writer: false
      class_attribute :created_userstamp_column, instance_writer: false
      class_attribute :updated_userstamp_column, instance_writer: false
      class_attribute :created_userstamp_name_column, instance_writer: false
      class_attribute :updated_userstamp_name_column, instance_writer: false

      self.record_userstamps = true
      self.created_userstamp_column = :created_by
      self.updated_userstamp_column = :updated_by
      self.created_userstamp_name_column = :created_by_name
      self.updated_userstamp_name_column = :updated_by_name
    end

    private

    # this is the current_user (see application_controller)
    def userstamp_object
      User.current
    end

    def default_userstamp_object
      nil
    end

    def default_userstamp_name
      nil
    end

    def userstamp_object_or_default
      userstamp_object.try(:id) || default_userstamp_object.try(:id)
    end

    def userstamp_name_object_or_default
      userstamp_object.try(:name) || default_userstamp_name
    end

    def _create_record(*args)
      if record_userstamps
        self[created_userstamp_column] = userstamp_object_or_default if respond_to?(created_userstamp_column) && self[created_userstamp_column].blank?
        self[updated_userstamp_column] = userstamp_object_or_default if respond_to?(updated_userstamp_column) && self[updated_userstamp_column].blank?
        self[created_userstamp_name_column] = userstamp_name_object_or_default if respond_to?(created_userstamp_name_column) && self[created_userstamp_name_column].blank?
        self[updated_userstamp_name_column] = userstamp_name_object_or_default if respond_to?(updated_userstamp_name_column) && self[updated_userstamp_name_column].blank?
      end

      super
    end

    def _update_record(*args)
      if record_userstamps && changed?
        self[updated_userstamp_column] = userstamp_object_or_default if respond_to?(updated_userstamp_column) && self[updated_userstamp_column].blank?
        self[updated_userstamp_name_column] = userstamp_name_object_or_default if respond_to?(updated_userstamp_name_column) && self[updated_userstamp_name_column].blank?
      end

      super
    end
  end

  module UserstampMigrationHelper
    def userstamps
      column ActiveRecord::Base.created_userstamp_column, :integer
      column ActiveRecord::Base.created_userstamp_name_column, :string
      column ActiveRecord::Base.updated_userstamp_column, :integer
      column ActiveRecord::Base.updated_userstamp_name_column, :string
    end
  end
end