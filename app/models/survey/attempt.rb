# frozen_string_literal: true

class Survey::Attempt < ActiveRecord::Base
  self.table_name = 'survey_attempts'

  # relations
  has_many :answers, dependent: :destroy
  belongs_to :survey
  belongs_to :participant, polymorphic: true

  # validations
  validates :participant_id,
            :participant_type,
            presence: true

  accepts_nested_attributes_for :answers,
                                reject_if: ->(q) { q[:question_id].blank? && q[:option_id].blank? },
                                allow_destroy: true

  # scopes

  scope :for_survey, ->(survey) {
    where(survey_id: survey.try(:id))
  }

  scope :exclude_survey, ->(survey) {
    where("NOT survey_id = #{survey.try(:id)}")
  }

  scope :for_participant, ->(participant) {
    where(participant_id: participant.try(:id),
          participant_type: participant.class.to_s)
  }

  scope :wins, -> { where(winner: true) }
  scope :looses, -> { where(winner: false) }
  scope :scores, -> { order('score DESC') }

  # callbacks

  validate :check_number_of_attempts_by_survey, on: :create
  after_create :collect_scores

  def correct_answers
    answers.where(correct: true)
  end

  def incorrect_answers
    answers.where(correct: false)
  end

  def collect_scores!
    collect_scores
    save
  end

  def self.high_score
    scores.first.score
  end

  private

  def check_number_of_attempts_by_survey
    attempts = self.class.for_survey(survey).for_participant(participant)
    upper_bound = survey.attempts_number
    errors.add(:questionnaire_id, 'Number of attempts exceeded') if attempts.size >= upper_bound && upper_bound.nonzero?
  end

  def collect_scores
    multi_select_questions = Survey::Question.joins(:section)
                                             .where(survey_sections: { survey_id: survey.id },
                                                    survey_questions: {
                                                      questions_type_id: Survey::QuestionsType.multi_select
                                                    })
    if multi_select_questions.empty? # No multi-select questions
      raw_score = answers.map(&:value).reduce(:+)
      self.score = raw_score
    else
      # Initial score without multi-select questions
      raw_score = answers.where.not(question_id: multi_select_questions.ids).map(&:value).reduce(:+) || 0
      multi_select_questions.each do |question|
        options = question.options
        correct_question_answers = answers.where(question_id: question.id, correct: true)
        break if correct_question_answers.empty? # If they didn't select any correct answers, then skip this step
        correct_options_sum = options.correct.map(&:weight).reduce(:+)
        correct_percentage = correct_question_answers.map(&:value).reduce(:+).fdiv(correct_options_sum)
        raw_score += correct_percentage
        if correct_percentage == 1
          option_value = 1 / options.count.to_f
          raw_score -= (option_value * answers.where(question_id: question.id, correct: false).count)
        end
      end
      self.score = raw_score || 0
      save
    end
  end
end
