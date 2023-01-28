# frozen_string_literal: true

class AddMandatoryToQuestionsTable < ActiveRecord::Migration[7.0]
  def change
    # Survey Questions table
    add_column :survey_questions, :mandatory, :boolean, default: false
  end
end
