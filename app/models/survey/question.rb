# frozen_string_literal: true

class Survey::Question < ActiveRecord::Base
  self.table_name = 'survey_questions'

  # relations
  has_many   :options
  has_many   :predefined_values
  has_many   :answers
  belongs_to :section

  accepts_nested_attributes_for :options,
                                reject_if: ->(a) { a[:options_type_id].blank? },
                                allow_destroy: true

  accepts_nested_attributes_for :predefined_values,
                                reject_if: ->(a) { a[:name].blank? },
                                allow_destroy: true

  # validations
  validates :text,
            presence: true,
            allow_blank: false

  validates :questions_type_id,
            presence: true

  validates :questions_type_id,
            inclusion: { in: Survey::QuestionsType.questions_type_ids, unless: proc { |q| q.questions_type_id.blank? } }

  scope :mandatory_only, -> { where(mandatory: true) }

  def correct_options
    options.correct
  end

  def incorrect_options
    options.incorrect
  end

  def text
    I18n.locale == I18n.default_locale ? super : locale_text.blank? ? super : locale_text
  end

  def description
    I18n.locale == I18n.default_locale ? super : locale_description.blank? ? super : locale_description
  end

  def head_number
    I18n.locale == I18n.default_locale ? super : locale_head_number.blank? ? super : locale_head_number
  end

  def mandatory?
    mandatory == true
  end
end
