# frozen_string_literal: true

class Survey::PredefinedValue < ActiveRecord::Base
  self.table_name = 'survey_predefined_values'

  # relations
  belongs_to :question, optional: true

  # validations
  validates :name, presence: true

  def to_s
    name
  end

  def name
    I18n.locale == I18n.default_locale ? super : locale_name || super
  end
end
