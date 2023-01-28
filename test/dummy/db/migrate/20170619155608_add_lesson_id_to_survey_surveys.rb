# frozen_string_literal: true

class AddLessonIdToSurveySurveys < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_surveys, :lesson_id, :integer
  end
end
