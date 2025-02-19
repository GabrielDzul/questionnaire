# frozen_string_literal: true

class Survey::Answer < ActiveRecord::Base
  self.table_name = 'survey_answers'

  belongs_to :attempt
  belongs_to :option
  belongs_to :predefined_value, optional: true
  belongs_to :question

  validates :option_id,
            :question_id,
            presence: true

  validates :predefined_value_id,
            presence: true,
            if: proc { |a| a.question && a.question.mandatory? && a.question.predefined_values.count > 0 && ![Survey::OptionsType.text, Survey::OptionsType.large_text].include?(a.option.options_type_id) }

  validates :option_text,
            presence: true,
            if: proc { |a| a.option && (a.question && a.question.mandatory? && a.question.predefined_values.count == 0 && [Survey::OptionsType.text, Survey::OptionsType.multi_choices_with_text, Survey::OptionsType.single_choice_with_text, Survey::OptionsType.large_text].include?(a.option.options_type_id)) }

  validates :option_number,
            presence: true,
            if: proc { |a| a.option && (a.question && a.question.mandatory? && [Survey::OptionsType.number, Survey::OptionsType.multi_choices_with_number, Survey::OptionsType.single_choice_with_number].include?(a.option.options_type_id)) }

  before_create :characterize_answer
  before_save :check_single_choice_with_field_case

  def value
    if option.nil?
      Survey::Option.find(option_id).weight
    else
      option.weight
    end
  end

  def correct?
    correct || option.correct?
  end

  #######

  private

  #######

  def characterize_answer
    self.correct = true if option.correct?
  end

  def check_single_choice_with_field_case
    if [Survey::OptionsType.multi_choices, Survey::OptionsType.single_choice].include?(option.options_type_id)
      self.option_text = nil
      self.option_number = nil
    end
  end
end
